//
//  ZZHTTPTaskChromium.m
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/14.
//

#import "ZZHTTPTaskChromium.h"
#import "ZZNetworkingDefineHeader.h"
#import "ZZNetworkingMacroHeader.h"

#include "net/url_request/url_fetcher.h"
#include "net/url_request/url_fetcher_delegate.h"
#include "net/http/http_response_headers.h"
#include "components/cronet/ios/cronet_environment.h"
#include "base/timer/timer.h"
#include "base/strings/sys_string_conversions.h"
#include "net/base/load_flags.h"

/* 网络回调协议 */
@protocol ZZURLFetcherProtocol <NSObject>

- (void)OnURLFetchComplete:(const net::URLFetcher *)fetcher;

- (void)OnURLFetchDownloadProgress:(const net::URLFetcher *)fetcher
                           current:(int64_t)current
                            totoal:(int64_t)total
             current_network_bytes:(int64_t)current_network_bytes;

- (void)OnURLFetchUploadProgress:(const net::URLFetcher *)fetcher current:(int64_t)current total:(int64_t)total;

- (void)OnTimeout;

@end //ZZURLFetcherProtocol

class ZZURLFetcherDelegate;

@interface ZZHTTPTaskChromium () <ZZURLFetcherProtocol> {
    scoped_refptr<ZZURLFetcherDelegate> fetcher_delegate;
}

@property (nonatomic, assign) cronet::CronetEnvironment *engine;    /* 包含所有网络栈配置和初始化信息的对象 */
@property (nonatomic, strong) ZZHTTPRequestChromium *request;

@property (nonatomic, assign) UInt64 taskID;
@property (nonatomic, assign) BOOL enableHTTPCache;

@property (nonatomic, copy)   ZZHTTPTaskChromiumCompletionBlock completionBlock;
@property (nonatomic, copy)   ZZHTTPResponseChromiumProgressBlock uploadProgressBlock;
@property (nonatomic, copy)   ZZHTTPResponseChromiumProgressBlock downloadProgressBlock;

@property (nonatomic, assign) float priority;
@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, assign) BOOL isCompleted;

@property (nonatomic, strong) NSMutableIndexSet *acceptableStatusCodes;

- (void)p_setFetcherPriority:(net::URLFetcher *)fetcher;

@end //ZZHTTPTaskChromium()


/**
 * 'ZZURLFetcherDelegate'类继承'URLFetcherDelegate'来实现URLFetcher回调代理接口
 *
 * 'ZZURLFetcherDelegate'类继承'RefCountedThreadSafe'来使用chromium智能指针scoped_refptr:
 *  1) 抽象出引用计数的基类, 避免模板膨胀的问题
 *  2) 线程安全的引用计数, 为避免线程问题, 基于线程安全的引用计数提供了一种Traits模式, 允许用户在引用计数为0时定制其行为,
 *     更好的实现用户的使用意图。比如，在引用计数达到0时，用户可能希望通知其它线程完成对象的清理，以保证对象的安全。
 *     这种策略在chromium的代码有较多的应用。
 *
 * 注意:
 *  1) 使用时需要将析构函数设为私有函数, 防止外部直接delete, 使得对象的生命周期难以管理和控制.
 *  2) 将引用计数类声明为友元类, 以便于引用计数类可以访问析构函数.
 */
class ZZURLFetcherDelegate : public net::URLFetcherDelegate, public base::RefCountedThreadSafe<ZZURLFetcherDelegate> {
public:
    ZZURLFetcherDelegate(__weak ZZHTTPTaskChromium *task, cronet::CronetEnvironment *engine):_task(task),_engine(engine) {}
    
    /* 网络请求完成时的回调 */
    void OnURLFetchComplete(const net::URLFetcher *source) override
    {
        _timeout_timer.Stop();                                               /* 取消定时器 */
        
        if (_isCancelled || ! _fetcher) {
            return;
        }
        
        [_task OnURLFetchComplete:source];                                    /* 派发给任务对象执行回调 */
    }
    
    /* 下载进度回调 */
    void OnURLFetchDownloadProgress(const net::URLFetcher *source,
                                    int64_t current,
                                    int64_t total,
                                    int64_t current_network_bytes) override
    {
        if (_isCancelled) {
            return;
        }
        
        [_task OnURLFetchDownloadProgress:source                                /* 派发给任务对象执行回调 */
                                  current:current
                                   totoal:total
                    current_network_bytes:current_network_bytes];
    }
    
    /* 上传进度回调 */
    void OnURLFetchUploadProgress(const net::URLFetcher *source,
                                  int64_t current,
                                  int64_t total) override
    {
        if (_isCancelled) {
            return;
        }
        
        [_task OnURLFetchUploadProgress:source current:current total:total];    /* 派发给任务对象执行回调 */
    }
    
public:
    /* 在网络线程上创建网络请求 */
    void createURLFetcherOnNetThread()
    {
        _engine->GetURLRequestContextGetter()->GetNetworkTaskRunner()->PostTask(FROM_HERE, base::Bind(&ZZURLFetcherDelegate::p_createURLFetcherOnNetThread, this));
    }
    
    /* 取消网络线程上的网络请求 */
    void cancel()
    {
        _engine->GetURLRequestContextGetter()->GetNetworkTaskRunner()->PostTask(FROM_HERE, base::Bind(&ZZURLFetcherDelegate::p_cancelOnNetThread, this));
    }
    
private:
    /* 参考以上注意点 */
    friend class base::RefCountedThreadSafe<ZZURLFetcherDelegate>;
    ~ZZURLFetcherDelegate() override {
    }
    
    /* 创建并开始网络请求 */
    void p_createURLFetcherOnNetThread()
    {
        if (! _task) {
            LOGW(@"The task is nil, do nothing...");
            return;
        }
        
        if (_isCancelled) {
            LOGW(@"The task is cancelled, do nothing...");
            return;
        }
        
        __strong ZZHTTPRequestChromium *request = _task.request;
        if (! request) {
            LOGE(@"ZZHTTPRequestChromium is nil.");
            return;
        }
        
        const std::string &native_url = base::SysNSStringToUTF8(request.urlString);
        GURL url(native_url);
        if (! url.is_valid()) {
            LOGE(@"Threading issue: url is invalid.");
            return;
        }
        
        /* http method */
        net::URLFetcher::RequestType requestType = net::URLFetcher::GET;
        if ([[request.HTTPMethod uppercaseString] isEqualToString:@"POST"]) {
            requestType = net::URLFetcher::POST;
        } else if ([[request.HTTPMethod uppercaseString] isEqualToString:@"PUT"]) {
            requestType = net::URLFetcher::PUT;
        } else if ([[request.HTTPMethod uppercaseString] isEqualToString:@"DELETE"]) {
            requestType = net::URLFetcher::DELETE_REQUEST;
        } else if ([[request.HTTPMethod uppercaseString] isEqualToString:@"HEAD"]) {
            requestType = net::URLFetcher::HEAD;
        } else if ([[request.HTTPMethod uppercaseString] isEqualToString:@"PATCH"]) {
            requestType = net::URLFetcher::PATCH;
        }
        
        /* 生成URLFetcher */
        _fetcher = std::move(net::URLFetcher::Create(url, requestType, this));
        _fetcher->SetRequestContext(_engine->GetURLRequestContextGetter());
        
        /* 设置头部 */
        NSDictionary <NSString *, NSString *> *headers = [request allHTTPHeaderFields];
        for (NSString *field in headers) {
            NSString *header = [NSString stringWithFormat:@"%@: %@", field, [headers objectForKey:field]];
            
            _fetcher->AddExtraRequestHeader(base::SysNSStringToUTF8(header));
        }
        
        /* 处理POST请求 */
        if (net::URLFetcher::POST == requestType) {
            NSData *body = request.HTTPBody;
            NSString *contentType = [headers objectForKey:@"Content-Type"];
            if (request.multipartForm) {
                body = [request.multipartForm finalFormDataWithRequest:request];
                contentType = [request.multipartForm getContentType];
            }
            
            std::string bodyString((char *)body.bytes, body.length);
            _fetcher->SetUploadData(base::SysNSStringToUTF8(contentType), bodyString);
        }
        
        /* 处理缓存 */
        if (! _task.enableHTTPCache) {
            _fetcher->SetLoadFlags(net::LOAD_DISABLE_CACHE);
        }
        
        /* 重试逻辑 */
        _fetcher->SetAutomaticallyRetryOn5xx(false);        /* 网络响应状态码为"5xx"时是否重试 */
        _fetcher->SetAutomaticallyRetryOnNetworkChanges(0); /* 网络状态改变时是否重试 */
        
        /* 设置网络任务的优先级 */
        [_task p_setFetcherPriority:_fetcher.get()];
        
        /* 开启网络请求任务 */
        _fetcher->Start();
        
        /* 开启网络超时定时器 */
        _timeout_timer.Start(FROM_HERE, base::TimeDelta::FromSeconds(request.timeoutInterval), base::Bind(&ZZURLFetcherDelegate::p_onTimeout, this));
    }
    
    /* 网络请求超时处理 */
    void p_onTimeout()
    {
        if (_fetcher) {
            _fetcher.reset();
        }
        
        [_task OnTimeout];
    }
    
    /* 取消网络任务 */
    void p_cancelOnNetThread()
    {
        if (_fetcher) {
            _fetcher.reset();
        }
        
        _isCancelled = true;
        
        _timeout_timer.Stop();
    }
    
private:
    /* 该代理回调对象是独一无二的, 对其生成副本没有任务意义, 因此限制编译器自动生成拷贝构造函数和赋值构造函数 */
    DISALLOW_COPY_AND_ASSIGN(ZZURLFetcherDelegate);

    __weak ZZHTTPTaskChromium *_task;                               /* 网络请求任务, 代理对象弱引用任务对象 */
    std::unique_ptr<net::URLFetcher> _fetcher;                      /* URLFetcher智能指针 */
    cronet::CronetEnvironment *_engine;                             /* 网络栈配置和初始化信息 */
    BOOL _isCancelled {false};                                      /* 用于标记任务是否取消 */
    
    base::OneShotTimer _timeout_timer;                              /* 超时定时器 */
}; //ZZURLFetcherDelegate


@implementation ZZHTTPTaskChromium

#pragma mark -- initializer

- (instancetype)initWithRequest:(ZZHTTPRequestChromium *)request
                         engine:(cronet::CronetEnvironment *)env
                         taskID:(UInt64)taskID
                enableHTTPCache:(BOOL)enableHTTPCache
                completionBlock:(ZZHTTPTaskChromiumCompletionBlock)completionBlock
         uploadProgressCallback:(ZZHTTPResponseChromiumProgressBlock)uploadProgressBlock
       downloadProgressCallback:(ZZHTTPResponseChromiumProgressBlock)downloadProgressBlock
{
    if (self = [super init]) {
        LOGD(@"ZZHTTPTaskChromium initializer: %s, self:%p", __FUNCTION__, self);
        
        self.engine  = env;
        self.request = request;
        self.taskID  = taskID;
        self.completionBlock = completionBlock;
        self.uploadProgressBlock = uploadProgressBlock;
        self.downloadProgressBlock = downloadProgressBlock;
        
        self.enableHTTPCache = enableHTTPCache;
        self.acceptableStatusCodes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    }
    
    return self;
}

- (instancetype)initWithRequest:(ZZHTTPRequestChromium *)request
                         engine:(cronet::CronetEnvironment *)env
                         taskID:(UInt64)taskID
                completionBlock:(ZZHTTPTaskChromiumCompletionBlock)completionBlock
         uploadProgressCallback:(ZZHTTPResponseChromiumProgressBlock)uploadProgressBlock
       downloadProgressCallback:(ZZHTTPResponseChromiumProgressBlock)downloadProgressBlock
{
    if (self = [super init]) {
        LOGD(@"ZZHTTPTaskChromium initializer: %s, self:%p", __FUNCTION__, self);
        
        self.engine  = env;
        self.request = request;
        self.taskID  = taskID;
        self.completionBlock = completionBlock;
        self.uploadProgressBlock = uploadProgressBlock;
        self.downloadProgressBlock = downloadProgressBlock;
        
        self.enableHTTPCache = YES;
        self.acceptableStatusCodes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    }
    
    return self;
}

- (instancetype)initWithRequest:(ZZHTTPRequestChromium *)request
                         engine:(cronet::CronetEnvironment *)env
                         taskID:(UInt64)taskID
                completionBlock:(ZZHTTPTaskChromiumCompletionBlock)completionBlock
{
    if (self = [super init]) {
        LOGD(@"ZZHTTPTaskChromium initializer: %s, self: %p", __FUNCTION__, self);
        
        self.engine  = env;
        self.request = request;
        self.taskID  = taskID;
        self.completionBlock = completionBlock;
        self.uploadProgressBlock = nil;
        self.downloadProgressBlock = nil;
        
        self.enableHTTPCache = YES;
        self.acceptableStatusCodes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    }
    
    return self;
}

- (void)dealloc
{
    LOGD(@"<%@: %p> dealloc", NSStringFromClass([self class]), self);
}

#pragma mark -- public methods

- (void)resume
{
    if (self.isCompleted) {
        LOGW(@"ZZHTTPTaskChromium: property 'isCompleted' of task %p is YES, reset it !!!", self);
        self.isCompleted = NO;
    }
    
    if (self.isCancelled) {
        LOGW(@"ZZHTTPTaskChromium: property 'isCancelled' of task %p is YES, reset it !!!", self);
        self.isCancelled = NO;
    }
    
    const std::string &native_url = base::SysNSStringToUTF8(self.request.urlString);
    GURL url(native_url);
    if (! url.is_valid()) {
        LOGE(@"ZZHTTPTaskChromium: the url string: %@ is malformed", self.request.urlString);
        
        if (self.completionBlock) {
            NSDictionary *userInfo = @{@"error_code" : @(NSURLErrorBadURL),
                                       NSLocalizedDescriptionKey : @"the url is malformed.",
                                       NSURLErrorFailingURLStringErrorKey : ((self.request.urlString) ?: @"nil")
                                       };
            
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:userInfo];
            self.completionBlock(nil, nil, error);
            self.completionBlock = nil;
        }
        
        NSAssert(NO, @"ZZHTTPTaskChromium: the url string: %@ is malformed", self.request.urlString);
        return;
    }
    
    /* 创建URLFetcherDelegate代理, 并通过其发起网络请求 */
    fetcher_delegate = new ZZURLFetcherDelegate(self, self.engine);
    fetcher_delegate->createURLFetcherOnNetThread();
}

- (void)suspend
{
    LOGW(@"ZZHTTPTaskChromium: %s is not supported in chromium net implementation", __FUNCTION__);
}

- (void)cancel
{
    LOGD(@"ZZHTTPTaskChromium: %p cancel", self);
    
    if (fetcher_delegate) {
        fetcher_delegate->cancel();
    }
    fetcher_delegate = nullptr;
    
    self.isCancelled = YES;
    
    ZZHTTPTaskChromiumCompletionBlock completionBlock = nil;
    if (self.completionBlock) {
        completionBlock = self.completionBlock;
        self.completionBlock = nil;
    }
    
    if (completionBlock) {
        NSString *desc = [NSString stringWithFormat:@"the request: %@ was cancelled.", self.request.urlString];
        NSDictionary *userInfo = @{@"error_code"             : @(NSURLErrorCancelled),
                                   NSLocalizedDescriptionKey : desc
                                   };
        
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:userInfo];
        completionBlock(nil, nil, error);
    }
}

- (ZZHTTPTaskState)state
{
    ZZHTTPTaskState state = ZZHTTPTaskStateRunning;
    if (self.isCancelled) {
        state = ZZHTTPTaskStateCanceling;
    } else if (self.isCompleted) {
        state = ZZHTTPTaskStateCompleted;
    }
    
    return state;
}

- (void)setPriority:(float)priority
{
    self.priority = priority;
}

#pragma mark -- ZZURLFetcherProtocol

/* 在 Chrome Network IO Thread 上执行 */
- (void)OnURLFetchComplete:(const net::URLFetcher *)fetcher
{
    /* 如果任务已经被取消, 则不执行回调 */
    if (self.isCancelled) {
        LOGW(@"ZZHTTPTaskChromium: %p is cancelled, do not callback.", self);
        return;
    }
    
    ZZHTTPResponseChromium *response = [[ZZHTTPResponseChromium alloc] initWithURLFetcher:fetcher];
    
    /* 修改完成标记 */
    self.isCompleted = YES;
    LOGD(@"ZZHTTPTaskChromium: %p done http request: %@", self, self.request.urlString);
    
    /* 判断响应状态 */
    NSError *responseError = nil;
    const auto &status = fetcher->GetStatus();
    if (net::URLRequestStatus::FAILED == status.status()) {                             /* 请求失败 */
        const auto error_code = status.error();
        const auto &error_string = net::ErrorToShortString(error_code);
        
        NSDictionary *userInfo = @{@"error_code"                : @(error_code),
                                   NSLocalizedDescriptionKey    : @(error_string.c_str()),
                                   NSURLErrorFailingURLErrorKey : [response URL]
                                   };
        responseError = [NSError errorWithDomain:ZZ_NETWORKING_ERROR_DOMAIN code:error_code userInfo:userInfo];
    } else if (net::URLRequestStatus::CANCELED == status.status()                       /* 任务取消 */
               || net::URLRequestStatus::IO_PENDING == status.status()) {               /* IO等待状态 */
        NSAssert(status.status() != net::URLRequestStatus::IO_PENDING, @"should not be IO_PENDING state !");
        
        NSInteger error_code = NSURLErrorCancelled;
        NSDictionary *userInfo = @{@"error_code"                : @(error_code),
                                   NSLocalizedDescriptionKey    : @"the request was cancelled.",
                                   NSURLErrorFailingURLErrorKey : [response URL]
                                   };
        responseError = [NSError errorWithDomain:ZZ_NETWORKING_ERROR_DOMAIN code:error_code userInfo:userInfo];
    }
    
    std::string responseString;
    if (net::URLRequestStatus::SUCCESS == status.status()) {                            /* 请求成功 */
        if (! fetcher->GetResponseAsString(&responseString)) {
            LOGW(@"ZZHTTPTaskChromium: %p get response as string failed !", self);
        }
    }
    
    const char *responseChars = responseString.c_str();
    NSData *responseData = [NSData dataWithBytes:responseChars length:responseString.length()];
    
    /* 不在可接受的状态码中 */
    NSInteger statusCode = response.statusCode;
    if (self.acceptableStatusCodes && (! [self.acceptableStatusCodes containsIndex:(NSUInteger)statusCode])
        && [response URL]) {
        LOGE(@"ZZHTTPTaskChromium: %p server response code is wrong, response code: %ld url: %@", self, statusCode, [response URL]);
        
        NSString *desc = [NSString stringWithFormat:@"server response code (%ld) is no 2xx.", statusCode];
        NSMutableDictionary *info = @{NSLocalizedDescriptionKey    : desc,
                                      NSURLErrorFailingURLErrorKey : [response URL]
                                      };
        if (responseData) {
            info[@"responseData"] = responseData;
        }
        responseError = [NSError errorWithDomain:ZZ_NETWORKING_ERROR_DOMAIN
                                            code:NSURLErrorBadServerResponse
                                        userInfo:info];
    }
    
    /* 在全局队列中进行回调, 不在 Chrome Network IO Thread 上回调 */
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        
        ZZHTTPTaskChromiumCompletionBlock completionBlock = nil;
        if (self && self.completionBlock) {
            completionBlock = self.completionBlock;
            self.completionBlock = nil;
        }
        
        if (completionBlock) {
            completionBlock(response, responseData, responseError);
        }
    });
}

/* 在 Chrome Network IO Thread 上执行 */
- (void)OnURLFetchDownloadProgress:(const net::URLFetcher *)fetcher
                           current:(int64_t)current
                            totoal:(int64_t)total
             current_network_bytes:(int64_t)current_network_bytes
{
    if (! self.downloadProgressBlock) {
        return;
    }
    
    /* 主线程上回调 */
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self && self.downloadProgressBlock) {
            self.downloadProgressBlock(current, total);
        }
    });
}

/* 在 Chrome Network IO Thread 上执行 */
- (void)OnURLFetchUploadProgress:(const net::URLFetcher *)fetcher
                         current:(int64_t)current
                           total:(int64_t)total
{
    if (! self.uploadProgressBlock) {
        return;
    }
    
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        if (self && self.uploadProgressBlock) {
            self.uploadProgressBlock(current, total);
        }
    });
}

- (void)OnTimeout
{
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @strongify(self);
        
        ZZHTTPTaskChromiumCompletionBlock completionBlock = nil;
        if (self && self.completionBlock) {
            completionBlock = self.completionBlock;
            self.completionBlock = nil;
        }
        
        if (completionBlock) {
            NSDictionary *info = @{@"error_code"             : @(NSURLErrorTimedOut),
                                   NSLocalizedDescriptionKey : @"the request was timeout"
                                   };
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:info];
            completionBlock(nil, nil, error);
        }
    });
}

#pragma mark -- private methods

- (void)p_setFetcherPriority:(net::URLFetcher *)fetcher
{
    if (self.priority > 0) {
        LOGD(@"ZZHTTPTaskChromium: %p set task priority: %f", self, self.priority);
        
        net::RequestPriority priority = net::DEFAULT_PRIORITY;
        if (self.priority <= 0.15) {
            priority = net::LOWEST;
        } else if (self.priority <= 0.25) {
            priority = net::DEFAULT_PRIORITY;
        } else if (self.priority <= 0.5) {
            priority = net::LOW;
        } else if (self.priority <= 0.75) {
            priority = net::MEDIUM;
        } else {
            priority = net::HIGHEST;
        }
        
        fetcher->SetPriority(priority);
    }
}

@end //ZZHTTPTaskChromium

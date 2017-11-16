//
//  ZZHTTPResponseChromium.m
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/14.
//

#import "ZZHTTPResponseChromium.h"
#import "ZZNetworkingDefineHeader.h"
#import "NSObject+ZZNetworking.h"

#include "net/url_request/url_fetcher.h"
#include "net/http/http_response_headers.h"
#include "base/strings/sys_string_conversions.h"
#include "base/time/time.h"

@interface ZZHTTPResponseChromium ()

@property (nonatomic, assign) const net::URLFetcher *fetcher;
@property (nullable,  strong) ZZCaseInsenstiveDictionary *allHeaders;
@property (nonatomic, assign) NSInteger httpStatusCode;
@property (nonatomic, copy)   NSURL *httpURL;

@property (nonatomic, readwrite, strong) ZZHTTPResponseChromiumLoadTimingInfo *timingInfo;

@end //ZZHTTPResponseChromium ()


@implementation ZZHTTPResponseChromium

- (instancetype)initWithURLFetcher:(const net::URLFetcher *)fetcher
{
    if (self = [super init]) {
        self.fetcher = fetcher;
        
        ZZCaseInsenstiveDictionary *headers = [[ZZCaseInsenstiveDictionary alloc] init];
        
        const auto &response_headers = self.fetcher->GetResponseHeaders();
        if (response_headers) {
            size_t iter = 0;
            std::string name;
            std::string value;
            while (response_headers->EnumerateHeaderLines(&iter, &name, &value)) {
                [headers setValue:base::SysUTF8ToNSString(value) forKey:base::SysUTF8ToNSString(name)];
            }
        }
        self.allHeaders = headers;
        
        self.httpStatusCode = self.fetcher->GetResponseCode();
        
        const GURL &url = self.fetcher->GetOriginalURL();
        const auto &url_string = url.spec();
        self.httpURL = [NSURL URLWithString:base::SysUTF8ToNSString(url_string)];
        
        self.timingInfo = [[ZZHTTPResponseChromiumLoadTimingInfo alloc] initWithURLFetcher:fetcher];
    }
    
    return self;
}

- (void)dealloc
{
    LOGD(@"<%@: %p> dealloc", NSStringFromClass([self class]), self);
}

- (NSInteger)statusCode
{
    return self.httpStatusCode;
}

- (ZZCaseInsenstiveDictionary *)allHeaderFields
{
    return self.allHeaders;
}

- (NSURL *)URL
{
    return self.httpURL;
}

- (NSString *)MIMEType
{
    NSString *contentType = self.allHeaders[@"Content-Type"];
    if (contentType) {
        return contentType;
    }
    
    for (NSString *key in [self.allHeaders allKeys]) {
        if ([[key lowercaseString] isEqualToString:[@"Content-Type" lowercaseString]]) {
            return self.allHeaders[key];
        }
    }
    
    return nil;
}


@end //ZZHTTPResponseChromium

@interface ZZHTTPResponseChromiumLoadTimingInfo ()

@property (nonatomic, readwrite, strong) NSDate *start;
@property (nonatomic, readwrite, assign) int64_t proxy;
@property (nonatomic, readwrite, assign) int64_t dns;
@property (nonatomic, readwrite, assign) int64_t connect;
@property (nonatomic, readwrite, assign) int64_t ssl;
@property (nonatomic, readwrite, assign) int64_t send;
@property (nonatomic, readwrite, assign) int64_t wait;
@property (nonatomic, readwrite, assign) int64_t receive;
@property (nonatomic, readwrite, assign) int64_t total;

@property (nonatomic, readwrite, assign) int64_t receivedResponseContentLenght;
@property (nonatomic, readwrite, assign) int64_t totalReceiveBytes;

@property (nonatomic, readwrite, assign) BOOL isSocketReused;
@property (nonatomic, readwrite, assign) BOOL isCached;
@property (nonatomic, readwrite, assign) BOOL isFromProxy;
@property (nonatomic, readwrite, copy)   NSString *remoteIP;
@property (nonatomic, readwrite, assign) uint16_t remotePort;

@end //ZZHTTPResponseChromiumLoadTimingInfo()


@implementation ZZHTTPResponseChromiumLoadTimingInfo

- (instancetype)initWithURLFetcher:(const net::URLFetcher *)fetcher
{
    if (self = [super init]) {
        auto info = fetcher->GetLoadTimingInfo();
        if (info) {
            net::LoadTimingInfo::ConnectTiming connectTiming = info->connect_timing;
            
            self.dns = (connectTiming.dns_end - connectTiming.dns_start).InMilliseconds();
            self.connect = (connectTiming.connect_end - connectTiming.connect_start).InMilliseconds();
            self.ssl = (connectTiming.ssl_end - connectTiming.ssl_start).InMilliseconds();
            self.send = (info->send_end - info->send_start).InMilliseconds();
            
            self.proxy = (info->proxy_resolve_end - info->proxy_resolve_start).InMilliseconds();
            self.wait = (info->receive_headers_end - info->send_end).InMilliseconds();
            self.receive = (base::TimeTicks::Now() - info->receive_headers_end).InMilliseconds();
            self.total = (base::Time::Now() - info->request_start_time).InMilliseconds();
            
            self.isSocketReused = info->socket_reused;
            self.isCached = fetcher->WasCached();
            self.isFromProxy = fetcher->WasFetchedViaProxy();
            
            const auto &pair = fetcher->GetSocketAddress();
            self.remoteIP = @(pair.host().c_str());
            self.remotePort = pair.port();
            
            self.receivedResponseContentLenght = fetcher->GetReceivedResponseContentLength();
            self.totalReceiveBytes = fetcher->GetTotalReceivedBytes();
        }
    }
    
    return self;
}

#pragma mark -- description

- (NSString *)description
{
    NSMutableString *logString = [[NSMutableString alloc] init];
    [logString appendFormat:@"remoteIP: \t\t\t\t\t\t%@\n", [NSObject zz_networking_defaultPlaceHolder:self.remoteIP]];
    [logString appendFormat:@"remotePort: \t\t\t\t\t\t%hu\n", self.remotePort];
    [logString appendFormat:@"isSocketReused: \t\t\t\t\t%@\n", ((self.isSocketReused)? @"YES" : @"NO")];
    [logString appendFormat:@"isFromProxy: \t\t\t\t\t\t%@\n", ((self.isFromProxy)? @"YES" : @"NO")];
    [logString appendFormat:@"isCached: \t\t\t\t\t\t%@\n", ((self.isCached)? @"YES" : @"NO")];
    [logString appendFormat:@"start: \t\t\t\t\t\t\t%@\n", [NSObject zz_networking_defaultPlaceHolder:self.start]];
    [logString appendFormat:@"DNS: \t\t\t\t\t\t\t%lld ms\n", self.dns];
    [logString appendFormat:@"connect: \t\t\t\t\t\t%lld ms\n", self.connect];
    [logString appendFormat:@"SSL: \t\t\t\t\t\t\t%lld ms\n", self.ssl];
    [logString appendFormat:@"send: \t\t\t\t\t\t\t%lld ms\n", self.send];
    [logString appendFormat:@"wait: \t\t\t\t\t\t\t%lld ms\n", self.wait];
    [logString appendFormat:@"receive: \t\t\t\t\t\t%lld ms\n", self.receive];
    [logString appendFormat:@"total: \t\t\t\t\t\t\t%lld ms\n", self.total];
    [logString appendFormat:@"proxy: \t\t\t\t\t\t\t%lld ms\n", self.proxy];
    [logString appendFormat:@"receivedResponseContentLenght: \t%lld bytes\n", self.receivedResponseContentLenght];
    [logString appendFormat:@"totalReceivedBytes:  \t\t\t\t%lld bytes\n", self.totalReceiveBytes];
    
    return logString;
}

@end //ZZHTTPResponseChromiumLoadTimingInfo

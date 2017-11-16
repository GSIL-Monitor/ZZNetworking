//
//  ZZHTTPTaskChromium.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/14.
//

#import "ZZHTTPTask.h"
#import "ZZHTTPRequestChromium.h"
#import "ZZHTTPResponseChromium.h"

namespace net {
    class URLFetcher;
    class URLFetcherDelegate;
}

namespace cronet {
    class CronetEnvironment;
}

/**
 * 网络请求任务完成回调block
 *
 * @param response 网络响应
 * @param data     网络响应数据
 * @param error    网络响应错误
 */
typedef void(^ZZHTTPTaskChromiumCompletionBlock)(ZZHTTPResponseChromium *response, id data, NSError *error);


/**
 * 网络请求任务进度回调block
 *
 * @param current 当前的进度
 * @param total   总任务数
 */
typedef void(^ZZHTTPResponseChromiumProgressBlock)(int64_t current, int64_t total);


@interface ZZHTTPTaskChromium : ZZHTTPTask

/**
 * 生成基于chromium net网络栈的网络请求任务
 *
 * @param request               网络请求
 * @param env                   包含所有网络栈配置和初始化信息的CronetEnvironment实例对象
 * @param taskID                网络请求标识符
 * @param enableHTTPCache       是否开启HTTP缓存
 * @param completionBlock       网络请求任务完成时的回调
 * @param uploadProgressBlock   上传进度回调
 * @param downloadProgressBlock 下载进度回调
 *
 * @return 基于chromium net网络栈的请求任务
 */
- (instancetype)initWithRequest:(ZZHTTPRequestChromium *)request
                         engine:(cronet::CronetEnvironment *)env
                         taskID:(UInt64)taskID
                enableHTTPCache:(BOOL)enableHTTPCache
                completionBlock:(ZZHTTPTaskChromiumCompletionBlock)completionBlock
         uploadProgressCallback:(ZZHTTPResponseChromiumProgressBlock)uploadProgressBlock
       downloadProgressCallback:(ZZHTTPResponseChromiumProgressBlock)downloadProgressBlock;


- (instancetype)initWithRequest:(ZZHTTPRequestChromium *)request
                         engine:(cronet::CronetEnvironment *)env
                         taskID:(UInt64)taskID
                completionBlock:(ZZHTTPTaskChromiumCompletionBlock)completionBlock
         uploadProgressCallback:(ZZHTTPResponseChromiumProgressBlock)uploadProgressBlock
       downloadProgressCallback:(ZZHTTPResponseChromiumProgressBlock)downloadProgressBlock;


- (instancetype)initWithRequest:(ZZHTTPRequestChromium *)request
                         engine:(cronet::CronetEnvironment *)env
                         taskID:(UInt64)taskID
                completionBlock:(ZZHTTPTaskChromiumCompletionBlock)completionBlock;

@end //ZZHTTPTaskChromium

//
//  ZZHTTPTaskChromium.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/14.
//

#import "ZZHTTPTask.h"
#import "ZZHTTPRequest.h"
#import "ZZHTTPResponseChromium.h"

namespace net {
    Class URLFetcher;
    Class URLFetcherDelegate;
}

namespace cronet {
    Class CronetEnvironment;
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

@property (nonatomic, strong) NSProgress *uploadProgress;                   /* 上传进度 */
@property (nonatomic, strong) NSProgress *downloadProgress;                 /* 下载进度 */


- (instancetype)initWithRequest:(ZZHTTPRequest *)request
                         engine:(cronet::CronetEnvironment)env
                         taskID:(UInt64)taskID
                completionBlock:(ZZHTTPTaskChromiumCompletionBlock)completionBlock;

@end //ZZHTTPTaskChromium

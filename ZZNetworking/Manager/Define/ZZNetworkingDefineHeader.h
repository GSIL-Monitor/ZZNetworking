//
//  ZZNetworkingDefineHeader.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import <Foundation/Foundation.h>
#import "ZZMultipartFormData.h"
#import "ZZURLRequestSerializationProtocol.h"
#import "ZZURLResponseSerializationProtocol.h"
#import "ZZNetworkingInterceptorPtorocol.h"
#import "ZZNetworkingValidatorProtocol.h"
#import "ZZHTTPRequestReformerProtocol.h"
#import "ZZHTTPResponse.h"
#import "ZZHTTPTask.h"
#import <pthread.h>
#import <objc/runtime.h>


/**
 * 网络请求的通用参数
 *
 * @return 通用参数
 */
typedef NSDictionary *(^ZZNetworkingCommonParamsBlock)(void);


/**
 * 返回json response的网络请求回调block
 *
 * @param error          错误信息(包括网络请求错误和数据解析错误)
 * @param responseObject 网络响应数据(根据'responseType'返回json字典或二进制数据)
 * @param response       网络请求响应
 */
typedef void(^ZZNetworkingJSONCompletionBlock)(NSError *error, NSDictionary *responseObject, ZZHTTPResponse *response);


static inline void safe_dispatch_async_on_main_queue(void (^block)(void))
{
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

static inline void safe_dispatch_sync_on_main_queue(void (^block)(void))
{
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

//
//  ZZNetworkingInterceptorPtorocol.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import <Foundation/Foundation.h>

@class ZZNetworkingManager;

@protocol ZZNetworkingInterceptorPtorocol <NSObject>

@required

+ (NSObject<ZZNetworkingInterceptorPtorocol> *)interceptor;

@optional

/**
 * 是否可以发起网络请求, 当与实现'ZZNetworkingValidatorProtocol'协议的实例同时存在时, interceptor该方法的优先级更高
 *
 * @param manager      网络管理对象
 * @param urlString    网络请求地址
 * @param params       请求参数
 * @param commonParams 通用参数
 *
 * @return 允许发起网络请求时返回YES, 否则返回NO
 */
- (BOOL)manager:(ZZNetworkingManager *)manager shouldRequestURL:(NSString *)urlString requestParams:(NSDictionary *)params commonParams:(NSDictionary *)commonParams;

/**
 * 发起网络请求后调用该协议方法
 *
 * @param manager      网络管理对象
 * @param urlString    请求的网络地址
 * @param params       请求参数
 * @param commonParams 通用参数
 */
- (void)manager:(ZZNetworkingManager *)manager afterRequestURL:(NSString *)urlString requestParams:(NSDictionary *)params commonParams:(NSDictionary *)commonParams;


- (BOOL)manager:(ZZNetworkingManager *)manager;

@end //ZZNetworkingInterceptorPtorocol

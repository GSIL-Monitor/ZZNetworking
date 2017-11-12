//
//  ZZNetworkingManager.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import <Foundation/Foundation.h>
#import "ZZNetworkingDefineHeader.h"

/* 底层网络栈实现类型 */
typedef NS_ENUM(NSInteger, ZZNetworkImplementationType)
{
    ZZNetworkImplementationTypeAFNetworking = 0,        /* 基于 AFNetworking 进行封装 */
    ZZNetworkImplementationTypeChromium     = 1,        /* 基于 Chromium 网络栈进行封装 */
};


@interface ZZNetworkingManager : NSObject


/**
 *  用于序列化json response的class, 如果是网络返回json response, 则在发起网络请求之前, 必须设置该属性值.
 */
@property (nonatomic, strong) Class<ZZJSONResponseSerializationProtocol> jsonResponseSerializer;


/**
 *  用于序列化binary response的class, 如果是网络返回binary response, 则在发起网络请求之前, 必须设置该属性值.
 */
@property (nonatomic, strong) Class<ZZBinaryResponseSerializationProtocol> binaryResponseSerializer;


/**
 *  默认请求序列化对象类型, 程序内部以基类的形式设置了默认值, 业务层开发时可以不用进行设置. 可配合属性'requestReformers'使用.
 *  即不设置'requestSerializer'属性值, 而使用'requestReformers'属性来对请求进行改造.
 *  如果需要自定义网络请求的序列化对象, 只要实现协议'ZZURLRequestSerializationProtocol'接口, 并不强制一定要继承基类.
 */
@property (nonatomic, strong) Class<ZZURLRequestSerializationProtocol> requestSerializer;


/**
 *  请求处理改造器列表, 在由'requestSerializer'生成请求对象前后, 对请求进行改造, 改变是累加的.
 */
@property (nonatomic, copy) NSArray<Class<ZZHTTPRequestReformerProtocol>> *requestReformers;


/* 通用参数, 静态 */
@property (nonatomic, copy) NSDictionary *commonParams;

/* 通用参数, 动态 => 在需要通用参数的场景, 先取commonParamsBlock, 然后拼接commonParams */
@property (nonatomic, copy) ZZNetworkingCommonParamsBlock commonParamsBlock;


/**
 *  执行网络结果回调的队列, 如果为'NULL', 则在主线程上执行, 默认值为NULL.
 */
@property (nonatomic, strong) dispatch_queue_t completionQueue;


/**
 *  是否输出日志输出, 默认为NO
 */
@property (nonatomic, assign) BOOL enableDebugLog;


/* 设置底层网络库实现, 默认基于'AFNetworking'实现 */
+ (void)setNetworkImplementation:(ZZNetworkImplementationType)implementation;
+ (ZZNetworkImplementationType)networkImplementaion;


/**
 * 通过URL和参数获取json, 调用后，网络请求task会自动resume
 * 会使用'requestSerializer'属性值来序列化请求, 'jsonResponseSerializer'属性值来序列化网络响应数据.
 *
 * @param URLString          请求的URL字符串
 * @param parameters         请求的参数，
 * @param needCommonParams   是否需要通用参数
 * @param completionBlock    回调block
 *
 * @return 网络请求任务实例对象
 */
+ (ZZHTTPTask *)JSON_GET:(NSString *)URLString
              parameters:(id)parameters
        needCommonParams:(BOOL)needCommonParams
              completion:(ZZNetworkingJSONCompletionBlock)completionBlock;


/**
 * 通过URL和参数获取json, 调用后，网络请求task会自动resume，会使用'requestSerializer'属性值来序列化请求.
 *
 * @param URLString          请求的URL字符串
 * @param parameters         请求的参数，
 * @param needCommonParams   是否需要通用参数
 * @param responseSerializer 设置这次网络请求的网络响应数据序列化对象, 如果为nil, 则为默认值
 * @param completionBlock    回调block
 *
 * @return 网络请求任务实例对象
 */
+ (ZZHTTPTask *)JSON_GET:(NSString *)URLString
              parameters:(id)parameters
        needCommonParams:(BOOL)needCommonParams
      responseSerializer:(Class<ZZJSONResponseSerializationProtocol>)responseSerializer
              completion:(ZZNetworkingJSONCompletionBlock)completionBlock;


/**
 * 通过URL和参数获取json, 调用后，网络请求task会自动resume，会使用'requestSerializer'属性值来序列化请求.
 *
 * @param URLString          请求的URL字符串
 * @param parameters         请求的参数
 * @param needCommonParams   是否需要通用参数
 * @param responseSerializer 设置这次网络请求的网络响应数据序列化对象, 如果为nil, 则为默认值
 * @param validator          数据验证类
 * @param interceptor        拦截器(如控制网络请求是否发起, AOP等)
 * @param completionBlock    回调block
 *
 * @return 网络请求任务实例对象
 */
+ (ZZHTTPTask *)JSON_GET:(NSString *)URLString
              parameters:(id)parameters
        needCommonParams:(BOOL)needCommonParams
      responseSerializer:(Class<ZZJSONResponseSerializationProtocol>)responseSerializer
               validator:(Class<ZZNetworkingValidatorProtocol>)validator
             interceptor:(Class<ZZNetworkingInterceptorPtorocol>)interceptor
              completion:(ZZNetworkingJSONCompletionBlock)completionBlock;


/**
 * 通过URL和参数获取json, 通过参数autoResume来决定是否resume
 *
 * @param URLString          请求的URL字符串
 * @param parameters         请求的参数
 * @param needCommonParams   是否需要通用参数
 * @param requestSerializer  设置这次网络请求的请求序列化对象, 如果为nil, 则为默认值
 * @param responseSerializer 设置这次网络请求的网络响应数据序列化对象, 如果为nil, 则为默认值
 * @param validator          数据验证类
 * @param interceptor        拦截器(如控制网络请求是否发起, AOP等)
 * @param autoResume         是否自动开始
 * @param completionBlock    回调block
 *
 * @return 网络请求任务实例对象
 */
+ (ZZHTTPTask *)JSON_GET:(NSString *)URLString
              parameters:(id)parameters
        needCommonParams:(BOOL)needCommonParams
       requestSerializer:(Class<ZZURLRequestSerializationProtocol>)requestSerializer
      responseSerializer:(Class<ZZJSONResponseSerializationProtocol>)responseSerializer
               validator:(Class<ZZNetworkingValidatorProtocol>)validator
             interceptor:(Class<ZZNetworkingInterceptorPtorocol>)interceptor
              autoResume:(BOOL)autoResume
              completion:(ZZNetworkingJSONCompletionBlock)completionBlock;

@end //ZZNetworkingManager

//
//  ZZHTTPRequestReformerProtocol.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import <Foundation/Foundation.h>
#import "ZZHTTPRequest.h"

/**
 *  'ZZHTTPRequestReformerProtocol'协议用来在使用'ZZURLRequestSerializationProtocol'协议生成请求的前后进行切面编程.
 *  这是为了避免在很多逻辑都耦合在request serializer中进行, 比如在生成请求时需要进行链路优选、请求加密等操作, 这些操作应该
 *  都是一个独立的执行单元, 不应该在request serializer中进行, request serializer应该只负责请求的生成操作, 其他对请求进行
 *  二次加工的操作都独立实现, 该协议为用户提供这样的功能.
 */
@protocol ZZHTTPRequestReformerProtocol <NSObject>

@required

/**
 *  生成请求改造器对象
 *
 * @return 改造器实例
 */
+ (NSObject<ZZHTTPRequestReformerProtocol> *)reformer;

@optional

/**
 * 在由request serializer生成request之前, 给外部提供一个机会来对url字符串进行处理, 如进行域名替换等
 *
 * @param urlString 请求的URL地址字符串
 *
 * @return 处理后新的URL地址字符串
 */
- (NSString *)reformBeforeGenerateRequestWithURLString:(NSString *)urlString;


/**
 * 在request serializer生成request后, 给外部提供一个机会来再次对request进行处理，
 * 如进行选路、加密等操作, 这每个操作应该都是一个独立的单元, 不应该都耦合在request serializer中,
 * 通过协议注册组合的方式执行每个单元
 *
 * @param request 经过request serializer处理后生成的请求
 * @param params  请求参数
 *
 * @return 处理后新的请求
 */
- (ZZHTTPRequest *)reformAfterGenerateRequest:(ZZHTTPRequest *)request parameters:(NSDictionary *)params;

@end //ZZHTTPRequestReformerProtocol

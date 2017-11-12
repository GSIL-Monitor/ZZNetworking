//
//  ZZURLRequestSerializationProtocol.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import <Foundation/Foundation.h>
#import "ZZNetworkingDefineHeader.h"
#import "ZZHTTPRequest.h"                                      /* 网络库中封装的网络请求对象 */

/**
 * 如果请求的body内需要带有文件名和文件, 需要通过该block来进行设置
 *
 * @param formData 用于构造包含文件和文件名的body
 */
typedef void(^ZZConstructingBodyBlock)(id<ZZMultipartFormData> formData);


@protocol ZZURLRequestSerializationProtocol <NSObject>

/**
 * 工厂方法, 获取serializer实例化对象
 *
 * @return 序列化serializer实例
 */
+ (NSObject<ZZURLRequestSerializationProtocol> *)serializer;


/**
 *  使用指定HTTP方法和URL字符串来创建'ZZHTTPRequest'对象,
 *  使用指定参数和multipart form data block构造'multipart/form-data'作为HTTP body
 *
 *  @param URL          用来创建请求URL的URL字符串
 *  @param params       请求的参数
 *  @param method       请求的HTTP方法
 *  @param bodyBlock    需要multipart body的请求体
 *  @param commonParams 通用参数
 *
 *  @return 'ZZHTTPRequest'对象
 */
- (ZZHTTPRequest *)requestWithURL:(NSString *)URL
                           params:(id)params
                           method:(NSString *)method
                constructingBlock:(ZZConstructingBodyBlock)bodyBlock
                     commonParams:(NSDictionary *)commonParams;


/**
 *  使用指定HTTP方法和URL字符串来创建'ZZHTTPRequest'对象,
 *  使用指定参数和multipart form data block构造'multipart/form-data'作为HTTP body
 *
 *  @param URL          用来创建请求URL的URL字符串
 *  @param headField    HTTP头部
 *  @param params       请求的参数
 *  @param method       请求的HTTP方法
 *  @param bodyBlock    需要multipart body的请求体
 *  @param commonParams 通用参数
 *
 *  @return 'ZZHTTPRequest'对象
 */
- (ZZHTTPRequest *)requestWithURL:(NSString *)URL
                      headerField:(NSDictionary *)headField
                           params:(id)params
                           method:(NSString *)method
                constructingBlock:(ZZConstructingBodyBlock)bodyBlock
                     commonParams:(NSDictionary *)commonParams;


/**
 *  获取User-Agent
 */
- (NSString *)userAgentString;

@end //ZZURLRequestSerializationProtocol

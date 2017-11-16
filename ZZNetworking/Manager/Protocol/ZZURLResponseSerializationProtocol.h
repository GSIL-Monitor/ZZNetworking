//
//  ZZURLResponseSerializationProtocol.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import <Foundation/Foundation.h>
#import "ZZHTTPResponse.h"

/* 用于解析json response的响应序列化对象 */
@protocol ZZJSONResponseSerializationProtocol <NSObject>

@required

/**
 *  The acceptable MIME types for responses. When non-`nil`, responses with a `Content-Type` with
 *  MIME types that do not intersect with the set will result in an error during validation.
 */
@property (nonatomic, copy) NSSet *acceptableContentTypes;

+ (NSObject<ZZJSONResponseSerializationProtocol> *)serializer;


/**
 * 解析返回值
 *
 * @param response      要被解析的对象
 * @param jsonObj       需要解析的JSON数据(如果能解析成功), 即返回的网络响应
 * @param responseError 网络响应错误
 * @param resultError   传递给业务层的错误
 *
 * @return 解析后的结果
 */
- (id)responseObjectForResponse:(ZZHTTPResponse *)response
                     jsonObject:(id)jsonObj
                  responseError:(NSError *)responseError
                    resultError:(NSError * __autoreleasing *)resultError;

@end //ZZJSONResponseSerializationProtocol



/* 用于解析binary response的响应序列化对象 */
@protocol ZZBinaryResponseSerializationProtocol <NSObject>

+ (NSObject<ZZBinaryResponseSerializationProtocol> *)serializer;

/**
 * 解析返回值
 *
 * @param response      要被解析的对象
 * @param data          返回的网络响应数据
 * @param responseError 网络响应错误
 * @param resultError   传递给业务层的错误
 *
 * @return 解析后的结果
 */
- (id)responseObjectForResponse:(ZZHTTPResponse *)response
                           data:(NSData *)data
                  responseError:(NSError *)responseError
                    resultError:(NSError * __autoreleasing *)resultError;


@end //ZZBinaryResponseSerializationProtocol

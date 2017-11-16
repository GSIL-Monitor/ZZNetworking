//
//  ZZMultipartFormData.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import <Foundation/Foundation.h>

/**
 *  ZZMultipartFormDate协议定义了一系列方法用来支持'ZZHTTPRequestSerializer'类实例方法
 *  '-multipartFormRequestWithMethod:URLString:parameters:constructBodyWithBlock:error:"中block形参中的参数
 */
@protocol ZZMultipartFormData <NSObject>

/**
 *  为HTTP头部添加'Content-Disposition:file; name=#{name}; filename=#{filename}"'和
 *  'Content-Type: #{mimeType}',接下来是编码后的文件数据和多表单内容分隔符
 *
 *  @param data     要被编码并被添加到多表单数据中的数据
 *  @param name     与指定数据相关联的名称，该参数不能为nil
 *  @param fileName 与指定数据相关联的文件名称，该参数不能为nil
 *  @param mimeType 指定数据的MIME类型(例如:JPEG图片的MIME类型为image/jpeg)，
 *                  参考http://www.iana.org/assignments/media-types/. 该参数不能为nil
 */
- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType;


/**
 *  为HTTP头部添加'Content-Disposition:form-data; name=#{name}"',接下来是编码后的数据和多表单内容分隔符
 *
 *  @param data 要被编码并被添加到表单数据中的数据
 *  @param name 与指定数据相关联的名称，该参数不能为nil
 */
- (void)appendPartWithFormData:(NSData *)data name:(NSString *)name;

@end //ZZMultipartFormData

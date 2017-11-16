//
//  ZZHTTPMultipartFormDataChromium.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/14.
//

#import "ZZMultipartFormData.h"

@class ZZHTTPRequestChromium;

/**
 *  'ZZHTTPMultipartFormDataChromium'类用来解析基于chromium net进行POST请求的multipart/form-data数据
 */
@interface ZZHTTPMultipartFormDataChromium : NSObject <ZZMultipartFormData>

/**
 * 类实现了'ZZMultipartFormData'协议, 内部已经组装了多表单数据的每一部分, 通过该方法来将各表单数据全部获取
 *
 * @param request 网络请求
 *
 * @return POST请求的body数据
 */
- (NSData *)finalFormDataWithRequest:(ZZHTTPRequestChromium *)request;


/**
 * 获取POST头部中的'Content-Type"
 *
 * @return "Content-Type"字符串
 */
- (NSString *)getContentType;

@end //ZZHTTPMultipartFormDataChromium

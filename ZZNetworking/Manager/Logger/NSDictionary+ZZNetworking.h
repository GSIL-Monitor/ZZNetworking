//
//  NSDictionary+ZZNetworking.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/16.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ZZNetworking)

/**
 *  ⚠️将字典对象转换为json字符串格式, 发生错误时返回nil
 *
 *  NSJSONWritingPrettyPrinted: 的意思是将生成的json数据格式化输出，这样可读性高，不设置则输出的json字符串就是一整行。
 */
- (NSString *)zz_networking_jsonPrettyStringEncoded;

@end //NSDictionary (ZZNetworking)

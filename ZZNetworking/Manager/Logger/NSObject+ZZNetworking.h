//
//  NSObject+ZZNetworking.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/16.
//

#import <Foundation/Foundation.h>

@interface NSObject (ZZNetworking)

FOUNDATION_EXPORT NSString * const ZZNetworkingDefaultPlaceHolder;


/**
 * 获取输入数据的易读形式, 主要是针对NSDictionary
 *
 * @param inputData 输入数据
 *
 * @return 易读形式数据
 */
+ (id)zz_networking_prettyPresentOfInput:(id)inputData;


/**
 *  获取输入的数据, 如果输入的数据为空, 则返回默认的占位字符串
 *
 *  @param inputData 输入数据
 *
 *  @return 当前实例对象或者占位字符串
 */
+ (NSString *)zz_networking_defaultPlaceHolder:(id)inputData;


/**
 * 获取当前的实例对象, 在某些场景下返回指定的默认值defaultData
 *   1) 当前实例对象为空对象时, 返回默认值
 *
 * @param defaultData 指定的默认值
 *
 * @return 当前实例对象或者默认值
 */
- (id)zz_networking_defaultValue:(id)defaultData;


/**
 * 判断当前实例对象是否为空对象, 该方法内部判断了[NSNull null]、NSString、 NSArray、NSDictionary、NSData.
 *
 * @return 如果为空对象, 则返回YES, 否则返回NO
 */
- (BOOL)zz_networking_idEmptyObject;

@end //NSObject (ZZNetworking)

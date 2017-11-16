//
//  NSObject+ZZNetworking.m
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/16.
//

#import "NSObject+ZZNetworking.h"
#import "NSDictionary+ZZNetworking.h"

NSString * const ZZNetworkingDefaultPlaceHolder = @"\t\t\t\tN/A";

@implementation NSObject (ZZNetworking)

+ (id)zz_networking_prettyPresentOfInput:(id)inputData
{
    if ([inputData isKindOfClass:[NSDictionary class]]) {
        NSString *json = [((NSDictionary *)inputData) zz_networking_jsonPrettyStringEncoded];
        return [self zz_networking_defaultPlaceHolder:json];
    } else {
        return [self zz_networking_defaultPlaceHolder:inputData];
    }
}

+ (NSString *)zz_networking_defaultPlaceHolder:(id)inputData
{
    if (nil == inputData) {
        return ZZNetworkingDefaultPlaceHolder;
    }
    
    return [inputData zz_networking_defaultValue:ZZNetworkingDefaultPlaceHolder];
}

- (id)zz_networking_defaultValue:(id)defaultData
{
    if ([self zz_networking_idEmptyObject]) {
        return defaultData;
    }
    
    return self;
}

- (BOOL)zz_networking_idEmptyObject
{
    if ([self isEqual:[NSNull null]]) {
        return YES;
    }
    
    if ([self isKindOfClass:[NSString class]]) {
        if (0 == [(NSString *)self length]) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSArray class]]) {
        if (0 == [(NSArray *)self count]) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        if (0 == [(NSDictionary *)self count]) {
            return YES;
        }
    }
    
    if ([self isKindOfClass:[NSData class]]) {
        if (0 == [(NSData *)self length]) {
            return YES;
        }
    }
    
    return NO;
}

@end //NSObject (ZZNetworking)

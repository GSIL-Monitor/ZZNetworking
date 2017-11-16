//
//  NSDictionary+ZZNetworking.m
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/16.
//

#import "NSDictionary+ZZNetworking.h"

@implementation NSDictionary (ZZNetworking)

- (NSString *)zz_networking_jsonPrettyStringEncoded
{
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (! error) {
            return jsonString;
        }
    }
    
    return nil;
}

@end //NSDictionary (ZZNetworking)

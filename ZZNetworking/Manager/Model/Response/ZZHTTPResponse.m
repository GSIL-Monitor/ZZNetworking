//
//  ZZHTTPResponse.m
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import "ZZHTTPResponse.h"

@implementation ZZCaseInsenstiveDictionary

- (instancetype)init
{
    if (self = [super init]) {
        inner_dict = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (instancetype)initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt
{
    if (self = [super init]) {
        inner_dict = [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys count:cnt];
    }
    
    return self;
}

- (NSUInteger)count
{
    return [inner_dict count];
}

- (id)objectForKey:(id)aKey
{
    id result = [inner_dict objectForKey:aKey];
    if ((! result) && [aKey isKindOfClass:[NSString class]]) {
        NSString *key = (NSString *)aKey;
        
        for (NSString *innerKey in [inner_dict allKeys]) {
            if (! [innerKey isKindOfClass:[NSString class]]) {
                continue;
            }
            
            if ([[innerKey lowercaseString] isEqualToString:[key lowercaseString]]) {
                result = inner_dict[innerKey];
            }
        }
    }
    
    return result;
}

- (NSEnumerator *)keyEnumerator
{
    return [inner_dict keyEnumerator];
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    [inner_dict setObject:anObject forKey:aKey];
}

- (void)removeObjectForKey:(id)aKey
{
    [inner_dict removeObjectForKey:aKey];
}

@end //ZZCaseInsenstiveDictionary



@implementation ZZHTTPResponse

@end //ZZHTTPResponse

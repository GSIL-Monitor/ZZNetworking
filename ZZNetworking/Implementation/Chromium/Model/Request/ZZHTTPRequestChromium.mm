//
//  ZZHTTPRequestChromium.m
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/14.
//

#import "ZZHTTPRequestChromium.h"
#import "ZZNetworkingDefineHeader.h"

@interface ZZHTTPRequestChromium ()

@property (nonatomic, copy)   NSString *method;
@property (nonatomic, copy)   NSData *body;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *allHTTPHeaders;
@property (nonatomic, assign) NSTimeInterval timeout;

@end //ZZHTTPRequestChromium ()


@implementation ZZHTTPRequestChromium

- (instancetype)initWithURL:(NSString *)url
                     method:(NSString *)method
              multipartForm:(ZZHTTPMultipartFormDataChromium *)form
{
    if (self = [super init]) {
        _urlString     = [url copy];
        _method        = [method copy];
        _multipartForm = form;
        _timeout       = ZZ_NETWORKING_DEFAULT_REQUEST_TIMEOUT;
    }
    
    return self;
}

- (void)dealloc
{
    LOGD(@"<%@ :%p> dealloc", NSStringFromClass([self class]), self);
}

#pragma mark -- getters/setters

- (NSURL *)URL
{
    return [NSURL URLWithString:self.urlString];
}

- (void)setURL:(NSURL *)URL
{
    [super setURL:URL];
    self.urlString = [URL absoluteString];
}

- (NSTimeInterval)timeoutInterval
{
    return self.timeout;
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    self.timeout = timeoutInterval;
}

- (NSData *)HTTPBody
{
    return self.body;
}

- (void)setHTTPBody:(NSData *)HTTPBody
{
    self.body = [HTTPBody copy];
}

- (NSDictionary<NSString *, NSString *> *)allHTTPHeaderFields
{
    return self.allHTTPHeaders;
}

- (void)setAllHTTPHeaderFields:(NSDictionary<NSString *,NSString *> *)allHTTPHeaderFields
{
    self.allHTTPHeaders = [allHTTPHeaderFields copy];
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    if (! self.allHTTPHeaders) {
        self.allHTTPHeaders = [[NSMutableDictionary alloc] init];
    }
    
    [self.allHTTPHeaders setValue:value forKey:field];
}

- (void)addValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    if (! self.allHTTPHeaders) {
        self.allHTTPHeaders = [[NSMutableDictionary alloc] init];
    }
    
    [self.allHTTPHeaders setValue:value forKey:field];
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field
{
    return [self.allHTTPHeaders valueForKey:field];
}

@end //ZZHTTPRequestChromium

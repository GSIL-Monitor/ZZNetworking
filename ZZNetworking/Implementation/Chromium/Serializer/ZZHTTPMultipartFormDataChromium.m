//
//  ZZHTTPMultipartFormDataChromium.m
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/14.
//

#import "ZZHTTPMultipartFormDataChromium.h"
#import "ZZHTTPRequestChromium.h"

/* 多表单内容分隔符 */
static NSString *p_createMultipartFormBoundary()
{
    return [NSString stringWithFormat:@"Boundary+%08X%08X", arc4random(), arc4random()];
}

/* 多表单回车换行符 */
static NSString *const kZZMultipartFormCRLF = @"\r\n";

/* 多表单内容分隔符的开始分隔符形式 */
static inline NSString *p_ZZMultipartFormInitialBoundary(NSString *boundary)
{
    return [NSString stringWithFormat:@"--%@%@", boundary, kZZMultipartFormCRLF];
}

/* 内容开始分隔符和内容结束分隔符中间的分隔形式 */
static inline NSString *p_ZZMultipartFormEncapsulationBoundary(NSString *boundary)
{
    return [NSString stringWithFormat:@"%@--%@%@", kZZMultipartFormCRLF, boundary, kZZMultipartFormCRLF];
}

/* 多表单内容分隔符的结束分隔符形式 */
static inline NSString *p_ZZMultipartFormFinalBoundary(NSString *boundary)
{
    return [NSString stringWithFormat:@"%@--%@--%@", kZZMultipartFormCRLF, boundary, kZZMultipartFormCRLF];
}


/**
 *  'ZZHTTPBodyPart'类表示消息请求体的一个部分
 */
@interface ZZHTTPBodyPart : NSObject

@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, copy)   NSDictionary *headers;
@property (nonatomic, copy)   NSString *boundary;
@property (nonatomic, strong) id body;
@property (nonatomic, assign) unsigned long long bodyContentLength;

@property (nonatomic, assign) BOOL hasInitialBoundary;
@property (nonatomic, assign) BOOL hasFinalBoundary;

- (NSData *)getData;

@end //ZZHTTPBodyPart

@implementation ZZHTTPBodyPart

- (NSString *)stringForHeaders
{
    NSMutableString *headerString = [[NSMutableString alloc] init];
    for (NSString *field in [self.headers allKeys]) {
        [headerString appendString:[NSString stringWithFormat:@"%@: %@%@", field, [self.headers valueForKey:field], kZZMultipartFormCRLF]];
    }
    [headerString appendString:kZZMultipartFormCRLF];
    
    return [NSString stringWithString:headerString];
}

- (NSData *)getData
{
    NSMutableData *fullData = [[NSMutableData alloc] init];
    
    NSData *encapsulationBoundaryData = [((self.hasInitialBoundary)? p_ZZMultipartFormInitialBoundary(self.boundary) : p_ZZMultipartFormEncapsulationBoundary(self.boundary)) dataUsingEncoding:self.stringEncoding];
    
    NSData *headersData = [[self stringForHeaders] dataUsingEncoding:self.stringEncoding];
    
    NSData *closingBoundaryData = ((self.hasFinalBoundary)? [p_ZZMultipartFormFinalBoundary(self.boundary) dataUsingEncoding:self.stringEncoding] : [NSData data]);
    
    [fullData appendData:encapsulationBoundaryData];
    [fullData appendData:headersData];
    [fullData appendData:(NSData *)self.body];
    [fullData appendData:closingBoundaryData];
    
    return fullData;
}

@end //ZZHTTPBodyPart


@interface ZZHTTPMultipartFormDataChromium ()

@property (nonatomic, strong) NSMutableArray *HTTPBodyParts;
@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, copy)   NSString *boundary;

@end //ZZHTTPMultipartFormDataChromium ()


@implementation ZZHTTPMultipartFormDataChromium

- (instancetype)init
{
    if (self = [super init]) {
        self.boundary = p_createMultipartFormBoundary();
        self.HTTPBodyParts = [[NSMutableArray alloc] init];
        self.stringEncoding = NSUTF8StringEncoding;
    }
    
    return self;
}

#pragma mark -- public methods

- (NSData *)finalFormDataWithRequest:(ZZHTTPRequestChromium *)request
{
    if ([request.params count] > 0) {
        for (NSString *key in [request.params allKeys]) {
            NSString *name = [key description];
            id value = request.params[key];
            
            NSData *data = nil;
            if ([value isKindOfClass:[NSData class]]) {
                data = (NSData *)value;
            } else if ([value isEqual:[NSNull null]]) {
                data = [NSData data];
            } else {
                data = [[value description] dataUsingEncoding:self.stringEncoding];
            }
            
            if (data) {
                [self appendPartWithFormData:data name:name];
            }
        }
    }
    
    if ([self.HTTPBodyParts count] > 0) {
        [[self.HTTPBodyParts firstObject] setHasInitialBoundary:YES];
        [[self.HTTPBodyParts lastObject] setHasFinalBoundary:YES];
        
        NSMutableData *body = [[NSMutableData alloc] init];
        for (ZZHTTPBodyPart *bodyPart in self.HTTPBodyParts) {
            [body appendData:[bodyPart getData]];
        }
        
        return body;
    }
    
    return nil;
}

- (NSString *)getContentType
{
    return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundary];
}

#pragma mark -- ZZMultipartFormData

- (void)appendPartWithFileData:(NSData *)data
                          name:(NSString *)name
                      fileName:(NSString *)fileName
                      mimeType:(NSString *)mimeType
{
    NSParameterAssert(name);
    NSParameterAssert(fileName);
    NSParameterAssert(mimeType);
    
    NSMutableDictionary *mutableHeaders = [[NSMutableDictionary alloc] init];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"; filename=\"%@\"", name, fileName] forKey:@"Content-Disposition"];
    [mutableHeaders setValue:mimeType forKey:@"Content-Type"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}

- (void)appendPartWithFormData:(NSData *)data name:(NSString *)name
{
    NSParameterAssert(name);
    
    NSMutableDictionary *mutableHeaders = [[NSMutableDictionary alloc] init];
    [mutableHeaders setValue:[NSString stringWithFormat:@"form-data; name=\"%@\"", name] forKey:@"Content-Disposition"];
    
    [self appendPartWithHeaders:mutableHeaders body:data];
}

- (void)appendPartWithHeaders:(NSDictionary *)headers body:(NSData *)data
{
    NSParameterAssert(headers);
    
    ZZHTTPBodyPart *bodyPart = [[ZZHTTPBodyPart alloc] init];
    bodyPart.stringEncoding = self.stringEncoding;
    bodyPart.headers = headers;
    bodyPart.boundary = self.boundary;
    bodyPart.bodyContentLength = [data length];
    bodyPart.body = data;
    bodyPart.hasInitialBoundary = NO;
    bodyPart.hasFinalBoundary = NO;
    
    [self.HTTPBodyParts addObject:bodyPart];
}

@end //ZZHTTPMultipartFormDataChromium

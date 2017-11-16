//
//  ZZHTTPRequestChromium.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/14.
//

#import "ZZHTTPRequest.h"
#import "ZZHTTPMultipartFormDataChromium.h"

@interface ZZHTTPRequestChromium : ZZHTTPRequest

@property (nonatomic, strong) ZZHTTPMultipartFormDataChromium *multipartForm;
@property (nonatomic, copy)   NSString *urlString;
@property (nonatomic, copy)   NSDictionary *params;

- (instancetype)initWithURL:(NSString *)url
                     method:(NSString *)method
              multipartForm:(ZZHTTPMultipartFormDataChromium *)form;

@end //ZZHTTPRequestChromium

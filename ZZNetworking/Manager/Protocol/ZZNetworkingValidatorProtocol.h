//
//  ZZNetworkingValidatorProtocol.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import <Foundation/Foundation.h>

@class ZZNetworkingManager;
@class ZZHTTPRequest;


@protocol ZZNetworkingValidatorProtocol <NSObject>

@required

+ (NSObject<ZZNetworkingValidatorProtocol> *)validator;

@optional

/**
 * 验证网络请求参数(如:当调用API的参数是来自用户输入的时候，验证是很必要的)是否正确，如果返回NO, 则不会发起网络请求
 *
 * @param manager       网络管理对象
 * @param URLString     网络请求地址
 * @param requestParams 网络请求参数
 * @param commonParams  通用参数
 *
 * @return 网络请求参数验证正确时返回YES, 否则返回NO, 验证不正确时不会发起网络请求
 */
- (BOOL)manager:(ZZNetworkingManager *)manager isCorrectWithRequestURL:(NSString *)URLString requestParams:(NSDictionary *)requestParams commonParams:(NSDictionary *)commonParams;


/**
 * 所有的callback数据都应该在这个函数里面进行检查，事实上，到了网络回调block的函数里面是不需要再额外验证返回数据是否为空的。
 * 因为判断逻辑都在这里做掉了。而且本来判断返回数据是否正确的逻辑就应该交给validator去做，不要放到回调到网络回调的block里面去做。
 * 注意: 如果网络响应错误或者responseSerializer解析响应数据错误, 是不会再调用该方法的. 即调用到方法时一定网络响应成功, 且数据解析成功.
 *
 * @param manager      网络管理对象
 * @param responseData 网络响应数据, 可能是NSDictionary和NSData.
 * @param request      对应的网络请求
 *
 * @return 网络响应数据验证通过时返回YES, 否则返回NO
 */
- (BOOL)manager:(ZZNetworkingManager *)manager isCorrectWithResponseData:(id)responseData request:(ZZHTTPRequest *)request;

@end //ZZNetworkingValidatorProtocol

//
//  ZZNetworkingManager.m
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import "ZZNetworkingManager.h"
#import "ZZNetworkingManagerChromium.h"
#import "ZZNetworkingManagerAFNetworking.h"

static ZZNetworkImplementationType p_curNetworkImpl = ZZNetworkImplementationTypeAFNetworking;


@implementation ZZNetworkingManager

+ (void)setNetworkImplementation:(ZZNetworkImplementationType)implementation
{
    p_curNetworkImpl = implementation;
}

+ (ZZNetworkImplementationType)networkImplementaion
{
    return p_curNetworkImpl;
}

+ (instancetype)sharedInstance
{
    if (ZZNetworkImplementationTypeAFNetworking == p_curNetworkImpl) {
        return [ZZNetworkingManagerAFNetworking sharedInstance];
    } else if (ZZNetworkImplementationTypeChromium == p_curNetworkImpl) {
        return [ZZNetworkingManagerChromium sharedInstance];
    } else {
        NSAssert(NO, @"please set the implemented net lib.");
        return nil;
    }
}

@end //ZZNetworkingManager

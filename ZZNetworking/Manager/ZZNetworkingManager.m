//
//  ZZNetworkingManager.m
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import "ZZNetworkingManager.h"

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

@end //ZZNetworkingManager

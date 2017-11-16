//
//  ZZNetworkingManagerChromium.m
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import "ZZNetworkingManagerChromium.h"
#import "ZZNetworkingDefineHeader.h"
#import "ZZNetworkingMacroHeader.h"

//#include "base/lazy_instance.h"
//#include "base/logging.h"
//#include "base/memory/scoped_vector.h"
//#include "base/strings/sys_string_conversions.h"
//#include "components/cronet/ios/cronet_environment.h"
//#include "components/cronet/url_request_context_config.h"

//base::LazyInstance<std::unique_ptr<cronet::CronetEnvironment>>::Leaky
//gChromeNet = LAZY_INSTANCE_INITIALIZER;

static dispatch_semaphore_t _lock = nil;                                /* 操作任务id的互斥锁 */
static UInt64 _currentTaskID      = 0;                                  /* 当前网络请求任务ID */

@interface ZZNetworkingManagerChromium ()

@end //ZZNetworkingManagerChromium ()


@implementation ZZNetworkingManagerChromium

@end //ZZNetworkingManagerChromium

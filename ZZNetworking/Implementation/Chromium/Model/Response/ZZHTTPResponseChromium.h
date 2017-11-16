//
//  ZZHTTPResponseChromium.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/14.
//

#import "ZZHTTPResponse.h"

namespace net {
    class URLFetcher;
}

@interface ZZHTTPResponseChromiumLoadTimingInfo : NSObject

@property (nonatomic, readonly, strong) NSDate *start;

/**
 *  The time spent determing which proxy to use.  0 when there is no PAC.
 */
@property (nonatomic, readonly, assign) int64_t proxy;


/**
 *  The time spent looking up the host's DNS address.  Null for requests that used proxies to look up the
 *  DNS address.
 */
@property (nonatomic, readonly, assign) int64_t dns;        /* DNS解析时间, 单位:ms */


/**
 *  The time spent establishing the connection. Connect time includes proxy connect times (though not
 *  proxy_resolve or DNS lookup times), time spent waiting in certain queues, TCP, and SSL time.
 */
@property (nonatomic, readonly, assign) int64_t connect;


/**
 *  The time when the SSL handshake started / completed. For non-HTTPS requests these are 0.
 *  These times are only for the SSL connection to the final destination server, not an SSL/SPDY proxy.
 */
@property (nonatomic, readonly, assign) int64_t ssl;


/**
 *  The time that sending HTTP reques.
 */
@property (nonatomic, readonly, assign) int64_t send;


/**
 *  The time at which the end of the HTTP headers were received
 */
@property (nonatomic, readonly, assign) int64_t wait;

@property (nonatomic, readonly, assign) int64_t receive;                         /* 响应的时间 */
@property (nonatomic, readonly, assign) int64_t total;                           /* 全部时间 */


/**
 *  The number of bytes in the raw response body (before response filters are applied, to decompress it,
 *  for instance).
 */
@property (nonatomic, readonly, assign) int64_t receivedResponseContentLenght;


/**
 *  The number of bytes received over the network during the processing of this request. This includes
 *  redirect headers, but not redirect bodies. It also excludes SSL and proxy handshakes.
 */
@property (nonatomic, readonly, assign) int64_t totalReceiveBytes;


/**
 *  For requests that are sent again after an AUTH challenge, this will be true if the original socket is reused,
 *  and false if a new socket is used. Responding to a proxy AUTH challenge is never considered to be reusing a
 *  socket, since a connection to the host wasn't established when the challenge was received.
 */
@property (nonatomic, readonly, assign) BOOL isSocketReused;


/**
 *  Returns true if the response body was served from the cache. This includes responses for which
 *  revalidation was required.
 */
@property (nonatomic, readonly, assign) BOOL isCached;


/**
 *  Returns true if the request was delivered through a proxy.  Must only be called after the
 *  OnURLFetchComplete callback has run and the request has not failed.
 */
@property (nonatomic, readonly, assign) BOOL isFromProxy;
@property (nonatomic, readonly, copy)   NSString *remoteIP;
@property (nonatomic, readonly, assign) uint16_t remotePort;

- (instancetype)initWithURLFetcher:(const net::URLFetcher *)fetcher;

@end //ZZHTTPResponseChromiumLoadTimingInfo


@interface ZZHTTPResponseChromium : ZZHTTPResponse

@property (nonatomic, readonly, strong) ZZHTTPResponseChromiumLoadTimingInfo *timingInfo;

- (instancetype)initWithURLFetcher:(const net::URLFetcher *)fetcher;

@end //ZZHTTPResponseChromium

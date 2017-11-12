//
//  ZZHTTPResponse.h
//  ZZNetworking
//
//  Created by renfeng.zhang on 2017/11/10.
//

#import <Foundation/Foundation.h>

@interface ZZCaseInsenstiveDictionary<__covariant KeyType, __covariant ObjectType> : NSMutableDictionary<KeyType, ObjectType> {
    NSMutableDictionary<KeyType, ObjectType> *inner_dict;
}

@end //ZZCaseInsenstiveDictionary


@interface ZZHTTPResponse : NSObject

/*!
 @abstract Returns the HTTP status code of the receiver.
 @result The HTTP status code of the receiver.
 */
@property (readonly) NSInteger statusCode;


/*!
 @abstract Returns a dictionary containing all the HTTP header fields
 of the receiver.
 @discussion By examining this header dictionary, clients can see
 the "raw" header information which was reported to the protocol
 implementation by the HTTP server. This may be of use to
 sophisticated or special-purpose HTTP clients.
 @result A dictionary containing all the HTTP header fields of the
 receiver.
 */
@property (nullable, readonly, copy) ZZCaseInsenstiveDictionary *allHeaderFields;


/*!
 @abstract Returns the URL of the receiver.
 @result The URL of the receiver.
 */
@property (nullable, readonly, copy) NSURL *URL;


/*!
 @abstract Returns the MIME type of the receiver.
 @discussion The MIME type is based on the information provided
 from an origin source. However, that value may be changed or
 corrected by a protocol implementation if it can be determined
 that the origin server or source reported the information
 incorrectly or imprecisely. An attempt to guess the MIME type may
 be made if the origin source did not report any such information.
 @result The MIME type of the receiver.
 */
@property (nullable, readonly, copy) NSString *MIMEType;

@end //ZZHTTPResponse

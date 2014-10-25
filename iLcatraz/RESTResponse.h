#import <Foundation/Foundation.h>
#import "HTTPResponse.h"


@interface RESTResponse : NSObject <HTTPResponse>
{
	NSUInteger offset;
	NSData *jsonData;
    NSUInteger status;
    NSDictionary *headers;
}

- (id)initWithText:(NSString *)text andStatus:(NSUInteger)aStatus;
- (id)initWithJSON:(NSString *)json andStatus:(NSUInteger)status;
- (id)initWithJSON:(NSString *)json status:(NSUInteger)status andCount:(NSInteger) count;
- (id)initWith405;

@end

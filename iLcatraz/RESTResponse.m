#import "RESTResponse.h"
#import "HTTPLogging.h"
#import "NSString+EString.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_FLAG_TRACE;//HTTP_LOG_LEVEL_OFF; // | HTTP_LOG_FLAG_TRACE;


@implementation RESTResponse
- (id)initWith405{
    if((self = [super init]))
	{
		HTTPLogTrace();
        offset = 0;
		jsonData = NULL;
        headers = [NSDictionary dictionaryWithObjectsAndKeys: @"0",@"Content-Length",@"close",@"Connection",nil];
        status=405;
	}
	return self;
}
/*
HTTPMessage *response = [[HTTPMessage alloc] initResponseWithStatusCode:405 description:nil version:HTTPVersion1_1];
[response setHeaderField:@"Content-Length" value:@"0"];
[response setHeaderField:@"Connection" value:@"close"];
return response;
*/
- (id)initWithJSON:(NSString *)json status:(NSUInteger)aStatus andCount:(NSInteger) count{
	if((self = [super init]))
	{
		HTTPLogTrace();
		
		offset = 0;
		jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        headers = [NSDictionary dictionaryWithObjectsAndKeys: @"application/json; charset=utf-8",@"Content-Type",[NSString stringWithFormat:@"%ld",(long)count],@"X-Count",nil];
        status=aStatus;
	}
	return self;
};

- (id)initWithJSON:(NSString *)json status:(NSUInteger)aStatus andLocation:(NSString*) location{
	if((self = [super init]))
	{
		HTTPLogTrace();
		
		offset = 0;
		jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        location = [location urlencode];
        headers = [NSDictionary dictionaryWithObjectsAndKeys: @"application/json; charset=utf-8",@"Content-Type",location,@"X-iTunes-Location",nil];
        status=aStatus;
	}
	return self;
};
- (id)initWithJSON:(NSString *)json andStatus:(NSUInteger)aStatus
{
	if((self = [super init]))
	{
		HTTPLogTrace();
		
		offset = 0;
		jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        headers = [NSDictionary dictionaryWithObjectsAndKeys: @"application/json; charset=utf-8",@"Content-Type",nil];
        status=aStatus;
	}
	return self;
}

- (id)initWithText:(NSString *)text andStatus:(NSUInteger)aStatus
{
	if((self = [super init]))
	{
		HTTPLogTrace();
		
		offset = 0;
		jsonData = [text dataUsingEncoding:NSUTF8StringEncoding];
        headers = [NSDictionary dictionaryWithObjectsAndKeys: @"text/plain; charset=utf-8",@"Content-Type",nil];
        status=aStatus;
	}
	return self;
}

- (void)dealloc
{
	HTTPLogTrace();
	
}

- (UInt64)contentLength
{
	UInt64 result = jsonData==NULL?0:(UInt64)[jsonData length];
	
	HTTPLogTrace2(@"%@[%p]:contentLength - %llu", THIS_FILE, self,result);
	
	return result;
}

- (UInt64)offset
{
	HTTPLogTrace();
	
	return offset;
}

- (void)setOffset:(UInt64)offsetParam
{
	HTTPLogTrace2(@"%@[%p]: setOffset:%lu", THIS_FILE, self, (unsigned long)offset);
	
	offset = (NSUInteger)offsetParam;
}

- (NSData *)readDataOfLength:(NSUInteger)lengthParameter
{
	HTTPLogTrace2(@"%@[%p]: readDataOfLength:%lu", THIS_FILE, self, (unsigned long)lengthParameter);
	
	NSUInteger remaining = [jsonData length] - offset;
	NSUInteger length = lengthParameter < remaining ? lengthParameter : remaining;
	
	void *bytes = (void *)([jsonData bytes] + offset);
	
	offset += length;
	
	return [NSData dataWithBytesNoCopy:bytes length:length freeWhenDone:NO];
}

- (BOOL)isDone
{
	BOOL result = (offset == [jsonData length]);
	
	HTTPLogTrace2(@"%@[%p]: isDone - %@", THIS_FILE, self, (result ? @"YES" : @"NO"));
	
	return result;
}

- (NSInteger)status
{
    HTTPLogTrace2(@"%@[%p]: status - %lu", THIS_FILE, self, (unsigned long)status);
    return status;
};

- (NSDictionary *)httpHeaders {
    HTTPLogTrace2(@"%@[%p]: headers - %@", THIS_FILE, self, headers);
    return headers;
};

@end
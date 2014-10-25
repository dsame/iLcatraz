//
//  me_dsa_ilcatrazAppDelegate.m
//  iLcatraz
//
//  Created by Sergey Dolin on 10/22/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import "me_dsa_iLcatrazAppDelegate.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "HTTPConnectionIL.h"
#import "ITunesService.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation me_dsa_iLcatrazAppDelegate

@synthesize window = _window;

	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
   // [[ITunesService service] jsonSources];
 
    httpServer = [[HTTPServer alloc] init];
    
    [httpServer setConnectionClass:[HTTPConnectionIL class]];
    
    [httpServer setType:@"_http._tcp."];
    
    [httpServer setPort:8123];
    
 //   NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    NSError *error;
	BOOL success = [httpServer start:&error];
	
	if(!success)
	{
		DDLogError(@"Error starting HTTP Server: %@", error);
	}


}

@end

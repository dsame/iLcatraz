//
//  me_dsa_ilcatrazAppDelegate.h
//  iLcatraz
//
//  Created by Sergey Dolin on 10/22/14.
//  Copyright (c) 2014 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HTTPServer;

@interface me_dsa_iLcatrazAppDelegate : NSObject <NSApplicationDelegate> {
    HTTPServer *httpServer;
}

@property (unsafe_unretained) IBOutlet NSWindow *window;

@end

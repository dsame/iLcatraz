//
//  me_dsa_ilcatrazAppDelegate.h
//  iLcatraz
//
//  Created by Sergey Dolin on 10/22/14.
//  Copyright (c) 2014 DSA. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class HTTPServer;

@interface me_dsa_iLcatrazAppDelegate : NSObject <NSApplicationDelegate> {
    HTTPServer *httpServer;
    NSStatusItem * _statusItem;
 //   NSMenu* _statusMenu;
}


@property (unsafe_unretained) IBOutlet NSMenu *statusMenu;

- (IBAction)showPreferencesPanel:(id)sender;
- (void)startHTTPServer;
- (void)switchPolicy;

//@property (unsafe_unretained) IBOutlet NSWindow *window;

@end

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
#import "PreferencesController.h"

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface me_dsa_iLcatrazAppDelegate () {
    PreferencesController *_preferencesPanelController;
}
@end

@implementation me_dsa_iLcatrazAppDelegate
@synthesize statusMenu = _statusMenu;

//@synthesize window = _window;

	
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:
      [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithBool:NO],@"runOnLaunch",
       [NSNumber numberWithBool:YES],@"randomPort",
       [NSNumber numberWithInt:8322],@"port",
       [NSNumber numberWithInt:0],@"showMenu",
       nil]];
   
    [self startHTTPServer];
}
- (void) awakeFromNib {
    [self switchPolicy];
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag{
    [self showPreferencesPanel:self];
    return NO;
}
- (void)switchPolicy{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"showMenu"] intValue]==1){
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:22];
        [_statusItem setMenu:_statusMenu];
        [_statusItem setImage:[[NSImage alloc] initByReferencingFile:[[NSBundle mainBundle] pathForResource:@"glogo" ofType:@"png"]]];
        [_statusItem setHighlightMode:YES];
    }else{
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
    }
}

- (void)startHTTPServer{
    if (httpServer!=NULL && [httpServer isRunning]){
        [httpServer stop:YES];
    }
    httpServer = [[HTTPServer alloc] init];
    
    [httpServer setConnectionClass:[HTTPConnectionIL class]];
    
    
    [httpServer setType:@"_ilcatraz._tcp."];
    
    BOOL randomPort=[[NSUserDefaults standardUserDefaults] boolForKey:@"randomPort"];
    if (!randomPort){
        NSInteger port=[[NSUserDefaults standardUserDefaults] integerForKey:@"port"];
        [httpServer setPort:port];
    }
    /*
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Root"];
	DDLogVerbose(@"Setting document root: %@", webPath);
    [httpServer setDocumentRoot:webPath];
*/
    NSError *error;
	BOOL success = [httpServer start:&error];
    
    
	if(success)
    {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"error"];
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"error"];
        DDLogError(@"Error starting HTTP Server: %@", error);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Can't run iLcatraz"];
        [alert setInformativeText:[error localizedDescription]];
        [alert setAlertStyle:NSWarningAlertStyle];
        
        [alert runModal];
	}
};
#pragma mark *** Preferences ***

- (IBAction)showPreferencesPanel:(id)sender {
    if (!_preferencesPanelController) {
        _preferencesPanelController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
        
        [_preferencesPanelController setAppDelegate:self];
        // Make the panel appear in a good default location.
        [[_preferencesPanelController window] center];
        
    }
    [_preferencesPanelController showWindow:self];
    NSApplication *thisApp = [NSApplication sharedApplication];
    [thisApp activateIgnoringOtherApps:YES];
    [[_preferencesPanelController window] orderFront:self];
}
@end

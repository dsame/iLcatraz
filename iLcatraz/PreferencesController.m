//
//  me.dsa.iLcatraz.PreferencesController
//  iLcatraz
//
//  Created by Macmini on 26.10.14.
//  Copyright (c) 2014 dsa. All rights reserved.
//

#import "PreferencesController.h"

@interface PreferencesController ()

@end

@implementation PreferencesController
@synthesize appDelegate;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)portChanged:(id)sender{
    [appDelegate startHTTPServer];
};

- (IBAction)switchPolicy:(id)sender{
    [appDelegate switchPolicy];
};

- (BOOL)loginItemExistsWithLoginItemReference:(LSSharedFileListRef)theLoginItemsRefs ForPath:(CFURLRef)thePath {
    BOOL exists = NO;
    UInt32 seedValue;
    
    // We're going to grab the contents of the shared file list (LSSharedFileListItemRef objects)
    // and pop it in an array so we can iterate through it to find our item.
    NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(theLoginItemsRefs, &seedValue);
    for (id item in loginItemsArray) {
        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
        if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef*) &thePath, NULL) == noErr) {
            if ([[(__bridge NSURL *)thePath path] hasPrefix:@"/Applications/MyApp.app"])
                exists = YES;
        }
        CFRelease((__bridge CFTypeRef)(loginItemsArray));
        return exists;
    };
    CFRelease((__bridge CFTypeRef)(loginItemsArray));
    return NO;
}

-(BOOL) findLaunchItem:(LSSharedFileListItemRef*)pItemRef inLoginsList:(LSSharedFileListRef*)pLoginsList{
    NSURL * appPath=[[NSRunningApplication currentApplication] bundleURL];
    NSString *appPathString=[appPath absoluteString];
    UInt32 seedValue;
    *pLoginsList = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    NSArray  *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(*pLoginsList, &seedValue);
    //Memory leak but it's best i can to avoid crash
    CFRetain(*pLoginsList);
    for (id item in loginItemsArray) {
        *pItemRef = (__bridge LSSharedFileListItemRef)item;
        CFURLRef path;
        if (LSSharedFileListItemResolve(*pItemRef, 0, &path, NULL) == noErr) {
            NSURL *nspath = (__bridge NSURL *)path;
            NSString *nppPathString=[nspath absoluteString];
            if ([nppPathString isEqualToString:appPathString]
                ||
                [nppPathString isEqualToString:[appPathString stringByAppendingString:@"/"]]
                ) {
                CFRelease((__bridge CFTypeRef)(loginItemsArray));
                //Memory leak but it's best i can to avoid crash
                CFRetain(*pItemRef);
                return YES;
            }
        }
    };
    CFRelease((__bridge CFTypeRef)(loginItemsArray));
    return NO;
}
-(void)setRunOnLaunch:(NSNumber*)runOnLaunch{
    LSSharedFileListRef loginsList;
    LSSharedFileListItemRef itemRef;
    
    BOOL exists=[self findLaunchItem:&itemRef inLoginsList:&loginsList];
    CFURLRef path = (__bridge CFURLRef)[[NSRunningApplication currentApplication] bundleURL];
    
    if ([runOnLaunch boolValue] && !exists){
        NSNumber * exist=[self runOnLaunch];
        if ([exist boolValue]) return;
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginsList, kLSSharedFileListItemLast, NULL, NULL, path, NULL, NULL);
        if (item)
            CFRelease(item);
    }else if (![runOnLaunch boolValue] && exists){
        LSSharedFileListItemRemove(loginsList, itemRef);
    }
}

-(NSNumber *)runOnLaunch{
    LSSharedFileListRef loginsList;
    LSSharedFileListItemRef itemRef;
    
    return [NSNumber numberWithBool:[self findLaunchItem:&itemRef inLoginsList:&loginsList]];
}
@end

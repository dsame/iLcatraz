//
//  me.dsa.iLcatraz.h
//  iLcatraz
//
//  Created by Macmini on 26.10.14.
//  Copyright (c) 2014 dsa. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "me_dsa_iLcatrazAppDelegate.h"

@interface PreferencesController : NSWindowController

@property (assign) NSNumber* runOnLaunch;
@property (unsafe_unretained)  me_dsa_iLcatrazAppDelegate *appDelegate;
- (IBAction)portChanged:(id)sender;
- (IBAction)switchPolicy:(id)sender;

@end

//
//  AppDelegate.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 2017/12/16.
//  Copyright © 2017年 TedZhang. All rights reserved.
//

#import "AppDelegate.h"
#import "AppController.h"
#import "PreferenceWindowController.h"
#import "SpotifyAddWindowController.h"
#import "INAppStoreWindow.h"
#import <ProductionAuthentication/Authentication.h>

@interface AppDelegate ()

@end

static PreferenceWindowController* preference = nil;
static ProductController* productCtl = nil;

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    INAppStoreWindow* appWindow = [NSApp mainWindow];
    [appWindow setTrafficLightButtonsLeftMargin:7.0];
    [appWindow setCenterTrafficLightButtons:0];
    [appWindow setTitleBarHeight:40.0];
    [appWindow setBottomBarHeight:50.0];
    
    
    if (preference == nil) {
        preference = [[PreferenceWindowController alloc] initWithWindowNibName:@"PreferenceWindow"];
    }
    
    if (productCtl == nil) {
        productCtl = [[ProductController alloc] init];
    }
        
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (IBAction)openPerferences:(id)sender {
    [preference showWindow:sender];
}
@end



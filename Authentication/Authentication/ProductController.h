//
//  ProductController.h
//  Authentication
//
//  Created by ted zhang on 3/7/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AboutWindowController, RegisterWindowController, SUUpdater;

@interface ProductController : NSObject
{
    AboutWindowController *aboutWindow;
    RegisterWindowController *registerWindow;
    SUUpdater *updater;
    NSDictionary *infoDictionary;
    NSBundle *bundle;
}

+ (void)setEncryptTemplate:(id)encryptTemlate;
+ (id)registerUser;
+ (BOOL)isRegister;
- (void)openRegister:(id)sender;
- (void)openAbout:(id)sender;
- (void)checkUpdates:(id)sender;
- (void)openOnlineHelp:(id)sender;
- (void)openEmailSupport:(id)sender;
- (void)openOrderURL:(id)sender;
- (void)openFaqURL:(id)sender;
- (void)openWebsiteURL:(id)sender;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (id)valueFromBundleInfoWithKey:(NSString*)key;
- (BOOL)validateMenuItem:(id)sender;
- (void)dealloc;
- (id)init;

@end


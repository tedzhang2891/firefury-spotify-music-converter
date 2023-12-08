//
//  ProductController.m
//  Authentication
//
//  Created by ted zhang on 3/7/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "ProductController.h"
#import "AboutWindowController.h"
#import "RegisterWindowController.h"
#import <Sparkle/Sparkle.h>

BOOL isInited = NO;

@implementation ProductController

+ (BOOL)isRegister {
    NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString* userID = [sharedUserDefaults objectForKey:@"UserID"];
    NSString* userKey = [sharedUserDefaults objectForKey:@"UserKey"];
    
    BOOL isValid = NO;
    if (userID && [userID length] && userKey && [userKey length]) {
        isValid = [RegisterWindowController isLicenseCodeValid:userKey forUser:userID];
    }
    
    return isValid;
}

+ (id)registerUser {
    NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
    return [sharedUserDefaults objectForKey:@"UserID"];
}

+ (void)setEncryptTemplate:(id)encryptTemlate {
    // Not used
}

- (id)init { 
    if (self = [super init]) {
        NSBundle* mainBundle = [NSBundle mainBundle];
        id preferred = [mainBundle preferredLocalizations];
        
        self->bundle = [NSBundle bundleForClass:[self class]];
        NSString* execPath = [self->bundle executablePath];
        NSLog(@"current language is %@, bundle path is %@", preferred[0], execPath);
        
        NSDictionary* plist = [mainBundle infoDictionary];
        NSDictionary* productInfo = plist[@"ProductInfo"];
        self->infoDictionary = [productInfo objectForKey:preferred[0]];
        self->updater = [[SUUpdater alloc] init];
        
        NSString* feedUrl = [self valueFromBundleInfoWithKey:@"SUFeedURL"];
        [self->updater setFeedURL:[NSURL URLWithString:feedUrl]];
        
        NSNotificationCenter* sharedNotificationCenter = [NSNotificationCenter defaultCenter];
        [sharedNotificationCenter addObserver:self selector:@selector(applicationDidFinishLaunching:) name:@"NSApplicationDidFinishLaunchingNotification" object:NSApp];
    }
    return self;
}

- (id)valueFromBundleInfoWithKey:(NSString *)key {
    NSString* value = [self->infoDictionary objectForKey:key];
    if (!value) {
        NSDictionary* plist = [[NSBundle mainBundle] infoDictionary];
        value = [plist objectForKey:key];
    }
    return value;
}

- (BOOL)validateMenuItem:(id)sender { 
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
    NSWorkspace* sharedWorkspace = [NSWorkspace sharedWorkspace];
    
    if (!isInited) {
        isInited = YES;
        NSString* quickGuideUrl = [self valueFromBundleInfoWithKey:@"QuickGuideForInstallURL"];
        if (quickGuideUrl && [quickGuideUrl length]) {
            if (![sharedUserDefaults objectForKey:@"QuickGuideAfterInstallIsShowed"]) {
                [sharedUserDefaults setBool:YES forKey:@"QuickGuideAfterInstallIsShowed"];
                [sharedWorkspace openURL:[NSURL URLWithString:quickGuideUrl]];
            }
        }
        
        NSMenu* mainMenu = [NSApp mainMenu];
        NSUInteger count = [mainMenu numberOfItems];
        NSMenuItem* menuItem = [mainMenu itemAtIndex:count - 1];
        
        if (menuItem && [menuItem hasSubmenu]) {
            NSString* helpBookName = [self valueFromBundleInfoWithKey:@"CFBundleHelpBookName"];
            NSMenu* subMenu = [menuItem submenu];
            if (helpBookName) {
                NSMenuItem* subMenu0 = [subMenu itemAtIndex:0];
                NSString* locHelp = [self->bundle localizedStringForKey:@"%@ Help" value:nil table:nil];
                NSString* bundleName = [self valueFromBundleInfoWithKey:@"CFBundleName"];
                NSString* productHelp = [NSString stringWithFormat:locHelp, bundleName];
                
                [subMenu0 setTitle:productHelp];
                [subMenu0 setKeyEquivalent:@"?"];
                [subMenu0 setKeyEquivalentModifierMask:NSEventModifierFlagCommand];
                [subMenu addItem:[NSMenuItem separatorItem]];
            }
            else if ([subMenu numberOfItems] > 0) {
                [subMenu removeItemAtIndex:0];
            }
            
            if ([self valueFromBundleInfoWithKey:@"WebSiteURL"]) {
                NSString* locVisitWebsite = [self->bundle localizedStringForKey:@"Visit WebSite" value:nil table:nil];
                NSMenuItem* openMenuItem = [[NSMenuItem alloc] initWithTitle:locVisitWebsite action:@selector(openWebsiteURL:) keyEquivalent:@""];
                [openMenuItem setTarget:self];
                [openMenuItem setEnabled:YES];
                [subMenu addItem:openMenuItem];
            }
            
            if ([self valueFromBundleInfoWithKey:@"OrderURL"]) {
                NSString* locOrderNow = [self->bundle localizedStringForKey:@"Order Now" value:nil table:nil];
                NSMenuItem* orderMenuItem = [[NSMenuItem alloc] initWithTitle:locOrderNow action:@selector(openOrderURL:) keyEquivalent:@""];
                [orderMenuItem setTarget:self];
                [orderMenuItem setEnabled:YES];
                [subMenu addItem:orderMenuItem];
            }
            
            [subMenu addItem:[NSMenuItem separatorItem]];
            
            if ([self valueFromBundleInfoWithKey:@"FaqURL"]) {
                NSString* locReadFAQ = [self->bundle localizedStringForKey:@"Read FAQ" value:nil table:nil];
                NSMenuItem* faqMenuItem = [[NSMenuItem alloc] initWithTitle:locReadFAQ action:@selector(openFaqURL:) keyEquivalent:@""];
                [faqMenuItem setTarget:self];
                [faqMenuItem setEnabled:YES];
                [subMenu addItem:faqMenuItem];
            }
            
            if ([self valueFromBundleInfoWithKey:@"SupportEMail"]) {
                NSString* locSupportEMail = [self->bundle localizedStringForKey:@"Email Support" value:nil table:nil];
                NSMenuItem* supportMenuItem = [[NSMenuItem alloc] initWithTitle:locSupportEMail action:@selector(openEmailSupport:) keyEquivalent:@""];
                [supportMenuItem setTarget:self];
                [supportMenuItem setEnabled:YES];
                [subMenu addItem:supportMenuItem];
            }
            
            if ([self valueFromBundleInfoWithKey:@"OnlineHelpURL"]) {
                NSString* locOnlineHelpURL = [self->bundle localizedStringForKey:@"Read Online Help" value:nil table:nil];
                NSMenuItem* onlineMenuItem = [[NSMenuItem alloc] initWithTitle:locOnlineHelpURL action:@selector(openOnlineHelp:) keyEquivalent:@""];
                [onlineMenuItem setTarget:self];
                [onlineMenuItem setEnabled:YES];
                [subMenu addItem:onlineMenuItem];
            }
        }
        
        NSMenuItem* firstMenuItem = [mainMenu itemAtIndex:0];
        NSMenu* firstSubMenu = [firstMenuItem submenu];
        NSMenuItem* firstSubItem = [firstSubMenu itemAtIndex:0];
        
        NSString* locAbout = [self->bundle localizedStringForKey:@"About %@" value:nil table:nil];
        NSString* bundleName = [self valueFromBundleInfoWithKey:@"CFBundleName"];
        NSString* aboutInfo = [NSString stringWithFormat:locAbout, bundleName];
        
        [firstSubItem setTitle:aboutInfo];
        [firstSubItem setTarget:self];
        [firstSubItem setAction:@selector(openAbout:)];
        
        if ([self valueFromBundleInfoWithKey:@"SUFeedURL"]) {
            NSString* locSUFeedURL = [self->bundle localizedStringForKey:@"Check for Updates..." value:nil table:nil];
            NSMenuItem* feedMenuItem = [[NSMenuItem alloc] initWithTitle:locSUFeedURL action:@selector(checkUpdates:) keyEquivalent:@""];
            [feedMenuItem setTarget:self];
            [feedMenuItem setEnabled:YES];
            [firstSubMenu insertItem:feedMenuItem atIndex:1];
        }
        
        NSMenuItem* quitItem = [firstSubMenu itemAtIndex:[firstSubMenu numberOfItems] - 1];
        NSString* locQuit = [self->bundle localizedStringForKey:@"Quit %@" value:nil table:nil];
        NSString* quitInfo = [NSString stringWithFormat:locQuit, bundleName];
        [quitItem setTitle:quitInfo];
        
        NSMenuItem* hideItem = [firstSubMenu itemAtIndex:[firstSubMenu numberOfItems] - 5];
        NSString* locHide = [self->bundle localizedStringForKey:@"Hide %@" value:nil table:nil];
        NSString* hideInfo = [NSString stringWithFormat:locHide, bundleName];
        [hideItem setTitle:hideInfo];
        
        NSString* locRegistration = [self->bundle localizedStringForKey:@"Registration..." value:nil table:nil];
        NSMenuItem* registerMenuItem = [[NSMenuItem alloc] initWithTitle:locRegistration action:@selector(openRegister:) keyEquivalent:@""];
        [registerMenuItem setTarget:self];
        [registerMenuItem setEnabled:YES];
        [firstSubMenu insertItem:registerMenuItem atIndex:2];
        
        [firstMenuItem setTitle:bundleName];
    }
}

- (void)openWebsiteURL:(id)sender { 
    NSString* websiteUrl = [self valueFromBundleInfoWithKey:@"WebSiteURL"];
    if (websiteUrl) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:websiteUrl]];
    }
}

- (void)openFaqURL:(id)sender { 
    NSString* faqUrl = [self valueFromBundleInfoWithKey:@"FaqURL"];
    if (faqUrl) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:faqUrl]];
    }
}

- (void)openOrderURL:(id)sender { 
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* plist = [mainBundle infoDictionary];
    NSString* installDMGPath = plist[@"InstallDMGPath"];
    NSString* regNowURL = plist[@"RegNowURL"];
    NSString* orderURL = nil;
    
    if (installDMGPath && regNowURL) {
        NSArray* pathArr = [installDMGPath componentsSeparatedByString:@"_a"];
        if ([pathArr count] >= 2) {
            NSString* path = [pathArr lastObject];
            if ([path length] >=5) {
                NSString* affilateNO = [path stringByDeletingPathExtension];
                NSCharacterSet* numberSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
                
                NSUInteger index = 0;
                while (index > [affilateNO length]) {
                    unichar c = [affilateNO characterAtIndex:index++];
                    if ([numberSet characterIsMember:c]) {
                        break;
                    }
                }
                
                NSLog(@"affilate is %@", affilateNO);
                orderURL = [regNowURL stringByAppendingFormat:@"&affilate=%@", affilateNO];
            }
        }
    }
    
    if (!orderURL) {
        orderURL = plist[@"OrderURL"];
    }
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:orderURL]];
}

- (void)openEmailSupport:(id)sender {
    NSString* supportEMail = [self valueFromBundleInfoWithKey:@"SupportEMail"];
    if (supportEMail) {
        NSString* sendMailStr = [NSString stringWithFormat:@"tell application \"Mail\" \n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tactivate \n\t\t\t\t\t\t\t\t\t\t\t\t\t\t\tmailto \"mailto:%@\" \n\t\t\t\t\t\t\t\t\t\t\t\t\t\tend tell", supportEMail];
        NSAppleScript* sendMail = [[NSAppleScript alloc] initWithSource:sendMailStr];
        [sendMail executeAndReturnError:nil];
    }
}

- (void)openOnlineHelp:(id)sender { 
    NSString* faqUrl = [self valueFromBundleInfoWithKey:@"OnlineHelpURL"];
    if (faqUrl) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:faqUrl]];
    }
}

- (void)checkUpdates:(id)sender { 
    [self->updater checkForUpdates:sender];
}

- (void)openAbout:(id)sender { 
    if (!self->aboutWindow) {
        self->aboutWindow = [[AboutWindowController alloc] init];
        [self->aboutWindow setProductController:self];
    }
    [self->aboutWindow showWindow:sender];
}

- (void)openRegister:(id)sender { 
    if (!self->registerWindow) {
        self->registerWindow = [[RegisterWindowController alloc] init];
        [self->registerWindow setDegelate:self];
    }
    [[self->registerWindow window] makeKeyAndOrderFront:sender];
}

@end

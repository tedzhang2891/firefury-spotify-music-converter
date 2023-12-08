//
//  PreferenceWindow.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 1/3/18.
//  Copyright © 2018 TedZhang. All rights reserved.
//

#import "PreferenceWindowController.h"

@interface PreferenceWindowController ()

@end

@implementation PreferenceWindowController

@dynamic debugDescription;
@dynamic description;
@dynamic hash;
@dynamic superclass;

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSWindow* window = [self window];
    [window setDelegate:self];
    [self.speedButton removeAllItems];
    NSArray* speedArray = nil;
    if (1) {
        speedArray = @[[NSNumber numberWithInt:1]];
    }
    else {
        speedArray = @[[NSNumber numberWithInt:20], [NSNumber numberWithInt:10], [NSNumber numberWithInt:5], [NSNumber numberWithInt:1]];
    }
    for (id obj in speedArray) {
        NSMenuItem* menuItem = [[NSMenuItem alloc] init];
        [menuItem setTitle:[NSString stringWithFormat:@"%@x", obj]];
        [menuItem setTag:[obj intValue]];
        NSMenu* menu = [self.speedButton menu];
        [menu addItem:menuItem];
    }
    
    NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger convertSpeed = [sharedUserDefaults integerForKey:@"PreferenceConvertSpeedKey"];
    [self.speedButton selectItemWithTag:convertSpeed];
    if ([sharedUserDefaults boolForKey:@"PreferenceKeepChaptersKey"]) {
        if (!AXIsProcessTrusted() || [sharedUserDefaults integerForKey:@"PreferenceOutputFormatKey"] != 2) {
            [sharedUserDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"PreferenceKeepChaptersKey"];
        }
    }
    
    if ([sharedUserDefaults integerForKey:@"PreferenceOutputFormatKey"] == 2) {
        [self.keepButton setState:[sharedUserDefaults boolForKey:@"PreferenceKeepChaptersKey"] != 0];
    }
    else {
        [self.keepButton setState:NSControlStateValueOff];
        [self.keepButton setEnabled:NO];
    }
}

- (NSNibName)windowNibName {
    return @"PreferenceWindow";
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)openLogFolder:(id)sender {
    NSWorkspace* sharedWorkapace = [NSWorkspace sharedWorkspace];
    NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString* logfolder = [sharedUserDefaults stringForKey:@"PreferenceLogFolderKey"];
    [sharedWorkapace selectFile:nil inFileViewerRootedAtPath:logfolder];
}

- (IBAction)changeOutputFolder:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    [openPanel setPrompt:@"Select"];
    [openPanel setCanChooseFiles:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanCreateDirectories:YES];
    if ([openPanel runModal] == NSModalResponseOK) {
        NSString* logPath = [[[openPanel URL] filePathURL] path];
        NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
        [sharedUserDefaults setObject:logPath forKey:@"PreferenceOutputFolderKey"];
    }
}

- (IBAction)changeOutputFormat:(id)sender {
    NSInteger selected = [sender selectedSegment];
    if (selected == 1) {
        [self.keepButton setEnabled:YES];
        NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
        if ([sharedUserDefaults boolForKey:@"PreferenceKeepChaptersKey"]) {
            if (AXIsProcessTrusted()) {
                [self.keepButton setState:NSControlStateValueOn];
            }
        }
    }
    else {
        [self.keepButton setState:NSControlStateValueOff];
        [self.keepButton setEnabled:NO];
    }
}

- (IBAction)changeKeepChapterOption:(id)sender {
    if ([sender state] == NSControlStateValueOn) {
        NSNumber* wrapBool = [NSNumber numberWithBool:YES];
        NSDictionary* dict = @{(__bridge NSString*)kAXTrustedCheckOptionPrompt: wrapBool};
        if (!AXIsProcessTrustedWithOptions((CFDictionaryRef)dict)) {
            [sender setState:NSControlStateValueOff];
        }
    }
    NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
    BOOL bstate = [sender state] == NSControlStateValueOn;
    [sharedUserDefaults setObject:[NSNumber numberWithBool:bstate] forKey:@"PreferenceKeepChaptersKey"];
}

- (IBAction)showWindow:(id)sender {
    [super showWindow:sender];
}

- (IBAction)windowWillClose:(id)sender { 
    NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
    [sharedUserDefaults synchronize];
}

+ (void)initialize {
    NSInteger speed = 0;

    NSString* searchPath = nil;
    NSString* searchBundle = nil;
    
    id searchList = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* bundleName = [mainBundle objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
    
    if ([searchList count]) {
        searchPath = [searchList objectAtIndex:0];
        searchBundle = [searchPath stringByAppendingPathComponent:bundleName];
    }
    else {
        searchBundle = NSTemporaryDirectory();
    }
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:searchBundle]) {
        [fileManager createDirectoryAtPath:searchBundle withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* mutable_preference = [NSMutableDictionary dictionary];
    [mutable_preference setObject:searchBundle forKey:@"PreferenceLogFolderKey"];
    [mutable_preference setObject:[NSNumber numberWithInt:2] forKey:@"PreferenceOutputFormatKey"];
    [mutable_preference setObject:[NSNumber numberWithInt:2] forKey:@"PreferenceOutputQualityKey"];
    [mutable_preference setObject:[NSNumber numberWithBool:NO] forKey:@"PreferenceOutputOrganizedKey"];
    
    if (1) {
        speed = 1;
    }
    else {
        speed = 20;
    }
    [mutable_preference setObject:[NSNumber numberWithInteger:speed] forKey:@"PreferenceConvertSpeedKey"];
    
    searchList = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    searchPath = [searchList objectAtIndex:0];
    NSString* outputFolder = [searchPath stringByAppendingPathComponent:bundleName];
    [mutable_preference setObject:outputFolder forKey:@"PreferenceOutputFolderKey"];
    [mutable_preference setObject:[NSNumber numberWithBool:YES] forKey:@"PreferenceAutoRenameFileKey"];
    [mutable_preference setObject:[NSNumber numberWithBool:YES] forKey:@"PreferenceDeleteFailureFileKey"];
    [mutable_preference setObject:[NSNumber numberWithBool:NO] forKey:@"PreferenceKeepChaptersKey"];
    [sharedUserDefaults registerDefaults:mutable_preference];
    
    if (1) {
        [sharedUserDefaults setObject:[NSNumber numberWithInteger:1] forKey:@"PreferenceConvertSpeedKey"];
    }
    else if ([sharedUserDefaults integerForKey:@"PreferenceConvertSpeedKey"] == 1) {
        [sharedUserDefaults setObject:[NSNumber numberWithInteger:20] forKey:@"PreferenceConvertSpeedKey"];
    }
    if ([sharedUserDefaults boolForKey:@"PreferenceKeepChaptersKey"] && (!AXIsProcessTrusted() || [sharedUserDefaults integerForKey:@"PreferenceOutputFormatKey"] != 2)) {
        [sharedUserDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"PreferenceKeepChaptersKey"];
    }
    
    BOOL bIsDir;
    outputFolder = [sharedUserDefaults stringForKey:@"PreferenceOutputFolderKey"];
    if (![fileManager fileExistsAtPath:outputFolder isDirectory:&bIsDir]) {
        [fileManager createDirectoryAtPath:outputFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString* logpath = [searchBundle stringByAppendingPathComponent:@"Application.log"];
    NSLog(@"log path is %@", logpath);
    
    NSDictionary<NSFileAttributeKey, id>* attributes = [fileManager attributesOfItemAtPath:logpath error:nil];
    if (attributes && [attributes fileSize] >= 0x500001) {
        [fileManager removeItemAtPath:logpath error:nil];
    }
    const char* log = [logpath fileSystemRepresentation];
    freopen(log, "a+", stderr);
}

@end

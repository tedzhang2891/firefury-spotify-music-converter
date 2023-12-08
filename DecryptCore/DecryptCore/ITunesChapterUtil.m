//
//  ITunesChapterUtil.m
//  DecryptCore
//
//  Created by ted zhang on 2018/2/13.
//  Copyright © 2018年 ted zhang. All rights reserved.
//

#import "ITunesChapterUtil.h"

@implementation ITunesChapterUtil

+ (id)chaptersFromITunesCurrentTrack {
    NSWorkspace* sharedWorkspace = [NSWorkspace sharedWorkspace];
    NSString* bundlePath = [sharedWorkspace absolutePathForAppBundleWithIdentifier:@"com.apple.iTunes"];
    NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
    NSString* bundleVer = [bundle objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    id verlist = [bundleVer componentsSeparatedByString:@"."];
    int major = [verlist[0] intValue];
    
    NSAppleScript* telliTunes = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to get duration of current track"];
    NSAppleEventDescriptor* iTunesEvent = [telliTunes executeAndReturnError:nil];
    double duration = [iTunesEvent doubleValue];
    if (duration == 0.0) {
        NSLog(@"can not get duration for current track");
        return nil;
    }
    
    
    NSString* script = [NSString stringWithFormat:@"                                                               set ns to {}\n                                                               tell application \"System Events\"\n                                                               tell process \"iTunes\"\n                                                               set m to get every menu bar item of menu bar 1\n                                                               set ic to count (m)\n                                                               if ic > %d then\n                                                               set c to item (ic - 1) of m\n                                                               set ms to menu item of menu 1 of c\n                                                               repeat with i in ms\n                                                               set ns to (ns & name of i as string) & \"\n\"\n                                                               end repeat\n                                                               end if\n                                                               end tell\n                                                               end tell\n", (major < 11) | 0xA];
    
    NSAppleScript* tellSystemEvents = [[NSAppleScript alloc] initWithSource:script];
    NSAppleEventDescriptor* systemEvent = [tellSystemEvents executeAndReturnError:nil];
    NSString* sysEvt = [systemEvent stringValue];
    if (sysEvt && [sysEvt length]) {
        NSMutableArray* evtArray = [NSMutableArray arrayWithCapacity:8];
        id events = [sysEvt componentsSeparatedByString:@"\n"];
        NSEnumerator* enumerator = [events objectEnumerator];
        for (id each in enumerator) {
            
        }
        
    }
    
    NSLog(@"get chapters failure");
    return nil;
}

@end

//
//  MusicApplication.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 2017/11/5.
//  Copyright © 2017年 TedZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>
#import <AppKit/AppKit.h>

typedef struct var_block {
    UInt64 unknown;
    UInt64 self;
    UInt64 signature;
}TVarBlock;

@class NSRunningApplication, NSString;

__attribute__((visibility("hidden")))
@interface MusicApplication : NSObject
{
    NSString *pluginPath;
    NSRunningApplication *runningApp;
    AudioObjectID buildinOutputDevice;
    AudioObjectID activeOutputDevice;
    int mode;
    NSString *_appPath;
    NSString *_appVersion;
}

+ (id) runningAppWithPath:(NSString*)path;
@property(readwrite) NSString *appVersion; // @synthesize appVersion=_appVersion;
@property(retain) NSString *appPath; // @synthesize appPath=_appPath;
- (void) getActiveAudioDevice:(AudioObjectID*)activeDevice buildinAudioDevice:(AudioObjectID*) builtinDevice;
- (BOOL) setOutputDevice:(AudioObjectID)objId;
- (BOOL) setOutputDeviceToBuildin;
- (void) hideApplicationWindow;
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;
- (BOOL) close;
- (BOOL) open;
- (BOOL) isRunning;
- (MusicApplication*) initWithPluginPath:(NSString*)path;

@end

//
//  MusicConverter.h
//  drm_removal_for_audio
//
//  Created by ted zhang on 2017/12/9.
//  Copyright © 2017年 TedZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Converter.h"
#import "ConvertCommunicationProtocol.h"

@class MusicApplication, NSImage, NSString;

__attribute__((visibility("default")))
@interface MusicConverter : NSObject <Converter>
{
    id <ConvertCommunicationProtocol> converterCore;
    MusicApplication *musicApp;
    NSString *musicAppIdentifer;
    NSString *pluginPath;
    long long timeoutValue;
    //NSImage *_currentTrackArtwork;
}

+ (NSString*)converterLogPath;
+ (id)sharedMusicConverter;
@property(retain) NSImage *currentTrackArtwork; // @synthesize currentTrackArtwork=_currentTrackArtwork;
- (void)disconnectToConvertCore;
- (BOOL)connectToConvertCore;
- (BOOL)convertFile:(NSString*)srcfile output:(NSString*)destfile metadata:(NSMutableDictionary*)mdata convertSpeed:(NSInteger)speed withProfile:(NSDictionary*)profile progressHandler:(void (^)(double, BOOL*))handle;
- (void)closeMusicApp;
- (BOOL)openMusicApp;
- (void)dealloc;
- (id)init;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long hash;
@property(readonly) Class superclass;

@end

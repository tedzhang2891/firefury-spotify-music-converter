//
//  Converter.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 2017/12/9.
//  Copyright © 2017年 TedZhang. All rights reserved.
//

#ifndef Converter_h
#define Converter_h

#import <Foundation/Foundation.h>

@class NSDictionary, NSImage, NSMutableDictionary, NSString;

@protocol Converter <NSObject>
+ (id)sharedMusicConverter;
@property(retain) NSImage *currentTrackArtwork;
- (BOOL)convertFile:(NSString *)srcfile output:(NSString *)outfile metadata:(NSMutableDictionary *)mdata convertSpeed:(int)speed withProfile:(NSDictionary *)profile progressHandler:(void (^)(double, BOOL*))handle;
- (void)closeMusicApp;
- (BOOL)openMusicApp;
@end

#endif /* Converter_h */

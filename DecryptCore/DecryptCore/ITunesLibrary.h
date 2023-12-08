//
//  ITunesLibrary.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 2018/1/1.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSDictionary;

__attribute__((visibility("default")))
@interface ITunesLibrary : NSObject
{
    NSDictionary *_library;
}

+ (NSString*)xmlLibraryPath;
+ (NSString*)iTunesMusicLibraryPath;
+ (NSString*)iTunesDatabaseLocationDirectory;
+ (id)sharedITuensLibrary;
//@property(retain, nonatomic) NSDictionary *library; // @synthesize library=_library;
- (void)dealloc;
- (void)reload;
- (id)library;

@end


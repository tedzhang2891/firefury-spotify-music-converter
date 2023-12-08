//
//  MediaTagUtil.h
//  FireFury Audio DRM Removal
//
//  Created by ted zhang on 2/13/18.
//  Copyright © 2018 TedZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef enum
{
    PICTURE_FORMAT_JPEG,
    PICTURE_FORMAT_PNG,
    PICTURE_FORMAT_GIF,
    PICTURE_FORMAT_UNKNOWN
} Picture_Format;

__attribute__((visibility("default")))
@interface MediaTagUtil : NSObject
{
}

+ (BOOL)writeMetadata:(id)metadata toPath:(id)filepath;
+ (NSData*)readCovr:(id)filepath;
+ (Picture_Format)getFormatData:(const void*)data andSize:(size_t)size;

@end



//
//  BackgroundView.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 2018/1/13.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

__attribute__((visibility("hidden")))
@interface BackgroundView : NSView
{
}

@property(retain) NSColor *backgroundColor; // @synthesize backgroundColor=_backgroundColor;
@property(retain) NSColor *borderColor; // @synthesize borderColor=_borderColor;
@property unsigned long long border; // @synthesize border=_border;
- (void)drawRect:(struct CGRect)rect;

@end


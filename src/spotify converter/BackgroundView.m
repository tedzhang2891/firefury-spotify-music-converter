//
//  BackgroundView.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 2018/1/13.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import "BackgroundView.h"

@implementation BackgroundView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSRect rect;
    if (self) {
        rect = [self bounds];
    }
    else {
        rect = NSMakeRect(0, 0, 0, 0);
    }
    
    NSInsetRect(rect, 1.0, 1.0);
    NSBezierPath* bezierPath = [NSBezierPath bezierPathWithRect:rect];
    if ([self border] && [self borderColor]) {
        [bezierPath setLineWidth:[self border]];
        [[self borderColor] setStroke];
        [bezierPath stroke];
    }
    
    if ([self backgroundColor]) {
        [[self backgroundColor] setFill];
        [bezierPath fill];
    }
}

@end

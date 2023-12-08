//
//  MGuideView.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 2018/1/13.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import "MGuideView.h"

@implementation MGuideView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [self updateSubGuideView];
}

- (void)updateSubGuideView { 
    NSView* superView = [self.guideView superview];
    if (self.isShowGuideView) {
        if (superView != self) {
            NSColor* white = [NSColor whiteColor];
            [self setBackgroundColor:white];
            [self addSubview:self.guideView];
            [self.guideView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            /*
            NSDictionary* viewDict = @{@"guideView": self.guideView};
            
            id layout = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[guideView]-0-|" options:0 metrics:nil views:viewDict];
            [self addConstraint:layout];
            
            layout = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[guideView]-0-|" options:0 metrics:nil views:viewDict];
            [self addConstraint:layout];
            */
        }
    }
    else if (superView) {
        [self.guideView removeFromSuperview];
    }
}

@dynamic isShowGuideView;
- (BOOL)isShowGuideView {
    return _isShowGuideView;
}

- (void)setIsShowGuideView:(BOOL)isShowGuideView {
    _isShowGuideView = isShowGuideView;
    [self updateSubGuideView];
}

@end

//
//  MGuideView.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 2018/1/13.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import "BackgroundView.h"

__attribute__((visibility("hidden")))
@interface MGuideView : BackgroundView
{
    BOOL _isShowGuideView;
}

@property (weak) IBOutlet NSView * guideView; // @synthesize guideView=_guideView;
@property(getter=isShowGuideView, setter=setIsShowGuideView:) BOOL isShowGuideView; // @synthesize isShowGuideView=_isShowGuideView;
- (void)drawRect:(struct CGRect)dirtyRect;
- (void)updateSubGuideView;

@end


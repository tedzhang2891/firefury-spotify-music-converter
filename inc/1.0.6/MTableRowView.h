//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSTableRowView.h"

@class NSColor;

__attribute__((visibility("hidden")))
@interface MTableRowView : NSTableRowView
{
    NSColor *_selectionColor;
}

@property(retain) NSColor *selectionColor; // @synthesize selectionColor=_selectionColor;
- (void)drawSelectionInRect:(struct CGRect)arg1;
- (long long)interiorBackgroundStyle;

@end


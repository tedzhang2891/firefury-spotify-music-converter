//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "MTableHeaderCell.h"

@class NSButtonCell, NSColor;

__attribute__((visibility("hidden")))
@interface CheckboxTableHeaderCell : MTableHeaderCell
{
    NSButtonCell *_checkboxCell;
    NSColor *bkColor;
}

- (void)drawWithFrame:(struct CGRect)arg1 inView:(id)arg2;
- (void)setChecked:(BOOL)arg1;
- (BOOL)isChecked;
- (void)dealloc;
- (id)initTextCell:(id)arg1;

@end


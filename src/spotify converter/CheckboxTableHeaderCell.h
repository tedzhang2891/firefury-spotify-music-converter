//
//  CheckboxTableHeaderCell.h
//  spotify converter
//
//  Created by ted zhang on 8/9/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

__attribute__((visibility("hidden")))
@interface CheckboxTableHeaderCell : NSTableHeaderCell
{
    NSButtonCell *_checkboxCell;
    NSColor *bkColor;
}

- (void)drawWithFrame:(struct CGRect)rect inView:(id)view;
- (void)setChecked:(BOOL)bState;
- (BOOL)isChecked;
- (id)initTextCell:(id)text;

@end



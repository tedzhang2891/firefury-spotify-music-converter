//
//  CheckboxTableHeaderCell.m
//  spotify converter
//
//  Created by ted zhang on 8/9/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "CheckboxTableHeaderCell.h"

@implementation CheckboxTableHeaderCell


- (void)drawWithFrame:(struct CGRect)rect inView:(id)view {
    CGRect inRect = rect;
    [super drawWithFrame:rect inView:view];
    [self->_checkboxCell cellSizeForBounds:rect];
    double diff = (rect.size.width - rect.origin.x) * 0.5;
    //inRect.size.width = rect.origin.x;
    inRect.size.width = rect.size.height;
    inRect.origin.x = 0;
    //inRect.origin.x = (diff - 2.0) + inRect.origin.x;
    [self->_checkboxCell drawWithFrame:inRect inView:view];
}

- (void)setChecked:(BOOL)bState { 
    [self->_checkboxCell setState:bState];
}

- (BOOL)isChecked { 
    return [self->_checkboxCell state];
}

- (id)initTextCell:(id)text { 
    if (self = [super initTextCell:text]) {
        self->bkColor = nil;
        NSButtonCell* btnCell = [[NSButtonCell alloc] initTextCell:@""];
        self->_checkboxCell = btnCell;
        [btnCell setButtonType:NSButtonTypeSwitch];
        [self->_checkboxCell setBordered:NO];
        [self->_checkboxCell setImagePosition:NSImageRight];
        [self->_checkboxCell setAlignment:NSTextAlignmentLeft];
        [self->_checkboxCell setControlSize:NSControlSizeRegular];
    }
    return self;
}

@end

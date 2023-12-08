//
//  MTableView.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 2018/1/13.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import "MTableView.h"

@implementation MTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)highlightSelectionInClipRect:(struct CGRect)rect {
    NSRange rowRange = [self rowsInRect:rect];
    NSUInteger start = rowRange.location;
    NSUInteger end = rowRange.location + rowRange.length;
    if (self.selectionColor) {
        [self.selectionColor set];
    }
    else {
        NSColor *color = [NSColor colorWithDeviceRed:(0.8784313725490196)
                                                 green:(0.9450980392156862)
                                                 blue:(0.7019607843137254)
                                                 alpha:1.0];
        [color set];
    }
    
    while (start < end) {
        if ([self.selectedRowIndexes containsIndex:start]) {
            NSRect rect = [self rectOfRow:start];
            NSRectFill(rect);
        }
        start ++;
    }
}

- (id)_highlightColorForCell:(id)cell { 
    return nil;
}

@end

@implementation MTableRowView

- (void)drawSelectionInRect:(struct CGRect)rect { 
    if (!self.selectionColor) {
        [[NSColor highlightColor] set];
    }
    [self.selectionColor set];
    NSRectFill(rect);
}

- (long long)interiorBackgroundStyle { 
    return 0;
}

@end

@implementation MTableHeaderCell

- (void)drawWithFrame:(struct CGRect)rect highlighted:(BOOL)bHighlight inView:(id)view {
    [super drawWithFrame:rect inView:view];
    return;
    
    // FIXME: below code not work correctly.
    
    CGRect rect1, slice1, remainder1;
    CGRect rect2, slice2, remainder2;
    CGFloat width = 0.0;
    CGFloat difference = 0.0;
    
    rect1.origin = rect.origin;
    rect1.size = rect.size;
    CGRectDivide(rect1, &slice1, &remainder1, 1.0, CGRectMaxYEdge);
    
    rect2.origin = remainder1.origin;
    rect2.size = remainder1.size;
    CGRectDivide(rect2, &slice2, &remainder2, 1.0, CGRectMinYEdge);
    
    NSColor* whiteColor = [NSColor whiteColor];
    [whiteColor set];
    
    NSRectFill(remainder2);
    
    if (bHighlight) {
        NSColor* deviceWhitecolor = [NSColor colorWithDeviceWhite:0.0 alpha:0.1];
        [deviceWhitecolor set];
        NSRectFillUsingOperation(remainder2, NSCompositingOperationSourceOver);
    }
    
    NSColor* color = [NSColor colorWithDeviceRed:0.8392156862745098 green:0.8392156862745098 blue:0.8392156862745098 alpha:1.0];
    [color set];
    NSRectFill(slice1);
    NSRectFill(slice2);
    CGRectInset(remainder2, 0.0, 1.0);
    
    NSFont* font = [NSFont boldSystemFontOfSize:12.0];
    NSColor* textColor = [self textColor];
    NSDictionary* fontDict = @{ NSFontAttributeName: font };
    NSString* stringVal = [self stringValue];
    if (stringVal) {
        [stringVal boundingRectWithSize:remainder2.size options:NSStringDrawingTruncatesLastVisibleLine attributes:fontDict];
        width = remainder2.size.width;
    }
    else {
        width = 0.0;
    }
    
    difference = remainder2.size.width - width;
    if (difference > 0.0) {
        remainder2.size.width = remainder2.size.width - difference;
        remainder2.origin.y = difference * 0.5 + remainder2.origin.y;
    }
    remainder2.origin.x = remainder2.origin.x + 5.0;
    remainder2.size.height = remainder2.size.height - 5.0;
    
    [self drawInteriorWithFrame:remainder2 inView:view];
    if (![stringVal isEqualToString:@"Title"]) {
        // FIXME: I don't know what string should equal to.
        NSColor* lightGrayColor = [NSColor lightGrayColor];
        [lightGrayColor set];
        CGRect bound;
        bound.size.width = rect.size.width - 4.0;
        bound.origin.y = 40;
        bound.origin.x = rect.origin.x + rect.size.height - 1.0;
        NSRectFill(bound);
    }
}

- (void)drawWithFrame:(struct CGRect)rect inView:(id)view {
    [self drawWithFrame:rect highlighted:NO inView:view];
}

- (void)highlight:(BOOL)bHightlight withFrame:(struct CGRect)rect inView:(id)view { 
    [self drawWithFrame:rect highlighted:bHightlight inView:view];
}

@end

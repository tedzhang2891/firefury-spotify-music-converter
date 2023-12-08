//
//  MTableView.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 2018/1/13.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// TableView
__attribute__((visibility("hidden")))
@interface MTableView : NSTableView
{
}

@property(retain) NSColor *selectionColor; // @synthesize selectionColor=_selectionColor;
- (void)highlightSelectionInClipRect:(struct CGRect)rect;
- (id)_highlightColorForCell:(id)cell;

@end


// TableRowView
__attribute__((visibility("hidden")))
@interface MTableRowView : NSTableRowView
{
}

@property(retain) NSColor *selectionColor; // @synthesize selectionColor=_selectionColor;
- (void)drawSelectionInRect:(struct CGRect)rect;
- (long long)interiorBackgroundStyle;

@end


// TableHeaderCell
__attribute__((visibility("hidden")))
@interface MTableHeaderCell : NSTableHeaderCell
{
}

- (void)highlight:(BOOL)bHightlight withFrame:(struct CGRect)rect inView:(id)view;
- (void)drawWithFrame:(struct CGRect)rect inView:(id)view;
- (void)drawWithFrame:(struct CGRect)rect highlighted:(BOOL)bHighlight inView:(id)view;

@end

//
//  HistoryWindowController.h
//  FireFury Audio DRM Removal
//
//  Created by ted zhang on 2018/1/23.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class NSMutableDictionary, NSOutlineView, NSString;

__attribute__((visibility("hidden")))
@interface HistoryWindowController : NSWindowController <NSWindowDelegate>
{
    //NSOutlineView *historyOutlineView;
    //NSMutableDictionary *records;
    //NSMutableDictionary *historyLibrary;
}
@property (weak) IBOutlet NSOutlineView *historyOutlineView;
@property (strong) IBOutlet NSArrayController *historyRecords;
@property (strong) NSMutableDictionary *records;
@property (strong) NSMutableDictionary *historyLibrary;

- (void)keyDown:(NSEvent *)event;
- (void)removeRecordFromList:(NSArray*)array;
- (IBAction)btnDeleteFromList:(id)sender;
- (IBAction)btnShowInFinder:(id)sender;
- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item;
- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (void)windowWillClose:(NSNotification *)notification;
- (void)runModal;
- (BOOL)addConvertedItem:(NSMutableDictionary*)record destinationPath:(NSString*)path;
- (id)convertedTrackURLs;
- (void)removeItemsFromFile:(id)items;
- (BOOL)loadHistoryRecordFile;
- (NSString*)historyRecordFilePath;
- (NSString*)dateStringFromDateTime:(NSDate*)dateTime;
- (void)dealloc;
- (void)awakeFromNib;
- (id)init;
- (void)showGuideView:(BOOL)bShow;

// Remaining properties
//@property(readonly, copy) NSString *debugDescription;
//@property(readonly, copy) NSString *description;
//@property(readonly) unsigned long long hash;
//@property(readonly) Class superclass;

@end


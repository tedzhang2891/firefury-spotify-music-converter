//
//  AppController.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 1/11/18.
//  Copyright © 2018 TedZhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AddWindowControllerProtocol.h"

@class BadgeNumberButton, HistoryWindowController, MTableView, ProductController, ProgressWindowController;

__attribute__((visibility("hidden")))
@interface AppController : NSWindowController <NSApplicationDelegate, NSWindowDelegate, NSTableViewDelegate>
{
    //NSView *titleBarView;
    //NSView *bottomBarView;
    ProgressWindowController *progressWindowController;
    HistoryWindowController *historyWindowController;
    ProductController *productController;
    //MTableView *convertTableView;
    NSMutableArray *convertItems;
    id <AddWindowControllerProtocol> addWindowController;
    //NSTextField *appTitleField;
    //NSTextField *audioInfoField;
    //NSButton *buyButton;
    //NSButton *unregisterButton;
    //NSButton *guideAddButton;
    //NSButton *convertButton;
    //BadgeNumberButton *historyButton;
}
@property (weak) IBOutlet NSTextField *appTitleField;
@property (weak) IBOutlet NSTextField *audioInfoField;
@property (weak) IBOutlet NSView *titleBarView;
@property (weak) IBOutlet NSView *bottomBarView;
@property (weak) IBOutlet MTableView *convertTableView;
@property (weak) IBOutlet NSButton *guideAddButton;
@property (weak) IBOutlet NSButton *unregisterButton;
@property (weak) IBOutlet NSButton *buyButton;
@property (weak) IBOutlet NSButton *convertButton;
@property (strong) IBOutlet NSArrayController *convertItemsController;


+ (NSFont*)fontForSize:(double)fontSize;
+ (void)initialize;
- (void)keyDown:(id)sender;
- (IBAction)history:(id)sender;
- (IBAction)convert:(id)sender;
- (IBAction)remove:(id)sender;
- (IBAction)add:(id)sender;
- (IBAction)settings:(id)sender;
- (IBAction)buyOnline:(id)sender;
- (IBAction)registerApp:(id)sender;
- (IBAction)openLogFolder:(id)sender;
- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (id)tableView:(id)view objectValueForTableColumn:(id)column row:(NSInteger)row;
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row;
- (void)drawSelectionInRect:(NSRect)dirtyRect;
- (long long)numberOfRowsInTableView:(id)sender;
- (void)updateMediaInfo;
- (BOOL)validateUserInterfaceItem:(id)sender;
- (void)userDidFinishRegister:(id)sender;
- (void)injectDidFailure:(id)sender;
- (void)applicationWillTerminate:(id)sender;
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender;
- (struct CGRect)window:(id)sender willPositionSheet:(id)sheet usingRect:(struct CGRect)rect;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;
- (void)showGuideView:(BOOL)bflag;
- (void)awakeFromNib;
- (void)dealloc;
- (id)init;
- (IBAction)openPerferences:(id)sender;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) NSUInteger hash;
@property(readonly) Class superclass;

@end


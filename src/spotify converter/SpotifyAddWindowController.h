//
//  SpotifyAddWindowController.h
//  spotify converter
//
//  Created by ted zhang on 8/1/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AddWindowControllerProtocol.h"
#import "DropViewDelegateProtocol.h"
#import "MGuideView.h"

__attribute__((visibility("hidden")))
@interface SpotifyAddWindowController : NSWindowController <AddWindowControllerProtocol, DropViewDelegate>
{
    //NSTableView *tracksTableView;
    //NSTextField *spotifyURLField;
    //NSButton *hiddenConvertedButton;
    NSRegularExpression *spotifyURLRegex;
    NSRegularExpression *spotifyURIRegex;
    long long pasteboardChangeCount;
    NSTimer *watchPasteboardTimer;
    void(^sheetCompleteHandler)(NSArray*);
    NSMutableArray *trackCheckStates;
}
@property (weak) IBOutlet NSTextField *spotifyURLField;
@property (weak) IBOutlet NSTableView *tracksTableView;
@property (weak) IBOutlet NSButton *hiddenConvertedButton;
@property BOOL isParsingURI;
@property(retain) IBOutlet NSArrayController *tracksArrayController;
@property(retain) IBOutlet MGuideView *guideView;
@property(retain) IBOutlet NSArray *convertedTrackURLs;
- (BOOL)validateUserInterfaceItem:(id)item;
- (void)keyDown:(NSEvent *)event;
- (void)closeSheetWithCode:(unsigned long long)code;
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)uncheckSelectedTrack:(id)track;
- (IBAction)checkSelectedTrack:(id)track;
- (void)updateTrackCheckState:(BOOL)state withIndexSet:(id)indexset;
- (void)setAllTrackCheckState:(BOOL)state;
- (void)updateAllCheckState;
- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)getTrackInfoForInfoString:(NSString*)info;
- (id)getTrackInfoForJson:(id)json;
- (NSArray*)getTrackInfosFromHTML:(NSMutableString*)html;
- (void)querySpotifyURI:(id)URI completeHandler:(void (^)(id, long))handler;
- (void)URIDidReceived:(id)URIs forURL:(id)url;
- (IBAction)btnHiddenConvert:(id)sender;
- (IBAction)btnParseURL:(id)sender;
- (void)beginSheetWithCompleteHandler:(void(^)(NSArray*))handler;
- (void)setTracks:(id)tracks;
- (void)watchPasteboardForSpotifyURL;
- (id)parseSpotifyContent:(id)arg1;
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context;
- (void)showGuideView:(BOOL)bShow;
- (void)awakeFromNib;
- (SpotifyAddWindowController*)init;
- (NSString*)windowNibName;


@end



//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "NSWindowController.h"

#import "AddWindowControllerProtocol.h"
#import "DropViewDelegate.h"

@class NSArray, NSArrayController, NSButton, NSMutableArray, NSRegularExpression, NSString, NSTableView, NSTextField, NSTimer, NSView;

__attribute__((visibility("hidden")))
@interface SpotifyAddWindowController : NSWindowController <AddWindowControllerProtocol, DropViewDelegate>
{
    NSTableView *tracksTableView;
    NSTextField *spotifyURLField;
    NSButton *hiddenConvertedButton;
    NSRegularExpression *spotifyURLRegex;
    NSRegularExpression *spotifyURIRegex;
    long long pasteboardChangeCount;
    NSTimer *watchPasteboardTimer;
    CDUnknownBlockType sheetCompleteHandler;
    NSMutableArray *trackCheckStates;
    BOOL _isParsingURI;
    NSArray *_convertedTrackURLs;
    NSView *_guideView;
    NSArrayController *_tracksArrayController;
}

@property BOOL isParsingURI; // @synthesize isParsingURI=_isParsingURI;
@property(retain) NSArrayController *tracksArrayController; // @synthesize tracksArrayController=_tracksArrayController;
@property(retain) NSView *guideView; // @synthesize guideView=_guideView;
@property(retain) NSArray *convertedTrackURLs; // @synthesize convertedTrackURLs=_convertedTrackURLs;
- (BOOL)validateUserInterfaceItem:(id)arg1;
- (void)keyDown:(id)arg1;
- (void)closeSheetWithCode:(unsigned long long)arg1;
- (void)cancel:(id)arg1;
- (void)ok:(id)arg1;
- (void)uncheckSelectedTrack:(id)arg1;
- (void)checkSelectedTrack:(id)arg1;
- (void)updateTrackCheckState:(BOOL)arg1 withIndexSet:(id)arg2;
- (void)setAllTrackCheckState:(BOOL)arg1;
- (void)updateAllCheckState;
- (void)tableView:(id)arg1 didClickTableColumn:(id)arg2;
- (void)tableView:(id)arg1 setObjectValue:(id)arg2 forTableColumn:(id)arg3 row:(long long)arg4;
- (void)tableView:(id)arg1 willDisplayCell:(id)arg2 forTableColumn:(id)arg3 row:(long long)arg4;
- (id)tableView:(id)arg1 objectValueForTableColumn:(id)arg2 row:(long long)arg3;
- (long long)numberOfRowsInTableView:(id)arg1;
- (id)getTrackInfoForInfoString:(id)arg1;
- (id)getTrackInfoForJson:(id)arg1;
- (id)getTrackInfosFromHTML:(id)arg1;
- (void)querySpotifyURI:(id)arg1 completeHandler:(CDUnknownBlockType)arg2;
- (void)URIDidReceived:(id)arg1 forURL:(id)arg2;
- (void)btnHiddenConvert:(id)arg1;
- (void)btnParseURL:(id)arg1;
- (void)beginSheetWithCompleteHandler:(CDUnknownBlockType)arg1;
- (void)setTracks:(id)arg1;
- (void)watchPasteboardForSpotifyURL;
- (id)parseSpotifyContent:(id)arg1;
- (void)observeValueForKeyPath:(id)arg1 ofObject:(id)arg2 change:(id)arg3 context:(void *)arg4;
- (void)showGuideView:(BOOL)arg1;
- (void)awakeFromNib;
- (void)dealloc;
- (id)init;
- (id)windowNibName;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) unsigned long long hash;
@property(readonly) Class superclass;

@end


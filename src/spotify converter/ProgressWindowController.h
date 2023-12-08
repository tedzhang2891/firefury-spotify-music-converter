//
//  ProgressWindowController.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 1/4/18.
//  Copyright © 2018 TedZhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

__attribute__((visibility("hidden")))
@interface ProgressWindowController : NSWindowController
{
    BOOL isAbort;
    NSInteger totalCount;
    NSInteger currentIndex;
    double totalDuration;
    NSDate *beginConvertTime;
    NSArray *convertTracks;
    //NSTextField *fileNameField;
    //NSTextField *indexInfoField;
    //NSTextField *remainTimeInfoField;
    //NSProgressIndicator *convertingProgressIndicator;
    //NSProgressIndicator *singleProgressIndicator;
    //NSProgressIndicator *totalProgressIndicator;
    //NSPopUpButton *finishActionButton;
    //NSImageView *trackArtworkImageView;
    
    
    __weak IBOutlet NSTextField *fileNameField;
    __weak IBOutlet NSTextField *indexInfoField;
    __weak IBOutlet NSTextField *remainTimeInfoField;
    __weak IBOutlet NSProgressIndicator *convertingProgressIndicator;
    __weak IBOutlet NSProgressIndicator *singleProgressIndicator;
    __weak IBOutlet NSProgressIndicator *totalProgressIndicator;
    __weak IBOutlet NSPopUpButton *finishActionButton;
    __weak IBOutlet NSImageView *trackArtworkImageView;
    
}

- (void)updateConverter:(id)converter convertedDuration:(double)duration totalConvertedDuration:(double)totalDuration isRegister:(BOOL)bReg;
- (void)doFinishAction;
- (IBAction)abort:(id)sender;
- (void)finish:(BOOL)bSuccess;
- (void)convertWithTracks:(id)convertItems completeHandler:(void (^)(id, id))notifyAppController;
- (NSMutableDictionary*)metadataFromTrack:(id)track;
- (NSMutableDictionary*)profileFromPreferences;
- (BOOL)ensureEnoughDiskSpaceWithDuration:(double)duration profile:(id)proinfo;
- (id)windowNibName;

@end


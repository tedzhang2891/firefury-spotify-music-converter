//
//  PreferenceWindow.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 1/3/18.
//  Copyright © 2018 TedZhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

__attribute__((visibility("hidden")))
@interface PreferenceWindowController : NSWindowController <NSWindowDelegate>
{
    NSPopUpButton *speedPopupButton;
    NSButton *keepChapterButton;
}

+ (void)initialize;
- (IBAction)windowWillClose:(id)sender;
- (IBAction)showWindow:(id)sender;
- (IBAction)changeKeepChapterOption:(id)sender;
- (IBAction)changeOutputFormat:(id)sender;
- (IBAction)changeOutputFolder:(id)sender;
- (IBAction)openLogFolder:(id)sender;
- (void)awakeFromNib;
- (NSNibName)windowNibName;

// Remaining properties
@property(readonly, copy) NSString *debugDescription;
@property(readonly, copy) NSString *description;
@property(readonly) NSUInteger hash;
@property(readonly) Class superclass;
@property (weak) IBOutlet NSPopUpButton *speedButton;
@property (weak) IBOutlet NSButton *keepButton;

@end


//
//  AboutWindowController.h
//  Authentication
//
//  Created by ted zhang on 3/7/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ProductController;

@interface AboutWindowController : NSWindowController
{
    //id oAppNameField;
    //id oAppVersionField;
    //id oCreditsScrollView;
    //NSImageView *imgFadeTop;
    //NSImageView *imgFadeBottom;
    //NSButton *logoButton;
    NSTimer *scrollingTimer;
    //ProductController *_productController;
}
@property (weak) IBOutlet NSTextField *AppNameField;
@property (weak) IBOutlet NSTextField *AppVersionField;
@property (weak) IBOutlet NSScrollView *CreditsScrollView;
@property (weak) IBOutlet NSButton *LogoButton;
@property (weak) IBOutlet NSImageView *ImgFadeTop;
@property (weak) IBOutlet NSImageView *ImgFadeBottom;

@property ProductController *productController; // @synthesize productController=_productController;
- (void)stopScrollingAnimation;
- (void)startScrollingAnimation;
- (void)scrollOneUnit;
- (void)setScrollAmount:(float)amount;
- (void)userDidFinishRegistration:(id)sender;
- (void)goToSite:(id)sender;
- (void)windowWillClose:(NSNotification *)notification;
- (void)showWindow:(id)arg1;
- (id)init;
- (void)dealloc;

@end



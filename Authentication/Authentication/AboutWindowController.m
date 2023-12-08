//
//  AboutWindowController.m
//  Authentication
//
//  Created by ted zhang on 3/7/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "AboutWindowController.h"
#import "ProductController.h"

@interface AboutWindowController ()

@end

@implementation AboutWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (id)init { 
    if (self = [super initWithWindowNibName:@"AboutWindow" owner:self]) {
        NSWindow* superWindow = [super window];
        [superWindow center];
        [superWindow setBackgroundColor:[NSColor whiteColor]];
        
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSDictionary* plist = [mainBundle infoDictionary];
        NSString* bundleVer = plist[@"CFBundleVersion"];
        NSString* bundleName = plist[@"CFBundleName"];
        NSString* iconFile = plist[@"CFBundleIconFile"];
        NSString* licenseTo = nil;
        
        [self.AppNameField setStringValue:bundleName];
        
        if ([ProductController isRegister]) {
            NSString* regUser = [ProductController registerUser];
            licenseTo = [NSString stringWithFormat:@"License to %@", regUser];
        }
        else {
            NSNotificationCenter* sharedDefaultCenter = [NSNotificationCenter defaultCenter];
            [sharedDefaultCenter addObserver:self selector:@selector(userDidFinishRegistration:) name:@"userDidFinishRegistration" object:nil];
            licenseTo = @"";
        }
        
        NSString* version = [NSString stringWithFormat:@"Version %@\n%@", bundleVer, licenseTo];
        [self.AppVersionField setStringValue:version];
        NSString* credits = [mainBundle pathForResource:@"Credits" ofType:@"rtf"];
        NSAttributedString* attrCredits = [[NSAttributedString alloc] initWithRTF:[NSData dataWithContentsOfFile:credits options:NSDataReadingMappedAlways error:nil] documentAttributes:nil];
        id creditsView = [self.CreditsScrollView documentView];
        NSTextStorage* txtStorage = [creditsView textStorage];
        [txtStorage setAttributedString:attrCredits];
        
        NSImage* iconImg = [NSImage imageNamed:iconFile];
        [self.LogoButton setImage:iconImg];
    }
    return self;
}

- (void)showWindow:(id)sender {
    [self startScrollingAnimation];
    [super showWindow:sender];
}

- (void)windowWillClose:(NSNotification *)notification {
    [self performSelector:@selector(stopScrollingAnimation)];
}

- (void)goToSite:(id)sender { 
    if (self.productController) {
        [self.productController openWebsiteURL:self];
    }
    else {
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSDictionary* plist = [mainBundle infoDictionary];
        NSWorkspace* sharedWorkspace = [NSWorkspace sharedWorkspace];
        NSString* webSiteURL = plist[@"WebSiteURL"];
        NSURL* url = [NSURL URLWithString:webSiteURL];
        [sharedWorkspace openURL:url];
    }
}

- (void)userDidFinishRegistration:(id)sender { 
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSDictionary* plist = [mainBundle infoDictionary];
    NSString* bundleVer = plist[@"CFBundleVersion"];
    NSString* regUser = [ProductController registerUser];
    NSString* license = [NSString stringWithFormat:@"Version %@\nLicense to %@", bundleVer, regUser];
    [self.AppVersionField setStringValue:license];
}

- (void)setScrollAmount:(float)amount { 
    NSView* docView = [self.CreditsScrollView documentView];
    [docView scrollPoint:CGPointMake(0.0, amount)];
    CGRect creditsBounds;
    CGRect contentBounds;
    if (self.CreditsScrollView) {
        creditsBounds = [self.CreditsScrollView bounds];
    }
    else {
        creditsBounds = CGRectMake(0.0, 0.0, 0.0, 0.0);
    }
    
    NSWindow* superWindow = [super window];
    NSView* contentView = [superWindow contentView];
    if (contentView) {
        contentBounds = [contentView convertRect:creditsBounds fromView:self.CreditsScrollView];
    }
    else {
        contentBounds = CGRectMake(0.0, 0.0, 0.0, 0.0);
    }
    
    [contentView setNeedsDisplayInRect:contentBounds];
}

- (void)scrollOneUnit {
    float y = 0.0;
    float height = 0.0;
    CGRect creditsBounds;
    CGRect docviewFrame;
    double amount = 0.0;
    if (self.CreditsScrollView) {
        creditsBounds = [self.CreditsScrollView documentVisibleRect];
        y = creditsBounds.origin.y;
    }
    else {
        creditsBounds = CGRectMake(0.0, 0.0, 0.0, 0.0);
        y = 0.0;
    }
    
    NSView* docView = [self.CreditsScrollView documentView];
    if (docView) {
        docviewFrame = [docView frame];
        height = docviewFrame.size.height - 200.0;
    }
    else {
        docviewFrame = CGRectMake(0.0, 0.0, 0.0, 0.0);
        height = -200.0;
    }

    if (y < height) {
        amount = y + 1.5;
    }
    else {
        amount = 0.0;
    }
    [self setScrollAmount:amount];
}

- (void)startScrollingAnimation { 
    if (!self->scrollingTimer) {
        [self setScrollAmount:0.0];
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.06 target:self selector:@selector(scrollOneUnit) userInfo:nil repeats:YES];
        self->scrollingTimer = timer;
    }
}

- (void)stopScrollingAnimation { 
    [self->scrollingTimer invalidate];
    self->scrollingTimer = nil;
}

@end

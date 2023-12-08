//
//  RegisterWindowController.h
//  Authentication
//
//  Created by ted zhang on 3/7/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RegCodeController;

@interface RegisterWindowController : NSWindowController
{
    id degelate;
}
@property (weak) IBOutlet NSImageView *logo;
@property (weak) IBOutlet NSTextField *descriptionField;
@property (weak) IBOutlet NSTextField *userID;
@property (weak) IBOutlet NSTextField *userKey;
@property (weak) IBOutlet NSButton *registerBtn;
@property (weak) IBOutlet NSButton *buyBtn;
@property (weak) IBOutlet NSButton *cancelBtn;

+ (BOOL)isLicenseCodeValid:(id)userKey forUser:(id)userID;
- (void)openOrderURL:(id)url;
- (void)enterLicenseCode:(id)data;
- (void)setDegelate:(id)obj;
- (id)init;

@end



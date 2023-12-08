//
//  RegisterWindowController.m
//  Authentication
//
//  Created by ted zhang on 3/7/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "RegisterWindowController.h"
#import "ProductController.h"
#import "RegCodeController.h"

@interface RegisterWindowController ()

@end

@implementation RegisterWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (id)init { 
    if (self = [super initWithWindowNibName:@"RegisterWindow" owner:self]) {
        NSWindow* superWindow = [super window];
        [superWindow center];
        
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSDictionary* plist = [mainBundle infoDictionary];
        NSString* iconFile = plist[@"CFBundleIconFile"];
        NSImage* iconImg = [NSImage imageNamed:iconFile];
        [self.logo setImage:iconImg];
        
        NSString* bundleName = plist[@"CFBundleName"];
        NSString* description = [self.descriptionField stringValue];
        NSString* info = [NSString stringWithFormat:description, bundleName];
        [self.descriptionField setStringValue:info];
        
        if ([ProductController isRegister]) {
            NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
            NSString* userID = [sharedUserDefaults objectForKey:@"UserID"];
            [self.userID setStringValue:userID];
            [self.userID setEditable:NO];
            
            NSString* userKey = [sharedUserDefaults objectForKey:@"UserKey"];
            [self.userKey setStringValue:userKey];
            [self.userKey setEditable:NO];
            
            [self.registerBtn setEnabled:NO];
            [self.buyBtn setEnabled:NO];
            [self.cancelBtn setTitle:@"Thank You!"];
        }
    }
    return self;
}

- (void)setDegelate:(id)obj { 
    self->degelate = obj;
}

- (void)enterLicenseCode:(id)data {
    NSString* userID = [self.userID stringValue];
    NSString* userKey = [self.userKey stringValue];
    BOOL isLicenseValid = [RegisterWindowController isLicenseCodeValid:userKey forUser:userID];
    
    NSAlert* anAlert = [[NSAlert alloc] init];
    [anAlert addButtonWithTitle:@"OK"];
    [anAlert setAlertStyle:NSAlertStyleWarning];
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* information = nil;
    
    if (isLicenseValid) {
        NSString* msg = [bundle localizedStringForKey:@"Registration Successful!" value:nil table:nil];
        [anAlert setMessageText:msg];
        
        information = [bundle localizedStringForKey:@"Thank you for purchase, if you have any problem, please contact us via Email." value:nil table:nil];
    }
    else {
        NSString* msg = [bundle localizedStringForKey:@"Invalid Registration Information!" value:nil table:nil];
        [anAlert setMessageText:msg];
        
        information = [bundle localizedStringForKey:@"Simple copy and paste your email address and product key exactly as it appears in the confirmation email." value:nil table:nil];
    }
    
    [anAlert setInformativeText:information];
    [anAlert beginSheetModalForWindow:[self window] completionHandler:^(NSModalResponse returnCode) {
        if (isLicenseValid) {
            NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
            [sharedUserDefaults setObject:userID forKey:@"UserID"];
            [sharedUserDefaults setObject:userKey forKey:@"UserKey"];
            [self.userID setEditable:NO];
            [self.userKey setEditable:NO];
            [self close];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userDidFinishRegistration" object:userID];
        }
    }];
}

- (void)openOrderURL:(id)url { 
    if (self->degelate) {
        [self->degelate openOrderURL:url];
    }
}

+ (BOOL)isLicenseCodeValid:(id)userKey forUser:(id)userID {
    //NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    NSCharacterSet* filter = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSString* cleanUserID = [userID stringByTrimmingCharactersInSet:filter];
    //const char* encodedUserID = [cleanUserID cStringUsingEncoding:NSUTF8StringEncoding];
    NSString* cleanUserKey = [userKey stringByTrimmingCharactersInSet:filter];
    //const char* encodedUserKey = [cleanUserKey cStringUsingEncoding:NSUTF8StringEncoding];
    
    RegCodeController* verifier = [[RegCodeController alloc] init];
    
    // Modelled after AquaticPrime's method of splitting public key to obfuscate it.
    // It is probably better if you invent your own splitting pattern. Go wild.
    NSMutableString *pubKeyBase64 = [NSMutableString string];
    [pubKeyBase64 appendString:@"MIIBtjCCASs"];
    [pubKeyBase64 appendString:@"GByqGSM44BAEwggEeAoGBAL+VrN8HeL5s3KI4BPmNdxb3"];
    [pubKeyBase64 appendString:@"bUfW+pQ/\n"];
    [pubKeyBase64 appendString:@"mIW"];
    [pubKeyBase64 appendString:@"s3ndd58mkESM8w5IrUR7AuH"];
    [pubKeyBase64 appendString:@"8ywNlAkWxQZxyjgGjRx/PYfXcuwT0r0NQwSdya\n"];
    [pubKeyBase64 appendString:@"EhhOxfTYpRwe75EuZrDB9kqk1pv"];
    [pubKeyBase64 appendString:@"EYHouCGTidYmQaEknMpfUBI6o"];
    [pubKeyBase64 appendString:@"gCGu8HedDDtc\n"];
    [pubKeyBase64 appendString:@"uxv6WYOsS4v/AhUA+JfQi0fz8CRofQpfjegsrh"];
    [pubKeyBase64 appendString:@"NG9YMCgYACU9n9g2Eg/"];
    [pubKeyBase64 appendString:@"Ga8rmq6\n"];
    [pubKeyBase64 appendString:@"ZEdHwlrOzGzpoO6Me94mLoSYr"];
    [pubKeyBase64 appendString:@"lD6bJ6v6Cnfkn1j4rPoHyoXDR7lCIAyAqVHJx"];
    [pubKeyBase64 appendString:@"33\n"];
    [pubKeyBase64 appendString:@"+sOQKY5/FoHU"];
    [pubKeyBase64 appendString:@"jO9FsPiY5kHF56+g2sdnpqDJBdLUDEB3"];
    [pubKeyBase64 appendString:@"Z3snZGqF7z6hMsKsibXD\n"];
    [pubKeyBase64 appendString:@"mJS9k0mwN6RYyTIuBA"];
    [pubKeyBase64 appendString:@"HuFFo6jwOBhAACgYB26hrsP88bltiuELM"];
    [pubKeyBase64 appendString:@"jxLNhTnn2/BiY\n"];
    [pubKeyBase64 appendString:@"kCpuoB9KPkn31JU8OAH5pJctqL"];
    [pubKeyBase64 appendString:@"m+pbB2nkJrK1PCJBhvGw"];
    [pubKeyBase64 appendString:@"2vdejA9JSc0oj7L50l\n"];
    [pubKeyBase64 appendString:@"DyrKVeN"];
    [pubKeyBase64 appendString:@"oZ6sId9d4BTzaPY+l9PH26uCVhYJQYu+W0MmU"];
    [pubKeyBase64 appendString:@"dj8slR52ZbUNPLDZBVDd\n"];
    [pubKeyBase64 appendString:@"vFrsZkYQpqPkYA=="];
    
    
    NSString* pubkey = [RegCodeController completePublicKeyPEM:pubKeyBase64];
    
    NSError *error = nil;
    BOOL result = [verifier setPublicKey:pubkey error:&error];
    if (!result) {
        NSLog(@"Must be able to set public key in license verifier.");
    }
    else {
        result = [verifier verifyRegCode:cleanUserKey forName:cleanUserID error:&error];
    }
    return result;
}

@end

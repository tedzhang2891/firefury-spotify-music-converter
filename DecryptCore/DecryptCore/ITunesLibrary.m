//
//  ITunesLibrary.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 2018/1/1.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import "ITunesLibrary.h"
#import <AppKit/AppKit.h>

@implementation ITunesLibrary

static ITunesLibrary* _instance = nil;

- (void)reload { 
    NSString* xmlLibraryPath = [ITunesLibrary xmlLibraryPath];
    NSDictionary* xmlLibraryDict = [NSDictionary dictionaryWithContentsOfFile:xmlLibraryPath];
    _library = xmlLibraryDict;
}

+ (NSString*)iTunesDatabaseLocationDirectory {
    NSError* error = nil;
    NSString* path;
    NSFileManager* sharedFileManager = [NSFileManager defaultManager];
    CFPropertyListRef propertylist = CFPreferencesCopyAppValue(CFSTR("Database Location"), CFSTR("com.apple.iTunes"));

    if ([(__bridge id)(propertylist) isKindOfClass:[NSData class]]) {
        BOOL bStale = NO;
        NSURL* url = [NSURL URLByResolvingBookmarkData:(__bridge NSData * _Nonnull)(propertylist) options:NSURLBookmarkResolutionWithoutUI relativeToURL:nil bookmarkDataIsStale:&bStale error:&error];
        
        if (bStale || error) {
            NSLog(@"iTunes Library Database Location bookarmIsStale:%d, %@", bStale, error);
            return nil;
        }
        path = [url path];
    }
    else if ([(__bridge id)(propertylist) isKindOfClass:[NSURL class]]) {
        path = [(__bridge id)(propertylist) path];
    }
    else if ([(__bridge id)(propertylist) isKindOfClass:[NSString class]]) {
        path = [[NSURL URLWithString:(__bridge id)(propertylist)] path];
    }
    
    if (!path) {
        return nil;
    }
    BOOL isDir;
    NSString* lastComponent = [path stringByDeletingLastPathComponent];
    BOOL isExists = [sharedFileManager fileExistsAtPath:lastComponent isDirectory:&isDir];
    if (!isDir || !isExists) {
        lastComponent = nil;
    }
    return lastComponent;
}

+ (id)sharedITuensLibrary { 
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance;
}

+ (NSString*)iTunesMusicLibraryPath {
    BOOL isExists = NO;
    NSString* libraryXML = nil;
    NSFileManager* sharedFileManager = [NSFileManager defaultManager];
    NSString* libraryPath = [ITunesLibrary iTunesDatabaseLocationDirectory];
    if (libraryPath) {
        libraryXML = [libraryPath stringByAppendingPathComponent:@"iTunes Music Library.xml"];
        isExists = [sharedFileManager fileExistsAtPath:libraryXML];
    }
    
    if (!isExists) {
        CFArrayRef itunesDatabase = CFPreferencesCopyAppValue(CFSTR("iTunesRecentDatabases"), CFSTR("com.apple.iTunes"));
        
        for (id obj in (__bridge id)itunesDatabase) {
            NSURL* url = [NSURL URLWithString:obj];
            if (url) {
                NSString* path = [url path];
                if ([sharedFileManager fileExistsAtPath:path]) {
                    libraryXML = path;
                    break;
                }
            }
        }
    }
    
    return libraryXML;
}

+ (NSString*)xmlLibraryPath {
    NSString* itunesLibraryDirectory = [ITunesLibrary iTunesDatabaseLocationDirectory];
    NSString* libraryXML = nil;
    NSFileManager* sharedFileManager = [NSFileManager defaultManager];
    if (itunesLibraryDirectory) {
        libraryXML = [itunesLibraryDirectory stringByAppendingPathComponent:@"iTunes Library.xml"];
        if (libraryXML) {
            if ([sharedFileManager fileExistsAtPath:libraryXML]) {
                return libraryXML;
            }
        }
    }
    NSString* itunesLibraryPath = [ITunesLibrary iTunesMusicLibraryPath];
    if (itunesLibraryPath) {
        libraryXML = [[itunesLibraryPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"iTunes Music Library.xml"];
        if ([sharedFileManager fileExistsAtPath:libraryXML]) {
            return libraryXML;
        }
        else {
            NSString* libraryITL = [itunesLibraryDirectory stringByAppendingPathComponent:@"iTunes Library.itl"];
            id attrPath = [sharedFileManager attributesOfItemAtPath:itunesLibraryPath error:nil];
            id attrITL = [sharedFileManager attributesOfItemAtPath:libraryITL error:nil];
            if (!attrPath || !attrITL) {
                return libraryXML;
            }
            NSDate* datePath = [attrPath fileModificationDate];
            NSDate* dateITL = [attrITL fileModificationDate];
            
            NSTimeInterval timeInt = [dateITL timeIntervalSinceDate:datePath];
            if (timeInt < 86400.0f) {
                return libraryITL;
            }
            NSLog(@"itl modification date is differ with xml date, %@, %@", dateITL, datePath);
        }
    }
    NSBundle* bundle = [NSBundle bundleWithPath:@"/Applications/iTunes.app"];
    NSString* value = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    if (NSOrderedAscending == [value compare:@"12.2.0" options:NSNumericSearch]) {
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSAlert* anAlert = [[NSAlert alloc] init];
        anAlert.messageText = [mainBundle localizedStringForKey:@"Can not find iTunes Music Library location" value:nil table:nil];
        anAlert.informativeText = [mainBundle localizedStringForKey:@"We need iTunes music library location for read information from iTunes, you can change this location in iTunes Preferences." value:nil table:nil];
        [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"Locate File" value:nil table:nil]];
        [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"Cancel" value:nil table:nil]];
        NSUInteger action = [anAlert runModal];
        // Response button event of the window
        if (action == NSModalResponseOK) {
            NSOpenPanel* openPanel = [NSOpenPanel openPanel];
            [openPanel setAllowsMultipleSelection:NO];
            [openPanel setCanChooseDirectories:NO];
            NSArray* ext = @[@"xml"];
            [openPanel setAllowedFileTypes:ext];
            if ([openPanel runModal] == NSModalResponseOK) {
                NSURL* url = [openPanel URL];
                libraryXML = [url path];
            }
        }
    }
    else {
        // TODO: MITunesSettingGuideWindowController
    }
    
    return libraryXML;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [ITunesLibrary sharedITuensLibrary] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [ITunesLibrary sharedITuensLibrary] ;
}

- (void)dealloc { 
    
}

- (id)library {
    if (!_library) {
        [self reload];
    }
    return _library;
}

@end

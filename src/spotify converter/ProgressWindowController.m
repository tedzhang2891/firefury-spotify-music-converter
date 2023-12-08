//
//  ProgressWindowController.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 1/4/18.
//  Copyright © 2018 TedZhang. All rights reserved.
//

#import "ProgressWindowController.h"
#import <ProductionAuthentication/Authentication.h>
#import <DecryptCore/DecryptCore.h>
#import "SystemComm.h"

@interface ProgressWindowController ()

@end

@implementation ProgressWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (id)windowNibName { 
    return (id)@"ProgressWindow";
}

- (BOOL)ensureEnoughDiskSpaceWithDuration:(double)duration profile:(id)proinfo {
    NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString* outputFolder = [sharedUserDefaults objectForKey:@"PreferenceOutputFolderKey"];
    NSFileManager* sharedFileManager = [NSFileManager defaultManager];
    NSBundle* mainBundle = [NSBundle mainBundle];
    
    id attr = [sharedFileManager attributesOfFileSystemForPath:outputFolder error:nil];
    if ([sharedFileManager fileExistsAtPath:outputFolder]) {
        if (![sharedFileManager isWritableFileAtPath:outputFolder]) {
            NSAlert* anAlert = [[NSAlert alloc] init];
            anAlert.messageText = [mainBundle localizedStringForKey:@"The output folder is read-only!" value:nil table:nil];
            anAlert.informativeText = [mainBundle localizedStringForKey:@"Change the output folder access permission or choose another output folder!" value:nil table:nil];
            [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"OK" value:nil table:nil]];
            [anAlert runModal];
            return NO;
        }
    }
    else {
        [sharedFileManager createDirectoryAtPath:outputFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSNumber* freeSize = [attr objectForKey:NSFileSystemFreeSize];
    NSUInteger ufreeSize = [freeSize unsignedIntegerValue];
    NSNumber* bitrate = [proinfo objectForKeyedSubscript:@"ConvertProfileBitrateKey"];
    
    if (([bitrate integerValue] * duration + 52428800.0) /*50MB*/ > (ufreeSize /*/ 1024 / 1024*/)) {

        NSAlert* anAlert = [[NSAlert alloc] init];
        anAlert.messageText = [mainBundle localizedStringForKey:@"Disk space is not enough!" value:nil table:nil];
        anAlert.informativeText = [mainBundle localizedStringForKey:@"There is not enough disk space in your output volume,please check it out and try again!" value:nil table:nil];
        [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"OK" value:nil table:nil]];
        [anAlert runModal];
        return NO;
    }
    
    return YES;
}

- (NSMutableDictionary*)profileFromPreferences { 
    int profileKey = 2;
    NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* profile = [NSMutableDictionary dictionary];
    NSInteger outputFormat = [sharedUserDefaults integerForKey:@"PreferenceOutputFormatKey"];
    
    if (outputFormat >= 1 && outputFormat <= 4) {
        [profile setObject:[NSNumber numberWithInteger:outputFormat] forKey:@"ConvertProfileCodecKey"];
    }
    
    NSInteger outputQualityKey = [sharedUserDefaults integerForKey:@"PreferenceOutputQualityKey"];
    if (outputQualityKey) {
        profileKey = (int)outputQualityKey;
    }
    
    switch (profileKey) {
        case 1:
            [profile setObject:[NSNumber numberWithInt:44100] forKeyedSubscript:@"ConvertProfileSamplerateKey"];
            [profile setObject:[NSNumber numberWithInt:2] forKeyedSubscript:@"ConvertProfileChannelKey"];
            [profile setObject:[NSNumber numberWithInt:320000] forKey:@"ConvertProfileBitrateKey"];
            break;
        
        case 2:
            [profile setObject:[NSNumber numberWithInt:44100] forKeyedSubscript:@"ConvertProfileSamplerateKey"];
            [profile setObject:[NSNumber numberWithInt:2] forKeyedSubscript:@"ConvertProfileChannelKey"];
            [profile setObject:[NSNumber numberWithInt:256000] forKey:@"ConvertProfileBitrateKey"];
            break;
            
        case 3:
            [profile setObject:[NSNumber numberWithInt:44100] forKeyedSubscript:@"ConvertProfileSamplerateKey"];
            [profile setObject:[NSNumber numberWithInt:2] forKeyedSubscript:@"ConvertProfileChannelKey"];
            [profile setObject:[NSNumber numberWithInt:128000] forKey:@"ConvertProfileBitrateKey"];
            break;
            
        case 4:
            [profile setObject:[NSNumber numberWithInt:22050] forKeyedSubscript:@"ConvertProfileSamplerateKey"];
            [profile setObject:[NSNumber numberWithInt:1] forKeyedSubscript:@"ConvertProfileChannelKey"];
            [profile setObject:[NSNumber numberWithInt:64000] forKey:@"ConvertProfileBitrateKey"];
            break;
        default:
            break;
    }
    
    return profile;
}

- (NSMutableDictionary*)metadataFromTrack:(id)track {
    NSMutableDictionary* meta = [NSMutableDictionary dictionary];
    if ([track objectForKeyedSubscript:@"Name"]) {
        [meta setObject:[track objectForKeyedSubscript:@"Name"] forKeyedSubscript:@"title"];
    }
    if ([track objectForKeyedSubscript:@"Artist"]) {
        [meta setObject:[track objectForKeyedSubscript:@"Artist"] forKeyedSubscript:@"artist"];
    }
    if ([track objectForKeyedSubscript:@"Album"]) {
        [meta setObject:[track objectForKeyedSubscript:@"Album"] forKeyedSubscript:@"album"];
    }
    if ([track objectForKeyedSubscript:@"Album Artist"]) {
        [meta setObject:[track objectForKeyedSubscript:@"Album Artist"] forKeyedSubscript:@"albumartist"];
    }
    if ([track objectForKeyedSubscript:@"Composer"]) {
        [meta setObject:[track objectForKeyedSubscript:@"Composer"] forKeyedSubscript:@"composer"];
    }
    if ([track objectForKeyedSubscript:@"Comments"]) {
        [meta setObject:[track objectForKeyedSubscript:@"Comments"] forKeyedSubscript:@"comment"];
    }
    if ([track objectForKeyedSubscript:@"Genre"]) {
        [meta setObject:[track objectForKeyedSubscript:@"Genre"] forKeyedSubscript:@"genre"];
    }
    if ([track objectForKeyedSubscript:@"Year"]) {
        [meta setObject:[NSString stringWithFormat:@"%@", [track objectForKeyedSubscript:@"Year"]] forKeyedSubscript:@"date"];
    }
    if ([track objectForKeyedSubscript:@"Track Number"]) {
        [meta setObject:[NSString stringWithFormat:@"%@", [track objectForKeyedSubscript:@"Track Number"]] forKeyedSubscript:@"track"];
    }
    if ([track objectForKeyedSubscript:@"Track Count"]) {
        [meta setObject:[NSString stringWithFormat:@"%@", [track objectForKeyedSubscript:@"Track Count"]] forKeyedSubscript:@"track count"];
    }
    if ([track objectForKeyedSubscript:@"Disc Number"]) {
        [meta setObject:[NSString stringWithFormat:@"%@", [track objectForKeyedSubscript:@"Disc Number"]] forKeyedSubscript:@"disc"];
    }
    if ([track objectForKeyedSubscript:@"Disc Count"]) {
        [meta setObject:[NSString stringWithFormat:@"%@", [track objectForKeyedSubscript:@"Disc Count"]] forKeyedSubscript:@"disc count"];
    }
    if ([track objectForKeyedSubscript:@"ArtworkURL"]) {
        [meta setObject:[NSURL URLWithString:[track objectForKeyedSubscript:@"ArtworkURL"]] forKeyedSubscript:@"artwork url"];
    }
    return meta;
}

- (void)finish:(BOOL)bSuccess {
    [convertingProgressIndicator stopAnimation:self];
    [self.window orderOut:nil];
    [NSApp endSheet:self.window returnCode:0];
    if (bSuccess) {
        [self doFinishAction];
    }
}

- (void)abort:(id)sender { 
    isAbort = YES;
    [self finish:NO];
}

- (void)doFinishAction { 
    NSInteger selTag = [finishActionButton selectedTag];
    if (selTag == 2) {
        NSAppleScript* appScript = [[NSAppleScript alloc] initWithSource:@"tell application \"Finder\" to sleep"];
        [appScript executeAndReturnError:nil];
    }
    else if (selTag == 1) {
        NSWorkspace* sharedWorkspace = [NSWorkspace sharedWorkspace];
        NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
        [sharedWorkspace selectFile:nil inFileViewerRootedAtPath:[sharedUserDefaults stringForKey:@"PreferenceOutputFolderKey"]];
    }
}

- (void)updateConverter:(id)converter convertedDuration:(double)duration totalConvertedDuration:(double)tduration isRegister:(BOOL)bReg{
    if (currentIndex >= totalCount) {
        return;
    }
    int timeOfHours = 0.0;
    NSDate* date = [NSDate date];
    NSTimeInterval convertInterval = [date timeIntervalSinceDate:beginConvertTime];
    id currentTrack = [convertTracks objectAtIndex:currentIndex];
    double itemTime = [[currentTrack objectForKeyedSubscript:@"Total Time"] doubleValue];
    itemTime /= 1000;
    
    NSInteger convertTime = itemTime;

    if (!bReg) {
        convertTime = 180.0f;
    }
    
    NSString* remains = NSLocalizedString(@"Remains",@"");
    NSString* trackName = [currentTrack objectForKeyedSubscript:@"Name"];
    [fileNameField setStringValue:trackName];
    NSString* infoField = [NSString stringWithFormat:@"%ld / %ld", currentIndex + 1, (long)totalCount];
    [indexInfoField setStringValue:infoField];
    
    timeOfHours = fmax(totalDuration - (duration + tduration), 0.0);
    if (timeOfHours >= 3601) {
        remains = [NSString stringWithFormat:@"%02d:%02d:%02d %@", timeOfHours / 3600, timeOfHours % 3600 / 60, timeOfHours % 60, NSLocalizedString(@"Remains",@"")];
    }
    else if (timeOfHours >= 61) {
        remains = [NSString stringWithFormat:@"%02d:%02d %@", timeOfHours / 60, timeOfHours % 60, NSLocalizedString(@"Remains",@"")];
    }
    else if (timeOfHours) {
        remains = [NSString stringWithFormat:@"00:%02d %@", timeOfHours % 60, NSLocalizedString(@"Remains",@"")];
    }
        
    [remainTimeInfoField setStringValue:remains];
    [singleProgressIndicator setDoubleValue:fmin(duration / convertTime, 1.0)];
    [totalProgressIndicator setDoubleValue:fmin((duration + tduration) / totalDuration, 1.0)];
    NSImage* artwork = [converter currentTrackArtwork];
    if (artwork != [trackArtworkImageView image]) {
        if (artwork) {
            [trackArtworkImageView setImage:artwork];
            [trackArtworkImageView setHidden:NO];
            [convertingProgressIndicator setHidden:YES];
        }
        else {
            [trackArtworkImageView setImage:nil];
            [trackArtworkImageView setHidden:YES];
            [convertingProgressIndicator setHidden:NO];
        }
    }
}

- (void)convertWithTracks:(id)convertItems completeHandler:(void (^)(id, id))notifyAppController {
    BOOL isRegister = [ProductController isRegister];
    
    double allTotalTime = 0;
    NSMutableArray* failedTracks = [NSMutableArray array];
    for (id item in convertItems) {
        double itemTime = [[item objectForKeyedSubscript:@"Total Time"] doubleValue];
        if (isRegister || itemTime <= 180999) {
            itemTime /= 1000;
        }
        else {
            itemTime = 180.0f;
        }
        allTotalTime = allTotalTime + itemTime;
    }
    
    MusicConverter* __block converter = nil;
    BOOL __block bServerOpen = NO;
    BOOL __block bConvertStatus = NO;
    double __block totalConvertedDuration = 0;
    
    NSMutableDictionary* profile = [self profileFromPreferences];
    if ([self ensureEnoughDiskSpaceWithDuration:allTotalTime profile:profile]) {
        convertTracks = [[NSArray alloc] initWithArray:convertItems];
        isAbort = NO;
        currentIndex = 0;
        totalCount = [convertTracks count];
        totalDuration = allTotalTime;
        [self loadWindow];
        [self updateConverter:nil convertedDuration:0.0 totalConvertedDuration:0.0 isRegister:isRegister];
        [convertingProgressIndicator startAnimation:self];
        [trackArtworkImageView setImage:nil];
        [trackArtworkImageView setHidden:YES];
        //[NSApp beginSheet:[self window] modalForWindow:[NSApp mainWindow] modalDelegate:nil didEndSelector:nil contextInfo:nil];
        [[NSApp mainWindow] beginSheet:[self window] completionHandler:nil];
        NSDate* date = [NSDate date];
        beginConvertTime = date;
        
        // Start block on global queue
        dispatch_queue_t global_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(global_queue, ^(void) {
            IOPMAssertionID assertionID = [SystemComm disableSystemSleep];
            if (!assertionID) {
                NSLog(@"Preventing system sleep failed!");
            }
            for (id track in convertTracks) {
                NSMutableDictionary* metadata = [self metadataFromTrack:track];
                NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
                NSString* outputFolder = [sharedUserDefaults stringForKey:@"PreferenceOutputFolderKey"];
                NSUUID* uuidObj = [NSUUID UUID];
                NSString* uuidStr = [uuidObj UUIDString];
                NSString* codecName = [NSString string];
                int codecKey = [[profile objectForKeyedSubscript:@"ConvertProfileCodecKey"] intValue];
                switch (codecKey) {
                    case 1:
                        codecName = @"mp3";
                        break;
                    case 2:
                        codecName = @"m4a";
                        break;
                    case 3:
                        codecName = @"flac";
                        break;
                    case 4:
                        codecName = @"wav";
                    default:
                        break;
                }
                double trackDuration = [[track objectForKeyedSubscript:@"Total Time"] doubleValue];
                trackDuration /= 1000;
                
                if (!isRegister) {
                    trackDuration = fmin(180.0f, trackDuration);
                }
                
                NSString* location = [track objectForKeyedSubscript:@"Location"];
                NSString* filepath = [[[NSURL URLWithString:location] filePathURL] path];
                if (!filepath) {
                    filepath = location;
                }
                [metadata setObject:[NSNumber numberWithInteger:trackDuration] forKeyedSubscript:@"duration"];
                NSString* lowerExts = [[filepath pathExtension] lowercaseString];
                
                
                if ([lowerExts isEqualToString:@"aa"] || [lowerExts isEqualToString:@"aax"]) {
                    // TODO: support new feature
                    NSLog(@"Not support.");
                    return;
                }
                else {
                    converter = [MusicConverter sharedMusicConverter];
                    if (!bServerOpen) {
                        bServerOpen = [converter openMusicApp];
                        
                    }
                }
                NSString* trackTitle = [metadata objectForKey:@"title"];
                //NSString* trackTitle = [ stringValue];
                //NSString* outputFile = [outputFolder stringByAppendingPathComponent:uuidStr];
                NSString* outputFile = [outputFolder stringByAppendingPathComponent:trackTitle];
                outputFile = [outputFile stringByAppendingPathExtension:codecName];
                NSInteger convertSpeed = [sharedUserDefaults integerForKey:@"PreferenceConvertSpeedKey"];
                
                void (^statusCallback)(double, BOOL*) = ^(double floatCompleted, BOOL* discription){
                    dispatch_queue_t main_queue = dispatch_get_main_queue();
                    dispatch_sync(main_queue, ^(void){
                        [self updateConverter:converter convertedDuration:floatCompleted totalConvertedDuration:(double)totalConvertedDuration isRegister:isRegister];
                        *discription = isAbort;
                    });
                };
                
                bConvertStatus = [converter convertFile:filepath output:outputFile metadata:metadata convertSpeed:(int)convertSpeed withProfile:profile progressHandler:statusCallback];
                if (!bConvertStatus) {
                    [failedTracks addObject:track];
                    NSLog(@"convert track %@ %@", location, @"failure");
                    break;
                }
                
                if (isAbort) {
                    break;
                }
                
                // write metadata
                [MediaTagUtil writeMetadata:metadata toPath:outputFile];
                
                {
                    NSLog(@"convert track %@ %@", location, @"successful");
                    // let main thread know
                    notifyAppController(track, outputFile);
                    
                    NSString* filename = [[filepath lastPathComponent] stringByDeletingPathExtension];
                    if ([sharedUserDefaults boolForKey:@"PreferenceOutputOrganizedKey"]) {
                        NSString* srcfilename = [NSString string];
                        NSString* artist = [metadata objectForKeyedSubscript:@"artist"];
                        NSString* album = [metadata objectForKeyedSubscript:@"album"];
                        if (!artist) {
                            artist = @"Unknown";
                        }
                        if (!album) {
                            album = @"Unknown";
                        }
                        
                        NSString* artist_replaced = [[artist stringByReplacingOccurrencesOfString:@"/" withString:@"|"] stringByReplacingOccurrencesOfString:@":" withString:@"|"];
                        NSCharacterSet* artistCSet = [NSCharacterSet characterSetWithCharactersInString:@"."];
                        NSString* new_artist = [artist_replaced stringByTrimmingCharactersInSet:artistCSet];
                        NSString* album_replaced = [[album stringByReplacingOccurrencesOfString:@"/" withString:@"|"] stringByReplacingOccurrencesOfString:@":" withString:@"|"];
                        NSCharacterSet* albumCSet = [NSCharacterSet characterSetWithCharactersInString:@"."];
                        NSString* new_album = [album_replaced stringByTrimmingCharactersInSet:albumCSet];
                        if ([metadata objectForKeyedSubscript:@"title"]) {
                            srcfilename = [metadata objectForKeyedSubscript:@"title"];
                        }
                        NSString* artistFolder = [outputFolder stringByAppendingPathComponent:new_artist];
                        NSString* albumFolder = [artistFolder stringByAppendingPathComponent:new_album];
                        NSFileManager* sharedFileManager = [NSFileManager defaultManager];
                        if (![sharedFileManager fileExistsAtPath:albumFolder]) {
                            [sharedFileManager createDirectoryAtPath:albumFolder withIntermediateDirectories:YES attributes:nil error:nil];
                        }
                        NSString* trackNumber = [metadata objectForKeyedSubscript:@"track"];
                        NSString* finalFileName = nil;
                        if (trackNumber) {
                            NSString* numberWithPlaceholder = [NSString stringWithFormat:@"%02d", [trackNumber intValue]];
                            if ([filename hasPrefix:numberWithPlaceholder]) {
                                finalFileName = filename;
                            }
                            else {
                                finalFileName = [NSString stringWithFormat:@"%02d %@", [trackNumber intValue], filename];
                            }
                        }
                        else {
                            finalFileName = filename;
                        }
                        
                        if ([finalFileName length] >= 251) {
                            finalFileName = [finalFileName substringToIndex:250];
                            NSString* finalFileName_replaced = [[finalFileName stringByReplacingOccurrencesOfString:@"/" withString:@"|"] stringByReplacingOccurrencesOfString:@":" withString:@"|"];
                            NSCharacterSet* finalFileNameCSet = [NSCharacterSet characterSetWithCharactersInString:@"."];
                            NSString* new_finalFileName = [finalFileName_replaced stringByTrimmingCharactersInSet:finalFileNameCSet];
                            
                            NSString* finalOutputName = [[outputFolder stringByAppendingPathComponent:new_finalFileName] stringByAppendingPathExtension:codecName];
                            if ([sharedUserDefaults boolForKey:@"PreferenceAutoRenameFileKey"]) {
                                BOOL bExistsFile = [sharedFileManager fileExistsAtPath:finalOutputName];
                                for (int index = 1; bExistsFile; index++) {
                                    finalOutputName = [finalOutputName stringByAppendingFormat:@" %d", index];
                                    bExistsFile = [sharedFileManager fileExistsAtPath:finalOutputName];
                                }
                            }
                            else if ([sharedFileManager fileExistsAtPath:finalOutputName]) {
                                [sharedFileManager removeItemAtPath:finalOutputName error:nil];
                            }
                            if ([sharedFileManager moveItemAtPath:outputFile toPath:finalOutputName error:nil]) {
                                [MediaTagUtil writeMetadata:metadata toPath:finalOutputName];
                            }
                            else {
                                NSLog(@"move file %@ to %@ failure", outputFile, finalOutputName);
                                [failedTracks addObject:track];
                            }
                            usleep(500000);
                        }
                    }
                }
                totalConvertedDuration += trackDuration;
                currentIndex ++;
            }
        
            if (converter && bServerOpen) {
                [converter closeMusicApp];
            }
            
            dispatch_queue_t global_queue = dispatch_get_main_queue();
            dispatch_async(global_queue, ^(void){
                if (isAbort) {
                    [self finish:NO];
                }
                else {
                    NSInteger nfailedTracks = [failedTracks count];
                    [self finish:(nfailedTracks < totalCount)];
                }
            });
            
            if (assertionID) {
                [SystemComm enableSystemSleep:assertionID];
            }
            
        });
    }
    else {
        bServerOpen = NO;
        converter = nil;
    }
    
    //ISSUE: below codes will cause deadlock.
    /*
    dispatch_queue_t global_queue = dispatch_get_main_queue();
    dispatch_async(global_queue, ^(void){
        if (converter && bServerOpen) {
            [converter closeMusicApp];
        }
        
        if (!bConvertStatus) {
            [self finish:NO];
        }
        else {
            [self finish:YES];
        }
    });
     */
    
    if (!isAbort && [failedTracks count]) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            NSBundle* mainBundle = [NSBundle mainBundle];
            NSAlert* anAlert = [[NSAlert alloc] init];
            anAlert.messageText = [mainBundle localizedStringForKey:@"Conversion Failure" value:nil table:nil];
            anAlert.informativeText = [mainBundle localizedStringForKey:@"%d tracks failed to convert , please retry it later." value:nil table:nil];
            [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"Retry" value:nil table:nil]];
            [anAlert addButtonWithTitle:[mainBundle localizedStringForKey:@"Cancel" value:nil table:nil]];
            NSUInteger action = [anAlert runModal];
            // Response button event of the window
            if (action == NSAlertFirstButtonReturn) {
                [self convertWithTracks:failedTracks completeHandler:notifyAppController];
            }
        });
    }
}

@end

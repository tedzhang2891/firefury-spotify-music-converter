//
//  SpotifyAddWindowController.m
//  spotify converter
//
//  Created by ted zhang on 8/1/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "SpotifyAddWindowController.h"
#import "CheckboxTableHeaderCell.h"
#import "DurationToStringTransformer.h"

NSString* ReplaceHTMLEntities(NSString* html) {
    NSString* newHtml = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&#160;" withString:@" "];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&#060;" withString:@"<"];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&#062;" withString:@">"];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&#038;" withString:@"&"];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&#034;" withString:@"\""];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    newHtml = [newHtml stringByReplacingOccurrencesOfString:@"&#039;" withString:@"'"];
    return newHtml;
}

@interface SpotifyAddWindowController ()

@end

@implementation SpotifyAddWindowController

- (BOOL)validateUserInterfaceItem:(id)item { 
    SEL action = [item action];
    if (action == @selector(ok:)) {
        if (![self isParsingURI]) {
            for (id state in self->trackCheckStates) {
                NSNumber* numBool = [NSNumber numberWithBool:YES];
                if ([state isEqual:numBool]) {
                    return YES;
                }
            }
        }
    }
    if (action != @selector(btnParseURL:)) {
        if (action == @selector(checkSelectedTrack:) || action == @selector(uncheckSelectedTrack:)) {
            [self.tracksTableView clickedRow];
        }
    }
    if ([self isParsingURI]) {
        return NO;
    }
    NSUInteger len = [[self.spotifyURLField stringValue] length];
    if (![[self.spotifyURLField stringValue] length]) {
        return NO;
    }
    NSTextCheckingResult* textResult = [self->spotifyURIRegex firstMatchInString:[self.spotifyURLField stringValue] options:NSMatchingReportCompletion range:NSMakeRange(0, len)];
    if (textResult) {
        return YES;
    }
    
    textResult = [self->spotifyURLRegex firstMatchInString:[self.spotifyURLField stringValue] options:NSMatchingReportCompletion range:NSMakeRange(0, len)];
    if (textResult) {
        return YES;
    }
    
    return YES;
}

- (void)keyDown:(NSEvent *)event { 
    if ([event keyCode] == 51 || [event keyCode] == 117) {
        NSIndexSet *selectedRowIndexes = [self.tracksTableView selectedRowIndexes];
        [self->trackCheckStates removeObjectsAtIndexes:selectedRowIndexes];
        [self.tracksArrayController removeObjectsAtArrangedObjectIndexes:selectedRowIndexes];
        [self.tracksTableView deselectAll:nil];
        [self.tracksTableView reloadData];
    }
}

- (void)closeSheetWithCode:(unsigned long long)code { 
    if (self->watchPasteboardTimer) {
        [self->watchPasteboardTimer invalidate];
        self->watchPasteboardTimer = nil;
    }
    [NSApp endSheet:[self window] returnCode:code];
    [[self window] orderOut:nil];
}

- (void)cancel:(id)sender { 
    [self closeSheetWithCode:0];
}

- (void)ok:(id)sender { 
    if (self->sheetCompleteHandler) {
        NSMutableIndexSet* mIndexSet = [NSMutableIndexSet indexSet];
        NSUInteger count = [self->trackCheckStates count];
        if (count) {
            NSUInteger index = 0;
            while (index < count) {
                id value = [self->trackCheckStates objectAtIndexedSubscript:index];
                NSNumber* numBool = [NSNumber numberWithBool:YES];
                if ([value isEqual:numBool]) {
                    [mIndexSet addIndex:index];
                }
                index++;
            }
        }
        
        id tracks = [self.tracksArrayController arrangedObjects];
        id selectedTracks = [tracks objectsAtIndexes:mIndexSet];
        self->sheetCompleteHandler(selectedTracks);
    }
    [self closeSheetWithCode:1];
}

- (void)uncheckSelectedTrack:(id)track { 
    NSIndexSet* selected = [self.tracksTableView selectedRowIndexes];
    NSInteger clickedIndex = [self.tracksTableView clickedRow];
    NSIndexSet* selectedIndex = nil;
    if ([selected containsIndex:clickedIndex]) {
        selectedIndex = [self.tracksTableView selectedRowIndexes];
    } else {
        selectedIndex = [NSIndexSet indexSetWithIndex:clickedIndex];
    }
    [self updateTrackCheckState:NO withIndexSet:selectedIndex];
}

- (void)checkSelectedTrack:(id)track { 
    NSIndexSet* selected = [self.tracksTableView selectedRowIndexes];
    NSInteger clickedIndex = [self.tracksTableView clickedRow];
    NSIndexSet* selectedIndex = nil;
    if ([selected containsIndex:clickedIndex]) {
        selectedIndex = [self.tracksTableView selectedRowIndexes];
    } else {
        selectedIndex = [NSIndexSet indexSetWithIndex:clickedIndex];
    }
    [self updateTrackCheckState:YES withIndexSet:selectedIndex];
}

- (void)updateTrackCheckState:(BOOL)state withIndexSet:(id)indexset { 
    [indexset enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        NSNumber* numBool = [NSNumber numberWithBool:state];
        [self->trackCheckStates replaceObjectAtIndex:idx withObject:numBool];
    }];
    [self.tracksTableView reloadDataForRowIndexes:indexset columnIndexes:[NSIndexSet indexSetWithIndex:0]];
    [self updateAllCheckState];
}

- (void)setAllTrackCheckState:(BOOL)state { 
    [self->trackCheckStates removeAllObjects];
    id tracks = [self.tracksArrayController arrangedObjects];
    NSUInteger count = [tracks count];
    if (count) {
        NSUInteger index = 0;
        while (index < count) {
            NSNumber* numBool = [NSNumber numberWithBool:state];
            [self->trackCheckStates addObject:numBool];
            index ++;
        }
    }
    [self.tracksTableView reloadData];
    NSTableColumn* tableColumn = [self.tracksTableView tableColumnWithIdentifier:@"check"];
    CheckboxTableHeaderCell* headerCell = [tableColumn headerCell];
    [headerCell setChecked:state];
    NSTableHeaderView* headerView = [self.tracksTableView headerView];
    [headerView setNeedsDisplay:YES];
}

- (void)updateAllCheckState {
    BOOL bAll = NO;
    for (id each in self->trackCheckStates) {
        NSNumber* numNo = [NSNumber numberWithBool:NO];
        if ([each isEqual:numNo]) {
            break;
        } else {
            bAll = YES;
        }
    }
    NSTableColumn* tableColumn = [self.tracksTableView tableColumnWithIdentifier:@"check"];
    id headerCell = [tableColumn headerCell];
    if ([headerCell isChecked] != bAll) {
        [headerCell setChecked:bAll];
        [[self.tracksTableView headerView] setNeedsDisplay:YES];
    }
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn { 
    NSUserInterfaceItemIdentifier userIdentifer = [tableColumn identifier];
    if ([userIdentifer isEqualToString:@"check"]) {
        id headerCell = [tableColumn headerCell];
        BOOL isChecked = [headerCell isChecked] == NO;
        [self setAllTrackCheckState:isChecked];
    }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row { 
    NSUserInterfaceItemIdentifier userIdentifer = [tableColumn identifier];
    if ([userIdentifer isEqualToString:@"check"]) {
        [self->trackCheckStates replaceObjectAtIndex:row withObject:object];
        NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:row];
        NSIndexSet* indexSet0 = [NSIndexSet indexSetWithIndex:0];
        [tableView reloadDataForRowIndexes:indexSet columnIndexes:indexSet0];
        [self updateAllCheckState];
    }
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row { 
    NSUserInterfaceItemIdentifier userIdentifer = [tableColumn identifier];
    if ([userIdentifer isEqualToString:@"check"]) {
        if ([self->trackCheckStates count] >= row) {
            id checkStatus = [self->trackCheckStates objectAtIndex:row];
            [cell setState:[checkStatus boolValue]];
        }
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSUserInterfaceItemIdentifier userIdentifer = [tableColumn identifier];
    id value = nil;
    if ([userIdentifer isEqualTo:@"check"]) {
        if ([self->trackCheckStates count]) {
            value = [self->trackCheckStates objectAtIndex:row];
        } else {
            value = [NSNumber numberWithBool:NO];
        }
    } else {
        id tracks = [self.tracksArrayController arrangedObjects];
        id track = [tracks objectAtIndex:row];
        if ([userIdentifer isEqualToString:@"Total Time"]) {
            NSValueTransformer* valueTrans = [NSValueTransformer valueTransformerForName:@"DurationToStringTransformer"];
            NSNumber* totalTime = [track objectForKeyedSubscript:@"Total Time"];
            value = [valueTrans transformedValue:totalTime];
        } else {
            value = [track objectForKey:userIdentifer];
        }
    }
    return value;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [[self.tracksArrayController arrangedObjects] count];
}

- (id)getTrackInfoForInfoString:(NSString*)info {
    NSRegularExpression* regularExp = [NSRegularExpression regularExpressionWithPattern:@"data-.+?=\".+?\"" options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionCaseInsensitive error:nil];
    NSMutableDictionary* __block trackInfo = [NSMutableDictionary dictionary];
    NSUInteger infoLen = [info length];
    NSInteger __block block_datasize = 0;
    
    [regularExp enumerateMatchesInString:info options:NSMatchingReportCompletion range:NSMakeRange(0, infoLen) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSRange range = [result range];
        NSString* subString = [info substringWithRange:range];
        NSRange equalRange = [subString rangeOfString:@"="];
        if (equalRange.location != NSNotFound) {
            NSString* subStrData = [subString substringWithRange:NSMakeRange(0, equalRange.location)];
            NSUInteger subStrLen = [subString length];
            NSString* subStrValue = [subString substringWithRange:NSMakeRange(equalRange.location + 2, subStrLen - 3 - equalRange.location)];
            if ([subStrData isEqualToString:@"data-name"]) {
                NSString* replaceHtml = ReplaceHTMLEntities(subStrValue);
                [trackInfo setObject:replaceHtml forKeyedSubscript:@"Name"];
                return;
            }
            if ([subStrData isEqualToString:@"data-uri"]) {
                [trackInfo setObject:subStrValue forKeyedSubscript:@"Location"];
                return;
            }
            if ([subStrData isEqualToString:@"data-artists"]) {
                NSString* replaceHtml = ReplaceHTMLEntities(subStrValue);
                [trackInfo setObject:replaceHtml forKeyedSubscript:@"Artist"];
                return;
            }
            if ([subStrData isEqualToString:@"data-duration-ms"]) {
                NSNumber *totalTime = [NSNumber numberWithInt:[subStrValue intValue]];
                [trackInfo setObject:totalTime forKeyedSubscript:@"Total Time"];
                return;
            }
            if ([subStrData isEqualToString:@"data-position"]) {
                NSNumber *trackNumber = [NSNumber numberWithInt:[subStrValue intValue]];
                [trackInfo setObject:trackNumber forKeyedSubscript:@"Track Number"];
                return;
            }
            if ([subStrData hasPrefix:@"data-size-"]) {
                NSUInteger dataSizeLen = [@"data-size-" length];
                NSString* subString = [subStrData substringFromIndex:dataSizeLen];
                NSInteger dataSize = [subString integerValue];
                if (dataSize <= block_datasize) {
                    return;
                }
                block_datasize = dataSize;
                [trackInfo setObject:subStrValue forKeyedSubscript:@"ArtworkURL"];
                return;
            }
        }
    }];
    return trackInfo;
}

- (id)getTrackInfoForJson:(id)json { 
    NSMutableDictionary* trackInfo = [NSMutableDictionary dictionary];
    [trackInfo setObject:[json objectForKeyedSubscript:@"name"] forKeyedSubscript:@"Name"];
    [trackInfo setObject:[json objectForKeyedSubscript:@"uri"] forKeyedSubscript:@"Location"];
    [trackInfo setObject:[json objectForKeyedSubscript:@"duration_ms"] forKeyedSubscript:@"Total Time"];
    
    id track_number = [json objectForKeyedSubscript:@"track_number"];
    if (track_number) {
        [trackInfo setObject:[NSString stringWithFormat:@"%@", track_number] forKeyedSubscript:@"Track Number"];
    }
    
    id artists = [json objectForKeyedSubscript:@"artists"];
    if (artists) {
        NSMutableString* artistsName = [NSMutableString stringWithString:@""];
        for (id artist in artists) {
            NSString* name = [artist objectForKeyedSubscript:@"name"];
            [artistsName appendFormat:@"%@, ", name];
        }
        NSUInteger artistsLen = [artistsName length];
        [artistsName deleteCharactersInRange:NSMakeRange(artistsLen - 2, 2)];
        [trackInfo setObject:artistsName forKeyedSubscript:@"Artist"];
    }
    
    id album = [json objectForKeyedSubscript:@"album"];
    
    id album_name = [album objectForKeyedSubscript:@"name"];
    [trackInfo setObject:album_name forKeyedSubscript:@"Album"];
    
    id images = [json objectForKeyedSubscript:@"images"];
    
    if (images) {
        NSInteger nWidth = 0;
        for (id image in images) {
            // find the large image
            NSInteger width = [[image objectForKeyedSubscript:@"width"] integerValue];
            if (width > nWidth) {
                id url = [image objectForKeyedSubscript:@"url"];
                [trackInfo setObject:url forKeyedSubscript:@"ArtworkURL"];
                nWidth = width;
            }
        }
    }
    
    id description = [json objectForKeyedSubscript:@"description"];
    if (description) {
        NSCharacterSet* charSet = [NSCharacterSet whitespaceCharacterSet];
        NSString* desc = [description stringByTrimmingCharactersInSet:charSet];
        [trackInfo setObject:desc forKeyedSubscript:@"Comments"];
    }
    
    NSString* type = [json objectForKeyedSubscript:@"type"];
    id show = [json objectForKeyedSubscript:@"show"];
    if ([type isEqualToString:@"episode"] && show) {
        NSString* show_publisher = [show objectForKeyedSubscript:@"publisher"];
        [trackInfo setObject:show_publisher forKeyedSubscript:@"Artist"];
        NSString* show_name = [show objectForKeyedSubscript:@"name"];
        [trackInfo setObject:show_name forKeyedSubscript:@"Album"];
    }
    
    return trackInfo;
}

- (NSArray*)getTrackInfosFromHTML:(NSMutableString*)html { 
    NSMutableDictionary* __block mDict = [NSMutableDictionary dictionary];
    NSUInteger htmlLen = [html length];
    
    NSRange searchRange = [html rangeOfString:@"<script id=\"resource\" type=\"application/json\">"];
    if (!searchRange.length) {
        NSRegularExpression* regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<li class=\"track-row\".*?>" options:NSRegularExpressionDotMatchesLineSeparators|NSRegularExpressionCaseInsensitive error:nil];
        [regularExpression enumerateMatchesInString:html options:NSMatchingReportCompletion range:NSMakeRange(0, htmlLen) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (result) {
                NSRange range = [result range];
                NSString* subHtml = [html substringWithRange:range];
                id trackInfo = [self getTrackInfoForInfoString:subHtml];
                if (trackInfo) {
                    NSString* location = [trackInfo objectForKeyedSubscript:@"Location"];
                    [mDict setObject:trackInfo forKey:location];
                }
            }
        }];
        return [mDict allValues];
    }
    
    NSRange jsonRange = [html rangeOfString:@"</script>" options:NSCaseInsensitiveSearch range:NSMakeRange(searchRange.location, htmlLen - searchRange.location)];
    if (jsonRange.length) {
        NSString* json = [html substringWithRange:NSMakeRange(searchRange.location + searchRange.length, jsonRange.location - (searchRange.location + searchRange.length))];
        NSData* jsondata = [json dataUsingEncoding:NSUTF8StringEncoding];
        id jsonobj = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableContainers error:nil];
        if (jsonobj) {
            NSString* type = [jsonobj objectForKeyedSubscript:@"type"];
            if ([type isEqualToString:@"track"] || [type isEqualToString:@"episode"]) {
                id trackInfo = [self getTrackInfoForJson:jsonobj];
                if (trackInfo) {
                    NSString* location = [trackInfo objectForKeyedSubscript:@"Location"];
                    [mDict setObject:trackInfo forKey:location];
                }
            } else if ([type isEqualToString:@"playlist"]) {
                id tracks = [jsonobj objectForKeyedSubscript:@"tracks"];
                if (tracks) {
                    id items = [tracks objectForKeyedSubscript:@"items"];
                    if ([items isKindOfClass:[NSArray class]]) {
                        for (id item in items) {
                            id track = [item objectForKeyedSubscript:@"track"];
                            id trackInfo = [self getTrackInfoForJson:track];
                            if (trackInfo) {
                                NSString* location = [trackInfo objectForKeyedSubscript:@"Location"];
                                [mDict setObject:trackInfo forKey:location];
                            }
                        }
                    }
                }
            } else if ([type isEqualToString:@"album"]) {
                id tracks = [jsonobj objectForKeyedSubscript:@"tracks"];
                if (tracks) {
                    id items = [tracks objectForKeyedSubscript:@"items"];
                    if ([items isKindOfClass:[NSArray class]]) {
                        for (id item in items) {
                            id track = [item objectForKeyedSubscript:@"track"];
                            id trackInfo = [self getTrackInfoForJson:track];
                            if (trackInfo) {
                                NSString* location = [trackInfo objectForKeyedSubscript:@"Location"];
                                [mDict setObject:trackInfo forKey:location];
                            }
                        }
                    }
                }
            } else if ([type isEqualToString:@"show"]) {
                NSString* mediaType = [jsonobj objectForKeyedSubscript:@"media_type"];
                if ([mediaType isEqualToString:@"audio"]) {
                    id episodes = [jsonobj objectForKeyedSubscript:@"episodes"];
                    if (episodes) {
                        id items = [episodes objectForKeyedSubscript:@"items"];
                        if ([items isKindOfClass:[NSArray class]]) {
                            for (id item in items) {
                                id trackInfo = [self getTrackInfoForJson:item];
                                if (trackInfo) {
                                    id publisher = [jsonobj objectForKeyedSubscript:@"publisher"];
                                    if (publisher) {
                                        [trackInfo setObject:publisher forKeyedSubscript:@"Artist"];
                                    }
                                    id name = [jsonobj objectForKeyedSubscript:@"name"];
                                    if (name) {
                                        [trackInfo setObject:publisher forKeyedSubscript:@"Album"];
                                    }
                                    NSString* location = [trackInfo objectForKeyedSubscript:@"Location"];
                                    [mDict setObject:trackInfo forKey:location];
                                }
                            }
                        }
                    }
                }
            }
            return [mDict allValues];
        }
    }
    return nil;
}

- (void)querySpotifyURI:(id)URI completeHandler:(void (^)(id, long))handler {
    NSUInteger nLen = [@"spotify:" length];
    NSString* trackId = [URI substringFromIndex:nLen];
    NSString* replace = [trackId stringByReplacingOccurrencesOfString:@":" withString:@"/"];
    NSString* urlString = [NSString stringWithFormat:@"https://open.spotify.com/embed/%@", replace];
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableString* html = [NSMutableString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    
    if (html) {
        id tracks = [self getTrackInfosFromHTML:html];
        if (tracks && [tracks count]) {
            handler(tracks, [tracks count]);
        } else {
            NSLog(@"can not parse tracks for %@, html is \n%@", URI, html);
        }
    } else {
        NSLog(@"can not get content of %@", URI);
    }
}

- (void)URIDidReceived:(id)URIs forURL:(id)url {
    if ([URIs count]) {
        if (!self.isParsingURI) {
            [NSApp activateIgnoringOtherApps:YES];
            [self setIsParsingURI:YES];
            [self.spotifyURLField setStringValue:url];
            
            NSMutableArray* tracks = [NSMutableArray array];
            [self setTracks:tracks];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSMutableArray* array = [NSMutableArray array];
                for (NSString* uri in URIs) {
                    [self querySpotifyURI:uri completeHandler:^(NSArray* resArray, long arg2) {
                        NSUInteger count = [resArray count];
                        NSLog(@"query info for %@ get %lu result", uri, count);
                        [array addObjectsFromArray:resArray];
                    }];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self setIsParsingURI:NO];
                    [self setTracks:array];
                    NSUInteger count = [array count];
                    if (!count) {
                        NSAlert* anAlert = [[NSAlert alloc] init];
                        anAlert.messageText = NSLocalizedString(@"Can not get Tracks", @"");
                        anAlert.informativeText = NSLocalizedString(@"can not parse content from spotify, please check your network connection.", @"");
                        [anAlert addButtonWithTitle:NSLocalizedString(@"OK", @"")];
                        [anAlert runModal];
                    }
                });
            });
        }
    }
}

- (void)btnHiddenConvert:(id)sender { 
    NSMutableArray* tracks = [self.tracksArrayController content];
    [self setTracks:tracks];
}

- (void)btnParseURL:(id)sender { 
    NSString* url = [self.spotifyURLField stringValue];
    [self parseSpotifyContent:url];
}

- (void)beginSheetWithCompleteHandler:(void(^)(NSArray*))handler {
    if (handler) {
        self->sheetCompleteHandler = handler;
    } else {
        self->sheetCompleteHandler = nil;
    }
    
    [self loadWindow];
    [self showGuideView:YES];
    [self.spotifyURLField setStringValue:@""];
    
    NSMutableArray* tracks = [NSMutableArray array];
    [self setTracks:tracks];
    NSPasteboard* pasteBoard = [NSPasteboard generalPasteboard];
    self->pasteboardChangeCount = [pasteBoard changeCount];
    
    self->watchPasteboardTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(watchPasteboardForSpotifyURL) userInfo:nil repeats:YES];
    
    //[NSApp beginSheet:self.window modalForWindow:deleWin modalDelegate:nil didEndSelector:nil contextInfo:nil];
    [[NSApp mainWindow] beginSheet:[self window] completionHandler:nil];
}

- (void)setTracks:(id)tracks { 
    [self.tracksArrayController setContent:tracks];
    NSControlStateValue state = self.hiddenConvertedButton.state;
    if (state == NSControlStateValueOn) {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"!(Location IN %@)", self.convertedTrackURLs];
        [self.tracksArrayController setFilterPredicate:predicate];
    }
    else {
        [self.tracksArrayController setFilterPredicate:nil];
    }
    
    [self.tracksArrayController rearrangeObjects];
    [self setAllTrackCheckState:YES];
}

- (void)watchPasteboardForSpotifyURL { 
    NSPasteboard* pasteBoard = [NSPasteboard generalPasteboard];
    if ([pasteBoard changeCount] != self->pasteboardChangeCount) {
        self->pasteboardChangeCount = [pasteBoard changeCount];
        NSString* spotifyUrl = [pasteBoard stringForType:NSPasteboardTypeString];
        [self parseSpotifyContent:spotifyUrl];
    }
}

- (id)parseSpotifyContent:(NSString*)spotifyContent {
    if (!spotifyContent) {
        return nil;
    }
    
    NSString* ret = nil;
    
    NSMutableSet* itemSet = [NSMutableSet set];
    NSUInteger contentLen = [spotifyContent length];
    
    NSString* __block uri = nil;
    NSString* __block url = nil;
    NSMutableArray* __block uriArray = nil;
    
    [self->spotifyURIRegex enumerateMatchesInString:spotifyContent options:0 range:NSMakeRange(0, spotifyContent.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSRange uriRange = [result range];
        uri = [spotifyContent substringWithRange:uriRange];
        NSLog(@"uristring is %@", uri);
        
        if (uri) {
            [uriArray addObject:uri];
        }
    }];
    
    [self->spotifyURLRegex enumerateMatchesInString:spotifyContent options:0 range:NSMakeRange(0, spotifyContent.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (uri) {
            NSRange urlRange = [result range];
            url = [spotifyContent substringWithRange:urlRange];
            NSRange openRange = [url rangeOfString:@"open.spotify.com/" options:NSCaseInsensitiveSearch];
            NSString* track = [url substringFromIndex:openRange.location + 17];
            if ([track hasPrefix:@"embed/"]) {
                track = [track substringFromIndex:[@"embed/" length]];
            }
            NSLog(@"urlstring is %@", track);
            
            if (track) {
                NSString* replaceString = [track stringByReplacingOccurrencesOfString:@"/" withString:@":"];
                NSString* uri = [NSString stringWithFormat:@"spotify:%@", replaceString];
                [uriArray addObject:uri];
            }
        }
    }];
    
    if ([uriArray count]) {
        NSMutableArray* mArray = [NSMutableArray array];
        [mArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [itemSet addObject:obj];
        }];
        [self URIDidReceived:uriArray forURL:url];
        ret = nil;
    } else {
        ret = url;
    }
    
    return ret;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey, id> *)change context:(void *)context; {
    if ([keyPath isEqualToString:@"tracksArrayController.arrangedObjects"]) {
        NSInteger count = [[[object tracksArrayController] arrangedObjects] count];
        [self showGuideView:(count==0)];
    }
}

- (void)showGuideView:(BOOL)bShow { 
    if (self.tracksTableView) {
        [self.tracksTableView.enclosingScrollView setHidden:bShow];
        [self.guideView setIsShowGuideView:bShow];
    }
}

- (void)awakeFromNib { 
    [self addObserver:self forKeyPath:@"tracksArrayController.arrangedObjects" options:NSKeyValueObservingOptionNew context:nil];
    
    for (NSTableColumn* col in self.tracksTableView.tableColumns) {
        NSString* identifier = [col identifier];
        NSString* headertext = [[col headerCell] stringValue];
        if ([identifier isEqualToString:@"check"]) {
            CheckboxTableHeaderCell* headercell = [[CheckboxTableHeaderCell alloc] initTextCell:@""];
            [col setHeaderCell:headercell];
        } else {
            NSTableHeaderCell* headercell = [[NSTableHeaderCell alloc] initTextCell:headertext];
            [col setHeaderCell:headercell];
        }
    }
    
    //Add by Ted, disable click on table header.
    
    [self.guideView setBorder:2];
    [self.guideView setBorderColor:[NSColor lightGrayColor]];
}

- (SpotifyAddWindowController*)init {
    if (self = [super init]) {
        self->trackCheckStates = [[NSMutableArray alloc] init];
        self->spotifyURLRegex = [NSRegularExpression regularExpressionWithPattern:@"http[s]?://open.spotify.com/(embed/)?((?:track)|(?:user/.*?/playlist)|(?:album)|(?:show)|(?:episode))/[a-z,A-Z,0-9,/,+,=]+" options:NSRegularExpressionCaseInsensitive error:nil];
        self->spotifyURIRegex = [NSRegularExpression regularExpressionWithPattern:@"spotify:((?:track)|(?:user:.*?:playlist)|(?:album)|(?:show)|(?:episode)):[a-z,A-Z,0-9,/,+,=]+" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    return self;
}

- (NSString*)windowNibName { 
    return @"SpotifyAddWindow";
}

@end

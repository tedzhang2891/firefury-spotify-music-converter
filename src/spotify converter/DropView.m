//
//  DropView.m
//  spotify converter
//
//  Created by ted zhang on 8/21/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import "DropView.h"

@implementation DropView

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
    BOOL retValue = NO;
    NSPasteboard* pasteboard = [sender draggingPasteboard];
    NSMutableArray* __block trackInfo = [NSMutableArray array];
    NSString* __block content = [pasteboard stringForType:NSPasteboardTypeString];
    NSString* __block url = nil;
    
    NSRegularExpression* regularExp = [NSRegularExpression regularExpressionWithPattern:@"http[s]?://open.spotify.com/(embed/)?((?:track)|(?:user/.*?/playlist)|(?:album)|(?:show)|(?:episode))/[a-z,A-Z,0-9,/,+,=]+" options:NSRegularExpressionCaseInsensitive error:nil];
    if (regularExp) {
        [regularExp enumerateMatchesInString:content options:2 range:NSMakeRange(0, [content length]) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            if (result) {
                NSRange range = [result range];
                NSString* spotifyUrl = [content substringWithRange:range];
                NSRange domainRange = [spotifyUrl rangeOfString:@"open.spotify.com/" options:NSCaseInsensitiveSearch];
                NSString* track = [spotifyUrl substringFromIndex:domainRange.location + 17];
                
                NSString* replaceString = [track stringByReplacingOccurrencesOfString:@"/" withString:@":"];
                NSString* uri = [NSString stringWithFormat:@"spotify:%@", replaceString];
                [trackInfo addObject:uri];
                if (!url) {
                    url = spotifyUrl;
                }
            }
        }];
        id delegate = [self delegate];
        if (delegate) {
            [delegate URIDidReceived:trackInfo forURL:url];
        }
        retValue = YES;
    }
    
    return retValue;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender { 
    return YES;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender {
    NSDragOperation dragOper = NSDragOperationNone;
    NSPasteboard* pasteboard = [sender draggingPasteboard];
    NSString* content = [pasteboard stringForType:NSPasteboardTypeString];
    NSRange srIdentity = [content rangeOfString:@"open.spotify.com" options:NSCaseInsensitiveSearch];
    NSRange srTrack = [content rangeOfString:@"track" options:NSCaseInsensitiveSearch];
    NSRange srPlaylist = [content rangeOfString:@"playlist" options:NSCaseInsensitiveSearch];
    NSRange srAlbum = [content rangeOfString:@"album" options:NSCaseInsensitiveSearch];
    NSRange srShow = [content rangeOfString:@"show" options:NSCaseInsensitiveSearch];
    NSRange srEpisode = [content rangeOfString:@"episode" options:NSCaseInsensitiveSearch];
    if (content || srIdentity.location != NSNotFound) {
        if (srTrack.location == NSNotFound &&
            srPlaylist.location == NSNotFound &&
            srAlbum.location == NSNotFound &&
            srShow.location == NSNotFound &&
            srEpisode.location == NSNotFound) {
            dragOper = NSDragOperationNone;
        } else {
            dragOper = NSDragOperationCopy;
        }
    } else {
        dragOper = NSDragOperationNone;
    }
    return dragOper;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender { 
    return [self draggingUpdated:sender];
}

- (instancetype)initWithCoder:(NSCoder *)decoder { 
    if (self = [super initWithCoder:decoder]) {
        NSArray* pastedboardTypeString = [NSArray arrayWithObjects:&NSPasteboardTypeString count:1];
        [self registerForDraggedTypes:pastedboardTypeString];
    }
    return self;
}

- (instancetype)initWithFrame:(NSRect)frameRect { 
    if (self = [super initWithFrame:frameRect]) {
        NSArray* pastedboardTypeString = [NSArray arrayWithObjects:&NSPasteboardTypeString count:1];
        [self registerForDraggedTypes:pastedboardTypeString];
    }
    return self;
}

@end

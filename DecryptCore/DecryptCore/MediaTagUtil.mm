//
//  MediaTagUtil.m
//  FireFury Audio DRM Removal
//
//  Created by ted zhang on 2/13/18.
//  Copyright © 2018 TedZhang. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "MediaTagUtil.h"
#import "tag.h"
#import "mpegfile.h"
#import "flacfile.h"
#import "mp4file.h"
#import "id3v2tag.h"
#import "tbytevector.h"
#import "attachedpictureframe.h"

using namespace TagLib;

@implementation MediaTagUtil

+ (Picture_Format)getFormatData:(const void*)data andSize:(size_t)size;
{
    /* JPEG : "\xff\xd8\xff". */
    if (size > 3 && (memcmp (data, "\xff\xd8\xff", 3) == 0))
    {
        return PICTURE_FORMAT_JPEG;
    }
    
    /* PNG : "\x89PNG\x0d\x0a\x1a\x0a". */
    if (size > 8 && (memcmp (data, "\x89PNG\x0d\x0a\x1a\x0a", 8) == 0))
    {
        return PICTURE_FORMAT_PNG;
    }
    
    /* GIF: "GIF87a" */
    if (size > 6 && (memcmp (data, "GIF87a", 6) == 0))
    {
        return PICTURE_FORMAT_GIF;
    }
    
    /* GIF: "GIF89a" */
    if (size > 6 && (memcmp (data, "GIF89a", 6) == 0))
    {
        return PICTURE_FORMAT_GIF;
    }
    
    return PICTURE_FORMAT_UNKNOWN;
}

+ (BOOL)writeMetadata:(id)metadata toPath:(id)filepath {
    NSString* fileExts = [filepath pathExtension];
    NSString* lowerExts = [fileExts lowercaseString];
    NSArray* imageArray = nil;
    BOOL bRet = NO;
    
    NSArray* artwork = [metadata objectForKeyedSubscript:@"artwork"];
    if (!artwork) {
        id artwork_url = [metadata objectForKeyedSubscript:@"artwork url"];
        if (artwork_url) {
            NSData* data4artwork = [NSData dataWithContentsOfURL:artwork_url];
            if (data4artwork) {
                NSBitmapImageRep* bitmapImage = [[NSBitmapImageRep alloc] initWithData:data4artwork];
                if (bitmapImage) {
                    NSNumber* compressionFactor = [NSNumber numberWithDouble:0.75];
                    NSDictionary* compressDict = @{ NSImageCompressionFactor: compressionFactor };
                    NSData* imageData = [bitmapImage representationUsingType:NSBitmapImageFileTypeJPEG properties:compressDict];
                    imageArray = [NSArray arrayWithObjects:&imageData count:1];
                }
            }
        }
    }
    else {
        imageArray = [[NSArray alloc] initWithArray:artwork];
    }
    
    const char* rawpath = [filepath fileSystemRepresentation];
    if ([lowerExts isEqualToString:@"mp3"]) {
        MPEG::File audioFile(rawpath);
        if (!audioFile.isValid()) {
            NSLog(@"open %@ for tag edit failure", filepath);
        }
        
        for (id img in imageArray) {
            ID3v2::Tag *tag = audioFile.ID3v2Tag(true);
            ID3v2::AttachedPictureFrame *frame = new TagLib::ID3v2::AttachedPictureFrame;
            
            frame->setMimeType("image/jpeg");
            const void* rawdata = [img bytes];
            NSUInteger imgLen = [img length];
            ByteVector imgByte((const char*)rawdata, (unsigned int)imgLen);
            frame->setPicture(imgByte);
            tag->addFrame(frame);
            audioFile.save();
        }
        
    }
    else if ([lowerExts isEqualToString:@"m4a"]) {
        // read the mp4 file
        MP4::File audioFile(rawpath);
        // get the tag ptr
        MP4::Tag *tag = audioFile.tag();
        
        NSString* title = [metadata objectForKeyedSubscript:@"title"];
        if (title) {
            tag->setTitle([title UTF8String]);
        }
        else {
            title = [[filepath lastPathComponent] stringByDeletingPathExtension];
            tag->setTitle([title UTF8String]);
        }
        
        NSString* artist = [metadata objectForKeyedSubscript:@"artist"];
        if (artist) {
            tag->setArtist([artist UTF8String]);
        }
        
        NSString* album = [metadata objectForKeyedSubscript:@"album"];
        if (album) {
            tag->setAlbum([album UTF8String]);
        }
        
        NSString* date = [metadata objectForKeyedSubscript:@"date"];
        if (date) {
            tag->setYear([date intValue]);
        }
        
        NSString* comment = [metadata objectForKeyedSubscript:@"comment"];
        if (comment) {
            tag->setComment([comment UTF8String]);
        }
        
        NSString* genre = [metadata objectForKeyedSubscript:@"genre"];
        if (genre) {
            tag->setGenre([genre UTF8String]);
        }
        
        NSString* albumartist = [metadata objectForKeyedSubscript:@"albumartist"];
        if (albumartist) {
            //tag->setalbumArtist([albumartist UTF8String]);
        }
        
        NSString* composer = [metadata objectForKeyedSubscript:@"composer"];
        if (composer) {
            //tag->setComposer([composer UTF8String]);
        }
        
        NSString* track = [metadata objectForKeyedSubscript:@"track"];
        NSString* track_count = [metadata objectForKeyedSubscript:@"track count"];
        if (track) {
            int trackid = [track intValue];
            // TODO: track count
            tag->setTrack(trackid);
        }
        
        NSString* disc = [metadata objectForKeyedSubscript:@"disc"];
        if (disc) {
            int discid = [disc intValue];
            // TODO: disc count
            //tag->setDisc(discid);
        }
        
        MP4::ItemListMap &extra_items = tag->itemListMap();
        /***********
         * Picture *
         ***********/
        if (imageArray)
        {
            Picture_Format pf;
            MP4::CoverArt::Format f;
            
            for (id img in imageArray) {
                const void* data = [img bytes];
                size_t data_size = [img length];

                pf = [MediaTagUtil getFormatData:data andSize:data_size];
                
                switch (pf)
                {
                    case PICTURE_FORMAT_JPEG:
                        f = MP4::CoverArt::JPEG;
                        break;
                    case PICTURE_FORMAT_PNG:
                        f = MP4::CoverArt::PNG;
                        break;
                    case PICTURE_FORMAT_GIF:
                        f = MP4::CoverArt::GIF;
                        break;
                    case PICTURE_FORMAT_UNKNOWN:
                    default:
                        NSLog(@"Unknown format");
                        f = MP4::CoverArt::JPEG;
                        break;
                }
                
                MP4::CoverArt art(f, ByteVector((char *)data,data_size));
                
                extra_items.insert ("covr", MP4::Item(MP4::CoverArtList().append(art)));
            }
        }
        else
        {
            extra_items.erase ("covr");
        }

        tag->save();
        audioFile.save();
    }
    else if ([lowerExts isEqualToString:@"m4b"]) {
    }
    else if ([lowerExts isEqualToString:@"flac"]) {
        FLAC::File audioFile(rawpath);
        if (!audioFile.isValid()) {
            NSLog(@"open %@ for tag edit failure", filepath);
        }
        
        for (id img in imageArray) {
            
            /*
             PROPOSED http://wiki.xiph.org/VorbisComment#METADATA_BLOCK_PICTURE
             */
            FLAC::Picture* picture = new TagLib::FLAC::Picture();
            const void* rawdata = [img bytes];
            NSUInteger imgLen = [img length];
            ByteVector imgByte((const char*)rawdata, (unsigned int)imgLen);
            picture->setData(imgByte);
            picture->setType((TagLib::FLAC::Picture::Type)  0x03); // FrontCover
            picture->setMimeType("image/jpeg");
            picture->setDescription("Front Cover");
            audioFile.addPicture(picture);
            audioFile.save();
        }
    }
    else {
        NSLog(@"unsupprot media %@, only support m4a,mp3,flac", filepath);
    }
    
    return bRet;
}

+ (NSData *)readCovr:(NSString*)filepath {
    NSString* fileExts = [filepath pathExtension];
    NSString* lowerExts = [fileExts lowercaseString];
    NSArray* imageArray = nil;
    BOOL bRet = NO;
    NSData* data = nil;
    
    const char* rawpath = [filepath fileSystemRepresentation];
    if ([lowerExts isEqualToString:@"mp3"]) {
        // TODO:
    }
    else if ([lowerExts isEqualToString:@"m4a"] || [lowerExts isEqualToString:@"m4p"]) {
        TagLib::MP4::File f(rawpath);
        TagLib::MP4::Tag* tag = f.tag();
        TagLib::MP4::ItemListMap itemsListMap = tag->itemListMap();
        TagLib::MP4::Item coverItem = itemsListMap["covr"];
        TagLib::MP4::CoverArtList coverArtList = coverItem.toCoverArtList();
        if (!coverArtList.isEmpty()) {
            TagLib::MP4::CoverArt coverArt = coverArtList.front();
            data = [[NSData alloc] initWithBytes:coverArt.data().data() length:coverArt.data().size()];
        }
    }
    else if ([lowerExts isEqualToString:@"m4b"]) {
        // TODO:
    }
    else if ([lowerExts isEqualToString:@"flac"]) {
        // TODO:
    }
    else {
        NSLog(@"can not read cover from media %@, only support m4a,mp3,flac", filepath);
    }
    
    
    return data;
}

@end

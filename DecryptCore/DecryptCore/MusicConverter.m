//
//  MusicConverter.m
//  drm_removal_for_audio
//
//  Created by ted zhang on 2017/12/9.
//  Copyright © 2017年 TedZhang. All rights reserved.
//

#import "Common.h"
#import "MusicConverter.h"
#import "MusicApplication.h"
#import "MediaTagUtil.h"

@implementation MusicConverter

@dynamic debugDescription;
@dynamic description;
@dynamic hash;
@dynamic superclass;

static MusicConverter* _instance = nil;

+ (NSString*)converterLogPath {
    NSUserDefaults* sharedUserDefault = [NSUserDefaults standardUserDefaults];
    NSString* logFolder = [sharedUserDefault stringForKey:@"PreferenceLogFolderKey"];
    if (!logFolder) {
        //logFolder = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"txt"]];
        logFolder = NSTemporaryDirectory();
    }
    NSString* searchPath = nil;
    NSString* searchBundle = nil;
    
    if (logFolder) {
        id searchList = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* bundleName = [mainBundle objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
        
        if ([searchList count]) {
            searchPath = [searchList objectAtIndex:0];
            searchBundle = [searchPath stringByAppendingPathComponent:bundleName];
        }
        else {
            searchBundle = NSTemporaryDirectory();
        }
        NSFileManager* fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:searchBundle]) {
            [fileManager createDirectoryAtPath:searchBundle withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return [logFolder stringByAppendingPathComponent:@"spotify.log"];
}

+ (id)sharedMusicConverter {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance ;
}

- (void)disconnectToConvertCore {
    converterCore = nil;
}

- (BOOL)connectToConvertCore {
    int index = 0;
    BOOL bResult = NO;
    id convertCore = nil;
    
    while (YES)
    {
        convertCore = [NSConnection rootProxyForConnectionWithRegisteredName:@"com.spotify.spotiftConverter" host:NULL];
        if (convertCore)
            break;
        sleep(1);
        
        if ( ++index > 60 )
        {
            bResult = NO;
            NSLog(@"can not connect to core");
            return bResult;
        }
    }
    
    [convertCore setProtocolForProxy:@protocol(ConvertCommunicationProtocol)];
    self->converterCore = convertCore;
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* bundleName = [mainBundle objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
    NSString* bundleVersion = [mainBundle objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    NSString* bundleInfo = [NSString stringWithFormat:@"%@ %@", bundleName, bundleVersion];
    NSProcessInfo* procInfo = [NSProcessInfo processInfo];
    NSString* OSVer = [procInfo operatingSystemVersionString];
    NSString* logPath = [MusicConverter converterLogPath];
    
    NSArray *keys = @[@"APP_NAME", @"LOG_PATH", @"SYSTEM", @"MUSIC"];
    NSArray *values = @[bundleInfo, logPath, OSVer, self->musicApp.appVersion];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    bResult = [self->converterCore prepareConverterWithProperties:dict];
    
    NSString* log = @"failure";
    if ( bResult )
        log = @"successful";
    NSLog(@"config converter %@", log);
    
    if ( !bResult )
    {
        self->converterCore = nil;
        bResult = NO;
    }
    
    return bResult;
}

- (BOOL)convertFile:(NSString*)srcfile output:(NSString*)destfile metadata:(NSMutableDictionary*)mdata convertSpeed:(NSInteger)speed withProfile:(NSDictionary*)profile progressHandler:(void (^)(double, BOOL*))handle {
    BOOL bRet = NO;
    BOOL bConvertFailed = NO;
    BOOL isAbort = NO;
    double convertedDuration = 0.0;
    double timeleft = -0.1;
    double elapsingTime = 0.0;
    double timeSpend = 0.0;
    NSLog(@"convert %@ to %@, speed %ld, meta data %@", srcfile, destfile, (long)speed, mdata);
    if (converterCore || [self connectToConvertCore]) {
        [musicApp hideApplicationWindow];
        NSFileManager* sharedFileManager = [NSFileManager defaultManager];
        NSUserDefaults* sharedUserDefaults = [NSUserDefaults standardUserDefaults];
        BOOL bPreferenceDeleteFailureFileKey = [sharedUserDefaults boolForKey:@"PreferenceDeleteFailureFileKey"];
        [self setCurrentTrackArtwork:nil];
        NSData* signature = [Common CreateSignature];
        
        double duration =  [[mdata objectForKey:@"duration"] doubleValue];
        
        timeleft = duration;
        if ([converterCore convertFile:srcfile output:destfile stopDuration:duration convertSpeed:speed withProfile:profile contextInfo:signature]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSString* exts = [[destfile pathExtension] lowercaseString];
                NSUserDefaults* sharedUserDefault = [NSUserDefaults standardUserDefaults];
                if ([sharedUserDefault boolForKey:@"PreferenceKeepChaptersKey"] &&
                    AXIsProcessTrusted() &&
                    ([exts isEqualToString:@"m4a"] || [exts isEqualToString:@"m4b"])) {
                }
                id artwork = [mdata objectForKeyedSubscript:@"artwork"];
                NSImage* img = nil;
                if ([artwork count]) {
                    img = [[NSImage alloc] initWithData:artwork[0]];
                    [self setCurrentTrackArtwork:img];
                }
                else {
                    NSURL* artworkurl = [mdata objectForKeyedSubscript:@"artwork url"];
                    if (!artworkurl) {
                        // Try to get covr from srcfile
                        NSData* data = [MediaTagUtil readCovr:srcfile];
                        if (data) {
                            img = [[NSImage alloc] initWithData:data];
                            [self setCurrentTrackArtwork:img];
                        }
                        else {
                            [self setCurrentTrackArtwork:nil];
                        }
                        return;
                    }
                    img = [[NSImage alloc] initWithContentsOfURL:artworkurl];
                    [self setCurrentTrackArtwork:img];
                }
            });
            while (YES) {
                while (YES) {
                    convertedDuration = [converterCore convertedDuration];
                    if (convertedDuration >= 0.0) {
                        break;
                    }
                    sleep(2);
                }
                if (timeleft - convertedDuration <= 0.05) {
                    break;
                }
                elapsingTime = timeSpend - convertedDuration;
                if (elapsingTime == 0.0) {
                    if (convertedDuration > timeoutValue) {
                        NSLog(@"duration %.3f, convert duration %.3lld", duration, timeoutValue);
                        [converterCore stopConvert];
                        break;
                    }
                }
                else {
                    timeSpend = convertedDuration;
                }
                
                if (bConvertFailed) {
                    if (bPreferenceDeleteFailureFileKey) {
                        if ([sharedFileManager removeItemAtPath:destfile error:nil]) {
                            NSLog(@"converting not completed, the converted file %@ was deleted.", destfile);
                        }
                    }
                    break;
                }
                
                if (handle) {
                    handle(convertedDuration, &isAbort);
                    if (isAbort) {
                        break;
                    }
                }
                
                sleep(2);
            }
            [converterCore stopConvert];
            bRet = !bConvertFailed;
            
            int stoptimes = 0;
            while (stoptimes > 5) {
                if ([converterCore isPlaying]) {
                    stoptimes ++;
                    sleep(1);
                }
                else
                    break;
            }
            if (stoptimes > 5) {
                NSLog(@"core is still playing");
            }
            
            if (bConvertFailed | isAbort) {
                if (bPreferenceDeleteFailureFileKey) {
                    [sharedFileManager removeItemAtPath:destfile error:nil];
                }
            }
            else {
                if ([self currentTrackArtwork] && ![mdata objectForKeyedSubscript:@"artwork"]) {
                    NSData* tiff = [[self currentTrackArtwork] TIFFRepresentation];
                    id bitmapRep = [NSBitmapImageRep imageRepWithData:tiff];
                    NSNumber* compressionFactor = [NSNumber numberWithDouble:0.75];
                    NSDictionary* compressFactor = @{ NSImageCompressionFactor: compressionFactor };
                    NSData* imageData = [bitmapRep representationUsingType:NSBitmapImageFileTypeJPEG properties:compressFactor];
                    //NSImage* test = [[NSImage alloc] initWithData:tiff];
                    NSArray* imageArray = [NSArray arrayWithObjects:&imageData count:1];
                    [mdata setObject:imageArray forKey:@"artwork"];
                }
            }
        }
        else {
            NSLog(@"can not start convert");
            bRet = NO;
        }
        
        
    }
    else {
        bRet = NO;
    }
    
    return bRet;
}

- (void)closeMusicApp {
    [self disconnectToConvertCore];
    [musicApp close];
}

- (BOOL)openMusicApp {
    BOOL bRet = YES;
    if (![self->musicApp isRunning] || !self->converterCore)
    {
        if (![self->musicApp open] || ![self connectToConvertCore])
        {
            bRet = NO;
        }
    }
    return bRet;
}

- (void)dealloc {

}

- (id)init {
    if (self = [super init]) {
        self->musicAppIdentifer = @"com.spotify.client";
        //NSBundle* mainBundle = [NSBundle mainBundle];
        NSBundle* bundle = [NSBundle bundleForClass:[MusicConverter class]];
        NSString* pluginPath = [bundle pathForResource:@"SpotifyConverterBundle" ofType:@"bundle"];
        self->pluginPath = pluginPath;
        NSUserDefaults* sharedUserDefault = [NSUserDefaults standardUserDefaults];
        NSInteger convertTimeout = [sharedUserDefault integerForKey:@"ConverterWaitTimeout"];
        NSInteger defaultTimeout = 30LL;
        if (convertTimeout)
            defaultTimeout = convertTimeout;
        self->timeoutValue = defaultTimeout;
        self->musicApp = [[MusicApplication alloc] initWithPluginPath:self->pluginPath];
        if ( !self->musicApp )
            NSLog(@"music app %@ is nil", self->musicAppIdentifer);
    }
    return self;
}

+(id) allocWithZone:(struct _NSZone *)zone
{
    return [MusicConverter sharedMusicConverter] ;
}

-(id) copyWithZone:(struct _NSZone *)zone
{
    return [MusicConverter sharedMusicConverter] ;
}

@end

//
//  InjectHelper.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 2017/10/22.
//  Copyright © 2017年 TedZhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/kext/KextManager.h>
#import "InjectHelper.h"
#import "VersionComparator.h"

AuthorizationRef myAuthorizationRef;
NSString* patchedITunesPath = nil;
NSString* patchedKextPath = nil;

typedef uint32_t csr_config_t;
/* Syscalls */
extern int csr_check(csr_config_t mask);
extern int csr_get_active_config(csr_config_t *config);

/* Rootless configuration flags */
#define CSR_ALLOW_UNTRUSTED_KEXTS        (1 << 0)    // 1
#define CSR_ALLOW_UNRESTRICTED_FS        (1 << 1)    // 2
#define CSR_ALLOW_TASK_FOR_PID            (1 << 2)    // 4
#define CSR_ALLOW_KERNEL_DEBUGGER        (1 << 3)    // 8
#define CSR_ALLOW_APPLE_INTERNAL        (1 << 4)    // 16
#define CSR_ALLOW_UNRESTRICTED_DTRACE    (1 << 5)    // 32
#define CSR_ALLOW_UNRESTRICTED_NVRAM    (1 << 6)    // 64
#define CSR_ALLOW_DEVICE_CONFIGURATION    (1 << 7)    // 128
#define CSR_ALLOW_ANY_RECOVERY_OS        (1 << 8)    // 256
#define CSR_ALLOW_UNAPPROVED_KEXTS        (1 << 9)    // 512

#define CSR_VALID_FLAGS (CSR_ALLOW_UNTRUSTED_KEXTS | \
CSR_ALLOW_UNRESTRICTED_FS | \
CSR_ALLOW_TASK_FOR_PID | \
CSR_ALLOW_KERNEL_DEBUGGER | \
CSR_ALLOW_APPLE_INTERNAL | \
CSR_ALLOW_UNRESTRICTED_DTRACE | \
CSR_ALLOW_UNRESTRICTED_NVRAM  | \
CSR_ALLOW_DEVICE_CONFIGURATION | \
CSR_ALLOW_ANY_RECOVERY_OS | \
CSR_ALLOW_UNAPPROVED_KEXTS)

@implementation InjectHelper

+ (NSArray*) applicationVersions:(NSBundle*)bundle
{
    if (bundle == nil) {
        NSBundle* iTunesBundle = [NSBundle bundleWithPath:@"/Applications/iTunes.app"];
        bundle = iTunesBundle;
    }
    
    NSString* bundleFullVer;
    NSDictionary* plist = [bundle infoDictionary];
    NSString* bundleVer = plist[@"CFBundleVersion"];
    NSString* bundleInfo = plist[@"CFBundleGetInfoString"];
    NSRange rVer = [bundleInfo rangeOfString:bundleVer];
    
    if (rVer.location != NSNotFound) {
        NSUInteger len = [bundleInfo length];
        NSRange newRange;
        newRange.location = rVer.location;
        newRange.length = len - rVer.location;
        NSRange newrVer = [bundleInfo rangeOfString:@"," options:NSCaseInsensitiveSearch range:newRange];
        
        if (newrVer.location != NSNotFound) {
            newrVer.length = newrVer.location - rVer.length - 1;
            newrVer.location = rVer.location;
            bundleFullVer = [bundleInfo substringWithRange:newrVer];
        }
    }
    
    NSArray* arrVer = [bundleFullVer componentsSeparatedByString:@"."];
    return arrVer;
}

+ (bool) isUnsupportVersion:(NSArray*)arrVer
{
    return FALSE;
}

+ (id)ITunesHelperPath {
    NSString* result = @"/Applications/iTunes.app/Contents/MacOS/iTunes";
    if (patchedITunesPath) {
        result = patchedITunesPath;
    }
    return result;
}

+ (bool) isSIPEnabled
{
    if (!&csr_get_active_config)
        return false;
    
    csr_config_t config = 0;
    csr_get_active_config(&config);
    return csr_check(CSR_ALLOW_UNTRUSTED_KEXTS);
}

+ (int) injectorModeForBundle:(NSBundle*)b
{
    int mode = 0;
    NSOperatingSystemVersion OSVer;
    NSString* bundleID = [b bundleIdentifier];
    if ([bundleID isEqualToString:@"com.spotify.client"]) {
        NSDictionary* bundle_info = [b infoDictionary];
        NSString* bundle_ver = [bundle_info objectForKey:@"CFBundleVersion"];
        
        NSProcessInfo* procInfo = [NSProcessInfo processInfo];
        if (procInfo != nil) {
            OSVer = [procInfo operatingSystemVersion];
            NSLog(@"spotify version is %@, osx verison is %ld.%ld.%ld", bundle_ver, OSVer.majorVersion, OSVer.minorVersion, OSVer.patchVersion);
        } else {
            NSLog(@"spotify version is %@, osx verison is %ld.%ld.%ld", bundle_ver, 0, 0, 0);
        }
        
        VersionComparator* versionComparator = [VersionComparator defaultComparator];
        long long compareResult = [versionComparator compareVersion:bundle_ver toVersion:@"1.0.87.491"];
        mode = 3;
        if (compareResult != -1) {
            mode = 4;
            if (OSVer.majorVersion == 10 && OSVer.minorVersion >= 13) {
                mode = 0;
                if (![InjectHelper isSIPEnabled]) {
                    NSString* kDriverKextIdentifier = @"com.apple.kext.mingjie.VirtualDisplay";
                    
                    CFStringRef kext_ids[1];
                    kext_ids[0] = (__bridge CFStringRef)kDriverKextIdentifier;
                    CFArrayRef kext_id_query = CFArrayCreate(nil, (const void**)kext_ids, 1, &kCFTypeArrayCallBacks);
                    CFDictionaryRef kext_infos = KextManagerCopyLoadedKextInfo(kext_id_query, nil);
                    CFRelease(kext_id_query);
                    
                    
                    CFDictionaryRef cuda_driver_info = nil;
                    if (CFDictionaryGetValueIfPresent(kext_infos, (__bridge CFStringRef)kDriverKextIdentifier, (const void**)&cuda_driver_info)) {
                        mode = 3;
                        bool started = CFBooleanGetValue((CFBooleanRef)CFDictionaryGetValue(cuda_driver_info, CFSTR("OSBundleStarted")));
                        if (!started) {
                            NSLog(@"kernel driver is installed, but does not appear to be running on this host");
                        }
                    } else {
                        NSLog(@"kernel driver does not appear to be installed on this host, need installed frist.");
                        // Install kext
                        bool(^installKext)(AuthorizationRef) = ^(AuthorizationRef authorization){
                            bool bRet = false;
                            const char* cuda_kext = [patchedKextPath UTF8String];
                            const char* const chown_args[4] = { "-R", "0:0", cuda_kext, NULL };
                            FILE *pipe = NULL;
                            OSStatus status;
                            
                            status = AuthorizationExecuteWithPrivileges(authorization, "/usr/sbin/chown", kAuthorizationFlagDefaults, chown_args, &pipe);
                            if (status == errAuthorizationSuccess) {
                                const char * const kextload_args[2] = { cuda_kext, NULL };
                                status = AuthorizationExecuteWithPrivileges(authorization, "/sbin/kextload", kAuthorizationFlagDefaults, kextload_args, &pipe);
                                if (status == errAuthorizationSuccess){
                                    bRet = true;
                                }
                            }
                            return bRet;
                        };
                        
                        if ([InjectHelper doAuthorizedOperations:installKext]) {
                            mode = 3;
                        }
                        else {
                            mode = 0;
                        }
                    }
                    CFRelease(kext_infos);
                    return mode;
                }
            }
        }
    }
    return mode;
}

+ (bool) doAuthorizedOperations:(bool(^)(AuthorizationRef)) handle
{
    bool bRet = false;
    OSStatus status;
    
    if (myAuthorizationRef) {
        if (!handle)
            return FALSE;
        return handle(myAuthorizationRef);
    }
    
    if (AuthorizationCreate(0, 0, 0, &myAuthorizationRef)) {
        AuthorizationFree(myAuthorizationRef, 0);
        return bRet;
    }
    
    AuthorizationItem right = {kAuthorizationRightExecute, 0, 0, 0};
    AuthorizationRights rights = {1, &right};
    AuthorizationFlags flags = kAuthorizationFlagInteractionAllowed | kAuthorizationFlagPreAuthorize | kAuthorizationFlagDestroyRights;
    
    status = AuthorizationCopyRights(myAuthorizationRef, &rights, 0, flags, 0);
    if (handle && status != errAuthorizationSuccess) {
        return handle(myAuthorizationRef);
    }
    
    return bRet;
}

+ (NSString*) fixUpdaterPath:(NSString*)path
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* directory = [path stringByDeletingLastPathComponent];
    NSDictionary* fileDict = [fileManager attributesOfItemAtPath:path error:nil];
    if ([fileDict fileSize] > 0xC7FFF) {
        return path;
    }
    
    NSArray* arrStr = [fileManager contentsOfDirectoryAtPath:directory error:nil];
    for (id obj in arrStr) {
        NSString* rootPath = [directory stringByAppendingPathComponent:obj];
        NSDictionary* dict = [fileManager attributesOfItemAtPath:rootPath error:nil];
        if ([dict fileSize] >= 0xC8001) {
            if ([obj isEqualToString:@"iPodUpdater.bak"]) {
                return rootPath;
            }
            if ([obj isEqualToString:@"libiTunesUpdater"]) {
                return rootPath;
            }
        }
    }
    return path;
}

+ (void)initialize { 
    NSBundle* bundle = [NSBundle bundleForClass:[InjectHelper class]];
    NSString* iTunesPatch = [bundle pathForResource:@"ITunes" ofType:nil];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* fullpath;
    
    if ([fileManager fileExistsAtPath:iTunesPatch]) {
        NSArray* ArrPath = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSBundle* mainBundle = [NSBundle mainBundle];
        NSString* bundleName = [mainBundle objectForInfoDictionaryKey:(NSString*)kCFBundleNameKey];
        
        if ([ArrPath count]) {
            NSString* path = [ArrPath objectAtIndex:0];
            fullpath = [path stringByAppendingPathComponent:bundleName];
        }
        else {
            fullpath = NSTemporaryDirectory();
        }
        
        if (![fileManager fileExistsAtPath:fullpath]) {
            [fileManager createDirectoryAtPath:fullpath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSArray* cmd = @[@"-o", iTunesPatch, @"-d", fullpath];
        NSTask* task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/unzip" arguments:cmd];
        [task waitUntilExit];
        
        NSString* iTunesPatch = [fullpath stringByAppendingPathComponent:@"ITunesPatch"];
        if (![task terminationStatus]) {
            if ([fileManager fileExistsAtPath:iTunesPatch]) {
                patchedITunesPath = iTunesPatch;
            }
        }
        
        NSString* virtualDisplay = [fullpath stringByAppendingPathComponent:@"VirtualDisplay.kext"];
        if (![fileManager fileExistsAtPath:virtualDisplay]) {
            NSString* virtualDisplay_kext = [bundle pathForResource:@"VirtualDisplay" ofType:@"kext"];
            [fileManager copyItemAtPath:virtualDisplay_kext toPath:virtualDisplay error:nil];
        }
        patchedKextPath = virtualDisplay;
    }
    else {
        NSLog(@"itunes patch not exist");
    }
}

@end

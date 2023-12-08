//
//  main.m
//  CoreEngineHelper
//
//  Created by ted zhang on 2/6/18.
//  Copyright © 2018 ted zhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[]) {
    char* szInjectPlugin = NULL;
    unsigned long pluginPathLen = 0;
    
    
    szInjectPlugin = getenv("INJECT_PLUGIN");
    if (szInjectPlugin) {
        NSFileManager* sharedFileManager = [NSFileManager defaultManager];
        pluginPathLen = strlen(szInjectPlugin);
        NSString* pluginPath = [sharedFileManager stringWithFileSystemRepresentation:szInjectPlugin length:pluginPathLen];
        NSLog(@"plugin path is %@", pluginPath);
        
        if ([sharedFileManager fileExistsAtPath:pluginPath]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSBundle* bundle = [NSBundle bundleWithPath:pluginPath];
                NSError* error = nil;
                BOOL bRet = [bundle loadAndReturnError:&error];
                if (!bRet) {
                    NSLog(@"load plugin %@ error, %@", pluginPath, error);
                }
            });
        }
    }
    else {
        NSLog(@"can not find plugin");
    }
    
    NSApplication* sharedApplication = [NSApplication sharedApplication];
    [sharedApplication run];
    return 0;
}

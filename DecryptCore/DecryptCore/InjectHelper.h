//
//  InjectHelper.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 2017/10/22.
//  Copyright © 2017年 TedZhang. All rights reserved.
//

#ifndef InjectHelper_h
#define InjectHelper_h

@interface InjectHelper : NSObject {  
}

+ (void) initialize;
+ (NSArray*) applicationVersions:(NSBundle*)bundle;
+ (bool) isUnsupportVersion:(NSArray*)arrVer;
+ (id) ITunesHelperPath;
+ (bool) isSIPEnabled;
+ (int) injectorModeForBundle:(NSBundle*)bundle;
+ (bool) doAuthorizedOperations:(bool(^)(AuthorizationRef)) handle;
+ (NSString*) fixUpdaterPath:(NSString*)path;

@end

typedef enum eOperateMode {
    OPERATE_RECORD_MODE = 0,
    OPERATE_PLUGIN_MODE = 1,
    OPERATE_HELPER_MODE = 2,
    OPERATE_PATCH_MODE = 3,
    OPERATE_SPOTIFY_MODE = 4
} OperateMode;
#endif /* InjectHelper_h */

//
//  VersionComparator.h
//  DecryptCore
//
//  Created by ted zhang on 8/22/18.
//  Copyright © 2018 ted zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

__attribute__((visibility("hidden")))
@interface VersionComparator : NSObject
{
}

+ (id)defaultComparator;
- (long long)compareVersion:(NSString*)bundle_ver toVersion:(NSString*)special_ver;
- (id)splitVersionString:(NSString*)version;
- (int)typeOfCharacter:(NSString*)special_char;

@end


//
//  SystemComm.h
//  FireFury Audio DRM Removal
//
//  Created by ted zhang on 2018/3/3.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/pwr_mgt/IOPMLib.h>

@interface SystemComm : NSObject

+ (IOPMAssertionID)disableSystemSleep;
+ (void)enableSystemSleep:(IOPMAssertionID)assertionID;


@end

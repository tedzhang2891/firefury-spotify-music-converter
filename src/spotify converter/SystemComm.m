//
//  SystemComm.m
//  FireFury Audio DRM Removal
//
//  Created by ted zhang on 2018/3/3.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import "SystemComm.h"

@implementation SystemComm

+ (IOPMAssertionID)disableSystemSleep {
    // kIOPMAssertionTypeNoDisplaySleep prevents display sleep,
    // kIOPMAssertionTypeNoIdleSleep prevents idle sleep
    
    // reasonForActivity is a descriptive string used by the system whenever it needs
    // to tell the user why the system is not sleeping. For example,
    // "Mail Compacting Mailboxes" would be a useful string.
    
    //  NOTE: IOPMAssertionCreateWithName limits the string to 128 characters.
    CFStringRef reasonForActivity= CFSTR("Describe Activity Type");
    
    IOPMAssertionID assertionID;
    IOReturn success = IOPMAssertionCreateWithName(kIOPMAssertionTypeNoDisplaySleep,
                                                   kIOPMAssertionLevelOn, reasonForActivity, &assertionID);
    if (success == kIOReturnSuccess)
    {
        
        // Add the work you need to do without
        // the system sleeping here.
        return assertionID;
        
        // The system will be able to sleep again.
    }
    return 0;
}

+ (void)enableSystemSleep:(IOPMAssertionID)assertionID {
    IOReturn success = IOPMAssertionRelease(assertionID);
}


@end

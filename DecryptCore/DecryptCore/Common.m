//
//  Common.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 12/15/17.
//  Copyright © 2017 TedZhang. All rights reserved.
//

#import "Common.h"
#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>

@implementation Common

+ (id)CreateSignature {
    id value;
    io_iterator_t next;
    io_iterator_t existing;
    IOOptionBits options;
    CFMutableDictionaryRef service_properties;
    kern_return_t kr;
    
    NSMutableData* data = [NSMutableData data];
    CFMutableDictionaryRef ethernetDict = IOServiceMatching("IOEthernetInterface");
    IOServiceGetMatchingServices(kIOMasterPortDefault, ethernetDict, &existing);
    
    next = IOIteratorNext(existing);
    if ( next )
    {
        do
        {
            kr =IORegistryEntryCreateCFProperties(next, &service_properties, kCFAllocatorDefault, options);
            if(kr == KERN_SUCCESS && service_properties)
            {
                NSDictionary* m = (__bridge NSDictionary *)service_properties;
                value = [m objectForKey:@"IOMACAddress"];
                if ( value )
                {
                    [data appendData:value];
                    CFRelease(service_properties);
                }
            }
            next = IOIteratorNext(existing);
        }
        while ( next );
    }
    IOObjectRelease(existing);
    return data;
}

@end

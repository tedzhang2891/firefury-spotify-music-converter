//
//  DurationToStringTransformer.m
//  FireFury DRM Removal
//
//  Created by ted zhang on 2018/1/15.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import "DurationToStringTransformer.h"

@implementation DurationToStringTransformer

- (id)transformedValue:(id)value { 
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    long nValue = [value intValue];
    long p1 = ((1250999897 * nValue) >> 63) + (((1250999897 * nValue) >> 32) >> 20);
    long p2 = (((274877907 * nValue) >> 63) + (((274877907 * nValue) >> 32) >> 6) - 3600 * p1);
    long p3 = ((p2 + ((-2004318071 * p2) >> 32)) >>31) + ((p2 + ((-2004318071 * p2) >> 32)) >> 5);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", p1,p3,(p2 - 60 * p3)];
}

+ (void)initialize { 
    DurationToStringTransformer* transformer = [[DurationToStringTransformer alloc] init];
    [NSValueTransformer setValueTransformer:transformer forName:@"DurationToStringTransformer"];
}

+ (Class)transformedValueClass { 
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation { 
    return NO;
}

@end

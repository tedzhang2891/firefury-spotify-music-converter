//
//  DurationToStringTransformer.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 2018/1/15.
//  Copyright © 2018年 TedZhang. All rights reserved.
//

#import <Foundation/Foundation.h>

__attribute__((visibility("hidden")))
@interface DurationToStringTransformer : NSValueTransformer
{
}

+ (BOOL)allowsReverseTransformation;
+ (Class)transformedValueClass;
+ (void)initialize;
- (id)transformedValue:(id)value;

@end


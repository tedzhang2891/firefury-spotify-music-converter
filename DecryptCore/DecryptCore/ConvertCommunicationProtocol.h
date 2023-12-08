//
//  ConvertCommunicationProtocol.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 2017/12/9.
//  Copyright © 2017年 TedZhang. All rights reserved.
//

#ifndef ConvertCommunicationProtocol_h
#define ConvertCommunicationProtocol_h

#import <Foundation/Foundation.h>

@class NSData, NSDictionary, NSString;

@protocol ConvertCommunicationProtocol <NSObject>
- (BOOL)isPlaying;
- (NSDictionary *)metadata;
- (double)convertedDuration;
- (BOOL)stopConvert;
- (BOOL)convertFile:(NSString *)srcfile output:(NSString *)destfile stopDuration:(double)duration convertSpeed:(NSInteger)speed withProfile:(NSDictionary *)profile contextInfo:(NSData *)data;
- (BOOL)prepareConverterWithProperties:(NSDictionary *)dict;
@end

#endif /* ConvertCommunicationProtocol_h */

//
//  AddWindowControllerProtocol.h
//  FireFury DRM Removal
//
//  Created by ted zhang on 1/3/18.
//  Copyright © 2018 TedZhang. All rights reserved.
//

#ifndef AddWindowControllerProtocol_h
#define AddWindowControllerProtocol_h

@protocol AddWindowControllerProtocol <NSObject>
@property(retain) NSArray *convertedTrackURLs;
- (void)beginSheetWithCompleteHandler:(void (^)(NSArray *))handler;
@end

#endif /* AddWindowControllerProtocol_h */

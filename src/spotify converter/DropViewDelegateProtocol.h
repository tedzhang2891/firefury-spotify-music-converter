//
//  DropViewDelegate-Protocol.h
//  spotify converter
//
//  Created by ted zhang on 8/8/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DropViewDelegate <NSObject>
- (void)URIDidReceived:(NSArray *)URIs forURL:(NSString *)url;
@end


//
//  ITunesChapterUtil.h
//  DecryptCore
//
//  Created by ted zhang on 2018/2/13.
//  Copyright © 2018年 ted zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Appkit/Appkit.h>

__attribute__((visibility("hidden")))
@interface ITunesChapterUtil : NSObject
{
}

+ (id)chaptersFromITunesCurrentTrack;

@end


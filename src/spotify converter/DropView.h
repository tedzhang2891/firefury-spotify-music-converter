//
//  DropView.h
//  spotify converter
//
//  Created by ted zhang on 8/21/18.
//  Copyright © 2018 firefury. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DropViewDelegateProtocol.h"

__attribute__((visibility("hidden")))
@interface DropView : NSView
{
}

@property(retain) IBOutlet id <DropViewDelegate> delegate; // @synthesize delegate=_delegate;
- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender;
- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender;
- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender;
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender;
- (instancetype)initWithCoder:(NSCoder *)decoder;
- (instancetype)initWithFrame:(NSRect)frameRect;

@end



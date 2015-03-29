//
//  StickMan.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-28.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    RUNNING_LEFT,
    RUNNING_RIGHT,
    STANDING,
    FALLING,
    DEAD
}playerState;
@interface StickMan : NSObject

@property playerState state;

- (StickMan*) init;
- (void)drawOpenGLES1;
@end

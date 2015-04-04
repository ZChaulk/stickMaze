//
//  StickMan.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-28.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
typedef enum{
    RUNNING_LEFT,
    RUNNING_RIGHT,
    STANDING,
    FALLING,
    RECOVERING,
    DEAD
}playerState;
@interface StickMan : NSObject{
    
    GLuint _standingID;
    GLuint _runLeftID[3];
    GLuint _runRightID[3];
    GLuint _fallingID[3];
    GLuint _recoveringID[3];
    int runRightTic;
    int runLeftTic;
    int standUpTic;
    int fallingTic;
    int deadTic;
    int maxHealth;
    bool canBeHurt;
    bool isDead;
}
@property playerState state;
@property bool isDead;
@property (nonatomic) int health,levelsCompletedThisGame;
- (void) dealloc;
- (void)loadTexture:(NSString *)file textureID:(GLuint) texID;
- (StickMan*) init;
- (void)drawOpenGLES1:(BOOL)zoomedOut;
- (void)bind;
- (bool) dealDamage;
- (bool) healDamage;
@end

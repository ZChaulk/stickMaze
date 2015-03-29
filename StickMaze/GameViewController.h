//
//  GameViewController.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-28.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>
#import "PauseMenuViewController.h"
#import "StickMan.h"
@protocol GameViewControllerDelegate <NSObject>

-(void)notifyGameDone;

@end

typedef enum{
    NORMAL,
    INVERTED,
    LEFT,
    RIGHT
}gravityBase;

@interface GameViewController : GLKViewController<PauseMenuProtocolDelegate>{
    CMMotionManager *motionMan;
    NSTimer *timer;
    float _avgAccX, _avgAccY, _avgAccZ, gravity;
    StickMan *player;
    gravityBase gBase;
}
@property id<GameViewControllerDelegate> gvDelegate;

- (IBAction)pause:(id)sender;

- (void)setupGL;
- (void)tearDownGL;
- (void)setupOrthographicView;
@property (strong, nonatomic) EAGLContext *context;

@end

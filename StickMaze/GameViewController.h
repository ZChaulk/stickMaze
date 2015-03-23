//
//  UIViewController+GameViewController.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-01.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "PauseMenuViewController.h"

@protocol GameViewControllerDelegate <NSObject>

-(void)notifyGameDone;

@end


@interface GameViewController : GLKViewController<PauseMenuProtocolDelegate>
@property id<GameViewControllerDelegate> gvDelegate;

- (IBAction)pause:(id)sender;

- (void)setupGL;
- (void)tearDownGL;
- (void)setupOrthographicView;
@property (strong, nonatomic) EAGLContext *context;

@end

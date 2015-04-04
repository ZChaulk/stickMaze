//
//  ViewController.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-01.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <GLKit/GLKit.h>

#import "GameViewController.h"
#import "RecordsViewController.h"
#import "StickMan.h"
@interface HomeViewController : GLKViewController<GameViewControllerDelegate, RecordsViewControllerDelegate> {
    StickMan *_homeStick;
    BOOL starting;
    GLfloat xPos, yPos;
    GameViewController *gvc ;
}
- (void)setupGL;
- (void)tearDownGL;
- (void)setupOrthographicView;
@property (strong, nonatomic) EAGLContext *context;

- (IBAction)start:(id)sender;
- (IBAction)records:(id)sender;

@end


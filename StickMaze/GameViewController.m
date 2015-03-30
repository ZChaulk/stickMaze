//
//  GameViewController.m
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-28.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import "GameViewController.h"

#import <OpenGLES/ES1/gl.h>
@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self setUpMotion];
    [self setupGL];
    
}
//motion section****************

- (void)setUpMotion{
    _avgAccX = _avgAccY = _avgAccZ = gravity = 0;
    gBase = NORMAL;
    motionMan = [[CMMotionManager alloc] init];
    if(!motionMan.gyroAvailable){
        NSLog(@"No gyro found.");
        return;
    }
    if(!motionMan.accelerometerAvailable)
    {
        NSLog(@"No accelerometer found.");
        return;
    }
    
    motionMan.accelerometerUpdateInterval = 0.05;
    [motionMan startAccelerometerUpdates];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(pollMotion:) userInfo:nil repeats:YES];
    
}

-(void) pollMotion:(NSTimer *)timer{
    CMAcceleration acc = motionMan.accelerometerData.acceleration;
    float alpha = 0.1;
    _avgAccX = alpha*acc.x + (1-alpha)*_avgAccX;
    _avgAccY = alpha*acc.y + (1-alpha)*_avgAccY;
    _avgAccZ = alpha*acc.z + (1-alpha)*_avgAccZ;
    gravity = atan2f(_avgAccY, _avgAccX)*180/3.14 + 90;
    if(gravity < 0)
        gravity += 360;
    [self updateForces];
}

-(void) updateForces{
    if(fabs(gravity) < 30){
        gBase = NORMAL;
    }
    else if(fabs(gravity - 90) < 30){
        gBase = RIGHT;
    }
    else if(fabs(gravity - 180) < 30){
        gBase = INVERTED;
    }
    else if(fabs(gravity - 270) < 30){
        gBase = LEFT;
    }
    
    float adjustedGravity = gravity;
    if(gBase == RIGHT){
        adjustedGravity -= 90;
    }
    else if(gBase == INVERTED){
        adjustedGravity -= 180;
    }
    else if(gBase == LEFT){
        adjustedGravity -= 270;
    }
    
    if(fabs(adjustedGravity) < 10)
        player.state = STANDING;
    else if(adjustedGravity > 0 && adjustedGravity < 60)
        player.state = RUNNING_RIGHT;
    else if(adjustedGravity >300 && adjustedGravity < 350)
        player.state = RUNNING_LEFT;
    
}

//openGL Section***********

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    player = [[StickMan alloc] init];
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
}
- (void)update
{
    [self setupOrthographicView: self.view.bounds.size];
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

- (void)setupOrthographicView: (CGSize)size
{
    glViewport(0, 0, size.width, size.height);
    float min = MIN(size.width, size.height);
    float width = 2 * size.width / min;
    float height = 2 * size.height / min;
    
    // set up orthographic projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-width, width, -height, height, -2, 2);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // clear the rendering buffer
    glClearColor(1, 0, 0, 1);
    // clear the rendering buffer
    glClear(GL_COLOR_BUFFER_BIT);
    // enable the vertex array rendering
    glEnableClientState(GL_VERTEX_ARRAY);
    [player drawOpenGLES1];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pause:(id)sender {
    //show pauseMenu
    PauseMenuViewController *pmvc = [[PauseMenuViewController alloc] initWithNibName:@"PauseMenuViewController" bundle:nil];
    pmvc.delegate = self;
    [self presentViewController:pmvc animated:YES completion:nil];
}

-(void)resumeGame:(PauseMenuViewController *)pauseMenuViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)endGame:(PauseMenuViewController *)pauseMenuViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.gvDelegate notifyGameDone];
    
}


@end

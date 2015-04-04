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
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    _scoreCon = [[ScoreController alloc] init];
    zoomedOut = NO;
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
    
    startUpAcceleratorVal = 0;
    
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
    //inital value of 0 causes game to start on right angle.  small counter to wait for accelerometer to adjust.
    if(startUpAcceleratorVal > 5)
        [self updateForces];
    else
        startUpAcceleratorVal++;
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
    if(adjustedGravity < 0)
        adjustedGravity += 360;
    
    if(player.state != FALLING && player.state != RECOVERING){
        if(fabs(adjustedGravity) < 10)
            player.state = STANDING;
        else if(adjustedGravity > 0 && adjustedGravity < 60)
            player.state = RUNNING_RIGHT;
        else if(adjustedGravity >300 && adjustedGravity < 350)
        player.state = RUNNING_LEFT;
    }
}

- (void) updateMaze{
    int orientation = 0;
    if(gBase == LEFT)
        orientation = 3;
    else if(gBase == RIGHT)
        orientation = 1;
    else if(gBase == INVERTED)
        orientation = 2;
    GLfloat deltaX = 0;
    GLfloat deltaY = 0;
    \
    if(![mazeModel hitsFloor:orientation]){
        if(orientation == 0)
            deltaY = -0.2;
        else if(orientation == 1) //Right
            deltaX = 0.2;
        else if (orientation == 2) //Inverted
            deltaY = 0.2;
        else//Left
            deltaX = -0.2;
        player.state = FALLING;
    }
    else if(player.state == FALLING){
        player.state = RECOVERING;
    }
    else if(player.state == RUNNING_RIGHT){
        if(orientation == 0) // normal
            deltaX = 0.1;
        else if(orientation == 1) //Right
            deltaY = 0.1;
        else if (orientation == 2) //Inverted
            deltaX = -0.1;
        else //Left
            deltaY = -0.1;
    }
    else if(player.state == RUNNING_LEFT){
        if(orientation == 0) // normal
            deltaX = -0.1;
        else if(orientation == 1) //Right
            deltaY = -0.1;
        else if (orientation == 2) //Inverted
            deltaX = 0.1;
        else //Left
            deltaY = 0.1;
    }
    
    [mazeModel moveStick:deltaX y:deltaY orientation:orientation];
    //first check to see if we've reached the end
    if([mazeModel hitsGoal]) {
        //add a victory animation
        
        //try to add one to the player's health
        zoomedOut = YES;
        [player healDamage];
        //iterate the player's score
        player.levelsCompletedThisGame++;
        self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", player.levelsCompletedThisGame];
        //make a new level for the player to play
        int oldLen = mazeModel.len;
        oldLen = (oldLen <= 25)? (oldLen+1) : oldLen;
        mazeModel = [[MazeModel alloc] initWithSize:oldLen];
    }
    //finally, check to see if we've hit any spikes
    if([mazeModel hitsSpikes:orientation]) {
        //see if we will deal damage to the player
        if([player dealDamage]) { //damage dealt, player still alive
            
        }
        else {
            //kill the player and all that
            
            //update the scores
            [_scoreCon updateScores:player.levelsCompletedThisGame];
            [_scoreCon saveScores];
        }
    }
    self.lifeLabel.text = [NSString stringWithFormat:@"Life: %d", player.health];
}
//openGL Section***********

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    player = [[StickMan alloc] init];
    mazeModel = [[MazeModel alloc] initWithSize:3];
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
    glClear(GL_COLOR_BUFFER_BIT);
    // enable the vertex array rendering
    glEnableClientState(GL_VERTEX_ARRAY);
    
   
    
    glPushMatrix();{
        if(!zoomedOut)
            [self updateMaze];
        [mazeModel drawOpenGLES1:zoomedOut];
    }glPopMatrix();
    
    glPushMatrix();{
        if(zoomedOut){
            
            glScalef(1./mazeModel.len, 1./mazeModel.len, 1./mazeModel.len);
            glTranslatef(mazeModel._playerXPos*mazeModel._playerScale, mazeModel._playerYPos*mazeModel._playerScale, 0);
            glTranslatef(-mazeModel.len*mazeModel._playerScale/2, -mazeModel.len*mazeModel._playerScale/2, 0);
        }
        if(gBase == LEFT){
            
            glRotatef(-90, 0, 0, 1);
        }
        else if(gBase == RIGHT){
           // glTranslatef(-0.15, 0, 0);
            glRotatef(90, 0, 0, 1);
        }
        else if(gBase == INVERTED){
            glRotatef(180, 0, 0, 1);
        }
    
        [player drawOpenGLES1:zoomedOut];
    }glPopMatrix();
}

- (IBAction)displayGestureForTapRecognizer:(UITapGestureRecognizer *)recognizer{
    zoomedOut = !zoomedOut;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pause:(id)sender {
    //show pauseMenu
    PauseMenuViewController *pmvc = [[PauseMenuViewController alloc] initWithNibName:@"PauseMenuViewController" bundle:nil];
    pmvc.delegate = self;
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [motionMan stopAccelerometerUpdates];
    [motionMan stopGyroUpdates];
    [self presentViewController:pmvc animated:YES completion:nil];
}

-(void)resumeGame:(PauseMenuViewController *)pauseMenuViewController{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    [motionMan startAccelerometerUpdates];
    [motionMan startGyroUpdates];
}

-(void)endGame:(PauseMenuViewController *)pauseMenuViewController{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
    [_scoreCon updateScores:player.levelsCompletedThisGame];
    [_scoreCon saveScores];
    [self.gvDelegate notifyGameDone];
    
}



@end

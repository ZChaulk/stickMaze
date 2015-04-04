//
//  HomeViewController.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-01.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import "HomeViewController.h"

#import <OpenGLES/ES1/gl.h>
@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    [self resetAnimation];
    
}
- (void)update
{
    [self setupOrthographicView];
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    
    _homeStick = [[StickMan alloc] init];
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}

- (void)setupOrthographicView
{
    // get iPhone display size & aspect ratio
    CGSize size = self.view.bounds.size;
    // set viewport based on display size
    glViewport(0, 0, size.width, size.height);
    
    GLfloat min = MIN(size.width, size.height);
    GLfloat width = 2.0*size.width/min;
    GLfloat height = 2.0*size.height/min;
    
    // set up orthographic projection
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-width, width, -height, height, -2, 2);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(1., 1., 1., 1.);
    // clear the rendering buffer
    glClear(GL_COLOR_BUFFER_BIT);
    // enable the vertex array rendering
    glEnableClientState(GL_VERTEX_ARRAY);
    
    if(starting){
        if(yPos < -0.5)
            yPos += 0.1;
        else if(_homeStick.state == FALLING)
            _homeStick.state = RECOVERING;
        else if(_homeStick.state == STANDING)
            _homeStick.state = RUNNING_RIGHT;
        else if(_homeStick.state == RUNNING_RIGHT && xPos < 3)
            xPos += 0.1;
        else if(xPos >= 3)
            [self openGame];
    }
    glPushMatrix();
    {
        glTranslatef(0, yPos, 0);
        
        glColor4f(0, 0, 0, 1);
        glLineWidth(10);
        glDisable(GL_BLEND);
        glEnable(GL_LINE_SMOOTH);
        GLfloat ground[] = {
            -5.0, yPos,    5.0, yPos
        };
        glVertexPointer(2, GL_FLOAT, 0, ground);
        glDrawArrays(GL_LINES, 0, 2);
        
    }
    glPopMatrix();
    glPushMatrix();
    {
        glTranslatef(xPos, 0, 0);
        [_homeStick drawOpenGLES1:NO];
    }
    glPopMatrix();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender {
    gvc = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    gvc.gvDelegate = self;
    starting = YES;
    
}

- (void) openGame{
    [self resetAnimation];
    [self presentViewController:gvc animated:NO completion:nil];
}

- (void) resetAnimation{
    xPos = 0.0;
    yPos = -3.0;
    starting = NO;
    
    _homeStick.state = FALLING;
}

- (IBAction)records:(id)sender {
    RecordsViewController *rvc = [[RecordsViewController alloc] initWithNibName:@"RecordsViewController" bundle:nil];
    rvc.delegate = self;
    [self presentViewController:rvc animated:YES completion:nil];
}

#pragma GameViewControllerDelegate methods

-(void)notifyGameDone
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)notifyReturn{
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end

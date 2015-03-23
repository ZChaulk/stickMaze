//
//  UIViewController+GameViewController.m
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-01.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES1/gl.h>
@interface GameViewController()

@end

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
    
    [self setupGL];
    
}
- (void)update
{
    [self setupOrthographicView];
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
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
    glOrthof(-width, width, -height, height, -1, 1);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // clear the rendering buffer
    glClear(GL_COLOR_BUFFER_BIT);
    // enable the vertex array rendering
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);
    
    const GLubyte colors[] = {
        0, 0, 0, 255
        
    };
    const GLfloat linePoints[] = {
        0, -0.5, -0.25, -1, //leg1
        0, -0.5, 0.25, -1, //leg2
        0, -0.5, 0, 0.2, //body
        0, 0.18, -0.2, -0.3, //arm1
        0, 0.18, 0.2, -0.3 //arm2 (down)
    };
    
    
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    glVertexPointer(2, GL_FLOAT, 0, linePoints);
    glEnable(GL_LINE_SMOOTH);
    glLineWidth(12);
    glDrawArrays(GL_LINES, 0, 24);
    
    //Draw HEad?
    
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
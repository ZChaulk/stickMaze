//
//  StickMan.m
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-28.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import "StickMan.h"
#import <OpenGLES/ES1/gl.h>
@implementation StickMan

- (StickMan*) init{
    self = [super init];
    if(self){
        self.state = STANDING;
    }
    return self;
}
- (void)drawOpenGLES1
{
    glEnableClientState(GL_VERTEX_ARRAY);
    
    const GLubyte colors[] = {
        0, 0, 0, 255
    };
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, colors);
    glEnable(GL_LINE_SMOOTH);
    glLineWidth(12);
    
    if(self.state == STANDING){
        const GLfloat linePoints[] = {
            0, -0.5, -0.25, -1, //leg1
            0, -0.5, 0.25, -1, //leg2
            0, -0.5, 0, 0.2, //body
            0, 0.18, -0.2, -0.3, //arm1
            0, 0.18, 0.2, -0.3 //arm2 (down)
        };

        glVertexPointer(2, GL_FLOAT, 0, linePoints);
        glDrawArrays(GL_LINES, 0, 10);
    }
    else if(self.state == RUNNING_LEFT){
        const GLfloat linePoints[] = {
            0, -0.5, -0.25, -1, //leg1
            0, -0.5, 0.25, -1, //leg2
            0, -0.5, 0, 0.2, //body
            0, 0.18, -0.2, -0.3, //arm1
        };
        
        glVertexPointer(2, GL_FLOAT, 0, linePoints);
        glDrawArrays(GL_LINES, 0, 8);
    }
    else if(self.state == RUNNING_RIGHT){
        const GLfloat linePoints[] = {
            0, -0.5, -0.25, -1, //leg1
            0, -0.5, 0.25, -1, //leg2
            0, -0.5, 0, 0.2, //body
            0, 0.18, 0.2, -0.3 //arm2 (down)
        };
        
        glVertexPointer(2, GL_FLOAT, 0, linePoints);
        glDrawArrays(GL_LINES, 0, 8);
    }
    else if(self.state == FALLING){
        
    }
    else if(self.state == DEAD){
        
    }
}
@end

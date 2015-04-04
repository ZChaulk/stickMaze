//
//  StickMan.m
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-28.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import "StickMan.h"
#import <UIKit/UIKit.h>
@implementation StickMan

@synthesize health, levelsCompletedThisGame;

- (StickMan*) init{
    self = [super init];
    if(self){
        self.state = STANDING;
        runLeftTic = runRightTic = standUpTic = fallingTic = 0;
        glGenTextures(1, &_standingID);
        glGenTextures(3, _runLeftID);
        glGenTextures(3, _runRightID);
        glGenTextures(3, _fallingID);
        glGenTextures(3, _recoveringID);
        [self loadTexture:@"standing.png" textureID:_standingID];
        [self loadTexture:@"runningLeft1.png" textureID:_runLeftID[0]];
        [self loadTexture:@"runningLeft2.png" textureID:_runLeftID[1]];
        [self loadTexture:@"runningLeft3.png" textureID:_runLeftID[2]];
        [self loadTexture:@"runningRight1.png" textureID:_runRightID[0]];
        [self loadTexture:@"runningRight2.png" textureID:_runRightID[1]];
        [self loadTexture:@"runningRight3.png" textureID:_runRightID[2]];
        [self loadTexture:@"gettingUp1.png" textureID:_recoveringID[0]];
        [self loadTexture:@"gettingUp2.png" textureID:_recoveringID[1]];
        [self loadTexture:@"gettingUp3.png" textureID:_recoveringID[2]];
        [self loadTexture:@"falling1.png" textureID:_fallingID[0]];
        [self loadTexture:@"falling2.png" textureID:_fallingID[1]];
        [self loadTexture:@"falling3.png" textureID:_fallingID[2]];
        maxHealth = 8;
        self.health = 4;
        canBeHurt = true;
        
        self.levelsCompletedThisGame = 0;
    }
    return self;
}
- (void)dealloc{
    glDeleteTextures(1, &_standingID);
}

- (void)loadTexture:(NSString *)file textureID:(GLuint) texID{
    CGImageRef texImage = [UIImage imageNamed:file].CGImage;
    if ( ! texImage ) {
        NSLog(@"Texture file not found!");
        return;
    }
    
    int texWidth = (int)CGImageGetWidth(texImage);
    int texHeight = (int)CGImageGetHeight(texImage);
    CGColorSpaceRef colorspace = CGImageGetColorSpace(texImage);
    
 
        GLubyte *texData = (GLubyte*)malloc(texWidth * texHeight * 4);
        
        CGContextRef texContext = CGBitmapContextCreate(texData, texWidth, texHeight, 8, texWidth*4, colorspace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        CGContextDrawImage(texContext, CGRectMake(0.0, 0.0, (float)texWidth, (float)texHeight), texImage);
        CGContextRelease(texContext);
        
        glBindTexture(GL_TEXTURE_2D, texID);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, texWidth, texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, texData);
        
        free(texData);
    
}

- (void)bind{
    glEnable(GL_TEXTURE_2D);
    
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    if(self.state == STANDING){
        glBindTexture(GL_TEXTURE_2D, _standingID);
        runLeftTic = runRightTic = fallingTic = standUpTic = 0;
    }
    else if(self.state == RUNNING_LEFT){
        glBindTexture(GL_TEXTURE_2D, _runLeftID[runLeftTic/2]);
        runLeftTic++;
        if(runLeftTic/2 > 2)
            runLeftTic = 0;
        
        runRightTic = fallingTic = standUpTic = 0;
    }
    else if(self.state == RUNNING_RIGHT){
        glBindTexture(GL_TEXTURE_2D, _runRightID[runRightTic/2]);
        runRightTic++;
        if(runRightTic/2> 2)
            runRightTic = 0;
        runLeftTic = fallingTic = standUpTic = 0;
    }
    else if(self.state == FALLING){
         glBindTexture(GL_TEXTURE_2D, _fallingID[fallingTic/2]);
        fallingTic++;
        if(fallingTic/2 > 2)
            fallingTic = 0;
        runLeftTic = runRightTic = standUpTic = 0;
    }
    else if(self.state == RECOVERING){
         glBindTexture(GL_TEXTURE_2D, _recoveringID[standUpTic/3]);
        standUpTic++;
        if(standUpTic/3 > 2){
            standUpTic =  0;
            self.state = STANDING;
        }
        runLeftTic = runRightTic = fallingTic = 0;
    }
    else if(self.state == DEAD){
        
    }
      
};

- (void)drawOpenGLES1:(BOOL)zoomedOut{
    const GLfloat square[] = {
        // pos  tex
        -0.5,1,   0,0,
        0.5,1,  1,0,
        -0.5,-1,   0,1,
        0.5,-1,  1,1
    };
    glColor4f(1, 1, 1, 1);
    glDisableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // set up the transformation for models
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    glVertexPointer(2, GL_FLOAT, 16, square);
    glTexCoordPointer(2, GL_FLOAT, 16, &square[2]);
    
    if(zoomedOut)
        glBindTexture(GL_TEXTURE_2D, _standingID);
    else
        [self bind];
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
}

- (bool) dealDamage { //return true if the player is alive
    if(canBeHurt) {
        self.health--;
        if(self.health > 0) {
            //set the invulnerability
            canBeHurt = false;
            //trigger the timer to turn off invulnerability
            [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(setVulnerable) userInfo:nil repeats:NO];
            return true;
        }
        else {
            return false; //we have died
        }
    }
    return true;
}

- (bool) healDamage { //return true if the player is healed
    if(self.health < maxHealth) { //the player can be healed
        self.health++;
        return true;
    }
    else { //the player is currently at full health
        return false;
    }
}

- (void) setInvulnerable {
    canBeHurt = false;
}
- (void) setVulnerable {
    canBeHurt = true;
}

@end

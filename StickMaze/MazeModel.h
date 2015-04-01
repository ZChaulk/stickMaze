//
//  MazeModel.h
//  StickMaze
//
//  Created by Jacob Frederick Parsons on 2015-03-29.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>

#ifndef StickMaze_MazeModel_h
#define StickMaze_MazeModel_h

@interface MazeModel : NSObject {
    //int _len;
    int _startX, _startY, _exitX, _exitY;
    int _playerScale;
    int _playerXOffset, _playerYOffset;
    GLfloat _playerXPos, _playerYPos;
}
@property (nonatomic) int len, goalX, goalY;

@property (nonatomic) GLfloat _playerXPos;
@property (nonatomic) GLfloat _playerYPos;
@property (nonatomic) int _playerScale;
@property (nonatomic) NSMutableArray *mazeCells;

- (MazeModel*) initWithSize:(int) sizeIn;
- (void) drawOpenGLES1:(BOOL)zoomedOut;
- (void) moveStick:(GLfloat)deltaX y:(GLfloat)deltaY orientation:(int)orientation;
- (BOOL) hitsFloor:(int)orientation;
- (BOOL) hitsSpikes:(int)orientation;
- (BOOL) hitsGoal;
@end

#endif

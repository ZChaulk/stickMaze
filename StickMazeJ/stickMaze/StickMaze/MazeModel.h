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

@property (nonatomic) int len;
@property (nonatomic) NSMutableArray *mazeCells;

- (MazeModel*) initWithSize:(int) sizeIn;
- (void) drawOpenGLES1;
- (void) moveStick:(GLfloat)deltaX y:(GLfloat)deltaY orientation:(int)orientation;
- (BOOL) hitsFloor:(int)orientation;
@end

#endif

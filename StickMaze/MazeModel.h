//
//  MazeModel.h
//  StickMaze
//
//  Created by Jacob Frederick Parsons on 2015-03-29.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#ifndef StickMaze_MazeModel_h
#define StickMaze_MazeModel_h

@interface MazeModel : NSObject {
    //int _len;
    int _startX, _startY, _exitX, _exitY;
}

@property (nonatomic) int len;
@property (nonatomic) NSMutableArray *mazeCells;

- (MazeModel*) initWithSize:(int) sizeIn;

@end

#endif

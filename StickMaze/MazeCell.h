//
//  MazeCell.h
//  StickMaze
//
//  Created by Jacob Frederick Parsons on 2015-03-29.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#ifndef StickMaze_MazeCell_h
#define StickMaze_MazeCell_h

@interface MazeCell : NSObject {
    
}

@property (nonatomic) bool wasSetUp;
@property (nonatomic) bool northExit, southExit, eastExit, westExit;
@property (nonatomic) bool northSpike, southSpike, eastSpike, westSpike;


- (MazeCell*) init;

@end

#endif

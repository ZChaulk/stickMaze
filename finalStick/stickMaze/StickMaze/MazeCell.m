//
//  MazeCell.m
//  StickMaze
//
//  Created by Jacob Frederick Parsons on 2015-03-29.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MazeCell.h"

@implementation MazeCell

@synthesize wasSetUp;
@synthesize northExit, southExit, eastExit, westExit;
@synthesize northSpike, southSpike, eastSpike, westSpike;

- (MazeCell*) init {
    self = [super init];
    if(self){
        //set everything up
        self.northExit = self.southExit = self.eastExit = self.westExit = false;
        self.northSpike = self.southSpike = self.eastSpike = self.westSpike = false;
        self.wasSetUp = false;
    }
    return self;
}

@end
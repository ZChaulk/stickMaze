//
//  MazeModel.m
//  StickMaze
//
//  Created by Jacob Frederick Parsons on 2015-03-29.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdlib.h>
#import "MazeModel.h"
#import "MazeCell.h"

@implementation MazeModel

@synthesize len;
@synthesize mazeCells;

- (MazeModel*) initWithSize:(int) sizeIn {
    self = [super init];
    if(self){
        //allocate the maze using the size
        self.len = sizeIn;
        self.mazeCells = [[NSMutableArray alloc] initWithCapacity:self.len];
        for(int i = 0; i < self.len; i++) {
            NSMutableArray *col = [[NSMutableArray alloc] initWithCapacity:self.len];
            for(int j = 0; j < self.len; j++) {
                [col insertObject:[[MazeCell alloc] init] atIndex:j];
            }
            [self.mazeCells insertObject:col atIndex:i];
        }
        //randomly choose a goal position
        int goalX = arc4random() % self.len;
        int goalY = arc4random() % self.len;
        //initialize the maze
        [self mazeSetup:goalX yPosition:goalY];
        //randomly put in the spikes
        
        //randomly select an edge position to start from
        int xEdge = arc4random() % 2;
        int yEdge = arc4random() % 2;
        int enterPos =arc4random() % self.len;
        //set that starting position
        
    }
    return self;
}

- (void) mazeSetup:(int) xPos yPosition:(int) yPos {
    //mark the current cell visited
    MazeCell *currentCell = self.mazeCells[xPos][yPos];
    currentCell.wasSetUp = true;
    //recursively configure the maze
    bool cellComplete = false;
    while(!cellComplete) {
        //1.) see if we can continue from this cell. if not, return
        int availableCells = 0;
        //north, south, east, west
        bool addrAvail[] = {false, false, false, false};
        MazeCell *entry;
        if(yPos > 0) { //north
            entry = self.mazeCells[xPos][yPos-1];
            if(!entry.wasSetUp) {
                availableCells++;
                addrAvail[0] = true;
            }
        }
        if(yPos < (self.len-1)) { //south
            entry = self.mazeCells[xPos][yPos+1];
            if(!entry.wasSetUp) {
                availableCells++;
                addrAvail[1] = true;
            }
        }
        if(xPos < (self.len-1)) { //east
            entry = self.mazeCells[xPos+1][yPos];
            if(!entry.wasSetUp) {
                availableCells++;
                addrAvail[2] = true;
            }
        }
        if(xPos > 0) { //west
            entry = self.mazeCells[xPos-1][yPos];
            if(!entry.wasSetUp) {
                availableCells++;
                addrAvail[3] = true;
            }
        }
        if(availableCells <= 1) {
            cellComplete = true;
            if(availableCells == 0) { continue; }
        }
        //2.) choose the cell to edit
        int cellToEnter = arc4random() % availableCells;
        for(int i = 0; i < 4; i++) {
            if(!addrAvail[i]) { cellToEnter++; }
            if(i == cellToEnter) { break; }
        }
        if(cellToEnter == 0) { //go north
            [self mazeSetup:xPos yPosition:yPos-1];
            //set the exit for this cell
            currentCell.northExit = true;
            //set the exit for the next cell
            entry = self.mazeCells[xPos][yPos-1];
            entry.southExit = true;
        }
        else if(cellToEnter == 1){ //go south
            [self mazeSetup:xPos yPosition:yPos+1];
            currentCell.southExit = true;
            //set the exit for the next cell
            entry = self.mazeCells[xPos][yPos+1];
            entry.northExit = true;
        }
        else if(cellToEnter == 2){ //"go east" - Elvis Presley
            [self mazeSetup:xPos+1 yPosition:yPos];
            currentCell.eastExit = true;
            //set the exit for the next cell
            entry = self.mazeCells[xPos+1][yPos];
            entry.westExit = true;
        }
        else{ //go west
            [self mazeSetup:xPos-1 yPosition:yPos];
            currentCell.westExit = true;
            //set the exit for the next cell
            entry = self.mazeCells[xPos-1][yPos];
            entry.eastExit = true;
        }
    }
}

@end
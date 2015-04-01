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
#import <CoreGraphics/CoreGraphics.h>
@implementation MazeModel

@synthesize len;
@synthesize mazeCells;

- (MazeModel*) initWithSize:(int) sizeIn {
    self = [super init];
    if(self){
        _playerScale = 3;
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
//        int xEdge = arc4random() % 2;
//        int yEdge = arc4random() % 2;
//        int enterPos =arc4random() % self.len;
        //set that starting position
        _playerXOffset = 0.5*_playerScale;
        _playerYOffset = 1.;
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

- (void) drawOpenGLES1{
    
    glTranslatef(-_playerXPos*_playerScale, -_playerYPos*_playerScale, 0);
    
    MazeCell *cellToDraw;
    int linesToDraw = 0;
    
    GLfloat linesArr[] = { //the array of all potential lines
        0., 0., 0., 0.,
        0., 0., 0., 0.,
        0., 0., 0., 0.,
        0., 0., 0., 0.
    };
    glColor4f(0, 0, 0, 1);
    glLineWidth(20.);
    glDisable(GL_BLEND);
    glEnable(GL_LINE_SMOOTH);
    //translate and rotate as required
    glTranslatef(-_playerXOffset, -_playerYOffset, 0.);
    
    //draw each applicable line for each cell of the maze
    for(int i = 0; i < self.len; i++) {
        for(int j = 0; j < self.len; j++) {
            linesToDraw = 0; //reset the number of lines we will draw this time
            cellToDraw = self.mazeCells[i][j]; //get the cell we will draw
            //consider drawing a north wall
            if(!cellToDraw.northExit) {
                //start point for north wall line X
                linesArr[(4*linesToDraw)] = (GLfloat)(_playerScale*i);
                //start point for north wall line Y
                linesArr[(4*linesToDraw)+1] = (GLfloat)(_playerScale*j);
                //end point for north wall line X
                linesArr[(4*linesToDraw)+2] = (GLfloat)(_playerScale*(i+1));
                //end point for north wall line Y
                linesArr[(4*linesToDraw)+3] = (GLfloat)(_playerScale*j);
                linesToDraw++;
            }
            //consider drawing a south wall
            if(!cellToDraw.southExit) {
                //start point for south wall line X
                linesArr[(4*linesToDraw)] = (GLfloat)(_playerScale*i);
                //start point for south wall line Y
                linesArr[(4*linesToDraw)+1] = (GLfloat)(_playerScale*(j+1));
                //end point for south wall line X
                linesArr[(4*linesToDraw)+2] = (GLfloat)(_playerScale*(i+1));
                //end point for south wall line Y
                linesArr[(4*linesToDraw)+3] = (GLfloat)(_playerScale*(j+1));
                linesToDraw++;
            }
            //consider drawing an east wall
            if(!cellToDraw.eastExit) {
                //start point for east wall line X
                linesArr[(4*linesToDraw)] = (GLfloat)(_playerScale*(i+1));
                //start point for east wall line Y
                linesArr[(4*linesToDraw)+1] = (GLfloat)(_playerScale*j);
                //end point for east wall line X
                linesArr[(4*linesToDraw)+2] = (GLfloat)(_playerScale*(i+1));
                //end point for east wall line Y
                linesArr[(4*linesToDraw)+3] = (GLfloat)(_playerScale*(j+1));
                linesToDraw++;
            }
                //consider drawing a west wall
            if(!cellToDraw.westExit) {
                //start point for west wall line X
                linesArr[(4*linesToDraw)] = (GLfloat)(_playerScale*i);
                //start point for west wall line Y
                linesArr[(4*linesToDraw)+1] = (GLfloat)(_playerScale*j);
                //end point for east west line X
                linesArr[(4*linesToDraw)+2] = (GLfloat)(_playerScale*i);
                //end point for east west line Y
                linesArr[(4*linesToDraw)+3] = (GLfloat)(_playerScale*(j+1));
                linesToDraw++;
            }
                //now we will draw this cell
            glVertexPointer(2, GL_FLOAT, 0, linesArr);
           // glColorPointer(4, GL_UNSIGNED_BYTE, 0, lineColor);
            glDrawArrays(GL_LINES, 0, (2*linesToDraw));
        }
    }
    
}


- (void) moveStick:(GLfloat)deltaX y:(GLfloat)deltaY orientation:(int)orientation{
    
    
    GLfloat scaledDeltaX = deltaX/_playerScale;
    GLfloat scaledDeltaY = deltaY/_playerScale;
    GLfloat actualXOffset = 0;
    GLfloat actualYOffset = 0;
    //switched if on side.
    if( orientation == 0 || orientation == 2){
        actualXOffset = _playerXOffset;
        actualYOffset = _playerYOffset;
    }
    else if (orientation == 1 || orientation == 3){
        actualXOffset = _playerYOffset;
        actualYOffset = _playerXOffset;
    }
    

    MazeCell *cell = self.mazeCells[(int)floorf(_playerXPos)][(int)floorf(_playerYPos)];
    
    if(_playerYPos + scaledDeltaY >= 0 && _playerYPos + scaledDeltaY <= self.len){
        if(scaledDeltaY > 0){
            if (cell.southExit) {
                _playerYPos += scaledDeltaY;
            }
            else if(ceilf(_playerYPos) == 0 &&
                    _playerYPos < actualYOffset)
                _playerYPos += scaledDeltaY;
            else if(_playerYPos < ceilf(_playerYPos) - actualYOffset/2. - 0.12)
                _playerYPos += scaledDeltaY;
            
        }
        else if(scaledDeltaY < 0){
            if (cell.northExit) {
                _playerYPos += scaledDeltaY;
            }
            else if(_playerYPos > floorf(_playerYPos) + 0.08)
                _playerYPos += scaledDeltaY;
            
        }
    }

    if(_playerXPos + scaledDeltaX >= 0 && _playerXPos + scaledDeltaX <= self.len){
        if(scaledDeltaX > 0){
            if (cell.eastExit) {
                _playerXPos += scaledDeltaX;
            }
            else if(ceilf(_playerXPos) == 0 &&
                    _playerXPos < actualXOffset)
                 _playerXPos += scaledDeltaX;
            else if(_playerXPos < ceilf(_playerXPos) - actualXOffset/2. - 0.08)
                _playerXPos += scaledDeltaX;
                
        }
        else if(scaledDeltaX < 0){
            if (cell.westExit) {
                _playerXPos += scaledDeltaX;
            }
            else if(_playerXPos > floorf(_playerXPos) + 0.05)
                _playerXPos += scaledDeltaX;

        }
    }
}


- (BOOL) hitsFloor:(int)orientation{
    MazeCell *cell = self.mazeCells[(int)floorf(_playerXPos)][(int)floorf(_playerYPos)];
    GLfloat actualXOffset = orientation%2 == 0 ? _playerXOffset : _playerYOffset;
    GLfloat actualYOffset = orientation%2 == 0 ? _playerYOffset : _playerXOffset;
    
    if(_playerYPos >= 0 && _playerYPos <= self.len){
//        if(scaledDeltaY > 0){
//            if (cell.southExit) {
//                _playerYPos += scaledDeltaY;
//            }
//            else if(ceilf(_playerYPos) == 0 &&
//                    _playerYPos < actualYOffset)
//                _playerYPos += scaledDeltaY;
//            else if(_playerYPos < ceilf(_playerYPos) - actualYOffset/2.)
//                _playerYPos += scaledDeltaY;
//            
//        }
//        else if(scaledDeltaY < 0){
//            if (cell.northExit) {
//                _playerYPos += scaledDeltaY;
//            }
//            else if(_playerYPos > floorf(_playerYPos))
//                _playerYPos += scaledDeltaY;
//            
//        }
    }
    
    if(_playerXPos >= 0 && _playerXPos <= self.len){
//        if(scaledDeltaX > 0){
//            if (cell.eastExit) {
//                _playerXPos += scaledDeltaX;
//            }
//            else if(ceilf(_playerXPos) == 0 &&
//                    _playerXPos < actualXOffset)
//                _playerXPos += scaledDeltaX;
//            else if(_playerXPos < ceilf(_playerXPos) - actualXOffset/2. - 0.1)
//                _playerXPos += scaledDeltaX;
//            
//        }
//        else if(scaledDeltaX < 0){
//            if (cell.westExit) {
//                _playerXPos += scaledDeltaX;
//            }
//            else if(_playerXPos > floorf(_playerXPos))
//                _playerXPos += scaledDeltaX;
//            
//        }
    }
    return true;
}



@end
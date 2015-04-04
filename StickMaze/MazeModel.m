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
@synthesize _playerXPos;
@synthesize _playerYPos;
@synthesize _playerScale;
@synthesize len, goalX, goalY;
@synthesize mazeCells;

- (MazeModel*) initWithSize:(int) sizeIn {
    self = [super init];
    if(self){
        _playerScale = 3;
        _spikeGenProbability = 5*4;// 4 walls/tile, 1 spike/4 tiles (not exactly since we discount doors but a little less is OK)
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
        self.goalX = (arc4random() % (self.len-1))+1;
        self.goalY = (arc4random() % (self.len-1))+1;
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
    //if the cell is complete we can add spikes
    
    //don't want spikes on the start or the goal
    if( (xPos != self.goalX || yPos != self.goalY) && (xPos != 0 || yPos != 0) ) {
        bool spikeChance;
        if(!currentCell.northExit) {
            spikeChance = ((arc4random()%_spikeGenProbability) < 1.);
            currentCell.northSpike = spikeChance;
        }
        if(!currentCell.southExit) {
            spikeChance = ((arc4random()%_spikeGenProbability) < 1.);
            currentCell.southSpike = spikeChance;
        }
        if(!currentCell.eastExit) {
            spikeChance = ((arc4random()%_spikeGenProbability) < 1.);
            currentCell.eastSpike = spikeChance;
        }
        if(!currentCell.westExit) {
            spikeChance = ((arc4random()%_spikeGenProbability) < 1.);
            currentCell.westSpike = spikeChance;
        }
    }
}

- (void) drawOpenGLES1:(BOOL)zoomedOut{
    
    
    
    MazeCell *cellToDraw;
    int linesToDraw = 0;
    GLfloat linesArr[] = { //the array of all potential lines
        0., 0., 0., 0.,
        0., 0., 0., 0.,
        0., 0., 0., 0.,
        0., 0., 0., 0.
    };
    GLfloat spikeLines[] = {
        0., 0., 0., 0.,
        0., 0., 0., 0.,
        0., 0., 0., 0.,
        0., 0., 0., 0.,
        0., 0.
    };
    GLfloat spikeScaledX, spikeScaledY, scaledIter;
    glColor4f(0, 0, 0, 1);
    
    if(zoomedOut){
        glScalef(1./self.len, 1./self.len, 1./self.len);
        glTranslatef(-self.len*_playerScale/2, -self.len*_playerScale/2, 0);
        
        glLineWidth(10.);
        
    }
    else{
        glLineWidth(20.);
        glTranslatef(-_playerXPos*_playerScale, -_playerYPos*_playerScale, 0);
        
    }
    glDisable(GL_BLEND);
    glEnable(GL_LINE_SMOOTH);
    //translate and rotate as required
    glTranslatef(-_playerXOffset/2. , -_playerYOffset/2., 0.);
    
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
                
                //consider drawing spikes
                if(cellToDraw.northSpike) {
                    spikeScaledX = (_playerScale*i); spikeScaledY = (_playerScale*j);
                    scaledIter = 0.25 * _playerScale;
                    for(int k = 0; k < 4; k++) { //there are four spikes on a spiked tile
                        spikeLines[(4*k)] = spikeScaledX + (scaledIter*k); //x1
                        spikeLines[(4*k)+1] = spikeScaledY; //y1
                        
                        spikeLines[(4*k)+2] = spikeScaledX + (scaledIter*k) + (scaledIter/2); //x2
                        spikeLines[(4*k)+3] = spikeScaledY + (scaledIter); //y2
                    }
                    //add the last point
                    spikeLines[16] = spikeScaledX + (_playerScale); spikeLines[17] = spikeScaledY;
                    glVertexPointer(2, GL_FLOAT, 0, spikeLines);
                    glDrawArrays(GL_LINE_STRIP, 0, 9);
                }
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
                
                //consider drawing spikes
                if(cellToDraw.southSpike) {
                    spikeScaledX = (_playerScale*i); spikeScaledY = (_playerScale*j);
                    scaledIter = 0.25 * _playerScale;
                    for(int k = 0; k < 4; k++) { //there are four spikes on a spiked tile
                        spikeLines[(4*k)] = spikeScaledX + (scaledIter*k); //x1
                        spikeLines[(4*k)+1] = spikeScaledY + (_playerScale); //y1
                        
                        spikeLines[(4*k)+2] = spikeScaledX + (scaledIter*k) + (scaledIter/2); //x2
                        spikeLines[(4*k)+3] = spikeScaledY + (_playerScale) - (scaledIter); //y2
                    }
                    //add the last point
                    spikeLines[16] = spikeScaledX + (_playerScale); spikeLines[17] = spikeScaledY + (_playerScale);
                    glVertexPointer(2, GL_FLOAT, 0, spikeLines);
                    glDrawArrays(GL_LINE_STRIP, 0, 9);
                }
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
                
                //consider drawing spikes
                if(cellToDraw.eastSpike) {
                    spikeScaledX = (_playerScale*i); spikeScaledY = (_playerScale*j);
                    scaledIter = 0.25 * _playerScale;
                    for(int k = 0; k < 4; k++) { //there are four spikes on a spiked tile
                        spikeLines[(4*k)] = spikeScaledX + _playerScale; //x1
                        spikeLines[(4*k)+1] = spikeScaledY + (scaledIter*k); //y1
                        
                        spikeLines[(4*k)+2] = spikeScaledX + _playerScale - scaledIter; //x2
                        spikeLines[(4*k)+3] = spikeScaledY + (scaledIter/2) + (scaledIter*k); //y2
                    }
                    //add the last point
                    spikeLines[16] = spikeScaledX + (_playerScale); spikeLines[17] = spikeScaledY + (_playerScale);
                    glVertexPointer(2, GL_FLOAT, 0, spikeLines);
                    glDrawArrays(GL_LINE_STRIP, 0, 9);
                }
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
                
                //consider drawing spikes
                if(cellToDraw.westSpike) {
                    spikeScaledX = (_playerScale*i); spikeScaledY = (_playerScale*j);
                    scaledIter = 0.25 * _playerScale;
                    for(int k = 0; k < 4; k++) { //there are four spikes on a spiked tile
                        //(x1, y1)->spike root in wall
                        spikeLines[(4*k)] = spikeScaledX; //x1
                        spikeLines[(4*k)+1] = spikeScaledY + (scaledIter*k); //y1
                        
                        //(x2, y2)->spike point
                        spikeLines[(4*k)+2] = spikeScaledX + scaledIter; //x2
                        spikeLines[(4*k)+3] = spikeScaledY + (scaledIter*k) + (scaledIter/2); //y2
                    }
                    //add the last point
                    spikeLines[16] = spikeScaledX; spikeLines[17] = spikeScaledY + (_playerScale);
                    glVertexPointer(2, GL_FLOAT, 0, spikeLines);
                    glDrawArrays(GL_LINE_STRIP, 0, 9);
                }
            }
            //consider drawing a background
            if((i == self.goalX && j == self.goalY) || (i==0 && j==0)) {
                if(i==0 && j==0) { glColor4f(1., 0., 0., 1.); } //draw a red background for the start
                else { glColor4f(0., 1., 0., 1.); } //draw a green background for the goal
                GLfloat goalBg[] = {
                    //triangle one
                    (_playerScale*i), (_playerScale*j),
                    (_playerScale*(i+1)), (_playerScale*j),
                    (_playerScale*i), (_playerScale*(j+1)),
                    //triangle two
                    (_playerScale*(i+1)), (_playerScale*(j+1))
                };
                glVertexPointer(2, GL_FLOAT, 0, goalBg);
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
                glColor4f(0., 0., 0., 1.); //back in black
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
    //switched if on side. (left and right map to 1 and 3, which are odd)
    GLfloat actualXOffset = orientation%2 == 0 ? _playerXOffset : _playerYOffset;
    GLfloat actualYOffset = orientation%2 == 0 ? _playerYOffset : _playerXOffset;
    
    MazeCell *cell = self.mazeCells[(int)floorf(_playerXPos)][(int)floorf(_playerYPos)];
    
    
    if(_playerYPos + scaledDeltaY >= 0 && _playerYPos + scaledDeltaY <= self.len){
        if(scaledDeltaY > 0){
            if (cell.southExit) {
                _playerYPos += scaledDeltaY;
            }
            else if(ceilf(_playerYPos) == 0 &&
                    _playerYPos < actualYOffset)
                _playerYPos += scaledDeltaY;
            else if(_playerYPos < ceilf(_playerYPos) - actualYOffset/2.)
                _playerYPos += scaledDeltaY;
            
        }
        else if(scaledDeltaY < 0){
            if (cell.northExit) {
                _playerYPos += scaledDeltaY;
            }
            else if(_playerYPos > floorf(_playerYPos) + 0.1)
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
            else if(_playerXPos < ceilf(_playerXPos) - actualXOffset/2.)
                _playerXPos += scaledDeltaX;
                
        }
        else if(scaledDeltaX < 0){
            if (cell.westExit) {
                _playerXPos += scaledDeltaX;
            }
            else if(_playerXPos > floorf(_playerXPos) + 0.1)
                _playerXPos += scaledDeltaX;

        }
    }
}


- (BOOL) hitsFloor:(int)orientation{
    
    MazeCell *cell = self.mazeCells[(int)floorf(_playerXPos)][(int)floorf(_playerYPos)];
    GLfloat actualXOffset = orientation%2 == 0 ? _playerXOffset : _playerYOffset;
    GLfloat actualYOffset = orientation%2 == 0 ? _playerYOffset : _playerXOffset;
    
    if(orientation == 0){
        if(cell.northExit)
            return false;
        else
            return _playerYPos < floorf(_playerYPos) + 0.1;
    }
    else if(orientation == 1){
        if(cell.eastExit)
            return false;
        else if(ceilf(_playerXPos) == 0)
            return _playerXPos > actualXOffset;
        else
            return _playerXPos > ceilf(_playerXPos) - actualXOffset/2. - 0.1;
    }
    else if(orientation == 2){
        if(cell.southExit)
            return false;
        else if(ceilf(_playerYPos) == 0)
            return _playerYPos < actualYOffset;
        else
            return _playerYPos > ceilf(_playerYPos) - actualYOffset/2. - 0.1;
    }
    else if(orientation == 3){
        if(cell.westExit)
            return false;
        else
            return _playerXPos < floorf(_playerXPos) + 0.1;
    }

    return true;
}


- (BOOL) hitsSpikes:(int)orientation {
//    GLfloat lol = _playerXPos;
//    GLfloat lols = _playerYPos;
    
    if(orientation == 0){
        
    }
    else if(orientation == 1){
        
    }
    else if(orientation == 2){
        
    }
    else if(orientation == 3){
        
    }
    return false;
}

- (BOOL) hitsGoal {
    if( ( floor( _playerXPos ) == self.goalX ) && ( floor( _playerYPos ) == self.goalY) ) {
        NSLog(@"GOAL REACHED");
        return true;
    }
    else {
        return false;
    }
}



@end
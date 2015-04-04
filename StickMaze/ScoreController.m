//
//  ScoreController.m
//  StickMaze
//
//  Created by Jacob Frederick Parsons on 2015-04-04.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ScoreController.h"

@implementation ScoreController

- (void) updateScores:(int)lastGameScore {
    _gameScores[0] = _gameScores[0] + lastGameScore;
    for(int i = 1; i < 6; i++) {
        if(lastGameScore > _gameScores[i]) {
            int tempLast = lastGameScore;
            int tempNext;
            for(int j = i; j < 6; j++) {
                tempNext = _gameScores[i];
                _gameScores[i] = tempLast;
                tempLast = tempNext;
            }
            break; //jump out of the loop or else we'll just duplicate the new score all down the list
        }
    }
    NSArray *emptyScores = @[@0, @0, @0, @0, @0, @0];

    _scores = [[NSMutableArray alloc] initWithArray:emptyScores];
    for(int i = 0; i < 6; i++) {
        [_scores replaceObjectAtIndex:i withObject:@(_gameScores[i])];
    }
    
}

//we should have a 6-place array. It will contain the total aggregate score
//followed by the top five scores
- (void) loadScores {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    NSString *path = [docsDir stringByAppendingPathComponent:@"scores.plist"];
    
    _scores = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    if([_scores count] != 6) {
        NSArray *emptyScores = @[@0, @0, @0, @0, @0, @0];
        _scores = [[NSMutableArray alloc] initWithArray:emptyScores];
    }
    
    //duplicate the values we loaded into our integer array
    for(int i = 0; i < 6; i++) {
        _gameScores[i] = [[_scores objectAtIndex:i] integerValue];
    }
}

- (bool) saveScores {
    //set up the scores we will write to file
    if([_scores count] < 6) { [self loadScores]; }
    NSMutableArray *topScores = [[NSMutableArray alloc] initWithArray:_scores];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [paths objectAtIndex:0];
    NSString *path = [docsDir stringByAppendingPathComponent:@"scores.plist"];
    
    [_scores writeToFile:path atomically:YES];
    
    NSMutableArray *checkFile = [[NSMutableArray alloc] initWithContentsOfFile:path];
    if([checkFile count] != 6) {
        return false;
    }
    else {
        bool arrayMatches = true;
        for(int i = 0; i < [checkFile count]; i++) {
            if(checkFile[i] != _scores[i]) { arrayMatches = false; break; }
        }
        return arrayMatches;
    }
}

- (int) getScore:(int)indx {
    if(indx < 0) { indx = 0; }
    if(indx >= 6) { indx = 5; }
    return _gameScores[indx];
}

@end

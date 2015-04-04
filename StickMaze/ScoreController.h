//
//  ScoreController.h
//  StickMaze
//
//  Created by Jacob Frederick Parsons on 2015-04-04.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#ifndef StickMaze_ScoreController_h
#define StickMaze_ScoreController_h

@interface ScoreController : NSObject {
    NSMutableArray *_scores;
    int _gameScores[6];
}

- (void) updateScores:(int)lastGameScore;
- (bool) saveScores;
- (void) loadScores;
- (int) getScore:(int)indx;

@end

#endif
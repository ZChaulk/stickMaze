//
//  RecordsViewController.m
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-28.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import "RecordsViewController.h"

@implementation RecordsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _scoreLoader = [[ScoreController alloc] init];
    [_scoreLoader loadScores];
    self.totalRuns.text = [NSString stringWithFormat:@"%d", [_scoreLoader getScore:0]];
    self.topScore.text = [NSString stringWithFormat:@"%d", [_scoreLoader getScore:1]];
    self.secondTop.text = [NSString stringWithFormat:@"%d", [_scoreLoader getScore:2]];
    self.thirdTop.text = [NSString stringWithFormat:@"%d", [_scoreLoader getScore:3]];
    self.fourthTop.text = [NSString stringWithFormat:@"%d", [_scoreLoader getScore:4]];
    self.fifthTop.text = [NSString stringWithFormat:@"%d", [_scoreLoader getScore:5]];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)returnPress:(id)sender {
    [self.delegate notifyReturn];
}

@end

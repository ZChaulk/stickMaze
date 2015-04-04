//
//  PauseMenuViewController.m
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-03.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import "PauseMenuViewController.h"


@interface PauseMenuViewController ()

@end

@implementation PauseMenuViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)resume:(id)sender {
    id<PauseMenuProtocolDelegate> strongDelegate = self.delegate;
    [strongDelegate resumeGame:self];
    
}

- (IBAction)quit:(id)sender {
    id<PauseMenuProtocolDelegate> strongDelegate = self.delegate;
    [strongDelegate endGame:self];
}
@end

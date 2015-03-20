//
//  HomeViewController.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-01.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import "HomeViewController.h"

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)start:(id)sender {
    GameViewController *gvc = [[GameViewController alloc] initWithNibName:@"GameViewController" bundle:nil];
    gvc.delegate = self;
    [self presentViewController:gvc animated:YES completion:nil];

}

- (IBAction)records:(id)sender {
    RecordsViewController *rvc = [[RecordsViewController alloc] initWithNibName:@"RecordsViewController" bundle:nil];
    //rvc.delegate = self;
    [self presentViewController:rvc animated:YES completion:nil];
}

#pragma GameViewControllerDelegate methods

-(void)notifyGameDone
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end

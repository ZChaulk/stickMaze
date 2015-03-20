//
//  UIViewController+GameViewController.m
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-01.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController()

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)pause:(id)sender {
    //show pauseMenu
    PauseMenuViewController *pmvc = [[PauseMenuViewController alloc] initWithNibName:@"PauseMenuViewController" bundle:nil];
    pmvc.delegate = self;
    [self presentViewController:pmvc animated:YES completion:nil];
}
 
-(void)resumeGame:(PauseMenuViewController *)pauseMenuViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)endGame:(PauseMenuViewController *)pauseMenuViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.delegate notifyGameDone];
    
}

@end

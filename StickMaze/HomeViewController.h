//
//  ViewController.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-01.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameViewController.h"
#import "RecordsViewController.h"
@interface HomeViewController : UIViewController<GameViewControllerDelegate>

- (IBAction)start:(id)sender;
- (IBAction)records:(id)sender;

@end


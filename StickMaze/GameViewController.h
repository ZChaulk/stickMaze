//
//  UIViewController+GameViewController.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-01.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PauseMenuViewController.h"

@protocol GameViewControllerDelegate <NSObject>

-(void)notifyGameDone;

@end


@interface GameViewController : UIViewController<PauseMenuProtocolDelegate>
@property id<GameViewControllerDelegate> delegate;

- (IBAction)pause:(id)sender;

@end

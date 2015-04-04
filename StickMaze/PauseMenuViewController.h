//
//  PauseMenuViewController.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-03.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol PauseMenuProtocolDelegate;

@interface PauseMenuViewController : UIViewController

@property (nonatomic, strong) id<PauseMenuProtocolDelegate> delegate;
//UI actions
- (IBAction)resume:(id)sender;
- (IBAction)quit:(id)sender;


@end


@protocol PauseMenuProtocolDelegate <NSObject>
//Delegate actions in response to UI actions
- (void) endGame:(PauseMenuViewController*) pauseMenuViewController;
- (void) resumeGame:(PauseMenuViewController*) pauseMenuViewController;
@end
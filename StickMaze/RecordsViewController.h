//
//  RecordsViewController.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-28.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ScoreController.h"

@protocol RecordsViewControllerDelegate <NSObject>

-(void)notifyReturn;

@end

@interface RecordsViewController : UIViewController {
    ScoreController *_scoreLoader;
}
- (IBAction)returnPress:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *totalRuns;
@property (weak, nonatomic) IBOutlet UILabel *topScore;
@property (weak, nonatomic) IBOutlet UILabel *secondTop;
@property (weak, nonatomic) IBOutlet UILabel *thirdTop;
@property (weak, nonatomic) IBOutlet UILabel *fourthTop;
@property (weak, nonatomic) IBOutlet UILabel *fifthTop;


@property (nonatomic, strong) id<RecordsViewControllerDelegate> delegate;

@end

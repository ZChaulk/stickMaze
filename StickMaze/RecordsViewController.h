//
//  RecordsViewController.h
//  StickMaze
//
//  Created by Zackary Neil Chaulk on 2015-03-28.
//  Copyright (c) 2015 Zackary Neil Chaulk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RecordsViewControllerDelegate <NSObject>

-(void)notifyReturn;

@end

@interface RecordsViewController : UIViewController
- (IBAction)returnPress:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *score;
@property (nonatomic, strong) id<RecordsViewControllerDelegate> delegate;

@end

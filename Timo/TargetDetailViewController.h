//
//  TargetDetailViewController.h
//  unknow
//
//  Created by 夏煜皓 on 2017/5/18.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Target;

@interface TargetDetailViewController : UIViewController

@property (nonatomic) NSInteger indexOfTarget;
@property (weak, nonatomic) IBOutlet UILabel *targetName;
@property (weak, nonatomic) IBOutlet UILabel *totalDuration;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modelChooseSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *barGraphsView;

@end

//
//  TimerViewController.h
//  Timo
//
//  Created by 夏煜皓 on 2017/6/14.
//  Copyright © 2017年 Chris Xia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Target.h"

@interface TimerViewController : UIViewController

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic) BOOL isStop;

@property (weak, nonatomic) IBOutlet UILabel *Timo;
@property (nonatomic,strong ) NSTimer *timer;

- (IBAction)startTimo:(id)sender;
- (BOOL)saveStatus;

@end

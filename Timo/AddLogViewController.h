//
//  AddLogViewController.h
//  Timo
//
//  Created by 夏煜皓 on 2017/6/27.
//  Copyright © 2017年 Yuhao Xia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Target;

@interface AddLogViewController : UIViewController
@property (nonatomic) NSInteger indexOfTarget;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *durationPicker;
@property (nonatomic) NSDate *startDateIfNeed;

@end

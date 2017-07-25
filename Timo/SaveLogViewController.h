//
//  SaveLogViewController.h
//  Timo
//
//  Created by 夏煜皓 on 2017/6/14.
//  Copyright © 2017年 Chris Xia. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Target;

@interface SaveLogViewController : UIViewController

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) Target *selectedTarget;

- (IBAction)saveLog:(id)sender;
- (IBAction)cancelSave:(id)sender;

@end

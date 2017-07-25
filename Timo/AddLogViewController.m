//
//  AddLogViewController.m
//  Timo
//
//  Created by 夏煜皓 on 2017/6/27.
//  Copyright © 2017年 Yuhao Xia. All rights reserved.
//

#import "AddLogViewController.h"
#import "TargetStore.h"
#import "Target.h"

@interface AddLogViewController ()

@property (weak, nonatomic) IBOutlet UILabel *TargetName;

@end

@implementation AddLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Target *tar = [[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget];
    self.TargetName.text = tar.targetName;
    [self.startDatePicker setCalendar:[NSCalendar currentCalendar]];
    [self.startDatePicker setValue:[UIColor colorWithRed:93.0/255.0
                                                   green:172.0/255.0
                                                    blue:129.0/255.0
                                                   alpha:1.00] forKey:@"textColor"];
    [self.durationPicker setCalendar:[NSCalendar currentCalendar]];
    [self.durationPicker setValue:[UIColor colorWithRed:93.0/255.0
                                                 green:172.0/255.0
                                                  blue:129.0/255.0
                                                 alpha:1.00] forKey:@"textColor"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.durationPicker setCountDownDuration:3600];
    if (self.startDateIfNeed) [self.startDatePicker setDate:self.startDateIfNeed animated:YES];
}

- (IBAction)saveDateLog:(id)sender
{
    NSDateInterval *newLog = [[NSDateInterval alloc] initWithStartDate:self.startDatePicker.date duration:self.durationPicker.countDownDuration];
    
    Target *tar = [[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget];
    [tar addDateLogs:newLog];
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.navigationItem.title isEqualToString:@"更改记录"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)cancelDateLog:(id)sender
{
        [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

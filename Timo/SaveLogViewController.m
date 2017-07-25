//
//  SaveLogViewController.m
//  Timo
//
//  Created by 夏煜皓 on 2017/6/14.
//  Copyright © 2017年 Chris Xia. All rights reserved.
//

#import "SaveLogViewController.h"
#import "Target.h"
#import "TargetStore.h"
#import "AddLogViewController.h"

@interface SaveLogViewController ()<UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *startDateTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationTextLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *targetsPickerView;
@end

@implementation SaveLogViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd '  ' HH:mm"];
    self.startDateTextLabel.text = [dateFormatter stringFromDate:self.startDate];
    self.endDateTextLabel.text = [dateFormatter stringFromDate:self.endDate];
    
    NSTimeInterval interval = [self.endDate timeIntervalSinceDate:self.startDate];
    int hour = (int)(interval / 3600);
    int minute = (int)(interval - hour * 3600 ) / 60;
    int second = interval - hour * 3600 - minute * 60;
    NSString *dural = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    self.durationTextLabel.text = dural;
    
    [self.targetsPickerView reloadAllComponents];
    
    NSLog(@"Save Log View appear.");
}

- (IBAction)saveLog:(id)sender
{
    NSDateInterval *dateLog = [[NSDateInterval alloc] initWithStartDate:self.startDate endDate:self.endDate];
    
    if (![[[TargetStore sharedStore] allTargets] count])  //从未创建过任何项目
    {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请先创建一个新目标吧！"
                                                                       message:@"目前没有创建过目标"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) { [self addNewItem:self]; }];
        //更改title
        NSMutableAttributedString *alertStr = [[NSMutableAttributedString alloc] initWithString:@"请先创建一个新目标吧！"];
        [alertStr addAttribute:NSForegroundColorAttributeName
                         value:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                         range:NSMakeRange(0, 11)];
        [alert setValue:alertStr forKey:@"attributedTitle"];
        
        //更改message
        NSMutableAttributedString *alertMes = [[NSMutableAttributedString alloc] initWithString:@"目前没有创建过目标"];
        [alertMes addAttribute:NSForegroundColorAttributeName
                         value:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                         range:NSMakeRange(0, 9)];
        [alert setValue:alertMes forKey:@"attributedMessage"];
        
        [defaultAction setValue:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                     forKey:@"_titleTextColor"];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else
    {
        //不存在选择目标时候默认选择picker第一行
        if (!self.selectedTarget) self.selectedTarget = [[[TargetStore sharedStore] allTargets] objectAtIndex:0];
        
        if (dateLog.duration <=  (24*3600) )
        {
            [self.selectedTarget addDateLogs:dateLog];
            NSLog(@"Added Log in %@ with log: %@", self.selectedTarget, dateLog);
            [self.navigationController popViewControllerAnimated:YES];
        }
        else    //超过24小时的日志
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"记录需要更改！"
                                                                           message:@"持续时间已经超过24小时"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action){
                                                                      [self performSegueWithIdentifier:@"changeLog" sender:self];}];
            //更改title
            NSMutableAttributedString *alertStr = [[NSMutableAttributedString alloc] initWithString:@"记录需要更改！"];
            [alertStr addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                             range:NSMakeRange(0, 7)];
            [alert setValue:alertStr forKey:@"attributedTitle"];
            
            //更改message
            NSMutableAttributedString *alertMes = [[NSMutableAttributedString alloc] initWithString:@"持续时间已经超过24小时"];
            [alertMes addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                             range:NSMakeRange(0, 12)];
            [alert setValue:alertMes forKey:@"attributedMessage"];
            
            [defaultAction setValue:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                             forKey:@"_titleTextColor"];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (IBAction)addNewItem:(id)sender
{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"新建项目" message:nil preferredStyle:
                                  UIAlertControllerStyleAlert];
    [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入项目名称";
    }];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action){
                                                        if ([[[alertVc textFields] objectAtIndex:0].text length]) //输入内容存在
                                                        {
                                                            [[TargetStore sharedStore] createTarget:[[alertVc textFields] objectAtIndex:0].text];
                                                            [self.targetsPickerView reloadAllComponents];
                                                            NSInteger lastRow = [[[TargetStore sharedStore] allTargets] count] - 1;
                                                            [self.targetsPickerView selectRow:lastRow inComponent:0 animated:YES];
                                                            self.selectedTarget = [[[TargetStore sharedStore] allTargets] objectAtIndex:[self.targetsPickerView selectedRowInComponent:0]];
                                                        }
                                                    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    //修改行为颜色
    NSMutableAttributedString *alertStr = [[NSMutableAttributedString alloc] initWithString:@"新建项目"];
    [alertStr addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                     range:NSMakeRange(0, 4)];
    [alertVc setValue:alertStr forKey:@"attributedTitle"];
    [action1 setValue:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
               forKey:@"_titleTextColor"];
    [action2 setValue:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
               forKey:@"_titleTextColor"];
    
    // 添加行为
    [alertVc addAction:action2];
    [alertVc addAction:action1];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (IBAction)cancelSave:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)targetsPickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)targetsPickerView numberOfRowsInComponent:(NSInteger)component
{

    NSArray *targets = [[TargetStore sharedStore] allTargets];
    return [targets count];
}

- (NSAttributedString *)pickerView:(UIPickerView *)targetsPickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray *targets = [[TargetStore sharedStore] allTargets];
    Target *target= [targets objectAtIndex:row];
    NSDictionary *color = @{NSForegroundColorAttributeName:
                                [UIColor colorWithRed:93.0/255.0
                                                green:172.0/255.0
                                                 blue:129.0/255.0
                                                alpha:1.00]};
    NSAttributedString *pickerLabel = [[NSAttributedString alloc] initWithString:target.targetName attributes:color];
    return  pickerLabel;
}

- (void)pickerView:(UIPickerView *)targetsPickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSArray *targets = [[TargetStore sharedStore] allTargets];
    if ([targets count]) self.selectedTarget = [targets objectAtIndex:row];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"changeLog"])
    {
        AddLogViewController *changeLogView = segue.destinationViewController;
        changeLogView.navigationItem.title = @"更改记录";
        changeLogView.indexOfTarget = [[[TargetStore sharedStore] allTargets] indexOfObject:self.selectedTarget];
        changeLogView.startDateIfNeed = self.startDate;
    }
    else
    {
        NSLog(@"Unidentifier Segue: %@", segue.identifier);
    }
}


@end

//
//  TargetDetailInfoTableViewController.m
//  Timo
//
//  Created by 夏煜皓 on 2017/7/12.
//  Copyright © 2017年 Yuhao Xia. All rights reserved.
//

#import "TargetDetailInfoTableViewController.h"
#import "Target.h"
#import "TargetStore.h"
#import "LogsTableViewController.h"
#import "AddLogViewController.h"
#import "PNChart.h"

@interface TargetDetailInfoTableViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *targetName;
@property (weak, nonatomic) IBOutlet UILabel *totalDuration;
@property (weak, nonatomic) IBOutlet UILabel *totalCounts;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modelChooseSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *barGraphsView;
@end

@implementation TargetDetailInfoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.targetName.delegate = self;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    Target *target = [[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget];
    //显示名字
    self.targetName.text = target.targetName;
    
    //计算总计时间和秒数
    int hours = target.totalDuration / 3600;
    int minutes = target.totalDuration /60 - hours*60;
    int seconds = target.totalDuration - hours * 3600 - minutes * 60;
    self.totalDuration.text = [NSString stringWithFormat:@"%d小时%d分%d秒", hours, minutes, seconds];
    
    //计算总计次数
    self.totalCounts.text = [NSString stringWithFormat:@"%u次", [target.dateLogs count]];
}

- (void)viewDidAppear:(BOOL)animated
{
    switch (self.modelChooseSegmentedControl.selectedSegmentIndex)
    {
        case 0:
            [self weeklyBarGraphBuild];
            break;
        case 1:
            [self monthlyBarGraphBuild];
            break;
        case 2:
            [self yearlyBarGraphBuild];
            break;
        default:
            break;
    }
}

- (IBAction)modelChooseInSegment:(id)sender
{
    UISegmentedControl *seg = sender;
    NSInteger index = seg.selectedSegmentIndex;
    
    switch (index)
    {
        case 0:
            NSLog(@"Press button 周");
            [self weeklyBarGraphBuild];
            break;
        case 1:
            NSLog(@"Press button 月");
            [self monthlyBarGraphBuild];
            break;
        case 2:
            NSLog(@"Press button 年");
            [self yearlyBarGraphBuild];
            break;
        default:
            break;
    }
}

- (void)weeklyBarGraphBuild
{
    //移除所有子视图
    [self.barGraphsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSDate *today = [NSDate date];
    //计算凌晨时间
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *todayComponents = [gregorian components:NSUIntegerMax
                                                     fromDate:today];
    todayComponents.day += 1;
    [todayComponents setHour:0];
    [todayComponents setMinute:0];
    [todayComponents setSecond:0];
    NSDate *endDate = [gregorian dateFromComponents:todayComponents]; //当天晚上24点的时间
    
    Target *date = [[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget];
    NSArray *dateLogs = date.dateLogs; // 该项目的logs
    
    float durations[7] = {0};
    //loop dateLogs,将不同日期的数据分别加入到可变数组durations中
    for (NSDateInterval *log in dateLogs)
    {
        NSTimeInterval interval = [endDate timeIntervalSinceDate:log.startDate];
        
        for (int i =0; i < 7; i++)
        {
            if ( (86400 * i < interval) && (interval <= 86400 * (i +1 )) )
            {
                durations[6-i] += log.duration;
                break;
            }
        }
    }
    
    NSMutableArray *dura = [[NSMutableArray alloc] init];
    for (int i = 0; i < 7; i++)
    {
        [dura addObject:[NSNumber numberWithFloat:durations[i]/3600.0]];
    }
    //计算Y轴坐标数组
    NSMutableArray *yLabelsArray = [[NSMutableArray alloc] init];
    float max = durations[0];   //计算最大值
    for (int i = 1; i < 7; i++)
    {
        if (max < durations[i]) max = durations[i];
    }
    
    for (float i = 4.0; i >= 1.0; i--)  //将对应数字加入素组
    {
        if (i == 4.0)
        {
            [yLabelsArray addObject:[NSNumber numberWithFloat:0.0]];
        }
        else
        {
            [yLabelsArray addObject:[NSNumber numberWithFloat:max/3600.0/i]];
        }
    }
    
    PNBarChart *barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, self.barGraphsView.bounds.size.width, self.barGraphsView.bounds.size.height)];
    // 是否显示xy 轴的数字
    barChart.showLabel = YES;
    // 是否显示水平线 但把柱子压低上移了
    barChart.showLevelLine = NO;
    //是否显示xy 轴
    barChart.showChartBorder = YES;
    // 是否显示柱子的数值
    barChart.isShowNumbers = NO;
    // 立体显示
    barChart.isGradientShow = NO;
    // 设置柱子的圆角
    barChart.barRadius = 3;
    // 设置bar color
    barChart.strokeColor = [UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:0.7];
    
    barChart.xLabels = @[@" ",@" ",@" ",@" ",@" ",@" ",@" "];
    
    barChart.yLabels = yLabelsArray;
    
    barChart.yValues = dura;
    
    barChart.yLabelFormatter = ^ (CGFloat yLabelValue) {
        
        return [NSString stringWithFormat:@"%.1f",yLabelValue];
    };
    
    [barChart strokeChart];
    
    [self.barGraphsView addSubview:barChart];
}

- (void)monthlyBarGraphBuild
{
    //移除所有子视图
    [self.barGraphsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSDate *today = [NSDate date];
    //计算凌晨时间
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *todayComponents =
    [gregorian components:NSUIntegerMax
                 fromDate:today];
    todayComponents.day += 1;
    [todayComponents setHour:0];
    [todayComponents setMinute:0];
    [todayComponents setSecond:0];
    NSDate *endDate = [gregorian dateFromComponents:todayComponents]; //当天晚上24点的时间
    Target *date = [[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget];
    NSArray *dateLogs = date.dateLogs; // 该项目的logs
    
    float durations[30] = {0};
    //loop dateLogs,将不同日期的数据分别加入到可变数组durations中
    for (NSDateInterval *log in dateLogs)
    {
        NSTimeInterval interval = [endDate timeIntervalSinceDate:log.startDate];
        
        for (int i =0; i < 30; i++)
        {
            if ( (86400 * i < interval) && (interval <= 86400 * (i +1 )) )
            {
                durations[29-i] += log.duration;
                break;
            }
        }
    }
    NSMutableArray *dura = [[NSMutableArray alloc] init];
    for (int i = 0; i < 30; i++)
    {
        [dura addObject:[NSNumber numberWithFloat:durations[i]/3600.0]];
    }
    //计算Y轴坐标数组
    NSMutableArray *yLabelsArray = [[NSMutableArray alloc] init];
    float max = durations[0];   //计算最大值
    for (int i = 1; i < 30; i++)
    {
        if (max < durations[i]) max = durations[i];
    }
    
    for (float i = 4.0; i >= 1.0; i--)  //将对应数字加入素组
    {
        if (i == 4.0)
        {
            [yLabelsArray addObject:[NSNumber numberWithFloat:0.0]];
        }
        else
        {
            [yLabelsArray addObject:[NSNumber numberWithFloat:max/3600.0/i]];
        }
    }
    
    PNBarChart *barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, self.barGraphsView.bounds.size.width, self.barGraphsView.bounds.size.height)];
    // 是否显示xy 轴的数字
    barChart.showLabel = YES;
    // 是否显示水平线 但把柱子压低上移了
    barChart.showLevelLine = NO;
    //是否显示xy 轴
    barChart.showChartBorder = YES;
    // 是否显示柱子的数值
    barChart.isShowNumbers = NO;
    // 立体显示
    barChart.isGradientShow = NO;
    // 设置柱子的圆角
    barChart.barRadius = 3;
    // 设置bar color
    barChart.strokeColor = [UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:0.7];
    
    barChart.xLabels = @[@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" "];
    
    barChart.yLabels = yLabelsArray;
    
    barChart.yValues = dura;
    
    barChart.yMaxValue = (int)barChart.yValueMax+2;
    
    barChart.yLabelFormatter = ^ (CGFloat yLabelValue) {
        
        return [NSString stringWithFormat:@"%.1f",yLabelValue];
    };
    
    [barChart strokeChart];
    
    [self.barGraphsView addSubview:barChart];
}

- (void)yearlyBarGraphBuild
{
    //移除所有子视图
    [self.barGraphsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSDate *today = [NSDate date];
    //计算凌晨时间
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *todayComponents =
    [gregorian components:NSUIntegerMax
                 fromDate:today];
    todayComponents.day += 1;
    [todayComponents setHour:0];
    [todayComponents setMinute:0];
    [todayComponents setSecond:0];
    NSDate *endDate = [gregorian dateFromComponents:todayComponents]; //当天晚上24点的时间
    Target *date = [[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget];
    NSArray *dateLogs = date.dateLogs; // 该项目的logs
    
    float durations[12] = {0};
    //loop dateLogs,将不同日期的数据分别加入到可变数组durations中
    for (NSDateInterval *log in dateLogs)
    {
        NSTimeInterval interval = [endDate timeIntervalSinceDate:log.startDate];
        
        for (int i =0; i < 12; i++)
        {
            if ( (86400* 30 * i < interval) && (interval <= 86400 * 30 * (i +1 )) )
            {
                durations[11-i] += log.duration;
                break;
            }
        }
    }
    NSMutableArray *dura = [[NSMutableArray alloc] init];
    for (int i = 0; i < 12; i++)
    {
        [dura addObject:[NSNumber numberWithFloat:durations[i]/3600.0]];
    }
    //计算Y轴坐标数组
    NSMutableArray *yLabelsArray = [[NSMutableArray alloc] init];
    float max = durations[0];   //计算最大值
    for (int i = 1; i < 12; i++)
    {
        if (max < durations[i]) max = durations[i];
    }
    
    for (float i = 4.0; i >= 1.0; i--)  //将对应数字加入素组
    {
        if (i == 4.0)
        {
            [yLabelsArray addObject:[NSNumber numberWithFloat:0.0]];
        }
        else
        {
            [yLabelsArray addObject:[NSNumber numberWithFloat:max/3600.0/i]];
        }
    }
    
    PNBarChart *barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, self.barGraphsView.bounds.size.width, self.barGraphsView.bounds.size.height)];
    // 是否显示xy 轴的数字
    barChart.showLabel = YES;
    // 是否显示水平线 但把柱子压低上移了
    barChart.showLevelLine = NO;
    //是否显示xy 轴
    barChart.showChartBorder = YES;
    // 是否显示柱子的数值
    barChart.isShowNumbers = NO;
    // 立体显示
    barChart.isGradientShow = NO;
    // 设置柱子的圆角
    barChart.barRadius = 3;
    // 设置bar color
    barChart.strokeColor = [UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:0.7];
    
    barChart.xLabels = @[@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" ",@" "];
    
    barChart.yLabels = yLabelsArray;
    
    barChart.yValues = dura;
    
    barChart.yLabelFormatter = ^ (CGFloat yLabelValue) {
        
        return [NSString stringWithFormat:@"%.1f",yLabelValue];
    };
    
    [barChart strokeChart];
    
    [self.barGraphsView addSubview:barChart];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 2;
    }
    else if (section == 1)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

//In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"LogsView"])
    {
        LogsTableViewController *logsViewController = segue.destinationViewController;
        logsViewController.indexOfTarget = self.indexOfTarget;
    }
    else if ([segue.identifier isEqualToString:@"AddLog"])
    {
        AddLogViewController *addLogViewController = segue.destinationViewController;
        addLogViewController.indexOfTarget = self.indexOfTarget;
        NSLog(@"Segue addLogView.");
    }
    else
    {
        NSLog(@"Unidentifier Segue: %@", segue.identifier);
    }
}

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.targetName.text)
    {
        Target *target = [[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget];
        target.targetName = textField.text;
    }
    [textField resignFirstResponder];
    return YES;
}

@end

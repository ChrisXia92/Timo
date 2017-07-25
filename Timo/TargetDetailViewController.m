//
//  TargetDetailViewController.m
//  unknow
//
//  Created by 夏煜皓 on 2017/5/18.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

#import "TargetDetailViewController.h"
#import "Target.h"
#import "TargetStore.h"
#import "LogsTableViewController.h"
#import "AddLogViewController.h"
#import "PNChart.h"

@interface TargetDetailViewController ()

@end

@implementation TargetDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    Target *target = [[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget];
    
    self.targetName.text = target.targetName;
    
    //计算总计时间和秒数
    int hours = target.totalDuration / 3600;
    int minutes = target.totalDuration /60 - hours*60;
    int seconds = target.totalDuration - hours * 3600 - minutes * 60;
    
    self.totalDuration.text = [NSString stringWithFormat:@"%d小时%d分%d秒", hours, minutes, seconds];
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
        [dura addObject:[NSNumber numberWithFloat:durations[i]/3600]];
    }
    
    PNBarChart *barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, self.barGraphsView.bounds.size.width, self.barGraphsView.bounds.size.height)];
    // 是否显示xy 轴的数字
    barChart.showLabel = YES;
    // 是否显示水平线 但把柱子压低上移了
    barChart.showLevelLine = NO;
    //是否显示xy 轴
    barChart.showChartBorder = YES;
    // 是否显示柿子的数值
    barChart.isShowNumbers = NO;
    // 立体显示
    barChart.isGradientShow = NO;
    // 设置柱子的圆角
    barChart.barRadius = 3;
    // 设置bar color
    barChart.strokeColor = [UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:0.7];
    
    barChart.xLabels = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7"];
    
    barChart.yValues = dura;
    
    barChart.yLabelFormatter = ^ (CGFloat yLabelValue) {
        
        return [NSString stringWithFormat:@"%f",yLabelValue];
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
        [dura addObject:[NSNumber numberWithFloat:durations[i]/3600]];
    }
    
    PNBarChart *barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, self.barGraphsView.bounds.size.width, self.barGraphsView.bounds.size.height)];
    // 是否显示xy 轴的数字
    barChart.showLabel = YES;
    // 是否显示水平线 但把柱子压低上移了
    barChart.showLevelLine = NO;
    //是否显示xy 轴
    barChart.showChartBorder = YES;
    // 是否显示柿子的数值
    barChart.isShowNumbers = NO;
    // 立体显示
    barChart.isGradientShow = NO;
    // 设置柱子的圆角
    barChart.barRadius = 3;
    // 设置bar color
    barChart.strokeColor = [UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:0.7];
    
    barChart.xLabels = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
    
    barChart.yValues = dura;
    
    barChart.yMaxValue = (int)barChart.yValueMax+2;
    
    barChart.yLabelFormatter = ^ (CGFloat yLabelValue) {
        
        return [NSString stringWithFormat:@"%f",yLabelValue];
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
        [dura addObject:[NSNumber numberWithFloat:durations[i]/3600]];
    }
    
    PNBarChart *barChart = [[PNBarChart alloc] initWithFrame:CGRectMake(0, 0, self.barGraphsView.bounds.size.width, self.barGraphsView.bounds.size.height)];
    // 是否显示xy 轴的数字
    barChart.showLabel = YES;
    // 是否显示水平线 但把柱子压低上移了
    barChart.showLevelLine = NO;
    //是否显示xy 轴
    barChart.showChartBorder = YES;
    // 是否显示柿子的数值
    barChart.isShowNumbers = NO;
    // 立体显示
    barChart.isGradientShow = NO;
    // 设置柱子的圆角
    barChart.barRadius = 3;
    // 设置bar color
    barChart.strokeColor = [UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:0.7];
    
    barChart.xLabels = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"",@"",@"12"];
    
    barChart.yValues = dura;
    
    barChart.yLabelFormatter = ^ (CGFloat yLabelValue) {
        
        return [NSString stringWithFormat:@"%f",yLabelValue];
    };
    
    [barChart strokeChart];
    
    [self.barGraphsView addSubview:barChart];

}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
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

@end

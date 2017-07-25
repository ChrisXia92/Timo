//
//  TotalInfoViewController.m
//  Timo
//
//  Created by 夏煜皓 on 2017/7/6.
//  Copyright © 2017年 Yuhao Xia. All rights reserved.
//

#import "TotalInfoViewController.h"
#import "Target.h"
#import "TargetStore.h"
#import "PNChart.h"

@interface TotalInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalDurationLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modelsSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *pieChartView;
@end

@implementation TotalInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

-(void)viewDidAppear:(BOOL)animated
{
    //刷新饼图
    switch (self.modelsSegmentedControl.selectedSegmentIndex)
    {
        case 0:
            [self todayPieGraphBuild];
            break;
        case 1:
            [self weeklyPieGraphBuild];
            break;
        case 2:
            [self monthlyPieGraphBuild];
            break;
        case 3:
            [self yearlyPieGraphBuild];
            break;
        default:
            break;
    }
}

- (IBAction)ModelChange:(id)sender
{
    UISegmentedControl *seg = sender;
    NSInteger index = seg.selectedSegmentIndex;
    
    switch (index)
    {
        case 0:
            [self todayPieGraphBuild];
            break;
        case 1:
            [self weeklyPieGraphBuild];
            break;
        case 2:
            [self monthlyPieGraphBuild];
            break;
        case 3:
            [self yearlyPieGraphBuild];
            break;
        default:
            break;
    }
}

- (void)todayPieGraphBuild
{
    //移除所有子视图
    [self.pieChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
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
    
    //重新读取数据库，将需要的数据分别筛选出来
    NSArray *allTargets = [[TargetStore sharedStore] allTargets];
    
    NSMutableDictionary *todayLogs = [[NSMutableDictionary alloc] init];
    NSInteger count = 0;
    
    for (Target *target in allTargets)  //遍历所有log，查找所有适配今天的数据
    {
        NSTimeInterval todayDuration = 0;
        
        for (NSDateInterval *log in target.dateLogs)
        {
            if ( [endDate timeIntervalSinceDate:log.startDate]>=0 && [endDate timeIntervalSinceDate:log.startDate]<= 24*3600 ) //startDate在当晚24点之前24小时内
            {
                if ([endDate timeIntervalSinceDate:log.endDate] >= 0)  //log.endDate在当晚24点之前
                {
                    todayDuration += log.duration;
                    count++;
                }
                else //log.endDate在当晚24点之后，需要切割时间块
                {
                    todayDuration += [endDate timeIntervalSinceDate:log.startDate];
                    count++;
                }
            }
            else if ( [endDate timeIntervalSinceDate:log.endDate]>=0 && [endDate timeIntervalSinceDate:log.endDate]<= 24*3600 )
                //endDate在当晚24点之前24小时内
            {
                todayDuration += (24*3600-[endDate timeIntervalSinceDate:log.endDate]);
                count++;
            }
        }
        NSNumber *todayDur = [NSNumber numberWithFloat:todayDuration/3600];
        NSString *ind = [NSString stringWithFormat: @"%lu", (unsigned long)[allTargets indexOfObject:target]];
        [todayLogs setValue:todayDur forKey:ind];
    }
    self.countLabel.text = [NSString stringWithFormat:@"记录次数: %i", (int)count];
    
    //创建饼图
    NSTimeInterval durations = 0;
    NSArray *arr = [todayLogs allKeys];
    for (NSString *key in arr)
    {
        
        durations += [[todayLogs valueForKey:key] floatValue];
    }
    self.totalDurationLabel.text = [NSString stringWithFormat:@"总计用时: %.2f", durations];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSString *key in arr)
    {
        NSInteger keyNum = [key integerValue];
        if ([[todayLogs valueForKey:key] floatValue]) [items addObject:[PNPieChartDataItem dataItemWithValue:[[todayLogs valueForKey:key] floatValue]
                                                                                                       color:[UIColor colorWithRed:93.0/255.0
                                                                                                                             green:172.0/255.0
                                                                                                                              blue:129.0/255.0
                                                                                                                             alpha:[[todayLogs valueForKey:key] floatValue]/durations*0.6+0.2]
                                                                                                 description:[[[[TargetStore sharedStore] allTargets] objectAtIndex:keyNum] targetName]]];
    }
    
    if (![items count])
    {
        UILabel *pieChartHint = [[UILabel alloc] initWithFrame:CGRectMake(self.pieChartView.bounds.size.width/2-63, self.pieChartView.bounds.size.height/2-21, 126, 42)];
        pieChartHint.font = [UIFont fontWithName:@"System" size:22.0];
        pieChartHint.textAlignment = NSTextAlignmentCenter;
        pieChartHint.text = @"暂无数据";
        pieChartHint.textColor = [UIColor colorWithRed:93.0/255.0
                                                  green:172.0/255.0
                                                   blue:129.0/255.0
                                                  alpha:1.00];
        [self.pieChartView addSubview:pieChartHint];
    }
    else
    {
        PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:self.pieChartView.bounds items:items];
        pieChart.descriptionTextColor = [UIColor colorWithRed:102.0/255.0
                                                        green:101.0/255.0
                                                         blue:106.0/255.0
                                                        alpha:1.00];
        pieChart.descriptionTextShadowColor = [UIColor colorWithRed:102.0/255.0
                                                              green:101.0/255.0
                                                               blue:106.0/255.0
                                                              alpha:0];
        pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        [pieChart strokeChart];
        pieChart.showAbsoluteValues = YES;
        pieChart.shouldHighlightSectorOnTouch =NO;
        [self.pieChartView addSubview:pieChart];
    }
}

- (void)weeklyPieGraphBuild
{
    //移除所有子视图
    [self.pieChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
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
    
    //重新读取数据库，将需要的数据分别筛选出来
    NSArray *allTargets = [[TargetStore sharedStore] allTargets];
    
    NSMutableDictionary *todayLogs = [[NSMutableDictionary alloc] init];
    NSInteger count = 0;
    
    for (Target *target in allTargets)  //遍历所有log，查找所有适配今天的数据
    {
        NSTimeInterval todayDuration = 0;
        
        for (NSDateInterval *log in target.dateLogs)
        {
            if ( [endDate timeIntervalSinceDate:log.startDate]>=0 && [endDate timeIntervalSinceDate:log.startDate]<= 7*24*3600 ) //startDate在当晚24点之前一周内
            {
                if ([endDate timeIntervalSinceDate:log.endDate] >= 0)  //log.endDate在当晚24点之前
                {
                    todayDuration += log.duration;
                    count++;
                }
                else //log.endDate在当晚24点之后，需要切割时间块
                {
                    todayDuration += [endDate timeIntervalSinceDate:log.startDate];
                    count++;
                }
            }
            else if ( [endDate timeIntervalSinceDate:log.endDate]>=0 && [endDate timeIntervalSinceDate:log.endDate]<= 7*24*3600 )
                //endDate在当晚24点之前一周
            {
                todayDuration += (7*24*3600-[endDate timeIntervalSinceDate:log.endDate]);
                count++;
            }
        }
        NSNumber *todayDur = [NSNumber numberWithFloat:todayDuration/3600];
        NSString *ind = [NSString stringWithFormat: @"%lu", (unsigned long)[allTargets indexOfObject:target]];
        [todayLogs setValue:todayDur forKey:ind];
    }
    self.countLabel.text = [NSString stringWithFormat:@"记录次数: %i", (int)count];
    
    //创建饼图
    NSTimeInterval durations = 0;
    NSArray *arr = [todayLogs allKeys];
    for (NSString *key in arr)
    {
        
        durations += [[todayLogs valueForKey:key] floatValue];
    }
    self.totalDurationLabel.text = [NSString stringWithFormat:@"总计用时: %.2f", durations];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSString *key in arr)
    {
        NSInteger keyNum = [key integerValue];
        if ([[todayLogs valueForKey:key] floatValue]) [items addObject:[PNPieChartDataItem dataItemWithValue:[[todayLogs valueForKey:key] floatValue]
                                                                                                       color:[UIColor colorWithRed:93.0/255.0
                                                                                                                             green:172.0/255.0
                                                                                                                              blue:129.0/255.0
                                                                                                                             alpha:[[todayLogs valueForKey:key] floatValue]/durations*0.6+0.2]
                                                                                                 description:[[[[TargetStore sharedStore] allTargets] objectAtIndex:keyNum] targetName]]];
    }
    
    if (![items count])
    {
        UILabel *pieChartHint = [[UILabel alloc] initWithFrame:CGRectMake(self.pieChartView.bounds.size.width/2-63, self.pieChartView.bounds.size.height/2-21, 126, 42)];
        pieChartHint.font = [UIFont fontWithName:@"System" size:22.0];
        pieChartHint.textAlignment = NSTextAlignmentCenter;
        pieChartHint.text = @"暂无数据";
        pieChartHint.textColor = [UIColor colorWithRed:93.0/255.0
                                                  green:172.0/255.0
                                                   blue:129.0/255.0
                                                  alpha:1.00];
        [self.pieChartView addSubview:pieChartHint];
    }
    else
    {
        PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:self.pieChartView.bounds items:items];
                pieChart.descriptionTextColor = [UIColor colorWithRed:102.0/255.0
                                                        green:101.0/255.0
                                                         blue:106.0/255.0
                                                        alpha:1.00];
        pieChart.descriptionTextShadowColor = [UIColor colorWithRed:102.0/255.0
                                                              green:101.0/255.0
                                                               blue:106.0/255.0
                                                              alpha:0];
        pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        [pieChart strokeChart];
        pieChart.showAbsoluteValues = YES;
        pieChart.shouldHighlightSectorOnTouch =NO;
        [self.pieChartView addSubview:pieChart];
    }
}

- (void)monthlyPieGraphBuild
{
    //移除所有子视图
    [self.pieChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
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
    
    //重新读取数据库，将需要的数据分别筛选出来
    NSArray *allTargets = [[TargetStore sharedStore] allTargets];
    
    NSMutableDictionary *todayLogs = [[NSMutableDictionary alloc] init];
    NSInteger count = 0;
    
    for (Target *target in allTargets)  //遍历所有log，查找所有适配今天的数据
    {
        NSTimeInterval todayDuration = 0;
        
        for (NSDateInterval *log in target.dateLogs)
        {
            if ( [endDate timeIntervalSinceDate:log.startDate]>=0 && [endDate timeIntervalSinceDate:log.startDate]<= 30*24*3600 ) //startDate在当晚24点之前一周内
            {
                if ([endDate timeIntervalSinceDate:log.endDate] >= 0)  //log.endDate在当晚24点之前
                {
                    todayDuration += log.duration;
                    count++;
                }
                else //log.endDate在当晚24点之后，需要切割时间块
                {
                    todayDuration += [endDate timeIntervalSinceDate:log.startDate];
                    count++;
                }
            }
            else if ( [endDate timeIntervalSinceDate:log.endDate]>=0 && [endDate timeIntervalSinceDate:log.endDate]<= 30*24*3600 )
                //endDate在当晚24点之前一周
            {
                todayDuration += (30*24*3600-[endDate timeIntervalSinceDate:log.endDate]);
                count++;
            }
        }
        NSNumber *todayDur = [NSNumber numberWithFloat:todayDuration/3600];
        NSString *ind = [NSString stringWithFormat: @"%lu", (unsigned long)[allTargets indexOfObject:target]];
        [todayLogs setValue:todayDur forKey:ind];
    }
    self.countLabel.text = [NSString stringWithFormat:@"记录次数: %i", (int)count];
    
    //创建饼图
    NSTimeInterval durations = 0;
    NSArray *arr = [todayLogs allKeys];
    for (NSString *key in arr)
    {

        durations += [[todayLogs valueForKey:key] floatValue];
    }
    self.totalDurationLabel.text = [NSString stringWithFormat:@"总计用时: %.2f", durations];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSString *key in arr)
    {
        NSInteger keyNum = [key integerValue];
        if ([[todayLogs valueForKey:key] floatValue]) [items addObject:[PNPieChartDataItem dataItemWithValue:[[todayLogs valueForKey:key] floatValue]
                                                                               color:[UIColor colorWithRed:93.0/255.0
                                                                                                     green:172.0/255.0
                                                                                                      blue:129.0/255.0
                                                                                                     alpha:[[todayLogs valueForKey:key] floatValue]/durations*0.6+0.2]
                                                                         description:[[[[TargetStore sharedStore] allTargets] objectAtIndex:keyNum] targetName]]];
    }
    
    if (![items count])
    {
        UILabel *pieChartHint = [[UILabel alloc] initWithFrame:CGRectMake(self.pieChartView.bounds.size.width/2-63, self.pieChartView.bounds.size.height/2-21, 126, 42)];
        pieChartHint.font = [UIFont fontWithName:@"System" size:22.0];
        pieChartHint.textAlignment = NSTextAlignmentCenter;
        pieChartHint.text = @"暂无数据";
        pieChartHint.textColor = [UIColor colorWithRed:93.0/255.0
                                                  green:172.0/255.0
                                                   blue:129.0/255.0
                                                  alpha:1.00];
        [self.pieChartView addSubview:pieChartHint];
    }
    else
    {
        PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:self.pieChartView.bounds items:items];
                pieChart.descriptionTextColor = [UIColor colorWithRed:102.0/255.0
                                                        green:101.0/255.0
                                                         blue:106.0/255.0
                                                        alpha:1.00];
        pieChart.descriptionTextShadowColor = [UIColor colorWithRed:102.0/255.0
                                                              green:101.0/255.0
                                                               blue:106.0/255.0
                                                              alpha:0];
        pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        [pieChart strokeChart];
        pieChart.showAbsoluteValues = YES;
        pieChart.shouldHighlightSectorOnTouch =NO;
        [self.pieChartView addSubview:pieChart];
    }
}

- (void)yearlyPieGraphBuild
{
    //移除所有子视图
    [self.pieChartView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
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
    
    //重新读取数据库，将需要的数据分别筛选出来
    NSArray *allTargets = [[TargetStore sharedStore] allTargets];
    
    NSMutableDictionary *todayLogs = [[NSMutableDictionary alloc] init];
    NSInteger count = 0;
    
    for (Target *target in allTargets)  //遍历所有log，查找所有适配今天的数据
    {
        NSTimeInterval todayDuration = 0;
        
        for (NSDateInterval *log in target.dateLogs)
        {
            if ( [endDate timeIntervalSinceDate:log.startDate]>=0 && [endDate timeIntervalSinceDate:log.startDate]<= 365*24*3600 ) //startDate在当晚24点之前一周内
            {
                if ([endDate timeIntervalSinceDate:log.endDate] >= 0)  //log.endDate在当晚24点之前
                {
                    todayDuration += log.duration;
                    count++;
                }
                else //log.endDate在当晚24点之后，需要切割时间块
                {
                    todayDuration += [endDate timeIntervalSinceDate:log.startDate];
                    count++;
                }
            }
            else if ( [endDate timeIntervalSinceDate:log.endDate]>=0 && [endDate timeIntervalSinceDate:log.endDate]<= 365*24*3600 )
                //endDate在当晚24点之前一周
            {
                todayDuration += (365*24*3600-[endDate timeIntervalSinceDate:log.endDate]);
                count++;
            }
        }
        NSNumber *todayDur = [NSNumber numberWithFloat:todayDuration/3600];
        NSString *ind = [NSString stringWithFormat: @"%lu", (unsigned long)[allTargets indexOfObject:target]];
        [todayLogs setValue:todayDur forKey:ind];
    }
    self.countLabel.text = [NSString stringWithFormat:@"记录次数: %i", (int)count];
    
    //创建饼图
    NSTimeInterval durations = 0;
    NSArray *arr = [todayLogs allKeys];
    for (NSString *key in arr)
    {
        
        durations += [[todayLogs valueForKey:key] floatValue];
    }
    self.totalDurationLabel.text = [NSString stringWithFormat:@"总计用时: %.2f", durations];
    
    NSMutableArray *items = [[NSMutableArray alloc] init];
    for (NSString *key in arr)
    {
        NSInteger keyNum = [key integerValue];
        if ([[todayLogs valueForKey:key] floatValue]) [items addObject:[PNPieChartDataItem dataItemWithValue:[[todayLogs valueForKey:key] floatValue]
                                                                                                       color:[UIColor colorWithRed:93.0/255.0
                                                                                                                             green:172.0/255.0
                                                                                                                              blue:129.0/255.0
                                                                                                                             alpha:[[todayLogs valueForKey:key] floatValue]/durations*0.6+0.2]
                                                                                                 description:[[[[TargetStore sharedStore] allTargets] objectAtIndex:keyNum] targetName]]];
    }
    
    if (![items count])
    {
        UILabel *pieChartHint = [[UILabel alloc] initWithFrame:CGRectMake(self.pieChartView.bounds.size.width/2-63, self.pieChartView.bounds.size.height/2-21, 126, 42)];
        pieChartHint.font = [UIFont fontWithName:@"System" size:22.0];
        pieChartHint.textAlignment = NSTextAlignmentCenter;
        pieChartHint.text = @"暂无数据";
        pieChartHint.textColor = [UIColor colorWithRed:93.0/255.0
                                                  green:172.0/255.0
                                                   blue:129.0/255.0
                                                  alpha:1.00];
        [self.pieChartView addSubview:pieChartHint];
    }
    else
    {
        PNPieChart *pieChart = [[PNPieChart alloc] initWithFrame:self.pieChartView.bounds items:items];
                pieChart.descriptionTextColor = [UIColor colorWithRed:102.0/255.0
                                                        green:101.0/255.0
                                                         blue:106.0/255.0
                                                        alpha:1.00];
        pieChart.descriptionTextShadowColor = [UIColor colorWithRed:102.0/255.0
                                                              green:101.0/255.0
                                                               blue:106.0/255.0
                                                              alpha:0];
        pieChart.descriptionTextFont  = [UIFont fontWithName:@"Avenir-Medium" size:14.0];
        [pieChart strokeChart];
        pieChart.showAbsoluteValues = YES;
        pieChart.shouldHighlightSectorOnTouch =NO;
        [self.pieChartView addSubview:pieChart];
    }
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

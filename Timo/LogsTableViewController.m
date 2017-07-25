//
//  LogsTableViewController.m
//  Timo
//
//  Created by 夏煜皓 on 2017/6/20.
//  Copyright © 2017年 Yuhao Xia. All rights reserved.
//

#import "LogsTableViewController.h"
#import "TargetStore.h"
#import "Target.h"

@interface LogsTableViewController ()

@end

@implementation LogsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSMutableArray *years = [[NSMutableArray alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    for (NSDateInterval *log in [[[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget] dateLogs])
    {
        NSDateComponents *todayComponents = [gregorian components:NSCalendarUnitYear fromDate:log.startDate];
        [years addObject:[NSNumber numberWithInteger:todayComponents.year]];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSNumber *number in years)
    {
        [dict setObject:number forKey:number];
    }
    return [[dict allKeys] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSMutableArray *years = [[NSMutableArray alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    for (NSDateInterval *log in [[[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget] dateLogs])
    {
        NSDateComponents *todayComponents = [gregorian components:NSCalendarUnitYear fromDate:log.startDate];
        [years addObject:[NSNumber numberWithInteger:todayComponents.year]];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSNumber *number in years)
    {
        [dict setObject:number forKey:number];
    }
    NSArray *y =[[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSComparisonResult result = [obj2 compare:obj1];
        return result;
    }];
    return [NSString stringWithFormat:@"%@年", [y objectAtIndex:section]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    
    NSMutableArray *years = [[NSMutableArray alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    for (NSDateInterval *log in [[[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget] dateLogs])
    {
        NSDateComponents *todayComponents = [gregorian components:NSCalendarUnitYear fromDate:log.startDate];
        [years addObject:[NSNumber numberWithInteger:todayComponents.year]];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    for (NSNumber *number in years)
    {
        [dict setObject:number forKey:number];
    }
    NSArray *year = [[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSComparisonResult result = [obj2 compare:obj1];
        return result;
    }];
    
    for (NSDateInterval *log in [[[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget] dateLogs])
    {
        NSDateComponents *todayComponents = [gregorian components:NSCalendarUnitYear fromDate:log.startDate];
        if ([year objectAtIndex:section] == [NSNumber numberWithInteger:todayComponents.year])
        {
            rows++;
        }
    }
    
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell"
                                                            forIndexPath:indexPath];
    
    NSArray *logs = [[[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget] dateLogs];
    
    NSDateInterval *log = [[NSDateInterval alloc] init];
    
    if (indexPath.section == 0)
    {
        log = logs[indexPath.row];
    }
    else
    {
        NSInteger index = 0;
        
        for (int i = 0; i < indexPath.section; i++)
        {
            index += [self.tableView numberOfRowsInSection:i];
        }
        log = logs[index + indexPath.row];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd ' ' HH:mm"];
    NSString *startDate = [dateFormatter stringFromDate:log.startDate];
    NSString *duration = [NSString stringWithFormat:@"%.2f 小时", log.duration/3600];
    
    cell.textLabel.text = startDate;
    cell.detailTextLabel.text = duration;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( [self.tableView numberOfRowsInSection:indexPath.section] == 1 )
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSInteger index = 0;
        
        if (indexPath.section == 0)
        {
            index = indexPath.row;
        }
        else
        {
            for (int i = 0; i < indexPath.section; i++)
            {
                index += [self.tableView numberOfRowsInSection:i];
            }
        }

        Target *target = [[[TargetStore sharedStore] allTargets] objectAtIndex:self.indexOfTarget];

        // Delete the row from the data source
        [target removeDateLogAtIndex:index];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

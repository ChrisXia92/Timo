//
//  TargetsViewController.m
//  unknow
//
//  Created by 夏煜皓 on 2017/5/16.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

#import "TargetsViewController.h"
#import "TargetDetailViewController.h"
#import "TargetStore.h"
#import "Target.h"
#import "LogsTableViewController.h"

@interface TargetsViewController ()

@end

@implementation TargetsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (IBAction)toggleEditingMode:(id)sender
{
    if (self.isEditing) {
        //[sender setTitle:@"Edit"];
        [self setEditing:NO animated:YES];
    }
    else
    {
        //[sender setTitle:@"Done"];
        [self setEditing:YES animated:YES];
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
                                                        if ([[[alertVc textFields] objectAtIndex:0].text length])
                                                        {
                                                            Target *newtar = [[TargetStore sharedStore] createTarget:[[alertVc textFields] objectAtIndex:0].text];
                                                            NSInteger lastRow = [[[TargetStore sharedStore] allTargets] indexOfObject:newtar];
                                                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
                                                            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                                                        }
                                                        [self.tableView reloadData];
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


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[TargetStore sharedStore] allTargets] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TargetCell"
                                                            forIndexPath:indexPath];
    
    NSArray *targets = [[TargetStore sharedStore] allTargets];
    Target *target = targets[indexPath.row];
    
    cell.textLabel.text = target.targetName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2f 小时", target.totalDuration/3600];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *allTargets = [[TargetStore sharedStore] allTargets];
    
    NSInteger count = [allTargets count];
    NSTimeInterval totalDuration = 0;
    
    for (Target *target in allTargets)
    {
        for (NSDateInterval *log in target.dateLogs)
        {
            totalDuration += log.duration;
        }
    }
    //修改section的标题
    return [NSString stringWithFormat:@"总项目数： %u   总计时间： %.2f小时", (int)count, totalDuration/3600];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //如果UITableView对象请求确认的是删除操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"真的确认删除么？"
                                                                       message:@"删除后无法恢复数据"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSArray *targets = [[TargetStore sharedStore] allTargets];
                                                              Target *target = targets[indexPath.row];
                                                              [[TargetStore sharedStore] removeTarget:target];
                                                              //删除表格视图中相应的表格行（带动画效果）
                                                              [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                                                              [self.tableView reloadData]; }];
        UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {}];
        //更改title
        NSMutableAttributedString *alertStr = [[NSMutableAttributedString alloc] initWithString:@"真的确认删除么？"];
        [alertStr addAttribute:NSForegroundColorAttributeName
                         value:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                         range:NSMakeRange(0, 8)];
        [alert setValue:alertStr forKey:@"attributedTitle"];
        
        //更改message
        NSMutableAttributedString *alertMes = [[NSMutableAttributedString alloc] initWithString:@"删除后无法恢复数据"];
        [alertMes addAttribute:NSForegroundColorAttributeName
                         value:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                         range:NSMakeRange(0, 9)];
        [alert setValue:alertMes forKey:@"attributedMessage"];
        
        //更改2个按键颜色
        [yesAction setValue:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                     forKey:@"_titleTextColor"];
        [noAction setValue:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                    forKey:@"_titleTextColor"];
        [alert addAction:noAction];
        [alert addAction:yesAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [[TargetStore sharedStore] moveTargetAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"TargetDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        TargetDetailViewController *targetDetail = segue.destinationViewController;
        targetDetail.indexOfTarget = indexPath.row;
        NSLog(@"TargetDetailView: %ld", (long)indexPath.row);
    }
    else {
        NSLog(@"Unidentifier Segue: %@", segue.identifier);
    }

}

@end

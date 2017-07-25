//
//  TimerViewController.m
//  Timo
//
//  Created by 夏煜皓 on 2017/6/14.
//  Copyright © 2017年 Chris Xia. All rights reserved.
//

#import "TimerViewController.h"
#import "SaveLogViewController.h"
#import "TimerStatus.h"

@interface TimerViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (nonatomic) NSDate *now;
@end

@implementation TimerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //读取之前保存的状态，若isStop为0则提示上次退出错误，是否保存上次的记录
    TimerStatus *lastStatus = [NSKeyedUnarchiver unarchiveObjectWithFile:[self statusArchivePath]];
    NSLog(@"%@", lastStatus);
    
    if (lastStatus)
    {
        if (lastStatus.isStop == 0)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"是否继续上一次记录？"
                                                                           message:@""
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                              //继续上次记录
                                                                  self.isStop = NO;
                                                                  self.startDate = lastStatus.startDate;
                                                                  self.startButton.titleLabel.text = @"STOP";
                                                                  //类方法会自动释放。
                                                                  self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
                                                              }];
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                                 self.isStop = YES;
                                                                 //类方法会自动释放。
                                                                 self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
                                                                 //需要让定时器暂停
                                                                 [self.timer setFireDate:[NSDate distantFuture]];}];
            //更改title
            NSMutableAttributedString *alertStr = [[NSMutableAttributedString alloc] initWithString:@"是否继续上一次记录？"];
            [alertStr addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                             range:NSMakeRange(0, 10)];
            [alert setValue:alertStr forKey:@"attributedTitle"];
            
            //更改message
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"MM-dd ' ' HH:mm"];
            NSString *message = [dateFormatter stringFromDate:lastStatus.startDate];
            
            NSMutableAttributedString *alertMes = [[NSMutableAttributedString alloc] initWithString:message];
            [alertMes addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                             range:NSMakeRange(0, [message length])];
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
        else
        {
            self.isStop = YES;
            //类方法会自动释放。
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
            //需要让定时器暂停
            [self.timer setFireDate:[NSDate distantFuture]];
        }
    }
    else
    {
        self.isStop = YES;
        //类方法会自动释放。
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refresh) userInfo:nil repeats:YES];
        //需要让定时器暂停
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)refresh
{
    //确定现在时间
    self.now = [NSDate date];
    
    //确定时间差
    NSTimeInterval intervalSinceStart = [self.now timeIntervalSinceDate:_startDate];
    
    int hour = (int)(intervalSinceStart / 3600);
    int minute = (int)(intervalSinceStart - hour * 3600 ) / 60;
    int second = intervalSinceStart - hour * 3600 - minute * 60;
    NSString *dural = [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minute, second];
    [self.Timo setText:dural];
    
}

- (IBAction)startTimo:(id)sender {
    
    UIButton *button = (id)sender;
    
    if (self.isStop == 1) {   //按钮时start时，开始计时，并将按钮变为stop
        
        self.startDate = [NSDate date];
        self.isStop = NO;
        
        [self.timer setFireDate:[NSDate date]];
        [button setTitle:@"STOP" forState:UIControlStateNormal];
        NSLog(@"Start counting, date:%@", self.startDate);
        
        [self saveStatus]; //保存状态
    }
    else if (self.isStop == 0)   //按钮时stop时，将计时显示出来，并将按钮变成start
    {
        self.endDate = [NSDate date];
        self.isStop = YES;
        
        [self saveStatus]; //保存状态
        
        [self.timer setFireDate:[NSDate distantFuture]];
        
        [button setTitle:@"START" forState:UIControlStateNormal];
        NSString *dural = [NSString stringWithFormat:@"00:00:00"];
        [self.Timo setText:dural];
        NSLog(@"Stop counting, date:%@", self.endDate);
        NSTimeInterval duration = [self.endDate timeIntervalSinceDate:self.startDate];
        
        //记录时间小于60秒时进行提醒，大于24小时进行提醒
        if (duration < 60)
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"真的需要保存么？"
                                                                           message:@"统计时间少于1分钟"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) { [self performSegueWithIdentifier:@"saveLog"                                               sender:self]; }];
            UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {}];
            //更改title
            NSMutableAttributedString *alertStr = [[NSMutableAttributedString alloc] initWithString:@"真的需要保存么？"];
            [alertStr addAttribute:NSForegroundColorAttributeName
                             value:[UIColor colorWithRed:93.0/255.0 green:172.0/255.0 blue:129.0/255.0 alpha:1.00]
                             range:NSMakeRange(0, 8)];
            [alert setValue:alertStr forKey:@"attributedTitle"];
            
            //更改message
            NSMutableAttributedString *alertMes = [[NSMutableAttributedString alloc] initWithString:@"统计时间少于1分钟"];
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
        else
        {
            [self performSegueWithIdentifier:@"saveLog" sender:self];
        }
    }
}

- (NSString *)statusArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingString:@"/timerStatus.archive"];
}

- (BOOL)saveStatus
{
    NSString *path = [self statusArchivePath];
    
    TimerStatus *status = [[TimerStatus alloc] initWithStartDate:self.startDate isStop:self.isStop];
    NSLog(@"尝试固化%@", status);
    return [NSKeyedArchiver archiveRootObject:status toFile:path];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"saveLog"])
    {
        SaveLogViewController *saveLogViewController = segue.destinationViewController;
        saveLogViewController.startDate = self.startDate;
        saveLogViewController.endDate = self.endDate;
    }
    else
    {
        NSLog(@"Unidentifier Segue: %@", segue.identifier);
    }
}

@end


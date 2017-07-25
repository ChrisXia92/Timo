//
//  Target.m
//  unknow
//
//  Created by 夏煜皓 on 2017/5/16.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

#import "Target.h"

@implementation Target

- (instancetype)initWithTargetName:(NSString *)targetName
{
    self = [super init];
    
    if (self)
    {
        self.targetName = targetName;
        self.dateLogs = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)addDateLogs:(NSDateInterval *)dateLog
{
    if (self.dateLogs)
    {
        if ( [self.dateLogs count] == 0 ) //如果尚未有日志
        {
            [self.dateLogs addObject:dateLog];
        }
        else
        {
            NSInteger i = 0;
            for (NSDateInterval *date in self.dateLogs)
            {
                i++;
                if ( [dateLog.startDate timeIntervalSinceDate:date.startDate] >= 0)
                {
                    NSUInteger index = [self.dateLogs indexOfObject:date];
                    [self.dateLogs insertObject:dateLog atIndex:index];
                    break;
                }
            }
            if (i == [self.dateLogs count]) [self.dateLogs addObject:dateLog];
        }
    }
    return;
}

- (void)removeDateLogAtIndex:(NSInteger)index
{
    if (self.dateLogs)
    {
        [self.dateLogs removeObjectAtIndex:index];
    }
    return;
}

-(NSTimeInterval)totalDuration
{
    NSTimeInterval duration = 0;
    
    for ( NSDateInterval *log in self.dateLogs ) duration += log.duration;
    
    return duration;
}

- (NSString *)description
{
    int hour = (int)(self.totalDuration / 3600);
    int minute = (int)(self.totalDuration - hour * 3600 ) / 60;
    int second = self.totalDuration - hour * 3600 - minute * 60;
    
    NSString *descriptionString = [[NSString alloc] initWithFormat:@"%@ : 已累积 %2d小时%2d分%2d秒", self.targetName, hour, minute, second];
    
    return descriptionString;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.targetName forKey:@"targetName"];
    [aCoder encodeObject:self.dateLogs forKey:@"timeLogs"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _targetName = [aDecoder decodeObjectForKey:@"targetName"];
        _dateLogs = [aDecoder decodeObjectForKey:@"timeLogs"];
    }
    return self;
}

@end

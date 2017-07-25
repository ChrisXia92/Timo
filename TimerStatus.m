//
//  TimerStatus.m
//  Timo
//
//  Created by 夏煜皓 on 2017/7/6.
//  Copyright © 2017年 Yuhao Xia. All rights reserved.
//

#import "TimerStatus.h"

@implementation TimerStatus

- (instancetype)initWithStartDate:(NSDate *)startDate isStop:(BOOL)isStop
{
    if (self)
    {
        self.startDate = [startDate copy];
        self.isStop = isStop;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.startDate forKey:@"startDate"];
    [aCoder encodeBool:self.isStop forKey:@"isStop"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    if (self) {
        _startDate = [aDecoder decodeObjectForKey:@"startDate"];
        _isStop = [aDecoder decodeBoolForKey:@"isStop"];
    }
    return self;
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"状态： 开始时间%@， 是否停止：%d", self.startDate, self.isStop];
}

@end

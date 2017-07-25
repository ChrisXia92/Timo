//
//  TimerStatus.h
//  Timo
//
//  Created by 夏煜皓 on 2017/7/6.
//  Copyright © 2017年 Yuhao Xia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerStatus : NSObject<NSCoding>
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic) BOOL isStop;

- (instancetype)initWithStartDate:(NSDate *)startDate isStop:(BOOL)isStop;
@end

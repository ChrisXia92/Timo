//
//  Target.h
//  unknow
//
//  Created by 夏煜皓 on 2017/5/16.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Target : NSObject<NSCoding>

@property (nonatomic, strong) NSMutableString *targetName;
@property (nonatomic, strong) NSMutableArray *dateLogs;

- (instancetype)initWithTargetName:(NSString *)targetName;

- (NSTimeInterval)totalDuration;
- (void)addDateLogs:(NSDateInterval *)dateLog;
- (void)removeDateLogAtIndex:(NSInteger)index;

@end

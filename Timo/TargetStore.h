//
//  TargetStore.h
//  unknow
//
//  Created by 夏煜皓 on 2017/5/16.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Target;

@interface TargetStore : NSObject

@property (nonatomic, readonly) NSArray *allTargets;

+ (instancetype)sharedStore;

- (Target *)createTarget:(NSString *)name;

- (void)removeTarget:(Target *)target;

- (void)moveTargetAtIndex:(NSInteger)fromIndex
                  toIndex:(NSInteger)toIndex;
- (BOOL)saveChanges;

@end

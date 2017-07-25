//
//  TargetStore.m
//  unknow
//
//  Created by 夏煜皓 on 2017/5/16.
//  Copyright © 2017年 Big Nerd Ranch. All rights reserved.
//

#import "TargetStore.h"
#import "Target.h"

@interface TargetStore()

@property (nonatomic) NSMutableArray *privateTargets;

@end

@implementation TargetStore

+ (instancetype)sharedStore
{
    static TargetStore *sharedStore = nil;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

// No one should call init
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[TargetStore sharedStore]"
                                 userInfo:nil];
    return nil;
}

// Secret designated initializer
- (instancetype)initPrivate
{
    self = [super init];
    
    if (self) {
        NSString *path = [self targetArchivePath];
        _privateTargets = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        //如果之前没有保存过privateTargets 就创建一个新的
        if (!_privateTargets) {
            _privateTargets = [[NSMutableArray alloc] init];
        }
    }
    
    return self;
}

- (NSArray *)allTargets
{
    return self.privateTargets;
}

- (Target *)createTarget:(NSString *)name
{
    Target *target = [[Target alloc] initWithTargetName:name];
    
    [self.privateTargets addObject:target];
    NSLog(@"%@ added.", target);
    
    return target;
}

- (void)removeTarget:(Target *)target
{
    [self.privateTargets removeObjectIdenticalTo:target];
}

- (void)moveTargetAtIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    if (fromIndex == toIndex) {
        return;
    }
    
    Target *target = self.privateTargets[fromIndex];
    [self.privateTargets removeObjectAtIndex:fromIndex];
    [self.privateTargets insertObject:target atIndex:toIndex];
    
}

- (NSString *)targetArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingString:@"/targets.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self targetArchivePath];
    NSLog(@"尝试固化项目数据");
    
    //如果固化成功就返回YES
    return [NSKeyedArchiver archiveRootObject:self.privateTargets toFile:path];
}

@end

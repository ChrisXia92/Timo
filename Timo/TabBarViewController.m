//
//  TabBarViewController.m
//  Timo
//
//  Created by 夏煜皓 on 2017/7/5.
//  Copyright © 2017年 Yuhao Xia. All rights reserved.
//

#import "TabBarViewController.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.selectedIndex = 1;
    self.tabBar.tintColor = [UIColor colorWithRed:93.0/255.0
                                            green:172.0/255.0
                                             blue:129.0/255.0
                                            alpha:1.00];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

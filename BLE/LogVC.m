//
//  LogVC.m
//  BLE
//
//  Created by JimmyJeng on 2015/5/6.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import "LogVC.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

@interface LogVC ()

@end

@implementation LogVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    float y = 10;
    for (NSString *msg in self.log) {
        
        UILabel *logLabel = [[UILabel alloc] init];
        logLabel.text = msg;
        logLabel.numberOfLines = 0;
        logLabel.lineBreakMode = NSLineBreakByWordWrapping;
        CGSize size = [logLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 20, MAXFLOAT)];
        logLabel.frame = CGRectMake(10, y, SCREEN_WIDTH - 20, size.height);
        
        [self.contentView addSubview:logLabel];
        y += size.height;
        y += 10;
    }
    
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, y);
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

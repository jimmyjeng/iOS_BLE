//
//  LogVC.h
//  BLE
//
//  Created by JimmyJeng on 2015/5/6.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogVC : UIViewController
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property NSMutableArray *log;
@end

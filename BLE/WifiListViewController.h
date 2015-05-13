//
//  WifiListViewController.h
//  BLE
//
//  Created by JimmyJeng on 2015/5/13.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface WifiListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSMutableArray *wifiList;
@property ViewController *mainView;
@end

//
//  ViewController.h
//  BLE
//
//  Created by JimmyJeng on 2015/4/27.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate,CBPeripheralDelegate , UITableViewDataSource, UITableViewDelegate>

- (IBAction)pressStartScan:(id)sender;
- (IBAction)pressStopScan:(id)sender;
- (IBAction)pressConnect:(id)sender;
- (IBAction)pressStopConnect:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *labelState;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end


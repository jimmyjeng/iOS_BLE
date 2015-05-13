//
//  ViewController.h
//  BLE
//
//  Created by JimmyJeng on 2015/4/27.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
enum BLEMode{
    BLE_INFO,
    BLE_WIFI,
};

@interface ViewController : UIViewController <CBCentralManagerDelegate,CBPeripheralDelegate , UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *labelState;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)pressStartScan:(id)sender;
- (IBAction)pressStopScan:(id)sender;
- (IBAction)pressConnect:(id)sender;
- (IBAction)pressStopConnect:(id)sender;
- (IBAction)segmentedValueChange:(id)sender;
- (void)logChanel:(NSString*)msg;
- (void)setWifiPassword:(NSMutableData *)data;
@end


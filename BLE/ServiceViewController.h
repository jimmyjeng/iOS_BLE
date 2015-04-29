//
//  ServiceViewController.h
//  BLE
//
//  Created by JimmyJeng on 2015/4/28.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ServiceViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelUUID;
@property CBPeripheral *periperal;
@property NSMutableArray *service;
@end

//
//  DeviceCell.h
//  BLE
//
//  Created by JimmyJeng on 2015/4/27.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelRSSI;
@property (weak, nonatomic) IBOutlet UILabel *labelUUID;

@end

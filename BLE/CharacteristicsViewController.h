//
//  CharacteristicsViewController.h
//  BLE
//
//  Created by JimmyJeng on 2015/4/28.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CharacteristicsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *labelUUID;
@property NSString *uuid;
@property NSArray *characteristics;
@end

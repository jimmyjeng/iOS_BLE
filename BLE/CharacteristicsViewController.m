//
//  CharacteristicsViewController.m
//  BLE
//
//  Created by JimmyJeng on 2015/4/28.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import "CharacteristicsViewController.h"
#import "CharacteristicCell.h"

@interface CharacteristicsViewController ()

@end

@implementation CharacteristicsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.labelUUID.text = self.uuid;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.characteristics count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CharacteristicCell *cell = (CharacteristicCell *)[tableView dequeueReusableCellWithIdentifier:@"CharacteristicCell"];
    CBCharacteristic *c = [self.characteristics objectAtIndex:indexPath.row];
    cell.labelUUID.text = c.UUID.UUIDString;
    return cell;
}

@end

//
//  WifiListViewController.m
//  BLE
//
//  Created by JimmyJeng on 2015/5/13.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import "WifiListViewController.h"

@interface WifiListViewController ()

@end

@implementation WifiListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.wifiList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wifiCell"];

    NSString *deviceName = [self.wifiList objectAtIndex:indexPath.row];
    cell.textLabel.text = [deviceName substringFromIndex:2];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"WIFI" message:@"Please Enter Wifi password" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    [alertView setTag:indexPath.row];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.mainView logChanel:@"cancel Wifi password"];
    }
    else if ( buttonIndex == 1 ) {
        NSData *deviceName = [[self.wifiList objectAtIndex:alertView.tag] dataUsingEncoding:NSUTF8StringEncoding];
        NSData *symbo = [@"\x7f" dataUsingEncoding:NSUTF8StringEncoding];
        NSData *pw = [[alertView textFieldAtIndex:0].text dataUsingEncoding:NSUTF8StringEncoding];
        NSMutableData* data = [NSMutableData data];
        [data appendBytes:deviceName.bytes length:deviceName.length];
        [data appendBytes:symbo.bytes length:symbo.length];
        [data appendBytes:pw.bytes length:pw.length];

        [self.mainView setWifiPassword:data];
    }
}
@end

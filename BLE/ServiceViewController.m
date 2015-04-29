//
//  ServiceViewController.m
//  BLE
//
//  Created by JimmyJeng on 2015/4/28.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import "ServiceViewController.h"
#import "ServiceCell.h"
#import "CharacteristicsViewController.h"

@interface ServiceViewController ()
@property NSInteger serviceIndex;
@end

@implementation ServiceViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.labelName.text = self.periperal.name;
//    self.labelUUID.text = [NSString stringWithFormat:@"%@",self.periperal.UUID ];
    self.labelUUID.text = [self GetUUID : self.periperal.UUID];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.periperal.services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServiceCell *cell = (ServiceCell *)[tableView dequeueReusableCellWithIdentifier:@"ServiceCell"];
    CBService *service = [self.periperal.services objectAtIndex:indexPath.row];
    cell.labelUUID.text = service.UUID.UUIDString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    self.serviceIndex = indexPath.row;
    [self performSegueWithIdentifier:@"ShowCharacteristics" sender:nil];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"ShowCharacteristics"]) {
        CharacteristicsViewController *destViewController = segue.destinationViewController;
        CBService *s = [self.service objectAtIndex:self.serviceIndex];
        destViewController.uuid = s.UUID.UUIDString;
        destViewController.characteristics = s.characteristics ;
    }
}

- (NSString *)GetUUID:(CFUUIDRef ) theUUID {
//    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    return (__bridge_transfer NSString *)string;
}

@end

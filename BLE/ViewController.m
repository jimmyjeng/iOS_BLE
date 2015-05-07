//
//  ViewController.m
//  BLE
//
//  Created by JimmyJeng on 2015/4/27.
//  Copyright (c) 2015年 JimmyJeng. All rights reserved.
//

#import "ViewController.h"
#import "ServiceViewController.h"
#import "DeviceCell.h"
#import "LogVC.h"

@interface ViewController ()
@property (nonatomic,strong) CBCentralManager *CM;
@property (nonatomic,strong) CBPeripheral *connectedPeripheral;
@property NSMutableArray *connectedService;
@property NSInteger serviceCount;
@property NSMutableArray *deviceList;
@property NSMutableArray *rssiList;
@property NSInteger deviceIndex;
@property BOOL isOK;
@property NSTimer *connectTimer;
@property NSMutableArray *log;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.deviceList = [[NSMutableArray alloc] init];
    self.rssiList = [[NSMutableArray alloc] init];
    self.connectedPeripheral = nil;
    self.connectedService = [[NSMutableArray alloc] init];;
    self.deviceIndex = -1;
    self.serviceCount = -1;
    self.isOK = NO;
    self.log = [[NSMutableArray alloc]init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressStartScan:(id)sender {
    [self logChanel:@"pressStartScan"];
    if (self.isOK) {
        self.deviceList = [[NSMutableArray alloc] init];
        self.rssiList = [[NSMutableArray alloc] init];
        
        // specify UDID
        //    NSArray    *uuidArray= [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"180D"], nil];
        //    [CM scanForPeripheralsWithServices:uuidArray options:options];
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        
        [self.CM scanForPeripheralsWithServices:nil options:options];
        //    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(scanTimeout:) userInfo:nil repeats:NO];
    
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please Open Bluetooth" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }

}

- (IBAction)pressStopScan:(id)sender {
    [self.CM stopScan];
}

- (IBAction)pressConnect:(id)sender {
    
    if (self.isOK) {
        //  for now one time one connect
        if (self.deviceIndex != -1) {
            CBPeripheral *peripheral;
            peripheral = [self.deviceList objectAtIndex:self.deviceIndex];
            [self.CM stopScan];
            self.connectedPeripheral = peripheral;
            [self.CM connectPeripheral:peripheral options:nil];
            NSString* msg = [NSString stringWithFormat:@"connecting %@",peripheral.name];
            self.labelState.text = msg;
            self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:20.0f target:self selector:@selector(connectTimeout:) userInfo:nil repeats:NO];
            [self logChanel:msg];
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please Open Bluetooth" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)pressStopConnect:(id)sender {
    if (self.connectedPeripheral!=NULL){
        [self.CM cancelPeripheralConnection:self.connectedPeripheral];
    }
}

- (void) scanTimeout:(NSTimer*)timer
{
    if (self.CM!=NULL){
        [self.CM stopScan];
    }else{
        [self logChanel:@"CM is Null"];
    }
    [self logChanel:@"scanTimeout"];
    [self.tableView reloadData];
}

- (void) connectTimeout:(NSTimer*)timer
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"connect time out !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    if (self.CM!=NULL){
        if (self.connectedPeripheral!=NULL){
            [self.CM cancelPeripheralConnection:self.connectedPeripheral];
        }
    }

    [self logChanel:@"connectTimeout"];
}

#pragma mark BlueTooth delegate
-(void)centralManagerDidUpdateState:(CBCentralManager*)cManager
{
    self.isOK = NO;
    switch (cManager.state) {
        case CBCentralManagerStateUnknown:
            self.labelState.text = @"Unknown";
            break;
        case CBCentralManagerStateUnsupported:
            self.labelState.text = @"Unsupported";
            break;
        case CBCentralManagerStateUnauthorized:
            self.labelState.text = @"Unauthorized";
            break;
        case CBCentralManagerStateResetting:
            self.labelState.text = @"Resetting";
            break;
        case CBCentralManagerStatePoweredOff:
            self.labelState.text = @"PoweredOff";
            [self logChanel:@"Power Off"];
            break;
        case CBCentralManagerStatePoweredOn:
            self.labelState.text = @"PoweredOn";
            [self logChanel:@"Power On"];
            self.isOK = YES;
            break;
        default:
            self.labelState.text = @"none";
            break;
    }

}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (peripheral.name) {
        
//        NSLog(@"@@ didDiscoverPeripheral");
//        NSLog(@"Peripheral Info:");
//        NSLog(@"peripheral : %@",peripheral);
//        NSLog(@"RSSI: %@",RSSI);
//        NSLog(@"adverisement:%@",advertisementData);
        
        if ( ![self.deviceList containsObject:peripheral] ) {
            [self.deviceList addObject:peripheral];
            [self.rssiList addObject:RSSI];
            [self.tableView reloadData];
        }
        else {
            NSInteger index = [self.deviceList indexOfObject:peripheral];
            [self.rssiList replaceObjectAtIndex:index withObject:RSSI];
            [self.tableView reloadData];
        }

    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self logChanel:[NSString stringWithFormat:@"didConnectPeripheral [%@]",peripheral.name ]];
    [self.connectTimer invalidate];
    self.labelState.text = @"Connect";
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    [self logChanel:[NSString stringWithFormat:@"didDisconnectPeripheral [%@]",peripheral.name ]];
    self.labelState.text = @"Disconnect";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"didDisconnectPeripheral" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    [self logChanel:@"didDiscoverServices"];
    if (!error) {
        
        [self logChanel:[NSString stringWithFormat:@"name:%@",peripheral.name ]];
        [self logChanel:[NSString stringWithFormat:@"UUID:%@",peripheral.identifier.UUIDString ]];
        
        self.serviceCount = [peripheral.services count];
        for (CBService *p in peripheral.services){
            [peripheral discoverCharacteristics:nil forService:p];
        }
    }
    else {
        [self logChanel:[NSString stringWithFormat:@"some error @ DiscoverServices : [%@]",error ]];
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    [self logChanel:@"didDiscoverCharacteristicsForService"];
    
    [self logChanel:[NSString stringWithFormat:@"= Service UUID %@",service.UUID]];
     
    if (!error) {
        [self logChanel:[NSString stringWithFormat:@"== %ld Characteristics of service",service.characteristics.count]];
        [self.connectedService addObject:service];
        
        for(CBCharacteristic *c in service.characteristics){
            [self logChanel:[NSString stringWithFormat:@"=== Characteristic UUID:%@ ",c.UUID]];
    
            // setNotification
//            [peripheral setNotifyValue:YES forCharacteristic:c];
            
            // Read
//            [peripheral readValueForCharacteristic:c];
            
            // Write
//            NSData *data = [NSData dataWithBytes:[@"test" UTF8String] length:@"test".length];
//            [peripheral writeValue:data forCharacteristic:c type:CBCharacteristicWriteWithResponse];
            
//            if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) {
//                if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) {
//                    [peripheral setNotifyValue:YES forCharacteristic:c];
//                }
//            }
        
//            if ([service.UUID isEqual:[CBUUID UUIDWithString:@"3BD91523-EC56-9CF3-B2DF-F2E239D01013"]]) {
//                if ([c.UUID isEqual:[CBUUID UUIDWithString:@"3BD91524-EC56-9CF3-B2DF-F2E239D01013"]]) {
//                    [peripheral setNotifyValue:YES forCharacteristic:c];
//                    NSLog(@"set notify");
//                }
//            }
            
            [peripheral readValueForCharacteristic:c];
        }
    }
    else {
        [self logChanel:@"Characteristic discorvery unsuccessfull !"];
        
    }
    
    self.serviceCount--;
    if (self.serviceCount == 0) {
        [self performSegueWithIdentifier:@"ShowServices" sender:nil];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        [self logChanel:[NSString stringWithFormat:@"peripheral[%@] , characteristic[%@]",peripheral.identifier.UUIDString , characteristic.UUID]];
        [self logChanel:[NSString stringWithFormat:@"Error:%@",error.description]];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
//    NSLog(@"didUpdateValueForCharacteristic");
    
    if (!error) {
        NSString *msg = @"";
        if (  characteristic.properties & (CBCharacteristicPropertyBroadcast) )
            msg = [msg stringByAppendingString:@"Broadcast "];
        
        if (  characteristic.properties & (CBCharacteristicPropertyRead) )
            msg = [msg stringByAppendingString:@"Read "];
        
        if (  characteristic.properties & (CBCharacteristicPropertyWriteWithoutResponse) )
            msg = [msg stringByAppendingString:@"WriteWithoutResponse "];
        
        if (  characteristic.properties & (CBCharacteristicPropertyWrite) )
            msg = [msg stringByAppendingString:@"Write "];
        
        if (  characteristic.properties & (CBCharacteristicPropertyNotify) )
            msg = [msg stringByAppendingString:@"Notify "];
        
        if (  characteristic.properties & (CBCharacteristicPropertyIndicate) )
            msg = [msg stringByAppendingString:@"Indicate "];
        
        if (  characteristic.properties & (CBCharacteristicPropertyAuthenticatedSignedWrites) )
            msg = [msg stringByAppendingString:@"AuthenticatedSignedWrites "];
        
        if (  characteristic.properties & (CBCharacteristicPropertyExtendedProperties) )
            msg = [msg stringByAppendingString:@"ExtendedProperties "];
        
        if (  characteristic.properties & (CBCharacteristicPropertyNotifyEncryptionRequired) )
            msg = [msg stringByAppendingString:@"NotifyEncryptionRequired "];
        
        if (  characteristic.properties & (CBCharacteristicPropertyIndicateEncryptionRequired) )
            msg = [msg stringByAppendingString:@"IndicateEncryptionRequired "];
        
        [self logChanel:[NSString stringWithFormat:@"UUID[%@](%@) : %@ ",characteristic.UUID ,msg, characteristic.value]];
    
    }
    else {
        [self logChanel:[NSString stringWithFormat:@"Error changing notification state: %@", [error localizedDescription]]];
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    
}

#pragma mark tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.deviceList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceCell *cell = (DeviceCell *)[tableView dequeueReusableCellWithIdentifier:@"DeviceCell"];
    CBPeripheral *p = [self.deviceList objectAtIndex:indexPath.row ];
    cell.labelName.text = [ NSString stringWithFormat:@"%@", p.name] ;
    cell.labelRSSI.text = [ NSString stringWithFormat:@"%@", [self.rssiList objectAtIndex:indexPath.row ] ] ;
//    cell.labelUUID.text = [self GetUUID:p.UUID];
    cell.labelUUID.text = p.identifier.UUIDString;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.CM stopScan];
    self.deviceIndex = indexPath.row;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  pass recipe data to DetailView
    
    if ([segue.identifier isEqualToString:@"ShowServices"]) {
        ServiceViewController *destViewController = segue.destinationViewController;
        destViewController.periperal = self.connectedPeripheral;
        destViewController.service = self.connectedService;
    }
    else if ([segue.identifier isEqualToString:@"ShowLog"]) {
        LogVC *destViewController = segue.destinationViewController;
        destViewController.log = self.log;
    }
}

- (void)logChanel:(NSString*)msg {
    NSLog(@"%@",msg);
    [self.log addObject:msg];
}
@end

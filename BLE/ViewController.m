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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressStartScan:(id)sender {
    NSLog(@"pressStartScan");
    
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
            self.labelState.text = [NSString stringWithFormat:@"connecting %@",peripheral.name];
            self.connectTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(connectTimeout:) userInfo:nil repeats:NO];
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
        NSLog(@"CM is Null!");
    }
    NSLog(@"scanTimeout");
    
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

    NSLog(@"connectTimeout");
    
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
            break;
        case CBCentralManagerStatePoweredOn:
            self.labelState.text = @"PoweredOn";
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
    NSLog(@"didConnectPeripheral [%@]",peripheral.name);
    [self.connectTimer invalidate];
    self.labelState.text = @"Connect";
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral [%@]",peripheral.name);
    self.labelState.text = @"Disconnect";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"didDisconnectPeripheral" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"didDiscoverServices");
    if (!error) {
        
//        NSLog(@"name:%@",peripheral.name);
//        NSLog(@"UUID:%@",peripheral.UUID);
//        NSLog(@"Services:%ld",[peripheral.services count]);
        
        self.serviceCount = [peripheral.services count];
        for (CBService *p in peripheral.services){
            [peripheral discoverCharacteristics:nil forService:p];
        }
    }
    else {
        NSLog(@"some error @ DiscoverServices : [%@]",error);
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
     NSLog(@"didDiscoverCharacteristicsForService");
    
    CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
    NSLog(@"=========== Service UUID %@ ===========\n",service.UUID);
    if (!error) {
        NSLog(@"=========== %ld Characteristics of service ",service.characteristics.count);
        [self.connectedService addObject:service];
        
        for(CBCharacteristic *c in service.characteristics){
            NSLog(@"Characteristic UUID:%@ ",c.UUID);
            if(service.UUID == NULL || s.UUID == NULL) return; // zach ios6 added
            
            //Register notification
//            if ([service.UUID isEqual:[CBUUID UUIDWithString:@"180D"]]) {
//                if ([c.UUID isEqual:[CBUUID UUIDWithString:@"2A37"]]) {
//                    [peripheral setNotifyValue:YES forCharacteristic:c];
//                    NSLog(@"registered notification 2A37");
//                }
//            }
            
            [peripheral readValueForCharacteristic:c];
        }
    }
    else {
        NSLog(@"Characteristic discorvery unsuccessfull !\n");
        
    }
    
    self.serviceCount--;
    if (self.serviceCount == 0) {
        [self performSegueWithIdentifier:@"ShowServices" sender:nil];
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
        
        NSLog(@"UUID[%@](%@) : %@ ",characteristic.UUID ,msg, characteristic.value);
    
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
    
    if (self.connectedPeripheral == [self.deviceList objectAtIndex:indexPath.row]) {
        [self performSegueWithIdentifier:@"ShowServices" sender:nil];
    }
    else {
        self.deviceIndex = indexPath.row;
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  pass recipe data to DetailView
    if ([segue.identifier isEqualToString:@"ShowServices"]) {
        ServiceViewController *destViewController = segue.destinationViewController;
        destViewController.periperal = self.connectedPeripheral;
        destViewController.service = self.connectedService;
    }
}

@end

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
#import "WifiListViewController.h"

@interface ViewController ()
@property CBCentralManager *CM;
@property CBPeripheral *connectedPeripheral;
@property NSMutableArray *connectedService;
@property CBCharacteristic *CharWifiResponse;
@property NSInteger serviceCount;
@property NSMutableArray *deviceList;
@property NSMutableArray *rssiList;
@property NSInteger deviceIndex;
@property BOOL isOK;
@property NSTimer *connectTimer;
@property NSMutableArray *log;
@property enum BLEMode mode;
@property NSMutableArray *wifiList;
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
    self.mode = BLE_INFO;
    self.wifiList = [[NSMutableArray alloc]init];
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
            [self logChanel:@"Device Unknown"];
            break;
        case CBCentralManagerStateUnsupported:
            self.labelState.text = @"Unsupported";
            [self logChanel:@"Device Unsupported"];
            break;
        case CBCentralManagerStateUnauthorized:
            self.labelState.text = @"Unauthorized";
            [self logChanel:@"Device Unauthorized"];
            break;
        case CBCentralManagerStateResetting:
            self.labelState.text = @"Resetting";
            [self logChanel:@"Device Resetting"];
            break;
        case CBCentralManagerStatePoweredOff:
            self.labelState.text = @"PoweredOff";
            [self logChanel:@"Device Power Off"];
            break;
        case CBCentralManagerStatePoweredOn:
            self.labelState.text = @"PoweredOn";
            [self logChanel:@"Device Power On"];
            self.isOK = YES;
            break;
        default:
            self.labelState.text = @"unexpect";
            [self logChanel:@"Device unexpect"];
            break;
    }

}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (peripheral.name) {
        
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
            [self detectCharacteristic:c];
            
            // setNotification
//            [peripheral setNotifyValue:YES forCharacteristic:c];
            
            // Read
//            [peripheral readValueForCharacteristic:c];
            
            // Write
//            NSData *data = [NSData dataWithBytes:[@"test" UTF8String] length:@"test".length];
//            [peripheral writeValue:data forCharacteristic:c type:CBCharacteristicWriteWithResponse];
        
            if ([service.UUID isEqual:[CBUUID UUIDWithString:@"B001"]]) {
                // wifi list
                if ([c.UUID isEqual:[CBUUID UUIDWithString:@"C001"]]) {
//                    [peripheral setNotifyValue:YES forCharacteristic:c];
                    [peripheral readValueForCharacteristic:c];
                }
                // data
                else if ([c.UUID isEqual:[CBUUID UUIDWithString:@"C002"]]) {
                    self.CharWifiResponse = c;
                }
                // response
                else if ([c.UUID isEqual:[CBUUID UUIDWithString:@"C003"]]) {
//                    [peripheral readValueForCharacteristic:c];
                    [peripheral setNotifyValue:YES forCharacteristic:c];
                }
            }
            
        }
    }
    else {
        [self logChanel:@"Characteristic discorvery unsuccessfull !"];
        
    }
    
    // load done
    self.serviceCount--;
    if (self.serviceCount == 0) {
        if (self.mode == BLE_INFO) {
            [self performSegueWithIdentifier:@"ShowServices" sender:nil];
        }
//        else if(self.mode == BLE_WIFI) {
//            [self performSegueWithIdentifier:@"ShowWifi" sender:nil];
//        }
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
        NSLog(@"Update Characteristic[%@] : %@",characteristic.UUID, characteristic.value);
        // wifi list
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"C001"]]) {
            [self converterWifiList:characteristic.value];
            if (self.mode == BLE_WIFI) {
               [self performSegueWithIdentifier:@"ShowWifi" sender:nil];
            }
           
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"C003"]]) {
            [self converterDomain:characteristic.value];
        }
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

#pragma mark other
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
    else if ([segue.identifier isEqualToString:@"ShowWifi"]) {
        WifiListViewController *destViewController = segue.destinationViewController;
        destViewController.wifiList = self.wifiList;
        destViewController.mainView = self;
    }
}

- (void)detectCharacteristic:(CBCharacteristic *)characteristic {
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
    
    [self logChanel:[NSString stringWithFormat:@"=== Characteristic UUID(%@): [%@] ",msg,characteristic.UUID]];
}


- (void)converterWifiList:(NSData *)data {
    NSMutableString *sbuf = [[NSMutableString alloc]init];
    const unsigned char *buf = data.bytes;

    NSInteger i;
    for (i=0; i<data.length; ++i) {
        [sbuf appendFormat:@"%02x",buf[i]];
    }

    NSArray *deviceList = [sbuf componentsSeparatedByString:@"7f"];
    for ( NSString *hexName in deviceList ) {
        if ([hexName length] > 0) {
            int i = 0;
            NSMutableString *deviceName = [[NSMutableString alloc]init];
            while ( i < [hexName length]) {
                NSString * hexChar = [hexName substringWithRange: NSMakeRange(i, 2)];
                int value = 0;
                sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
                [deviceName appendFormat:@"%c", (char)value];
                i+=2;
            }
            // the deviceName two is mode
            if ( [deviceName length] > 2) {
                [self logChanel:[NSString stringWithFormat:@"Wifi:%@",[deviceName substringFromIndex:2]]];
                [self.wifiList addObject:deviceName];
            }
        }
    }
    
}

- (void)converterDomain:(NSData *)data {
    NSMutableString *sbuf = [[NSMutableString alloc]init];
    const unsigned char *buf = data.bytes;
    
    NSInteger i;
    for (i=0; i<data.length; ++i) {
        [sbuf appendFormat:@"%02x",buf[i]];
    }
    
    NSArray *wifiInfo = [sbuf componentsSeparatedByString:@"7f"];
    
    i = 0;
    NSMutableString *ip = [[NSMutableString alloc]init];
    while ( i < [[wifiInfo objectAtIndex:0] length]) {
        NSString * hexChar = [[wifiInfo objectAtIndex:0] substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [ip appendFormat:@"%c", (char)value];
        i+=2;
    }
   
    NSMutableString *domain = [[NSMutableString alloc]init];
    i = 0;
    while ( i < [[wifiInfo objectAtIndex:1] length]) {
        NSString * hexChar = [[wifiInfo objectAtIndex:1] substringWithRange: NSMakeRange(i, 2)];
        int value = 0;
        sscanf([hexChar cStringUsingEncoding:NSASCIIStringEncoding], "%x", &value);
        [domain appendFormat:@"%c", (char)value];
        i+=2;
    }
    
    [self logChanel:[NSString stringWithFormat:@"ip:%@",ip]];
    [self logChanel:[NSString stringWithFormat:@"domain:%@",domain]];
    
}
- (void)logChanel:(NSString*)msg {
    NSLog(@"%@",msg);
    [self.log addObject:msg];
}

- (IBAction)segmentedValueChange:(id)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            self.mode = BLE_INFO;
            break;
        case 1:
            self.mode = BLE_WIFI;
            break;
        default:
            break;
    }
}

- (void)setWifiPassword:(NSMutableData *)data {
    [self logChanel:[NSString stringWithFormat:@"setPassword :%@",data]];
//    NSData *temp = [NSData dataWithBytes:[@"test" UTF8String] length:@"test".length];
    [self.connectedPeripheral writeValue:data forCharacteristic:self.CharWifiResponse type:CBCharacteristicWriteWithResponse];
}
@end

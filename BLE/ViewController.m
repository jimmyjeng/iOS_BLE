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
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressStartScan:(id)sender {
    NSLog(@"pressStartScan");
    self.deviceList = [[NSMutableArray alloc] init];
    self.rssiList = [[NSMutableArray alloc] init];
    // multiple discoveries of the same peripheral are coalesced into a single discovery event.
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
    
    [self.CM scanForPeripheralsWithServices:nil options:options];
//    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(scanTimeout:) userInfo:nil repeats:NO];
    
    // specify UDID
//    NSArray    *uuidArray= [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"180D"], nil];
//    [CM scanForPeripheralsWithServices:uuidArray options:options];
}

- (IBAction)pressStopScan:(id)sender {
    [self.CM stopScan];
}

- (IBAction)pressConnect:(id)sender {
    
    //  for now one time one connect
    if (self.deviceIndex != -1) {
        CBPeripheral *peripheral;
        peripheral = [self.deviceList objectAtIndex:self.deviceIndex];
        [self.CM stopScan];
        self.connectedPeripheral = peripheral;
        [self.CM connectPeripheral:peripheral options:nil];
        NSLog(@"connecting %@ ...",peripheral.name);
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

#pragma mark BlueTooth delegate
-(void)centralManagerDidUpdateState:(CBCentralManager*)cManager
{
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
        
        BOOL exist = NO;
        
        for (CBPeripheral *p in self.deviceList ) {
            if ([[self GetUUID:p.UUID] isEqualToString:[self GetUUID:peripheral.UUID]]) {
                exist = YES;
            }
        }
        
        if (exist == NO) {
            [self.deviceList addObject:peripheral];
            [self.rssiList addObject:RSSI];
            [self.tableView reloadData];
        }
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"didConnectPeripheral [%@]",peripheral.name);
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"didDisconnectPeripheral [%@]",peripheral.name);
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"didDisconnectPeripheral" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    NSLog(@"## didDiscoverServices");
    if (!error) {
        
//        NSLog(@"name:%@",peripheral.name);
//        NSLog(@"UUID:%@",peripheral.UUID);
//        NSLog(@"Services:%ld",[peripheral.services count]);
        self.serviceCount = [peripheral.services count];
        for (CBService *p in peripheral.services){
            NSLog(@"Service found with UUID: %@\n", p.UUID);
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
            NSLog(@"char UUID:%@ ",c.UUID);
            //  CBService *s = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if(service.UUID == NULL || s.UUID == NULL) return; // zach ios6 added
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
    cell.labelUUID.text = [self GetUUID:p.UUID];
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

- (NSString *)GetUUID:(CFUUIDRef ) theUUID {
    //    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    return (__bridge_transfer NSString *)string;
}
@end

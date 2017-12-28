#import "CBController.h"
#import "MyPeripheral.h"

@implementation CBController
@synthesize delegate;
@synthesize devicesList;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        devicesList = [[NSMutableArray alloc] init];
        _connectedPeripheralList = [[NSMutableArray alloc] init];
        _transServiceUUID = nil;
        _transTxUUID = nil;
        _transRxUUID = nil;  
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    aryHex=[[NSArray alloc] initWithObjects:@"0000",@"0001",@"0010",@"0011",@"0100",@"0101",@"0110",@"0111",@"1000",@"1001",@"1010",@"1011",@"1100",@"1101",@"1110",@"1111",nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)dealloc {
    [manager release];
    [devicesList release];
    [self disconnectDevice:nil];
    [super dealloc];
}

//开始扫描外设
- (void) startScan 
{
    NSLog(@"[CBController] start scan");
    [manager scanForPeripheralsWithServices:nil options:nil];
    [devicesList removeAllObjects];
}

//停止扫描外设
- (void) stopScan 
{
    NSLog(@"[CBController] stop scan");
    [manager stopScan];
}

//16进制字符串转化成data
- (NSMutableData *) hexStrToData: (NSString *)hexStr
{
    NSMutableData *data= [[NSMutableData alloc] init];
    NSUInteger len = [hexStr length];
    
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < len/2; i++) {
        byte_chars[0] = [hexStr characterAtIndex:i*2];
        byte_chars[1] = [hexStr characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1]; 
    }
    return [data autorelease];
}

//连接外设
- (void)connectDevice:(MyPeripheral *) myPeripheral
{
    NSLog(@"[CBController] connectDevice: %@", myPeripheral.advName);
    if (myPeripheral.connectStaus != MYPERIPHERAL_CONNECT_STATUS_IDLE)
        return;
    [manager connectPeripheral:myPeripheral.peripheral options:nil];  //connect to device
}


//断开外设
- (void)disconnectDevice: (MyPeripheral *)myPeripheral
{
    NSLog(@"[CBController] disconnectDevice");
    [manager cancelPeripheralConnection: myPeripheral.peripheral];
}



- (void)updateDiscoverPeripherals {
    
}

- (void)updateMyPeripheralForNewConnected:(MyPeripheral *)myPeripheral {
    
}

- (void)updateMyPeripheralForDisconnect:(MyPeripheral *)myPeripheral
{
    
}

//添加发现的外设到DevicesList
- (void)addDiscoverPeripheral:(CBPeripheral *)aPeripheral advName:(NSString *)advName
{
    MyPeripheral *myPeripheral = nil;
    for (uint8_t i = 0; i < [devicesList count]; i++)
    {
        myPeripheral = [devicesList objectAtIndex:i];
        if (myPeripheral.peripheral == aPeripheral)
        {
            myPeripheral.advName = advName;
            break;
        }
        myPeripheral = nil;
    }
    if (myPeripheral == nil)
    {
        [aPeripheral retain];
        myPeripheral = [[MyPeripheral alloc] init];
        myPeripheral.peripheral = aPeripheral;
        myPeripheral.advName = advName;
        [devicesList addObject:myPeripheral];
    }

    [self updateDiscoverPeripherals];
    
    //2013-12-12
    [self connectDevice:myPeripheral];
}

//存储外设
- (void)storeMyPeripheral: (CBPeripheral *)aPeripheral
{
    MyPeripheral *myPeripheral = nil;
    bool b = FALSE;
    for (uint8_t i = 0; i < [devicesList count]; i++)
    {
        myPeripheral = [devicesList objectAtIndex:i];
        if (myPeripheral.peripheral == aPeripheral)
        {
            b = TRUE;
            //NSLog(@"storeMyPeripheral 1");
            break;
        }
    }
    if(!b) {
        myPeripheral = [[MyPeripheral alloc] init];
        myPeripheral.peripheral = aPeripheral;
    }
    myPeripheral.connectStaus = MYPERIPHERAL_CONNECT_STATUS_CONNECTED;
    [_connectedPeripheralList addObject:myPeripheral];
    
}

- (MyPeripheral *)retrieveMyPeripheral:(CBPeripheral *)aPeripheral
{
    MyPeripheral *myPeripheral = nil;
    for (uint8_t i = 0; i < [_connectedPeripheralList count]; i++)
    {
        myPeripheral = [_connectedPeripheralList objectAtIndex:i];
        if (myPeripheral.peripheral == aPeripheral)
        {
            break;
        }
    }
    return myPeripheral;
}

//移除我的外设
- (void)removeMyPeripheral: (CBPeripheral *) aPeripheral
{
    MyPeripheral *myPeripheral = nil;
    for (uint8_t i = 0; i < [_connectedPeripheralList count]; i++)
    {
        myPeripheral = [_connectedPeripheralList objectAtIndex:i];
        if (myPeripheral.peripheral == aPeripheral)
        {
            myPeripheral.connectStaus = MYPERIPHERAL_CONNECT_STATUS_IDLE;
            [self updateMyPeripheralForDisconnect:myPeripheral];
            [_connectedPeripheralList removeObject:myPeripheral];
            return;
        }
    }
    for (uint8_t i = 0; i < [devicesList count]; i++)
    {
        myPeripheral = [devicesList objectAtIndex:i];
        if (myPeripheral.peripheral == aPeripheral)
        {
            myPeripheral.connectStaus = MYPERIPHERAL_CONNECT_STATUS_IDLE;
            [self updateMyPeripheralForDisconnect:myPeripheral];
            break;
        }
    }
}

- (void)configureTransparentServiceUUID: (NSString *)serviceUUID txUUID:(NSString *)txUUID rxUUID:(NSString *)rxUUID
{
    if (serviceUUID)
    {
        _transServiceUUID = [CBUUID UUIDWithString:serviceUUID];
        [_transServiceUUID retain];
        _transTxUUID = [CBUUID UUIDWithString:txUUID];
        [_transTxUUID retain];
        _transRxUUID = [CBUUID UUIDWithString:rxUUID];
        [_transRxUUID retain];
    }
    else
    {
        _transServiceUUID = nil;
        _transTxUUID = nil;
        _transRxUUID = nil;
    }
}

//提示蓝牙是否可用
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([manager state]) 
    {
        //不支持LBE
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"Bluetooth power on");
            return TRUE;
        case CBCentralManagerStateUnknown:
        default:
            return FALSE;
            
    }
    
    NSLog(@"Central manager state: %@", state);
    
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth alert"  message:state delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
    return FALSE;
}

#pragma mark - CBCentralManager delegate methods
//更新蓝牙状态
- (void) centralManagerDidUpdateState:(CBCentralManager *)central 
{
    [self isLECapableHardware];
}

//发现外设
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI 
{    
    //NSLog(@"<---------\n[CBController] didDiscoverPeripheral, %@, count=%u, RSSI=%d, count=%d", aPeripheral.UUID, [advertisementData count], [RSSI intValue], [devicesList count]);
    NSArray *advDataArray = [advertisementData allValues];
    NSArray *advValueArray = [advertisementData allKeys];
    for (int i=0; i < [advertisementData count]; i++)
    {
        NSLog(@"adv data=%@, %@ ", [advDataArray objectAtIndex:i], [advValueArray objectAtIndex:i]);
    }
    NSLog(@"-------->");
    [self addDiscoverPeripheral:aPeripheral advName:[advertisementData valueForKey:CBAdvertisementDataLocalNameKey]];
}


- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Retrieved peripheral: %u - %@", [peripherals count], peripherals);
    if([peripherals count] >=1)
    {
        [self connectDevice:[peripherals objectAtIndex:0]];
    }
}

//连接外设回调函数
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral 
{    
    //NSLog(@"[CBController] didConnectPeripheral, uuid=%@", aPeripheral.UUID);

    [aPeripheral setDelegate:self];

    [self storeMyPeripheral:aPeripheral];

    isISSCPeripheral = FALSE;
    NSMutableArray *uuids = [[NSMutableArray alloc] initWithObjects:[CBUUID UUIDWithString:
                                                                     UUIDSTR_LightBlue_SERVICE],   [CBUUID UUIDWithString:UUIDSTR_DEVICE_INFO_SERVICE],
                                                                    [CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE],
                             nil];
    
    if (_transServiceUUID)
    {
        [uuids addObject:_transServiceUUID];
    }
    [aPeripheral discoverServices:uuids];
    //[aPeripheral discoverServices:nil];
    [uuids release];
}

//断开外设回调函数
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    //NSLog(@"[CBController] didDisonnectPeripheral uuid = %@, error msg:%d, %@, %@", aPeripheral.UUID, error.code ,[error localizedFailureReason], [error localizedDescription]);

    [self removeMyPeripheral:aPeripheral];
    
    
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"[CBController] Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    [self removeMyPeripheral:aPeripheral];
}

#pragma mark - CBPeripheral delegate methods
//发现服务
-   (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error 
{
    if(error)
    {
        NSLog(@"Error diccovering service:%@",[error localizedDescription]);
        return;
    }
    for (CBService *aService in aPeripheral.services)
    {
        NSLog(@"[CBController] Service found with UUID: %@", aService.UUID);
      //  NSArray *uuids = [[NSArray alloc] initWithObjects:[CBUUID UUIDWithString:@"2A4D"], nil];
        [aPeripheral discoverCharacteristics:nil forService:aService];
      //  [uuids release];
    }
}

//发现特征
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error 
{
    NSLog(@"\n[CBController] didDiscoverCharacteristicsForService: %@", service.UUID);
    CBCharacteristic *aChar = nil;
    MyPeripheral *myPeripheral = [self retrieveMyPeripheral:aPeripheral];
    if (myPeripheral == nil)
    {
        return;
    }

    if (_transServiceUUID && [service.UUID isEqual:_transServiceUUID]) {
        isISSCPeripheral = TRUE;
        for (aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:_transRxUUID])
            {
                [myPeripheral setTransparentDataWriteChar:aChar];
                NSLog(@"found custom TRANS_RX");
            }
            else if ([aChar.UUID isEqual:_transTxUUID])
            {
                NSLog(@"found custome TRANS_TX");
                [myPeripheral setTransparentDataReadChar:aChar];
            }
        }
    }
    //2013-12-12
    else if([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_LightBlue_SERVICE]])
    {
        isISSCPeripheral=TRUE;
        for(aChar in service.characteristics)
        {
            if ((_transServiceUUID == nil) && [aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_LightBlue_NotifyCHAR]])
            {
                [aPeripheral setNotifyValue:TRUE forCharacteristic:aChar];
                NSLog(@"found TRANS_RX");
                
            }
        }
    }
    else if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE]]) {
        isISSCPeripheral = TRUE;
        for (aChar in service.characteristics)
        {
            if ((_transServiceUUID == nil) && [aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_RX]]) {
                [myPeripheral setTransparentDataWriteChar:aChar];
                NSLog(@"found TRANS_RX");
                
            }
            else if ((_transServiceUUID == nil) && [aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_TX]]) {
                 NSLog(@"found TRANS_TX");
                [aPeripheral setNotifyValue:TRUE forCharacteristic:aChar];
                [myPeripheral setTransparentDataReadChar:aChar];
                //[aPeripheral setNotifyValue:TRUE forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_CONNECTION_PARAMETER_CHAR]]) {
                [myPeripheral setConnectionParameterChar:aChar];
                 NSLog(@"found CONNECTION_PARAMETER_CHAR");
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_AIR_PATCH_CHAR]]) {
                [myPeripheral setAirPatchChar:aChar];
                NSLog(@"found UUIDSTR_AIR_PATCH_CHAR");
                
            }
        }
    }
    else if([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_DEVICE_INFO_SERVICE]]) {

        for (aChar in service.characteristics)
        {
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_MANUFACTURE_NAME_CHAR]]) {
                [myPeripheral setManufactureNameChar:aChar];
                NSLog(@"found manufacture name char");
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_MODEL_NUMBER_CHAR]]) {
                [myPeripheral setModelNumberChar:aChar];
                    NSLog(@"found model number char");

            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_SERIAL_NUMBER_CHAR]]) {
                [myPeripheral setSerialNumberChar:aChar];
                NSLog(@"found serial number char");
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_HARDWARE_REVISION_CHAR]]) {
                [myPeripheral setHardwareRevisionChar:aChar];
                NSLog(@"found hardware revision char");
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_FIRMWARE_REVISION_CHAR]]) {
                [myPeripheral setFirmwareRevisionChar:aChar];
                NSLog(@"found firmware revision char");
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_SOFTWARE_REVISION_CHAR]]) {
                [myPeripheral setSoftwareRevisionChar:aChar];
                NSLog(@"found software revision char");
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_SYSTEM_ID_CHAR]]) {
                [myPeripheral setSystemIDChar:aChar];
                NSLog(@"[CBController] found system ID char");
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_IEEE_11073_20601_CHAR]]) {
                [myPeripheral setCertDataListChar:aChar];
                NSLog(@"found certification data list char");
            }
        }
    }
    isISSCPeripheral = TRUE;
    if (isISSCPeripheral == TRUE) {
        [self updateMyPeripheralForNewConnected:myPeripheral];
    }
}

//接收外设数据
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error 
{
    MyPeripheral *myPeripheral = [self retrieveMyPeripheral:aPeripheral];
    if (myPeripheral == nil)
    {
        return;
    }
    NSLog(@"[CBController] didUpdateValueForCharacteristic");
    if([characteristic.service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_LightBlue_SERVICE]])
    {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_LightBlue_NotifyCHAR]])
        {
            NSLog(@"%@",characteristic.value);
            NSString *strTemp=[NSString stringWithFormat:@"%@",characteristic.value];
            strTemp=[strTemp stringByReplacingOccurrencesOfString:@"<" withString:@""];
            strTemp=[strTemp stringByReplacingOccurrencesOfString:@">" withString:@""];
            
            NSMutableString *str = [[NSMutableString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
            NSLog(@"%@",str);
            [self hexStrToData:[NSString stringWithFormat:@"%@",characteristic.value]];
        }
        else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_LightBlue_ReadCHAR]])
        {
            NSLog(@"%@",characteristic.value);
        }
    }
    else if ([characteristic.service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_DEVICE_INFO_SERVICE]])
    {
        if (myPeripheral.deviceInfoDelegate == nil)
            return;
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_MANUFACTURE_NAME_CHAR]])
        {
            NSLog(@"[CBController] update manufacture name");
            
            if ([(NSObject *)myPeripheral.deviceInfoDelegate respondsToSelector:@selector(MyPeripheral:didUpdateManufactureName:error:)])
            {
                [[myPeripheral deviceInfoDelegate] MyPeripheral:myPeripheral didUpdateManufactureName:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] error:error];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_MODEL_NUMBER_CHAR]])
        {
            NSLog(@"[CBController] update model number");

            
            if ([(NSObject *)myPeripheral.deviceInfoDelegate respondsToSelector:@selector(MyPeripheral:didUpdateModelNumber:error:)])
            {
                [myPeripheral.deviceInfoDelegate MyPeripheral:myPeripheral didUpdateModelNumber:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] error:error];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_SERIAL_NUMBER_CHAR]])
        {
            NSLog(@"[CBController] update serial number");
            
            if ([(NSObject *)myPeripheral.deviceInfoDelegate respondsToSelector:@selector(MyPeripheral:didUpdateSerialNumber:error:)])
            {
                [myPeripheral.deviceInfoDelegate MyPeripheral:myPeripheral didUpdateSerialNumber:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] error:error];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_HARDWARE_REVISION_CHAR]])
        {
            NSLog(@"[CBController] update hardware revision");

            
            if ([(NSObject *)myPeripheral.deviceInfoDelegate respondsToSelector:@selector(MyPeripheral:didUpdateHardwareRevision:error:)])
            {
                [myPeripheral.deviceInfoDelegate MyPeripheral:myPeripheral didUpdateHardwareRevision:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] error:error];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_FIRMWARE_REVISION_CHAR]])
        {
            NSLog(@"[CBController] update firmware revision");

            
            if ([(NSObject *)myPeripheral.deviceInfoDelegate respondsToSelector:@selector(MyPeripheral:didUpdateFirmwareRevision:error:)])
            {
                [myPeripheral.deviceInfoDelegate MyPeripheral:myPeripheral didUpdateFirmwareRevision:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] error:error];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_SOFTWARE_REVISION_CHAR]])
        {

            NSLog(@"[CBController] update software revision");

            if ([(NSObject *)myPeripheral.deviceInfoDelegate respondsToSelector:@selector(MyPeripheral:didUpdateSoftwareRevision:error:)])
            {
                [myPeripheral.deviceInfoDelegate MyPeripheral:myPeripheral didUpdateSoftwareRevision:[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding] error:error];
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_SYSTEM_ID_CHAR]])
        {
            NSLog(@"[CBController] update system ID");

            if ([(NSObject *)myPeripheral.deviceInfoDelegate respondsToSelector:@selector(MyPeripheral:didUpdateSystemId:error:)])
            {
                
                [myPeripheral.deviceInfoDelegate MyPeripheral:myPeripheral didUpdateSystemId:characteristic.value error:error];
                
            }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_IEEE_11073_20601_CHAR]])
        {
            NSLog(@"[CBController] update IEEE_11073_20601: %@",characteristic.value);

            if ([(NSObject *)myPeripheral.deviceInfoDelegate respondsToSelector:@selector(MyPeripheral:didUpdateIEEE_11073_20601:error:)])
            {
                
                [myPeripheral.deviceInfoDelegate MyPeripheral:myPeripheral didUpdateIEEE_11073_20601:characteristic.value error:error];
                
            }
        }
    }
    else if ([characteristic.service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE]]) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_CONNECTION_PARAMETER_CHAR]])
        {
            NSLog(@"[CBController] update connection parameter: %@", characteristic.value);
            unsigned char buf[10];
            CONNECTION_PARAMETER_FORMAT *parameter;
            
            [characteristic.value getBytes:&buf[0] length:sizeof(CONNECTION_PARAMETER_FORMAT)];
            parameter = (CONNECTION_PARAMETER_FORMAT *)&buf[0];


            if ([myPeripheral retrieveBackupConnectionParameter]->status == 0xff) {
                [myPeripheral updateBackupConnectionParameter:parameter];
            }
            else {
                switch (myPeripheral.updateConnectionParameterStep) {
                    case UPDATE_PARAMETERS_STEP_PREPARE:
                        if ((myPeripheral.proprietaryDelegate != nil) && ([(NSObject *)myPeripheral.proprietaryDelegate respondsToSelector:@selector(MyPeripheral:didUpdateConnectionParameterAllowStatus:)]))
                            [myPeripheral.proprietaryDelegate MyPeripheral:myPeripheral didUpdateConnectionParameterAllowStatus:(buf[0] == 0x00)];
                            break;
                    case UPDATE_PARAMETERS_STEP_CHECK_RESULT:
                        if (buf[0] != 0x00) {
                            NSLog(@"[CBController] check connection parameter status again");
                            [myPeripheral checkConnectionParameterStatus];
                        }
                        else {
                            if ((myPeripheral.proprietaryDelegate != nil) && ([(NSObject *)myPeripheral.proprietaryDelegate respondsToSelector:@selector(MyPeripheral:didUpdateConnectionParameterStatus:interval:timeout:latency:)])){
                                if ([myPeripheral compareBackupConnectionParameter:parameter] == TRUE) {
                                    NSLog(@"[CBController] connection parameter no change");
                                    [myPeripheral.proprietaryDelegate MyPeripheral:myPeripheral didUpdateConnectionParameterStatus:FALSE interval:parameter->maxInterval*1.25 timeout:parameter->connectionTimeout*10 latency:parameter->latency];
                                }
                                else {
                                    //NSLog(@"connection parameter update success");
                                    [myPeripheral.proprietaryDelegate MyPeripheral:myPeripheral didUpdateConnectionParameterStatus:TRUE interval:parameter->maxInterval*1.25 timeout:parameter->connectionTimeout*10 latency:parameter->latency];
                                    [myPeripheral updateBackupConnectionParameter:parameter];
                                }
                            }
                        }
                    default:
                        break;
                }
           }
        }
        else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_AIR_PATCH_CHAR]]) {
            [myPeripheral updateAirPatchEvent:characteristic.value];
        }
        //接收数据
        else if ((_transServiceUUID == nil) && [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_TX]])
        {
            NSString *str1 = [NSString stringWithFormat:@"%@",characteristic.value];
            str1=[str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
            NSLog(str1);
            
            //[self processReceiveData:characteristic.value];
            //NSMutableString *str = [[NSMutableString alloc] initWithData:characteristic.value encoding:NSASCIIStringEncoding];
            //NSLog(@"%@",str);
            [self receiveData:characteristic.value];
            if ((myPeripheral.transDataDelegate != nil) && ([(NSObject *)myPeripheral.transDataDelegate respondsToSelector:@selector(MyPeripheral:didReceiveTransparentData:)])) {
                [myPeripheral.transDataDelegate MyPeripheral:myPeripheral didReceiveTransparentData:characteristic.value];
            }
        }
    }
    else if (_transServiceUUID && [characteristic.service.UUID isEqual:_transServiceUUID]) {
        if ([characteristic.UUID isEqual:_transTxUUID]) {
            if ((myPeripheral.transDataDelegate != nil) && ([(NSObject *)myPeripheral.transDataDelegate respondsToSelector:@selector(MyPeripheral:didReceiveTransparentData:)])) {
                [myPeripheral.transDataDelegate MyPeripheral:myPeripheral didReceiveTransparentData:characteristic.value];
            }
        }
    }
}

//2013-12-26  16进制数字转化为2进制数字
- (NSString *)stringToHexadecimal:(NSString * )num
{
    NSString *strRet=@"";
    NSString *strNum;
    for(int i=0;i<[num length];i++)
    {
        NSString *temp;
        strNum=[num substringWithRange:NSMakeRange(i,1)];
        if([strNum isEqualToString:@"a"])
        {
            temp=[aryHex objectAtIndex:10];
        }
        else if([strNum isEqualToString:@"b"])
        {
            temp=[aryHex objectAtIndex:11];
        }
        else if([strNum isEqualToString:@"c"])
        {
            temp=[aryHex objectAtIndex:12];
        }
        else if([strNum isEqualToString:@"d"])
        {
            temp=[aryHex objectAtIndex:13];
        }
        else if([strNum isEqualToString:@"e"])
        {
            temp=[aryHex objectAtIndex:14];
        }
        else if([strNum isEqualToString:@"f"])
        {
            temp=[aryHex objectAtIndex:15];
        }
        else
        {
            temp=[aryHex objectAtIndex:[strNum intValue]];
        }
        
        strRet=[strRet stringByAppendingString:temp];
    }
    if([strRet length]==4)
    {
        strRet=[@"0000" stringByAppendingString:strRet];
    }
    //NSLog(@"%@",strRet);
    return strRet;
}

//2013-12-25 处理蓝牙接受的数据
- (void) processReceiveData:(NSData *)data
{
    Byte *testBytes=(Byte *)[data bytes];
    NSMutableArray *tempAry=[[NSMutableArray alloc] init];
    for(int i=0;i<[data length];i++)
    {
        //NSLog(@"%x",testBytes[i]);
        NSString *hexStr=[NSString stringWithFormat:@"%x",testBytes[i]];
        //NSString *temp=[self stringToHexadecimal:[NSString stringWithFormat:@"%x",testBytes[i]]];
        NSString *temp=[self stringToHexadecimal:hexStr];
        //NSLog(@"%d:%@",i,hexStr);
        //NSLog(@"%d:%@",i,temp);
        [tempAry addObject:temp];
    }
    NSString *weight=[NSString stringWithFormat:@"%@%@",tempAry[8],tempAry[9]];
    double dWeight=[self calculateMeasureData:weight];
    NSString *showWeight=[NSString stringWithFormat:@"你的体重是%.1f",dWeight/10];
    NSLog(showWeight);
}

//2013-12-25 将二进制字符串转化为10进制数字
-(double)calculateMeasureData:(NSString *)strData
{
    if([strData length]==0) return -1;
    double iRet=0;
    double dTemp;
    int dataLength=[strData length];
    for(int i=0;i<dataLength;i++)
    {
        dTemp=[[strData substringWithRange:NSMakeRange(i, 1)] doubleValue];
        if(dTemp>0)
        {
            iRet=iRet+dTemp*pow(2,dataLength-i-1);
        }
        
    }
    return iRet;
}

//发送value到特征
- (void) peripheral:(CBPeripheral *)aPeripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error 
{
    NSLog(@"[CBController] didWriteValueForCharacteristic error msg:%d, %@, %@", error.code ,[error localizedFailureReason], [error localizedDescription]);
    MyPeripheral *myPeripheral = [self retrieveMyPeripheral:aPeripheral];
    if (myPeripheral == nil)
    {
        return;
    }
    
    if ((_transServiceUUID == nil) && [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_ISSC_TRANS_RX]])
    {
        if ((myPeripheral.transDataDelegate != nil) && ([(NSObject *)myPeripheral.transDataDelegate respondsToSelector:@selector(MyPeripheral:didSendTransparentDataStatus:)]))
        {
            [myPeripheral.transDataDelegate MyPeripheral:myPeripheral didSendTransparentDataStatus:error];
        }
    }
    else if (_transServiceUUID && [characteristic.UUID isEqual:_transRxUUID])
    {
        if ((myPeripheral.transDataDelegate != nil) && ([(NSObject *)myPeripheral.transDataDelegate respondsToSelector:@selector(MyPeripheral:didSendTransparentDataStatus:)]))
        {
            [myPeripheral.transDataDelegate MyPeripheral:myPeripheral didSendTransparentDataStatus:error];
        }
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"[CBController] didDiscoverDescriptorsForCharacteristic error msg:%d, %@, %@", error.code ,[error localizedFailureReason], [error localizedDescription]);
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    NSLog(@"[CBController] didUpdateValueForDescriptor");
}

//特征值更新回调函数
-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //2014-03-14
    //NSLog(@"[CBController] didUpdateNotificationStateForCharacteristic, UUID = %@", characteristic.UUID);
    MyPeripheral *myPeripheral = [self retrieveMyPeripheral:peripheral];
    if (myPeripheral == nil)
    {
        return;
    }
    if ((myPeripheral.transDataDelegate != nil) && ([(NSObject *)myPeripheral.transDataDelegate respondsToSelector:@selector(MyPeripheral:didUpdateTransDataNotifyStatus:)]))
    {
        [myPeripheral.transDataDelegate MyPeripheral:myPeripheral didUpdateTransDataNotifyStatus:characteristic.isNotifying];
    }
    
}
@end

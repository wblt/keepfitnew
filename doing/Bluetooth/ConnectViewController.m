
#import "AppDelegate.h"
#import "ConnectViewController.h"
#import "SettingAlertView.h"
@interface ConnectViewController ()

@end

@implementation ConnectViewController

@synthesize activityIndicatorView;
@synthesize statusLabel;
@synthesize connectionStatus;
@synthesize versionLabel;
@synthesize userInfo;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 28, 57, 57)];
        [titleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Icon_old"]]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        self.navigationItem.titleView = titleLabel;
        
        [titleLabel release];

        buttonToLogin = [[UIBarButtonItem alloc] initWithTitle:@" 返回 " style:UIBarButtonItemStyleBordered target:self action:@selector(backToLogin:)];
        refreshButton = [[UIBarButtonItem alloc] initWithTitle:@" 刷新 " style:UIBarButtonItemStyleBordered target:self action:@selector(refreshDeviceList:)];
        scanButton = [[UIBarButtonItem alloc] initWithTitle:@"  搜索  " style:UIBarButtonItemStyleBordered target:self action:@selector(startScan)];
        cancelButton = [[UIBarButtonItem alloc] initWithTitle:@" 取消 " style:UIBarButtonItemStyleBordered target:self action:@selector(actionButtonCancelScan:)];
    

        connectedDeviceInfo = [NSMutableArray new];
        connectingList = [NSMutableArray new];

        deviceInfo = [[DeviceInfo alloc]init];
        refreshDeviceListTimer = nil;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setConnectionStatus:LE_STATUS_IDLE];  
}

- (void)viewDidAppear:(BOOL)animated
{
    [[self navigationController] setToolbarHidden:NO animated:NO];
    if([connectedDeviceInfo count] == 0)
    {
        [self configureTransparentServiceUUID:nil txUUID:nil rxUUID:nil];
    }
    //[self startScan];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:animated];
}

- (void)viewDidUnload
{
    [devicesTableView release];
    devicesTableView = nil;
    [self setVersionLabel:nil];
    [refreshButton release];
    refreshButton = nil;
    [super viewDidUnload];
}


- (void)didReceiveMemoryWarning
{
    NSLog(@"[ConnectViewController] didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [devicesTableView release];
    [versionLabel release];
    [refreshButton release];
    [cancelButton release];
    [scanButton release];
    [uuidSettingButton release];
    [buttonToLogin release];
    [self.lblWeight release];
    [super dealloc];
}

//显示外设列表
- (void) displayDevicesList
{
    [devicesTableView reloadData];
}

//切换到主属性界面
- (void) switchToMainFeaturePage
{
    NSLog(@"[ConnectViewController] switchToMainFeaturePage");
    
    if([[[self navigationController] viewControllers] containsObject:[deviceInfo mainViewController]] == FALSE)
    {
        deviceInfo.mainViewController.userInfo=self.userInfo;
        [[self navigationController] pushViewController:[deviceInfo mainViewController] animated:YES];
    }
}

//获取连接状态
- (int) connectionStatus
{
    return connectionStatus;
}

//设置连接状态
- (void) setConnectionStatus:(int)status
{
    if (status == LE_STATUS_IDLE)
    {
        statusLabel.textColor = [UIColor redColor];
    }
    else
    {
        statusLabel.textColor = [UIColor blackColor];
    }
    connectionStatus = status;

    switch (status)
    {
        case LE_STATUS_IDLE:
            statusLabel.text = @"暂停";
            [activityIndicatorView stopAnimating];
            break;
        case LE_STATUS_SCANNING:
            [devicesTableView reloadData];
            statusLabel.text = @"请上秤";
            [activityIndicatorView startAnimating];
            break;
        default:
            break;
    }
    [self updateButtonType];
}

//取消扫描
- (IBAction)actionButtonCancelScan:(id)sender
{
    NSLog(@"[ConnectViewController] actionButtonCancelScan");
    [self stopScan];
    [self setConnectionStatus:LE_STATUS_IDLE];
}

//开始扫描
- (void)startScan
{
    [super startScan];
    if ([connectingList count] > 0)
    {
        for (int i=0; i< [connectingList count]; i++)
        {
            MyPeripheral *connectingPeripheral = [connectingList objectAtIndex:i];
            
            if (connectingPeripheral.connectStaus == MYPERIPHERAL_CONNECT_STATUS_CONNECTING)
            {
                NSLog(@"startScan add connecting List: %@",connectingPeripheral.advName);
                [devicesList addObject:connectingPeripheral];
            }
            else
            {
                [connectingList removeObjectAtIndex:i];
                NSLog(@"startScan remove connecting List: %@",connectingPeripheral.advName);
            }
        }
    }
    [self setConnectionStatus:LE_STATUS_SCANNING];
}

//停止扫描
- (void)stopScan
{
    [super stopScan];
    if (refreshDeviceListTimer)
    {
        [refreshDeviceListTimer invalidate];
        refreshDeviceListTimer = nil;
        self.lblWeight.text=@"";
    }
}

-(void)receiveData:(NSData *)data
{
    [self processReceiveData:data];
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
    NSString *showWeight=[NSString stringWithFormat:@"你的体重是%.1fkg",dWeight/10];
    self.lblWeight.text=showWeight;
    NSLog(showWeight);
}

//2013-12-26 将二进制字符串转化为10进制数字
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

//弹窗提示
- (void) showMessage:(NSString *)msg
{
    @try
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@""
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [alert show];
    }
    @catch (NSException *exception)
    {
        NSLog(@"%d:%@",__LINE__,exception);
    }
    
}

//跳转回蓝牙连接页面
-(void)popToRootPage
{
    
}

//更新发现的设备
- (void)updateDiscoverPeripherals
{
    [super updateDiscoverPeripherals];
    [devicesTableView reloadData];
}

//失去连接
- (void)updateMyPeripheralForDisconnect:(MyPeripheral *)myPeripheral
{
    NSLog(@"updateMyPeripheralForDisconnect");
    if (myPeripheral == controlPeripheral)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(popToRootPage) userInfo:nil repeats:NO];
    }
    
    for (int idx =0; idx< [connectedDeviceInfo count]; idx++)
    {
        DeviceInfo *tmpDeviceInfo = [connectedDeviceInfo objectAtIndex:idx];
        if (tmpDeviceInfo.myPeripheral == myPeripheral)
        {
            [connectedDeviceInfo removeObjectAtIndex:idx];
            break;
        }
    }
    
    for (int idx =0; idx< [connectingList count]; idx++)
    {
        MyPeripheral *tmpPeripheral = [connectingList objectAtIndex:idx];
        if (tmpPeripheral == myPeripheral)
        {
            [connectingList removeObjectAtIndex:idx];
            break;
        }
        else
        {
            //NSLog(@"updateMyPeripheralForDisconnect3 %@, %@", tmpPeripheral.advName, myPeripheral.advName);
        }
        
    }

    [self displayDevicesList];
    [self updateButtonType];
    
    if(connectionStatus == LE_STATUS_SCANNING)
    {
        [self stopScan];
        [self startScan];
        [devicesTableView reloadData];
    }
}

//新连接
- (void)updateMyPeripheralForNewConnected:(MyPeripheral *)myPeripheral
{
    NSLog(@"[ConnectViewController] updateMyPeripheralForNewConnected");
    DeviceInfo *tmpDeviceInfo = [[DeviceInfo alloc]init];
    tmpDeviceInfo.mainViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    tmpDeviceInfo.mainViewController.connectedPeripheral = myPeripheral;
    tmpDeviceInfo.myPeripheral = myPeripheral;
    tmpDeviceInfo.myPeripheral.connectStaus = myPeripheral.connectStaus;
   
    bool b = FALSE;
    for (int idx =0; idx< [connectedDeviceInfo count]; idx++)
    {
        DeviceInfo *tmpDeviceInfo = [connectedDeviceInfo objectAtIndex:idx];
        if (tmpDeviceInfo.myPeripheral == myPeripheral)
        {
            b = TRUE;
            break;
        }
    }
    if (!b)
    {
        [connectedDeviceInfo addObject:tmpDeviceInfo];
    }
    else
    {
        NSLog(@"Connected List Filter!");
    }
    
    for (int idx =0; idx< [connectingList count]; idx++)
    {
        MyPeripheral *tmpPeripheral = [connectingList objectAtIndex:idx];
        if (tmpPeripheral == myPeripheral)
        {
            [connectingList removeObjectAtIndex:idx];
            break;
        }
    }
    
    for (int idx =0; idx< [devicesList count]; idx++)
    {
        MyPeripheral *tmpPeripheral = [devicesList objectAtIndex:idx];
        if (tmpPeripheral == myPeripheral)
        {
            [devicesList removeObjectAtIndex:idx];
            break;
        }
    }
    [self displayDevicesList];
    [self updateButtonType];
}

//每个区有多少行
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return [connectedDeviceInfo count];
        case 1:
            return [devicesList count];
        default:
            return 0;
        }
    }

//绘制cell
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    UITableViewCell *cell;
    
    switch (indexPath.section)
    {
        //连接的设备
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"connectedList"];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"connectedList"] autorelease];
            }
            DeviceInfo *tmpDeviceInfo = [connectedDeviceInfo objectAtIndex:indexPath.row];
            
            cell.textLabel.text = tmpDeviceInfo.myPeripheral.advName;
            cell.detailTextLabel.text = @"connected";
            cell.accessoryView = nil;
            if (cell.textLabel.text == nil)
            {
                cell.textLabel.text = @"Unknow";
            }
            
            UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [accessoryButton addTarget:self action:@selector(actionButtonDisconnect:)  forControlEvents:UIControlEventTouchUpInside];
            accessoryButton.tag = indexPath.row;
            [accessoryButton setTitle:@"Disonnect" forState:UIControlStateNormal];
            [accessoryButton setFrame:CGRectMake(0,0,100,35)];
            cell.accessoryView  = accessoryButton;           
        }
            break;
         //发现的设备
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"devicesList"];
            if (cell == nil)
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"devicesList"] autorelease];
            }
            MyPeripheral *tmpPeripheral = [devicesList objectAtIndex:indexPath.row];
            cell.textLabel.text = tmpPeripheral.advName;
            cell.detailTextLabel.text = @"";
            cell.accessoryView = nil;
            if (tmpPeripheral.connectStaus == MYPERIPHERAL_CONNECT_STATUS_CONNECTING)
            {
                cell.detailTextLabel.text = @"connecting...";
                UIButton *accessoryButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [accessoryButton addTarget:self action:@selector(actionButtonCancelConnect:)  forControlEvents:UIControlEventTouchUpInside];
                accessoryButton.tag = indexPath.row;
                [accessoryButton setTitle:@"Cancel" forState:UIControlStateNormal];
                [accessoryButton setFrame:CGRectMake(0,0,100,35)];
                cell.accessoryView  = accessoryButton;
                
            }
            
            if (cell.textLabel.text == nil)
            {
                cell.textLabel.text = @"Unknow";
            }
        }
            break;
    }
    
    return cell;
}

//每个区的标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	NSString *title = nil;
	switch (section)
    {
        case 0:
            title=@"连接的设备:";
            break;
		case 1:
            title=@"发现的设备:";
			break;
            
		default:
			break;
	}
	return title;
}

//返回tableview有多少个区
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

//选中cell时触发
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            //NSLog(@"[ConnectViewController] didSelectRowAtIndexPath section 0, Row = %d",[indexPath row]);
            deviceInfo = [connectedDeviceInfo objectAtIndex:indexPath.row];
            controlPeripheral = deviceInfo.myPeripheral;
            [self stopScan];
            [self setConnectionStatus:LE_STATUS_IDLE];
            [activityIndicatorView stopAnimating];
            if (refreshDeviceListTimer)
            {
                [refreshDeviceListTimer invalidate];
                refreshDeviceListTimer = nil;
            }
            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(switchToMainFeaturePage) userInfo:nil repeats:NO];
        }
            break;
        case 1:
        {
            NSLog(@"[ConnectViewController] didSelectRowAtIndexPath section 0, Row = %d",[indexPath row]);
            int count = [devicesList count];
            if ((count != 0) && count > indexPath.row)
            {
                MyPeripheral *tmpPeripheral = [devicesList objectAtIndex:indexPath.row];
                if (tmpPeripheral.connectStaus != MYPERIPHERAL_CONNECT_STATUS_IDLE)
                {
                    break;
                }
                [self connectDevice:tmpPeripheral];
                tmpPeripheral.connectStaus = MYPERIPHERAL_CONNECT_STATUS_CONNECTING;
                [devicesList replaceObjectAtIndex:indexPath.row withObject:tmpPeripheral];
                [connectingList addObject:tmpPeripheral];
                [self displayDevicesList];
                [self updateButtonType];
            }
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction)refreshDeviceList:(id)sender
{
    NSLog(@"[ConnectViewController] refreshDeviceList");
    [self stopScan];
    [self startScan];
    [devicesTableView reloadData];
}


//Disconnect按钮点击事件
- (IBAction)actionButtonDisconnect:(id)sender
{
    int idx = [sender tag];
    DeviceInfo *tmpDeviceInfo = [connectedDeviceInfo objectAtIndex:idx];
    [self disconnectDevice:tmpDeviceInfo.myPeripheral];
}

//Cancle按钮点击事件
- (IBAction)actionButtonCancelConnect:(id)sender
{
    int idx = [sender tag];
    MyPeripheral *tmpPeripheral = [devicesList objectAtIndex:idx];
    tmpPeripheral.connectStaus = MYPERIPHERAL_CONNECT_STATUS_IDLE;
    [devicesList replaceObjectAtIndex:idx withObject:tmpPeripheral];
    
    for (int idx =0; idx< [connectingList count]; idx++)
    {
        MyPeripheral *tmpConnectingPeripheral = [connectingList objectAtIndex:idx];
        if (tmpConnectingPeripheral == tmpPeripheral)
        {
            [connectingList removeObjectAtIndex:idx];
            break;
        }
    }
    
    [self disconnectDevice:tmpPeripheral];
    [self displayDevicesList];
    [self updateButtonType];
}

//更新底部按钮
- (void) updateButtonType
{
    NSArray *toolbarItems = nil;
    switch (connectionStatus)
    {
        case LE_STATUS_IDLE:
            toolbarItems = [[NSArray alloc] initWithObjects:scanButton, nil];
            [self setToolbarItems:toolbarItems animated:NO];
            [toolbarItems release];
            break;
        case LE_STATUS_SCANNING:
            toolbarItems = [[NSArray alloc] initWithObjects:refreshButton,cancelButton , nil];
            [self setToolbarItems:toolbarItems animated:NO];
            [toolbarItems release];
            break;
    }
}

@end












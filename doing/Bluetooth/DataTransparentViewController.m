#import "DataTransparentViewController.h"
#import "AppDelegate.h"
#import "UserInfo.h"
#import "ConnectViewController.h"


@interface DataTransparentViewController ()

@end

@implementation DataTransparentViewController
@synthesize dirArray;
@synthesize connectedPeripheral;
@synthesize comparedPath;
@synthesize checkRxDataTimer;
@synthesize receivedDataPath;
@synthesize userInfo;
@synthesize uploadUserInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    //NSLog(@"[DataTransparentViewController] initWithNibName");
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
        content = [[NSMutableString alloc] initWithCapacity:100008];
    }
    return self;
}

- (void)viewDidLoad
{
    //NSLog(@"[DataTransparentViewController] viewDidLoad");
    [super viewDidLoad];
    
    webSend=0;
    showData=0;

    aryHex=[[NSArray alloc] initWithObjects:@"0000",@"0001",@"0010",@"0011",@"0100",@"0101",@"0110",@"0111",@"1000",@"1001",@"1010",@"1011",@"1100",@"1101",@"1110",@"1111",nil];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 28, 57, 57)];
    [titleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Icon_old"]]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    self.navigationItem.titleView = titleLabel;
    [titleLabel release];
    

    uploadButton = [[UIBarButtonItem alloc] initWithTitle:@" 上传 " style:UIBarButtonItemStyleBordered target:self action:@selector(uploadMsgToServer)];
    clearButton = [[UIBarButtonItem alloc] initWithTitle:@"  清空  " style:UIBarButtonItemStyleBordered target:self action:@selector(clearWebView)];
    NSArray *toolbarItems = [[NSArray alloc] initWithObjects:uploadButton,clearButton, nil];
    self.toolbarItems = toolbarItems;
    [toolbarItems release];
     writeType = CBCharacteristicWriteWithResponse;
    
    [self.webView setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [self groupComponentsDisplay];
    editingTextField = self.inputTextField;
    fileManager = [NSFileManager defaultManager];
    
    NSString *path = [[NSString alloc] initWithFormat:@"%@/%@.app",NSHomeDirectory(), [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"]];
    NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtPath: path];
    
    dirArray = [[NSMutableArray alloc] init];
    
    NSString *currentFile;
    while (currentFile = [dirEnumerator nextObject])
    {
        NSRange range = [currentFile rangeOfString:@".txt"];
        if (range.location != NSNotFound)
        {
            [dirArray addObject:currentFile];
        }
    }
    if ([dirArray count] == 0)
    {
        [dirArray addObject:@"No File"];
    }
    NSLog(@"dirarray count = %d", [dirArray count]);
    [path release];
    comparedPath = nil;
    checkRxDataTimer = nil;
    receivedDataPath = nil;
    [connectedPeripheral setTransDataNotification:TRUE];

}

- (void)viewDidAppear:(BOOL)animated
{
    //NSLog(@"[DataTransparentViewController] viewDidAppear");
    [self groupComponentsDisplay];
    webFinishLoad = TRUE;
    [self reloadOutputView];

    [self.navigationController setToolbarHidden:NO animated:YES];
    if (([connectedPeripheral transparentDataWriteChar] == nil) || ([connectedPeripheral transparentDataReadChar] == nil) )
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Service Not Found" message:@"Can't find custom service UUID or TX/RX UUID" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    }
    
    [self sendData];
}

- (void)viewDidDisappear:(BOOL)animated {
    //NSLog(@"[DataTransparentViewController] viewDidDisappear");
    [editingTextField resignFirstResponder];

    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.inputTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    //NSLog(@"[DataTransparentViewController] didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    //NSLog(@"[DataTransparentViewController] dealloc");
    if (checkRxDataTimer)
    {
        [checkRxDataTimer invalidate];
    }
    if (receivedDataPath)
    {
        [fileManager removeItemAtPath:receivedDataPath error:NULL];
    }
    [_inputTextField release];
    [_segmentedControl release];
    [_timerDeltaTimeTextField release];
    [_timerPatternSizeTextField release];
    [_timerRepeatTimesTextField release];
    [_timerStartButton release];
    [_webView release];
    [_timerDeltaTimeLabel release];
    [_timerPatternSizeLabel release];
    [_timerRepeatTimesLabel release];
    [_timerLabel release];
    [_statusLabel release];
    [saveAsButton release];
    [compareButton release];
    [txFileButton release];
    [clearButton release];
    [cancelButton release];
    [writeTypeButton release];
    [_writeTypeLabel release];
    [super dealloc];
}

- (void)sendTransparentData:(NSData *)data
{
    NSLog(@"[DataTransparentViewController] sendTransparentData:%@", data);
    CBCharacteristicWriteType type = [connectedPeripheral sendTransparentData:data type:writeType];
    if (type == CBCharacteristicWriteWithoutResponse)
    {
        writeAllowFlag = TRUE;
        if (txPath)
        {
            [NSTimer scheduledTimerWithTimeInterval:0.0001 target:self selector:@selector(writeFile) userInfo:nil repeats:NO];
        }
    }
}
- (void)MyPeripheral:(MyPeripheral *)peripheral didSendTransparentDataStatus:(NSError *)error
{
    NSLog(@"[DataTransparentViewController] didSendTransparentDataStatus");
    if (error == nil)
    {
        writeAllowFlag = TRUE;
        if (txPath)
        {
            [NSTimer scheduledTimerWithTimeInterval:0.001 target:self selector:@selector(writeFile) userInfo:nil repeats:NO];
        }
    }
    else if (writeType == CBCharacteristicWriteWithResponse)
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Transparent data TX error" message:error.domain delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        if (txPath)
        {
            [txPath release];
            txPath = nil;
        }
        if (sendDataTimer)
        {
            [sendDataTimer invalidate];
            sendDataTimer = nil;
            [self.timerStartButton setTitle: @"Start" forState:UIControlStateNormal];
        }
    }
}

- (void) moveTextViewForKeyboard:(NSNotification*)aNotification up: (BOOL) up
{
    NSDictionary* info = [aNotification userInfo];
    
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    
    CGRect keyboardEndFrame;
    
    [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[info objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    // Animate up or down
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = self.view.frame;
    CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    
    newFrame.origin.y -= (keyboardFrame.size.height-100) * (up? 1 : -1);
    self.view.frame = newFrame;
    
    [UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self moveTextViewForKeyboard:notification up:YES];
	[self.webView stringByEvaluatingJavaScriptFromString:@"window.scrollTo(document.body.scrollWidth, document.body.scrollHeight);"];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self moveTextViewForKeyboard:notification up:NO];
	[self.webView stringByEvaluatingJavaScriptFromString:@"window.scrollTo(document.body.scrollWidth, document.body.scrollHeight);"];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    NSLog(@"[DataTransparentViewController] webViewDidFinishLoad");
    [self.webView stringByEvaluatingJavaScriptFromString:@"window.scrollTo(document.body.scrollWidth, document.body.scrollHeight);"];
    webFinishLoad = TRUE;
}

- (void)reloadOutputView
{
    return;
    if (webFinishLoad)
    {
        NSLog(@"[DataTransparentViewController] reloadOutputView");
        webFinishLoad = FALSE;
        NSString *tmp = [[NSString alloc] initWithFormat:@"<html><body>%@</body></html>", content];
        [self.webView loadHTMLString:tmp baseURL:nil];
        [tmp release];
    }
    
	// TODO implement scrollsToBottomAnimated
}

-(void)reloadMeasureData:(NSString *)data
{
    if(showData==0)
    {
        showData+=1;
        NSString *tmp = [[NSString alloc] initWithFormat:@"<html><body>%@</body></html>", data];
        
        [self.webView loadHTMLString:tmp baseURL:nil];
        [tmp release];
    }
    
}



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

// <--- UITextFieldDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.3f];
    float width=self.view.frame.size.width;
    float height=self.view.frame.size.height;
    CGRect rect=CGRectMake(0.0f,-80*(textView.tag),width,height);//上移80个单位，一般也够用了
    self.view.frame=rect;
    [UIView commitAnimations];
    return YES;
}

- (BOOL) textFieldDidBeginEditing: (UITextField *)textField
{
    NSLog(@"[DataTransparentViewController] textFieldDidBeginEditing LE");
    editingTextField = textField;
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    return YES;
}

- (BOOL) textFieldDidEndEditing: (UITextField *)textField
{
    NSLog(@"[DataTransparentViewController] textFieldDidEndEditing LE");

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"[DataTransparentViewController] shouldChangeCharactersInRange LE");
    if (textField != self.inputTextField)
    {
        NSCharacterSet *unacceptedInput = [[NSCharacterSet characterSetWithCharactersInString:@"1234567890"] invertedSet];
		if ([[string componentsSeparatedByCharactersInSet:unacceptedInput] count] > 1)
			return NO;
		else
			return YES;
    }
    else
    {
        if ([self.inputTextField.text length] > 20)
        {
            return NO;
        }
    }
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    self.navigationItem.rightBarButtonItem = nil;
    NSLog(@"[DataTransparentViewController] textFieldShouldReturn LE");
    if (textField == self.inputTextField)
    {
        self.inputTextField.placeholder = @"";
        [self sendData];
        self.inputTextField.text = @"";
    }
	return YES;
}
// UITextFieldDelegate --->

- (void)sendData
{
    NSLog(@"[DataTransparentViewController] sendData");
    [self sendTransparentData:[@"send" dataUsingEncoding:NSUTF8StringEncoding]];
    /*
    self.inputTextField.text=@"send";
    if ([[self.inputTextField text] length])
    {
        [self sendTransparentData:[[self.inputTextField text] dataUsingEncoding:NSUTF8StringEncoding]];
        [content appendFormat:@"<span>%@</span><br>", self.inputTextField.text];
        [self reloadOutputView];
    }*/
}

- (void) groupComponentsDisplay
{
    BOOL bRawModeGroup = false, bTimerModeGroup = false;

    if ([self.segmentedControl selectedSegmentIndex] == CBTimerMode)
    {
        bTimerModeGroup = false;
        bRawModeGroup = true;
    }
    else {
        bTimerModeGroup = true;
        bRawModeGroup = false;
    }
    
    self.webView.hidden = bRawModeGroup;
    self.inputTextField.hidden = bRawModeGroup;
    
    self.timerPatternSizeLabel.hidden = bTimerModeGroup;
    self.timerPatternSizeTextField.hidden = bTimerModeGroup;
    self.timerRepeatTimesLabel.hidden = bTimerModeGroup;
    self.timerRepeatTimesTextField.hidden = bTimerModeGroup;
    self.timerDeltaTimeLabel.hidden = bTimerModeGroup;
    self.timerDeltaTimeTextField.hidden = bTimerModeGroup;
    self.timerStartButton.hidden = bTimerModeGroup;
    
}

- (IBAction)segmentModeSwitch:(id)sender
{
    if (txPath)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Transmitting a file" message:nil delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alertView show];
        [alertView release];
        [self.segmentedControl setSelectedSegmentIndex:CBRawMode];
        return;
    }
    [self groupComponentsDisplay];
    int segmentIndex = [self.segmentedControl selectedSegmentIndex];

    if (segmentIndex == CBRawMode)
    {
        self.timerLabel.text = @"";
        [self reloadOutputView];
        NSArray *toolbarItems = [[NSArray alloc] initWithObjects:compareButton, txFileButton, writeTypeButton, clearButton, nil];
        [self setToolbarItems:toolbarItems animated:TRUE];
        [toolbarItems release];
    }
    else if (segmentIndex == CBLoopBackMode)
    {
        NSArray *toolbarItems = [[NSArray alloc] initWithObjects: writeTypeButton,clearButton, nil];
        [self setToolbarItems:toolbarItems animated:TRUE];
        [toolbarItems release];
    }
    else if (segmentIndex == CBTimerMode)
    {
        NSArray *toolbarItems = [[NSArray alloc] initWithObjects:writeTypeButton, nil];
        [self setToolbarItems:toolbarItems animated:TRUE];
        [toolbarItems release];
        
    }
    if (sendDataTimer)
    {
        [self.timerStartButton setTitle: @"Start" forState:UIControlStateNormal];
        [sendDataTimer invalidate];
        sendDataTimer = nil;
    }
}

- (void) SendTestPattern
{
      NSLog(@"[DataTransparentViewController] Send test pattern");
    
//    timeUpFlag = TRUE;
    if (writeAllowFlag == FALSE)
    {
        return;
    }
    writeAllowFlag = FALSE;
    //NSLog(@"Send test pattern2");
    NSString *tmp;
    timerCount++;
    
    if (pattern_times == 0)
    {
        tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %d, times = unlimited, Count = %d",timer_second,pattern_length, timerCount];
    }
    else
    {
        tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %d, times = %d, Count = %d",timer_second,pattern_length, pattern_times,timerCount];
        if (timerCount >= pattern_times)
        {
            [sendDataTimer invalidate];
            sendDataTimer = nil;
            [self.timerStartButton setTitle: @"Start" forState:UIControlStateNormal];
            NSLog(@"timer stop");
        }
    }
    NSLog(@"times = %d, counter = %d", pattern_times, timerCount);
    self.timerLabel.text = tmp;
    [tmp release];
    NSMutableString *pattern_str = [[NSMutableString alloc] initWithCapacity:pattern_length+10];
    for (int i=0; i<pattern_length-1; i++) {
        [pattern_str appendFormat:@"%d",timerCount%10];
    }
    [pattern_str appendFormat:@"\n"];
    [self sendTransparentData:[pattern_str dataUsingEncoding:NSMacOSRomanStringEncoding]];
    [pattern_str release];    
}

- (IBAction)timerButtonAction:(id)sender
{
    if (sendDataTimer)
    {
        [sendDataTimer invalidate];
        sendDataTimer = nil;
        [self.timerStartButton setTitle: @"Start" forState:UIControlStateNormal];
        return;
    }
    [editingTextField resignFirstResponder];
    float miliSecond = [self.timerDeltaTimeTextField.text integerValue];
    if (miliSecond != 0)
    {
        timer_second = (miliSecond/1000);
    }
    else
    {
        [self.timerDeltaTimeTextField becomeFirstResponder];
        return;
    }
    pattern_length = [self.timerPatternSizeTextField.text integerValue];
    if (pattern_length == 0)
    {
        [self.timerPatternSizeTextField becomeFirstResponder];
        return;
    }
    pattern_times = [self.timerRepeatTimesTextField.text integerValue];
    
    NSString *tmp;
    if (pattern_times == 0)
    {
        tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %d, times = unlimited",timer_second,pattern_length];
    }
    else
    {
        tmp = [[NSString alloc] initWithFormat:@"Timer = %.3fs, Len = %d, times = %d",timer_second,pattern_length,pattern_times];
    }
    self.timerLabel.text = tmp;
    [tmp release];
    [self.timerStartButton setTitle: @"Stop" forState:UIControlStateNormal];
    timerCount = 0;

    writeAllowFlag = TRUE;
    sendDataTimer = [NSTimer scheduledTimerWithTimeInterval:timer_second target:self selector:@selector(SendTestPattern) userInfo:nil repeats:YES];
    
}

//2013-10-17  16进制数字转化为2进制数字
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

//2013-10-17 处理蓝牙接受的数据
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
    
    for(int i=0;i<[tempAry count];i++)
    {
        //NSLog(@"%d:%@",i,[tempAry objectAtIndex:i]);
    }
    [self parseMeasureData:tempAry];
}

//分析电子秤上传数据
- (void)parseMeasureData:(NSMutableArray *)array
{
    if([array count]==21)
    {
        NSMutableString *outputString=[[NSMutableString alloc] initWithCapacity:10000];
        NSMutableArray *sendArray=[[NSMutableArray alloc] init];
        
        NSString *temp=@"";
        NSString *tempResult=@"";
        double iTemp=0;
        //设备类型
        if([(NSString *)[array objectAtIndex:1] isEqualToString:@"01010000"])
        {
            NSLog(@"%@:%@<br>",@"设备类型:",@"电子秤");
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"设备类型",@"电子秤"]];
            //[self reloadMeasureData:[NSString stringWithFormat:@"%@:%@",@"设备类型",@"电子秤"]];
            
        }
        else
        {
            NSLog(@"%@:%@<br>",@"设备类型:",@"未知设备");
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"设备类型",@"未知设备"]];
            //[self reloadMeasureData:[NSString stringWithFormat:@"%@:%@",@"设备类型:",@"未知设备"]];
        }
        
        //数据长度
        temp=[array objectAtIndex:3];
        iTemp=[self calculateMeasureData:temp];
        NSLog(@"%@:%.0f",@"数据长度:",iTemp);
        [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%.0f",@"数据长度",iTemp]];
        
        //用户组号
        temp=[array objectAtIndex:5];
        iTemp=[[temp substringWithRange:NSMakeRange(7-0, 1)] intValue]-[[temp substringWithRange:NSMakeRange(7-3, 1)] intValue]+[[temp substringWithRange:NSMakeRange(7-4, 1)] intValue]-[[temp substringWithRange:NSMakeRange(7-7, 1)] intValue];
        if(iTemp==0) tempResult=@"普通";
        else if(iTemp==1) tempResult=@"业余";
        else if(iTemp==2) tempResult=@"专业";
        else tempResult=@"未知";
        NSLog(@"%@:%@",@"用户组号:",tempResult);
        [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"用户组号",tempResult]];
        
        //性别
        temp=[array objectAtIndex:6];
        iTemp=[[temp substringWithRange:NSMakeRange(0, 1)] intValue];
        if(iTemp==1) tempResult=@"男";
        else if(iTemp==0) tempResult=@"女";
        else tempResult=@"未知";
        NSLog(@"%@:%@",@"性别",tempResult);
        
        [sendArray addObject:tempResult];
        [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"性别",tempResult]];
        
        //年龄
        iTemp=[self calculateMeasureData:[temp substringFromIndex:1]];
        NSLog(@"%@:%.0f",@"年龄",iTemp);
        
        [sendArray addObject:[NSString stringWithFormat:@"%.0f",iTemp]];
        [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%.0f",@"年龄",iTemp]];
        
        //身高
        temp=[array objectAtIndex:7];
        iTemp=[self calculateMeasureData:temp];
        NSLog(@"%@:%.0f",@"身高",iTemp);
        
        [sendArray addObject:[NSString stringWithFormat:@"%.0f",iTemp]];
        [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%.0f",@"身高",iTemp]];
        
        //体重
        temp=[array objectAtIndex:8];
        if([temp isEqualToString:@"11111111"])
        {
            NSLog(@"%@:%@",@"体重",@"Error");
            
            [sendArray addObject:@"0"];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"体重",@"Error"]];
        }
        else
        {
            NSString *tempLowWeight=[array objectAtIndex:9];
            temp=[temp stringByAppendingString:tempLowWeight];
            iTemp=[self calculateMeasureData:temp];
            iTemp=iTemp/10;
            NSLog(@"%@:%.1f",@"体重",iTemp);
            
            [sendArray addObject:[NSString stringWithFormat:@"%.1f",iTemp]];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%.1f",@"体重",iTemp]];
        }
        
        //脂肪
        temp=[array objectAtIndex:10];
        if([temp isEqualToString:@"11111111"])
        {
            NSLog(@"%@:%@",@"脂肪",@"Error");
            
            [sendArray addObject:@"0"];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"脂肪",@"Error"]];
            NSLog(@"%@:%@",@"骨头",@"Error");
            
            [sendArray addObject:@"0"];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"骨头",@"Error"]];
            NSLog(@"%@:%@",@"肌肉",@"Error");
            
            [sendArray addObject:@"0"];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"肌肉",@"Error"]];
            NSLog(@"%@:%@",@"内脏",@"Error");
            
            [sendArray addObject:@"0"];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"内脏",@"Error"]];
            NSLog(@"%@:%@",@"水分",@"Error");
            
            [sendArray addObject:@"0"];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"水分",@"Error"]];
            NSLog(@"%@:%@",@"热量",@"Error");
            
            [sendArray addObject:@"0"];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%@",@"热量",@"Error"]];
        }
        else
        {
            //脂肪
            NSString *tempLowFat=[array objectAtIndex:11];
            temp=[temp stringByAppendingString:tempLowFat];
            iTemp=[self calculateMeasureData:temp];
            iTemp=iTemp/10;
            NSLog(@"%@:%.1f",@"脂肪",iTemp);
            [sendArray addObject:[NSString stringWithFormat:@"%.1f",iTemp]];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%.1f",@"脂肪",iTemp]];
            
            //骨头
            temp=[array objectAtIndex:12];
            iTemp=[self calculateMeasureData:temp];
            iTemp=iTemp/10;
            NSLog(@"%@:%.1fkg",@"骨头",iTemp);
            
            [sendArray addObject:[NSString stringWithFormat:@"%.1f",iTemp]];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%.1fkg",@"骨头",iTemp]];
            
            //肌肉
            temp=[array objectAtIndex:13];
            NSString *tempLowMuscle=[array objectAtIndex:14];
            temp=[temp stringByAppendingString:tempLowMuscle];
            iTemp=[self calculateMeasureData:temp];
            iTemp=iTemp/10;
            NSLog(@"%@:%.1fkg",@"肌肉",iTemp);
            [sendArray addObject:[NSString stringWithFormat:@"%.1f",iTemp]];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%.1fkg",@"肌肉",iTemp]];
            
            //内脏
            temp=[array objectAtIndex:15];
            iTemp=[self calculateMeasureData:temp];
            NSLog(@"%@:%.0f",@"内脏",iTemp);
            
            [sendArray addObject:[NSString stringWithFormat:@"%.0f",iTemp]];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%.0f",@"内脏",iTemp]];
            
            //水份
            temp=[array objectAtIndex:16];
            NSString *tempLowWater=[array objectAtIndex:17];
            temp=[temp stringByAppendingString:tempLowWater];
            iTemp=[self calculateMeasureData:temp];
            iTemp=iTemp/10;
            NSLog(@"%@:%.1f",@"水份",iTemp);
            
            [sendArray addObject:[NSString stringWithFormat:@"%.1f",iTemp]];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%.1f",@"水份",iTemp]];
            
            //热量
            temp=[array objectAtIndex:18];
            NSString *tempLowHot=[array objectAtIndex:19];
            temp=[temp stringByAppendingString:tempLowHot];
            iTemp=[self calculateMeasureData:temp];
            NSLog(@"%@:%.0f",@"热量",iTemp);
            
            [sendArray addObject:[NSString stringWithFormat:@"%.0f",iTemp]];
            [outputString appendFormat:@"<span>%@</span><br>",[NSString stringWithFormat:@"%@:%.0f",@"热量",iTemp]];
            
            [self reloadMeasureData:outputString];
            
        }

    }
}

//将二进制字符串转化为10进制数字
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
    //NSLog(@"%d",iRet);
    return iRet;
}

- (void)MyPeripheral:(MyPeripheral *)peripheral didReceiveTransparentData:(NSData *)data
{
    NSLog(@"[DataTransparentViewController] didReceiveTransparentData");
    if ([data length] > 0)
    {
        int segmentIndex = [self.segmentedControl selectedSegmentIndex];
        
        NSMutableString *str = [[NSMutableString alloc] initWithData:data encoding:NSASCIIStringEncoding];
        [str replaceOccurrencesOfString:@"\n" withString:@"<br>" options:NSLiteralSearch range:NSMakeRange(0, [str length])];
        //Byte *testByte=(Byte *)[data bytes];
        //2013-10-17
        [self processReceiveData:data];
        
        [content appendFormat:@"<span style=\"color:red\">%@</span><br>", str];
        if (segmentIndex == CBLoopBackMode)
        {
            [content appendFormat:@"<span>%@</span><br>",str];
            [self sendTransparentData:data];
        }

        if (checkRxDataTimer == nil)
        {
            checkRxDataTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_RX_TIMER target:self selector:@selector(checkRxData) userInfo:nil repeats:YES];
            rxDataTime.trail_time = 0;
            rxDataTime.transmit_time = 0;
            rxDataTime.sinceDate = [[NSDate date] retain];
            lastReceivedByteCount = 0;
            
            receivedByteCount = 0;
        }
        
        if (receivedDataPath == nil)
        {
            receivedDataPath = [[NSString alloc] initWithFormat:@"%@/Documents/%f.txt",NSHomeDirectory(), [rxDataTime.sinceDate timeIntervalSince1970]];
            if (![fileManager createFileAtPath:receivedDataPath contents:nil attributes:nil])
            {
                NSLog(@"Create file fail");
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Create file fail!"  message:@"Create file fail! Cant save recevied file." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                [alertView release];
            }
            else
                NSLog(@"create file %@", receivedDataPath);
        }

        NSFileHandle *fileHandleWrite = [NSFileHandle fileHandleForWritingAtPath:receivedDataPath];
        if (fileHandleWrite == nil)
        {
            NSLog(@"open file fail");
        }
        rxDataTime.transmit_time = [[NSDate date] timeIntervalSinceDate:rxDataTime.sinceDate];
        receivedByteCount += [data length];
        [fileHandleWrite seekToEndOfFile];
        [fileHandleWrite writeData:data];
        [fileHandleWrite closeFile];
        if ([content length] > 5000)
        {
            NSRange range = {2500,1000};
            range = [content rangeOfString:@"<span style=" options:NSLiteralSearch range:range];
            if (range.location != NSNotFound)
            {
                range.length = range.location;
                range.location = 0;
                [content deleteCharactersInRange:range];
            }
            
        }
    }
}

- (void)saveReceivedData
{
    
}

- (void)selectCompareFile
{
    TableAlertView  *alert = [[[TableAlertView alloc] initWithCaller:self data:dirArray title:@"Select a file to compare" buttonTitle:@"Don't compare" andContext:@"Compare"] autorelease];
    [alert show];
}

- (void)selectTxFile
{
    TableAlertView  *alert = [[[TableAlertView alloc] initWithCaller:self data:dirArray title:@"Tx File" buttonTitle:@"Cancel" andContext:@"TxFile"] autorelease];
    [alert show];
}

- (void)toggleWriteType
{
    if (writeType == CBCharacteristicWriteWithResponse)
    {
        writeType = CBCharacteristicWriteWithoutResponse;
        [self.writeTypeLabel setText:@"Write without Response"];
    }
    else
    {
        writeType = CBCharacteristicWriteWithResponse;
        [self.writeTypeLabel setText:@"Write with Response"];
    }
    
}

//跳回连接页面
-(IBAction)popToConnectView:(id)sender
{
    ConnectViewController *connectView=[[ConnectViewController alloc] init];
    connectView.userInfo=self.userInfo;
    [self.navigationController pushViewController:connectView animated:YES];
}

- (void)clearWebView
{
    NSString *htmlBody = @"<html><body></body></html>";
	NSRange range;
    range.location = 0;
    range.length = [content length];
    [content deleteCharactersInRange:range];
	[self.webView loadHTMLString:htmlBody baseURL:nil];
}

-(void)didSelectRowAtIndex:(NSInteger)row withContext:(id)context
{
    NSString *tmp = (NSString *)context;
    if ([tmp isEqualToString:@"Compare"]) {
        NSLog(@"DataTransparentViewController] didSelectRowAtIndex Compare");
        if(row >= 0){
            comparedPath = [[NSString alloc] initWithFormat:@"%@/%@.app/%@",NSHomeDirectory(), [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"], [dirArray objectAtIndex:row]];
            NSLog(@"Did select %@", comparedPath);
        }
        else{
            NSLog(@"Selection cancelled");
            if (comparedPath) {
                [comparedPath release];
                comparedPath = nil;
            }
        }
    }
    else {
        if (row >= 0) {
            txPath = [[NSString alloc] initWithFormat:@"%@/%@.app/%@",NSHomeDirectory(), [[[NSBundle mainBundle] infoDictionary]   objectForKey:@"CFBundleName"], [dirArray objectAtIndex:row]];
            fileReadOffset = 0;
            writeAllowFlag = TRUE;
            [self writeFile];
            self.navigationItem.rightBarButtonItem = cancelButton;
        }
        else{
            NSLog(@"Selection cancelled");
            if (txPath) {
                [txPath release];
                txPath = nil;
            }
        }
        
    }
}

- (void)cancelEditing
{
    [editingTextField resignFirstResponder];
    if (txPath)
    {
        [txPath release];
        txPath = nil;
    }
    self.navigationItem.rightBarButtonItem = nil;
}

-(void) writeFile
{
  //  NSLog(@"DataTransparentViewController] writeFile");
    if (!txPath)
        return;
    NSFileHandle *fileHandleRead = [NSFileHandle fileHandleForReadingAtPath:txPath];
    if (fileHandleRead == nil) {
        NSLog(@"open file fail");
    }
    NSMutableData *data = [NSMutableData alloc];
    [fileHandleRead seekToFileOffset:fileReadOffset];
    [data setData: [fileHandleRead readDataOfLength:20]];
    
    if ([data length]) {
        fileReadOffset += [data length];
        NSLog(@"offset = %ld",fileReadOffset);
        [self sendTransparentData:data];
        [self.statusLabel setText:[[NSString alloc] initWithFormat:@"Writing file, Tx bytes = %ld", fileReadOffset]];
    }
    else {
        fileReadOffset = 0;
        NSString *str = [[NSString alloc] initWithFormat:@"file = %@",txPath];
        [txPath release];
        txPath = nil;
        self.navigationItem.rightBarButtonItem = nil;
        NSLog(@"tx complete");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Tx File Complete" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        [str release];
        [alertView release];
    }
    [data release];
    [fileHandleRead closeFile];
}

- (void)checkRxData
{
    rxDataTime.trail_time++;
    static short refreshOutputViewCount = 0;
    refreshOutputViewCount++;

    if (lastReceivedByteCount < receivedByteCount)
    {//check if new incoming data
        rxDataTime.trail_time = 0;
        lastReceivedByteCount = receivedByteCount;
        NSLog(@"current time = %f", (rxDataTime.transmit_time));
        
        NSString *tmp = [[NSString alloc] initWithFormat:@"Rx bytes = %d, time = %f",receivedByteCount, rxDataTime.transmit_time];
        self.statusLabel.text = tmp;
        [tmp release];
        if (refreshOutputViewCount > 10)
        {
            refreshOutputViewCount = 0;
            [self reloadOutputView];
        }
    }
    else if ((refreshOutputViewCount > rxDataTime.trail_time) && (refreshOutputViewCount > 10))
    {
        refreshOutputViewCount = 0;
        [self reloadOutputView];
    }
    else if (rxDataTime.trail_time >=50)
    {//no new incoming data over 5 seconds
        NSLog(@"rxDataTime.trail_time >=50..1");
        [checkRxDataTimer invalidate]; //remove timer
        checkRxDataTimer = nil;
        BOOL bResult = TRUE;
        refreshOutputViewCount = 0;
        if (comparedPath && [comparedPath length] != 0 && receivedDataPath)
        {
            NSLog(@"compare...");
            bResult = [fileManager contentsEqualAtPath:comparedPath andPath:receivedDataPath];
            
            NSString *tmp = [[NSString alloc] initWithFormat:@"Rx bytes = %d,  time = %.3fs,  compare %@",receivedByteCount, rxDataTime.transmit_time, bResult ?@"Pass":@"Fail"];
            self.statusLabel.text = tmp;
            [tmp release];
            if (bResult == false)
            {

                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Compare Fail"  message:[NSString stringWithFormat:@"Please check /Documents/%@.txt", [rxDataTime.sinceDate description]]  delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
                [alertView release];
            }
            [rxDataTime.sinceDate release];
        }
        if (bResult && receivedDataPath)
        {
            [fileManager removeItemAtPath:receivedDataPath error:NULL];
            receivedDataPath = nil;
        }
        NSLog(@"rxDataTime.trail_time >=50..2");
    }
}
- (void)viewDidUnload
{
    [self setWriteTypeLabel:nil];
    [super viewDidUnload];
}

- (void)MyPeripheral:(MyPeripheral *)peripheral didUpdateTransDataNotifyStatus:(BOOL)notify
{
    NSLog(@"DataTransparentViewController] didUpdateTransDataNotifyStatus = %@",notify==true?@"true":@"false");
}
@end

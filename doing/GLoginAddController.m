#import "GLoginAddController.h"

@interface GLoginAddController ()

@end

@implementation GLoginAddController

@synthesize pickerAge,pickerSex,datePickerView,heightPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}


- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    UIBezierPath* path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(45, 45) radius:45 startAngle:0 endAngle:2*M_PI clockwise:YES];
    CAShapeLayer* shape = [CAShapeLayer layer];
    shape.path = path.CGPath;
    
    self.viewHeight.layer.masksToBounds=YES;
    self.viewHeight.layer.cornerRadius=5.0;
    
    self.viewAge.layer.masksToBounds=YES;
    self.viewAge.layer.cornerRadius=5.0;
    
    self.viewSex.layer.masksToBounds=YES;
    self.viewSex.layer.cornerRadius=5.0;
    
    self.viewWC.layer.masksToBounds=YES;
    self.viewWC.layer.cornerRadius=5.0;
    
    self.viewHC.layer.masksToBounds=YES;
    self.viewHC.layer.cornerRadius=5.0;
    
    self.navigationController.navigationBarHidden=YES;
    tmpImage=nil;
    self.dbModule=[[DbModel alloc] init];
    _network=[[NetworkModule alloc] init];
    
    myBirthday=@"";
    myHeight=@"";
    myAge=@"20";
    myHC=@"";
    myWC=@"";
    
    self.lblSexValue.text=@"";
    self.lblHeightValue.text=@"";
    self.lblAgeValue.text=@"";
    self.lblWC.text=NSLocalizedString(@"可选", nil);
    self.lblHC.text=NSLocalizedString(@"可选", nil);
    
    self.lblSexValue.text=NSLocalizedString(@"profile_male", nil);
    mySex=NSLocalizedString(@"profile_male", nil);
    
    _strAgeName=NSLocalizedString(@"profile_age", nil);
    _strHeightName=NSLocalizedString(@"profile_height", nil);
    _strSexName=NSLocalizedString(@"profile_sex", nil);
    _strHCName=NSLocalizedString(@"profile_hc", nil);
    _strWCName=NSLocalizedString(@"profile_wc", nil);
    
    self.lblAge.text=NSLocalizedString(@"profile_age", nil);
    self.lblHeight.text=NSLocalizedString(@"profile_height", nil);
    self.lblSex.text=NSLocalizedString(@"profile_sex", nil);
    self.lblWCTitle.text=NSLocalizedString(@"m_wc", nil);
    self.lblHCTitle.text=NSLocalizedString(@"m_hc", nil);
    
    [self initPickerData];
    [self initMyViewControl];
    self.lblTopTitle.text=NSLocalizedString(@"profile_title", nil);
    if(self.iEditStyle == 1)
    {
        self.lblTopTitle.text=NSLocalizedString(@"profile_title", nil);
        [self setEditYunfuInfo];
    }

    [self initView];
    [self forbiddenGesturePop];
    
    [self.btnPickerCancle setTitle:NSLocalizedString(@"cancle", nil) forState:UIControlStateNormal];
    [self.btnPickerFinish setTitle:NSLocalizedString(@"finish", nil) forState:UIControlStateNormal];
    
    self.imageBack.hidden=NO;
    self.btnBack.hidden=NO;
    if(!_canBack)
    {
        self.imageBack.hidden=YES;
        self.btnBack.hidden=YES;
    }
}

-(void)forbiddenGesturePop
{
    //2015-06-25防止滑动返回
    UIGestureRecognizer *panGestureReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContentView:)];
    panGestureReconginzer.delegate = self;
    [self.view addGestureRecognizer:panGestureReconginzer];
}

//向右拖动界面
- (void)panInContentView:(UIPanGestureRecognizer *)panGestureReconginzer
{
    return;
}

-(void)initView
{
    self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone5FontSizeTitle];
    self.lblSex.font=[UIFont systemFontOfSize:iPhone5FontSizeName];
    if(is_iPhone6)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6FontSizeTitle];
        self.lblSex.font=[UIFont systemFontOfSize:iPhone6FontSizeName];
    }
    else if(is_iPhone6P)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6PFontSizeTitle];
        self.lblSex.font=[UIFont systemFontOfSize:iPhone6PFontSizeName];
    }
    
    self.btnLogin.frame=CGRectMake((SCREEN_WIDTH-240)/2.0, SCREEN_HEIGHT-40-40, 240, 40);
    
    [self.btnLogin.titleLabel setFont:self.lblSex.font];
    [self.btnLogin setTitle:NSLocalizedString(@"已有账号", nil) forState:UIControlStateNormal];
    
    self.lblSexValue.font=self.lblSex.font;
    self.lblAge.font=self.lblSex.font;
    self.lblHeight.font=self.lblSex.font;
    self.lblAgeValue.font=self.lblSex.font;
    self.lblHeightValue.font=self.lblSex.font;
    self.lblHC.font=self.lblSex.font;
    self.lblWC.font=self.lblSex.font;
    self.lblHCTitle.font=self.lblSex.font;
    self.lblWC.font=self.lblSex.font;
    self.lblPickerText.font=self.lblSex.font;
    
    self.viewTop.frame=CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT);
    self.lblTopTitle.frame=CGRectMake((SCREEN_WIDTH-150)/2, 20, 150, 44);
    
    self.imageBack.frame=CGRectMake(20, (44-0.03125*SCREEN_WIDTH)/2+20, 0.03125*SCREEN_WIDTH, 0.03125*SCREEN_WIDTH);
    self.imageFinish.frame=CGRectMake(SCREEN_WIDTH-0.046875*SCREEN_WIDTH-20, (44-0.03125*SCREEN_WIDTH)/2+20, 0.046875*SCREEN_WIDTH, 0.03125*SCREEN_WIDTH);
    
    self.btnBack.frame=CGRectMake(0, 20, 60, 44);
    self.btnFinish.frame=CGRectMake(SCREEN_WIDTH-60, 20, 60, 44);
    
    
    self.viewSex.frame=CGRectMake(58, 0.25*SCREEN_WIDTH, SCREEN_WIDTH-58-58, 0.1125*SCREEN_WIDTH);
    self.viewHeight.frame=CGRectMake(58, self.viewSex.frame.origin.y+self.viewSex.frame.size.height+22, SCREEN_WIDTH-58-58, 0.1125*SCREEN_WIDTH);
    self.viewAge.frame=CGRectMake(58, self.viewHeight.frame.origin.y+self.viewHeight.frame.size.height+22, SCREEN_WIDTH-58-58, 0.1125*SCREEN_WIDTH);
    self.viewWC.frame=CGRectMake(58, self.viewAge.frame.origin.y+self.viewAge.frame.size.height+22, SCREEN_WIDTH-58-58, 0.1125*SCREEN_WIDTH);
    self.viewHC.frame=CGRectMake(58, self.viewWC.frame.origin.y+self.viewWC.frame.size.height+22, SCREEN_WIDTH-58-58, 0.1125*SCREEN_WIDTH);
    
    self.imageAge.frame=CGRectMake(12, (self.viewAge.frame.size.height-0.075*SCREEN_WIDTH)/2, 0.075*SCREEN_WIDTH, 0.075*SCREEN_WIDTH);
    self.imageSex.frame=self.imageAge.frame;
    self.imageHeight.frame=self.imageAge.frame;
    self.imageHC.frame=self.imageAge.frame;
    self.imageWC.frame=self.imageAge.frame;
    
    self.btnSex.frame=CGRectMake(0, 0, self.viewSex.frame.size.width, self.viewSex.frame.size.height);
    self.btnAge.frame=CGRectMake(0, 0, self.viewAge.frame.size.width, self.viewAge.frame.size.height);
    self.btnHeight.frame=CGRectMake(0, 0, self.viewHeight.frame.size.width, self.viewHeight.frame.size.height);
    self.btnHC.frame=CGRectMake(0, 0, self.viewHC.frame.size.width, self.viewHC.frame.size.height);
    self.btnWC.frame=CGRectMake(0, 0, self.viewWC.frame.size.width, self.viewWC.frame.size.height);
    
    self.lblSex.frame=CGRectMake(self.imageSex.frame.origin.x+self.imageSex.frame.size.width+5, 0, 60, self.viewSex.frame.size.height);
    self.lblAge.frame=self.lblSex.frame;
    self.lblHeight.frame=self.lblSex.frame;
    self.lblHCTitle.frame=self.lblSex.frame;
    self.lblWCTitle.frame=self.lblSex.frame;
    
    self.lblSexValue.frame=CGRectMake(self.viewSex.frame.size.width-0.1875*SCREEN_WIDTH, 0, 0.1875*SCREEN_WIDTH, self.lblSex.frame.size.height);
    
    self.lblAgeValue.frame=self.lblSexValue.frame;
    self.lblHeightValue.frame=self.lblSexValue.frame;
    self.lblHC.frame=self.lblSexValue.frame;
    self.lblWC.frame=self.lblSexValue.frame;
    
    self.toumingView.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.pickerView.frame=CGRectMake(0, self.pickerView.frame.origin.y, SCREEN_WIDTH, self.pickerView.frame.size.height);
    self.pickerAge.frame=CGRectMake(0, self.pickerAge.frame.origin.y, SCREEN_WIDTH, self.pickerAge.frame.size.height);
    self.pickerSex.frame=CGRectMake(0, self.pickerSex.frame.origin.y, SCREEN_WIDTH, self.pickerSex.frame.size.height);
    self.pickerHC.frame=self.pickerSex.frame;
    self.pickerWC.frame=self.pickerSex.frame;
    
    self.lblPickerText.frame=CGRectMake(0, self.lblPickerText.frame.origin.y, SCREEN_WIDTH, self.lblPickerText.frame.size.height);
    
    self.btnPickerCancle.frame=CGRectMake(0, self.btnPickerCancle.frame.origin.y, SCREEN_WIDTH/2, self.btnPickerCancle.frame.size.height);
    self.btnPickerFinish.frame=CGRectMake(SCREEN_WIDTH/2, self.btnPickerFinish.frame.origin.y, SCREEN_WIDTH/2, self.btnPickerFinish.frame.size.height);
}


- (IBAction)clickSex:(id)sender
{
    selectedViewTag=((UIButton *)sender).tag;
    [self showPickerView];
}

- (IBAction)clickHeight:(id)sender
{
    selectedViewTag=((UIButton *)sender).tag;
    [self showPickerView];
}

- (IBAction)clickAge:(id)sender
{
    selectedViewTag=((UIButton *)sender).tag;
    [self showPickerView];
}

- (IBAction)clickWC:(id)sender {
    selectedViewTag=((UIButton *)sender).tag;
    [self showPickerView];
}

- (IBAction)clickHC:(id)sender {
    selectedViewTag=((UIButton *)sender).tag;
    [self showPickerView];
}

- (void)setLeftMenuEnable:(BOOL)aBool
{
    _canBack=aBool;
}

-(void)setEditYunfuInfo
{
    myBirthday=[AppDelegate shareUserInfo].userBirthday;
    myAge=[AppDelegate shareUserInfo].userAge;
    self.lblAgeValue.text=[NSString stringWithFormat:@"%@",myAge];
    NSString *textheight=[NSString stringWithFormat:@"%@cm",[AppDelegate shareUserInfo].userHeight];
    self.lblHeightValue.text=textheight;
    myHeight=[AppDelegate shareUserInfo].userHeight;
    mySex=[AppDelegate shareUserInfo].sex;
    myWC=[AppDelegate shareUserInfo].userWC;
    myHC=[AppDelegate shareUserInfo].userHC;
    mySex=NSLocalizedString(mySex, nil);
    self.lblSexValue.text=mySex;
    self.lblWC.text=[myWC stringByAppendingString:@"cm"];
    self.lblHC.text=[myHC stringByAppendingString:@"cm"];
}

-(void)viewDidAppear:(BOOL)animated
{
    if(self.heightPicker)
    {
        [self.heightPicker selectRow:160 inComponent:0 animated:NO];
    }
    if(self.pickerSex)
    {
        [self.pickerSex selectRow:0 inComponent:0 animated:NO];
    }
    if(self.pickerAge)
    {
        [self.pickerAge selectRow:19 inComponent:0 animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)initMyViewControl
{
    
    screenHeight=[[UIScreen mainScreen] bounds].size.height;

    //pickerView高244
    if(self.pickerView != nil)
    {
        [self.pickerView setFrame:CGRectMake(0, screenHeight, 320, 244)];
        

        self.pickerView.hidden=YES;
        self.pickerAge.hidden=YES;
        self.pickerAge.delegate=self;
        self.pickerAge.dataSource=self;
        
        self.pickerSex.hidden=YES;
        self.pickerSex.delegate=self;
        self.pickerSex.dataSource=self;
        
        self.heightPicker.hidden=YES;
        self.heightPicker.delegate=self;
        self.heightPicker.dataSource=self;
        
        self.pickerHC.hidden=YES;
        self.pickerHC.delegate=self;
        self.pickerHC.dataSource=self;
        
        self.pickerWC.hidden=YES;
        self.pickerWC.delegate=self;
        self.pickerWC.dataSource=self;
        self.datePickerView.hidden=YES;
        
        NSTimeInterval secondsPerDay=24*60*60;
        NSDate *minDate=[[NSDate alloc] initWithTimeIntervalSinceNow:-100*365*secondsPerDay];
        self.datePickerView.minimumDate=minDate;
        self.datePickerView.maximumDate=[NSDate date];
        [self.toumingView setFrame:CGRectMake(0, 0, 320, screenHeight)];
        self.toumingView.hidden=YES;
    }
}

//初始化身高和体重的picker的数据
- (void)initPickerData
{
    if(aryHeight == nil)
    {
        arySex=[[NSMutableArray alloc] init];
        [arySex addObject:NSLocalizedString(@"profile_male", nil)];
        [arySex addObject:NSLocalizedString(@"profile_female", nil)];
        
        aryAge=[[NSMutableArray alloc] init];
        for(int i=0;i<=120;i++)
        {
            [aryAge addObject:[NSString stringWithFormat:@"%d",i+1]];
        }
        
        aryHC=[[NSMutableArray alloc] init];
        aryWC=[[NSMutableArray alloc] init];
        for(int i=30;i<=150;i++)
        {
            [aryHC addObject:[NSString stringWithFormat:@"%d",i]];
            [aryWC addObject:[NSString stringWithFormat:@"%d",i]];
        }
        
        aryHeight=[[NSMutableArray alloc] init];
        for(int i=10;i<=220;i++)
        {
            [aryHeight addObject:[NSString stringWithFormat:@"%d",i]];
        }
        
        /*
        aryHeight2=[[NSMutableArray alloc] init];
        for(int k=0;k<=9;k++)
        {
            [aryHeight2 addObject:[NSString stringWithFormat:@".%d",k]];
        }
        */
        
        
        aryWeight=[[NSMutableArray alloc] init];
        for(int j=1;j<=150;j++)
        {
            [aryWeight addObject:[NSString stringWithFormat:@"%d",j]];
        }
        
        aryWeight2=[[NSMutableArray alloc] init];
        for(int y=0;y<=9;y++)
        {
            [aryWeight2 addObject:[NSString stringWithFormat:@".%d",y]];
        }
        
        
    }
}

//判断点击的view是哪个
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch=[touches anyObject];
    //UIView *view=[touch view];
    //selectedViewTag=view.tag;
    [self canclePickerSelect:nil];
}


-(void)showPickerView
{
    if(selectedViewTag != 12 &&
       selectedViewTag != 14 &&
       selectedViewTag != 13 &&
       selectedViewTag != 15 &&
       selectedViewTag != 16)
    {
        return ;
    }
    
    if(selectedViewTag == 12)
    {
        self.toumingView.hidden=NO;
        
        self.pickerAge.hidden=YES;
        self.pickerSex.hidden=NO;
        self.heightPicker.hidden=YES;
        self.pickerHC.hidden=YES;
        self.pickerWC.hidden=YES;
        self.datePickerView.hidden=YES;
        self.lblPickerText.text=NSLocalizedString(@"profile_sex", nil);
        
        [self.pickerAge selectRow:0 inComponent:0 animated:NO];
        if([mySex isEqualToString:@"女"])
        {
            [self.pickerSex selectRow:1 inComponent:0 animated:NO];
        }
        
        self.pickerView.hidden=NO;
    }
    
    else if (selectedViewTag == 13)
    {
        self.toumingView.hidden=NO;
        
        self.pickerAge.hidden=NO;
        self.pickerSex.hidden=YES;
        self.heightPicker.hidden=YES;
        self.pickerHC.hidden=YES;
        self.pickerWC.hidden=YES;
        self.datePickerView.hidden=YES;
        
        self.lblPickerText.text=_strAgeName;
        if(myAge && ![myAge isEqualToString:@""])
        {
            NSInteger index=[aryAge indexOfObject:myAge];
            if(index >= 0 && index<=aryAge.count)
            {
                [self.pickerAge selectRow:index inComponent:0 animated:NO];
            }
        }
        else
        {
            [self.pickerAge selectRow:19 inComponent:0 animated:NO];
        }
        self.pickerView.hidden=NO;
    }
    else if(selectedViewTag  == 14)
    {
        self.toumingView.hidden=NO;
        
        self.pickerSex.hidden=YES;
        self.pickerAge.hidden=YES;
        self.heightPicker.hidden=NO;
        self.pickerHC.hidden=YES;
        self.pickerWC.hidden=YES;
        self.datePickerView.hidden=YES;
        NSString *strShowHeight=_strHeightName;
        if(![myHeight isEqualToString:@""])
        {
            NSArray *aryTempHeight=[myHeight componentsSeparatedByString:@"."];
            if(aryHeight!=nil && aryHeight.count>=2)
            {
                NSInteger iRow1=[aryHeight indexOfObject:[aryTempHeight objectAtIndex:0]];
                //NSString *pointHeight=[@"." stringByAppendingString:[aryTempHeight objectAtIndex:1]];
                //NSInteger iRow2=[aryHeight2 indexOfObject:pointHeight];
                [self.heightPicker selectRow:iRow1 inComponent:0 animated:NO];
                //[self.heightPicker selectRow:iRow2 inComponent:2 animated:NO];
                
                strShowHeight=[NSString stringWithFormat:@"%@:%@cm",_strHeightName,myHeight];
            }
        }
        self.lblPickerText.text=strShowHeight;
        self.pickerView.hidden=NO;
    }

    else if(selectedViewTag  == 15)
    {
        self.toumingView.hidden=NO;
        
        self.pickerSex.hidden=YES;
        self.pickerAge.hidden=YES;
        self.heightPicker.hidden=YES;
        self.pickerHC.hidden=YES;
        self.pickerWC.hidden=NO;
        self.datePickerView.hidden=YES;
        self.lblPickerText.text=_strWCName;
        if(myWC && ![myWC isEqualToString:@""])
        {
            NSInteger index=[aryWC indexOfObject:myWC];
            if(index >= 0 && index<=aryWC.count)
            {
                [self.pickerWC selectRow:index inComponent:0 animated:NO];
            }
        }
        else
        {
            [self.pickerWC selectRow:49 inComponent:0 animated:NO];
        }
        self.pickerView.hidden=NO;
    }
    
    else if(selectedViewTag  == 16)
    {
        self.toumingView.hidden=NO;
        
        self.pickerSex.hidden=YES;
        self.pickerAge.hidden=YES;
        self.heightPicker.hidden=YES;
        self.pickerHC.hidden=NO;
        self.pickerWC.hidden=YES;
        self.datePickerView.hidden=YES;
        self.lblPickerText.text=_strHCName;
        if(myHC && ![myHC isEqualToString:@""])
        {
            NSInteger index=[aryHC indexOfObject:myHC];
            if(index >= 0 && index<=aryHC.count)
            {
                [self.pickerHC selectRow:index inComponent:0 animated:NO];
            }
        }
        else
        {
            [self.pickerHC selectRow:49 inComponent:0 animated:NO];
        }
        self.pickerView.hidden=NO;
    }
    
    [self showPickerView:YES];
}

- (void)showPhotoSheet
{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择", nil];
    }
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    
    sheet.tag = 255;
    
    [sheet showInView:self.view];
    
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

//保存图片进去沙盒
- (BOOL) saveImage:(UIImage *)currentImage withName:(NSString *)imageName
{
    
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 0.5);
    // 获取沙盒目录
    NSString *imagePath=[NSString stringWithFormat:@"Image/UserImage/%@",imageName];
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imagePath];
    
    // 将图片写入文件
    
    BOOL result=[imageData writeToFile:fullPath atomically:NO];
    if(result)
    {
        NSLog(@"保存头像成功");
        photoPath=fullPath;
        return YES;
    }
    else
    {
        NSLog(@"保存图片失败");
        return YES;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[picker dismissViewControllerAnimated:YES completion:^{}];
    tmpImage = [info objectForKey:UIImagePickerControllerEditedImage];
    CGSize sizeImage=tmpImage.size;
    sizeImage.height=240;
    sizeImage.width=240;
    tmpImage=[self imageWithImage:tmpImage scaledToSize:sizeImage];
    myUserIcon=tmpImage; //赋值用户头像
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissViewControllerAnimated:YES completion:^{}];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 255)
    {
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else
        {
            if (buttonIndex == 0)
            {
                return;
            }
            else
            {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        // 跳转到相机或相册页面
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
    }
}

//uiview翻转动画
- (void)doUIViewAnimation:(UIView *)view
{
    [UIView beginAnimations:@"animationID" context:nil];
	[UIView setAnimationDuration:1.0f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationRepeatAutoreverses:NO];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:view cache:YES];
    [view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
	[UIView commitAnimations];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView.tag == 23)
    {
            return 4;
    }
    else if(pickerView.tag == 22)
    {
        return 1;
    }
    else
    {
        return 1;
    }
}
//picker行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35;
}

//picker每一列的数据个数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag == 23)
    {
        if(component == 1)
        {
            return [aryWeight count];
        }
        else if(component == 2)
        {
            return [aryWeight2 count];
        }
        return 1;
        
    }
    else if(pickerView.tag == 22)
    {
        /*
        if(component == 1)
        {
            return [aryHeight count];
        }
        
        else if(component == 2)
        {
            return [aryHeight2 count];
        }
        return 1;
         */
        return [aryHeight count];
    }
    else if(pickerView.tag == 32)
    {
        return aryAge.count;
    }
    else if (pickerView.tag == 42)
    {
        return arySex.count;
    }
    else if (pickerView.tag == 52)
    {
        return aryWC.count;
    }
    else if (pickerView.tag == 62)
    {
        return aryHC.count;
    }
    return 0;
}

//选择器的标题，也就是显示内容
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == 23)
    {
        if(component == 1)
        {
            return [aryWeight objectAtIndex:row];
        }
        else if(component == 2)
        {
            return [aryWeight2 objectAtIndex:row];
        }
        else if(component == 3)
        {
            return @"";
        }
        else
        {
            return @"";
        }
    }
    else if (pickerView.tag == 32)
    {
        return [aryAge objectAtIndex:row];
    }
    else if(pickerView.tag == 42)
    {
        return [arySex objectAtIndex:row];
    }
    else if(pickerView.tag == 52)
    {
        return [aryWC objectAtIndex:row];
    }
    else if(pickerView.tag == 62)
    {
        return [aryHC objectAtIndex:row];
    }
    else if(pickerView.tag == 22)
    {
        return [aryHeight objectAtIndex:row];
        /*
        if(component == 1)
        {
            return [aryHeight objectAtIndex:row];
        }
        else if(component == 2)
        {
            return [aryHeight2 objectAtIndex:row];
        }
        else if(component == 3)
        {
            return @"";
        }
        else
        {
            return @"";
        }
         */
    }
    return @"";
}

//选择器选择完之后触发函数
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

    if(pickerView.tag == 22)
    {
        NSInteger row=[self.heightPicker selectedRowInComponent:0];
        //NSInteger row2=[self.heightPicker selectedRowInComponent:2];
        NSString *strHeight=[aryHeight objectAtIndex:row];
        //NSString *strHeight2=[aryHeight2 objectAtIndex:row2];
        NSString *height=[NSString stringWithFormat:@"%@:%@cm",_strHeightName,strHeight];
        self.lblPickerText.text=height;
    }
    else if(pickerView.tag == 32)
    {
        NSInteger row=[self.pickerAge selectedRowInComponent:0];
        NSString *strValue=[aryAge objectAtIndex:row];
        NSString *text=[NSString stringWithFormat:@"%@:%@",_strAgeName,strValue];
        self.lblPickerText.text=text;
    }
    else if(pickerView.tag == 42)
    {
        NSInteger row=[self.pickerSex selectedRowInComponent:0];
        NSString *strValue=[arySex objectAtIndex:row];
        NSString *text=[NSString stringWithFormat:@"%@:%@",_strSexName,strValue];
        self.lblPickerText.text=text;
    }
    else if(pickerView.tag == 52)
    {
        NSInteger row=[self.pickerWC selectedRowInComponent:0];
        NSString *strValue=[aryWC objectAtIndex:row];
        NSString *text=[NSString stringWithFormat:@"%@:%@",_strWCName,strValue];
        self.lblPickerText.text=text;
    }
    else if(pickerView.tag == 62)
    {
        NSInteger row=[self.pickerHC selectedRowInComponent:0];
        NSString *strValue=[aryHC objectAtIndex:row];
        NSString *text=[NSString stringWithFormat:@"%@:%@",_strHCName,strValue];
        self.lblPickerText.text=text;
    }
}

//返回按钮
- (IBAction)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//确认注册
- (IBAction)goNext:(id)sender
{
    BOOL checkRet=[self checkRegisterMember];
    if(!checkRet)
    {
        NSString *userCtime=[AppDelegate shareUserInfo].account_ctime;
        NSString *regCTime=[PublicModule getMyTimeInterval:[NSDate date]];
        NSString *imgName=@"";
        if(self.iEditStyle == 1)
        {
            imgName=[userCtime stringByAppendingString:@".png"];
        }
        else
        {
            imgName=[regCTime stringByAppendingString:@".png"];
        }
        
        
        if(tmpImage!=nil)
        {
            [self saveImage:myUserIcon withName:imgName];
        }
        
        BOOL result=NO;
        if(self.iEditStyle == 1)
        {
            result=[self editMemberWithCTime:userCtime];
        }
        else
        {
            result=[self registerMemberWithCTime:regCTime];
        }
        
        if(result)
        {
            NSArray *aryData=[[NSArray alloc] initWithObjects:mySex,myHeight,myAge,myWC,myHC, nil];
            [_delegate uploadUserInfoToService:aryData];
            if(self.iEditStyle == 1)
            {
                [self setGlobalMember:userCtime];
            }
            else
            {
                [self setGlobalMember:regCTime];
            }
            
            [self goback:nil];
        }
    }
    
}

- (IBAction)gotoLogin:(id)sender
{
    [self poptoLogin];
}


-(void)poptoLogin
{
    GLoginController *vc=[[GLoginController alloc] init];
    vc.iShowResiger = 1;
    [self.navigationController pushViewController:vc animated:YES];
    
}

//修改图片大小
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize

{

    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

//设置全局用户
- (void) setGlobalMember:(NSString *)ctime
{
    [[NSUserDefaults standardUserDefaults] setObject:ctime forKey:@"c_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_delegate setUserInfo];
}


-(BOOL)editMemberWithCTime:(NSString *)ctime
{

    NSString *uname=@"";
    NSString *upwd=@"";
    NSString *uid=@"";
    NSString *usession=@"";
    NSString *localicon=@"";
    NSString *remoteicon=@"";
    if([mySex isEqualToString:@"男"] || [mySex isEqualToString:@"Male"])
    {
        mySex=@"男";
    }
    else
    {
        mySex=@"女";
    }
    NSString *sex=mySex;
    NSString *nickname=@"";
    NSString *country=@"";
    NSString *province=@"";
    NSString *city=@"";
    NSString *address=@"";
    NSString *latitude=@"";
    NSString *longitude=@"";
    NSString *utype=@"0";
    NSString *userCtime=ctime;
    NSString *doingNum=@"";
    NSString *msign=@"";
    NSString *myOwnness=@"";
    NSString *age=myAge;
    NSString *height=myHeight;

    
    NSArray *aryMemberInfo=[[NSArray alloc] initWithObjects:uname,
                            upwd,
                            uid,
                            usession,
                            localicon,
                            remoteicon,
                            sex,
                            nickname,
                            country,
                            province,
                            city,
                            address,
                            latitude,
                            longitude,
                            utype,
                            userCtime,
                            doingNum,
                            msign,
                            myOwnness,
                            age,
                            height,
                            myWC,
                            myHC, nil];
    
    BOOL result=[self.dbModule updateLocalAccount:aryMemberInfo];
    return result;
}

//注册用户
- (BOOL)registerMemberWithCTime:(NSString *)ctime
{
    NSString *uname=@"";
    NSString *upwd=@"";
    NSString *uid=@"";
    NSString *usession=@"";
    NSString *localicon=@"";
    NSString *remoteicon=@"";
    if([mySex isEqualToString:@"男"] || [mySex isEqualToString:@"Male"])
    {
        mySex=@"男";
    }
    else
    {
        mySex=@"女";
    }
    NSString *sex=mySex;
    NSString *nickname=@"";
    NSString *country=@"";
    NSString *province=@"";
    NSString *city=@"";
    NSString *address=@"";
    NSString *latitude=@"";
    NSString *longitude=@"";
    NSString *utype=@"0";
    NSString *userCtime=ctime;
    NSString *doingNum=@"";
    NSString *msign=@"";
    NSString *myOwnness=@"";
    NSString *age=myAge;
    NSString *height=myHeight;
    
    
    NSArray *aryMemberInfo=[[NSArray alloc] initWithObjects:uname,
                            upwd,
                            uid,
                            usession,
                            localicon,
                            remoteicon,
                            sex,
                            nickname,
                            country,
                            province,
                            city,
                            address,
                            latitude,
                            longitude,
                            utype,
                            userCtime,
                            doingNum,
                            msign,
                            myOwnness,
                            age,
                            height,
                            myWC,
                            myHC, nil];
    BOOL result=[self.dbModule updateLocalAccount:aryMemberInfo];
    return result;
}

-(BOOL)checkRegisterMember
{
    
    //判断用户资料是否填写完毕
    if([myHeight isEqualToString:@""]||
       [mySex isEqualToString:@""]||
       [myAge isEqualToString:@""])
    {
        NSString *msg=@"";
        if([myHeight isEqualToString:@""])
        {
            msg=[msg stringByAppendingString:_strHeightName];
        }
        if([myAge isEqualToString:@""])
        {
            if([msg isEqualToString:@""])
            {
                 msg=[msg stringByAppendingString:_strAgeName];
            }
            else
            {
                 msg=[msg stringByAppendingString:@","];
                msg=[msg stringByAppendingString:_strAgeName];
            }
        }
        if([mySex isEqualToString:@""])
        {
            if([msg isEqualToString:@""])
            {
                msg=[msg stringByAppendingString:_strSexName];
            }
            else
            {
                msg=[msg stringByAppendingString:@","];
                msg=[msg stringByAppendingString:_strSexName];
            }
        }
        
        msg=[NSLocalizedString(@"请填写", nil) stringByAppendingString:msg];
        
        [Dialog simpleToast:msg];
        return YES;  //代表资料不完整
    }
    else
    {
        return NO;
    }
}


- (IBAction)finishPickerSelected:(id)sender
{
    [self showPickerView:NO];
    [self setPickerValue];
}

//点击picker完成后显示选择的值
-(void)setPickerValue
{
    if(selectedViewTag == 12)
    {
        NSInteger row=[self.pickerSex selectedRowInComponent:0];
        NSString *strValue=[arySex objectAtIndex:row];
        NSString *text=[NSString stringWithFormat:@"%@",strValue];
        self.lblSexValue.text=text;
        mySex=text;
    }
    else if(selectedViewTag == 13)
    {
        NSInteger row=[self.pickerAge selectedRowInComponent:0];
        NSString *strValue=[aryAge objectAtIndex:row];
        NSString *text=[NSString stringWithFormat:@"%@",strValue];
        self.lblAgeValue.text=text;
        myAge=text;
    }
    else if(selectedViewTag == 14)
    {
        NSInteger row1=[self.heightPicker selectedRowInComponent:0];
        //NSInteger row2=[self.heightPicker selectedRowInComponent:2];
        NSString *strHeight=[aryHeight objectAtIndex:row1];
        //NSString *strHeight2=[aryHeight2 objectAtIndex:row2];
        NSString *height=strHeight;
        NSString *textheight=[NSString stringWithFormat:@"%@cm",height];
        self.lblHeightValue.text=textheight;
        myHeight=height;
    }
    else if(selectedViewTag == 15)
    {
        NSInteger row1=[self.pickerWC selectedRowInComponent:0];
        NSString *strValue=[aryWC objectAtIndex:row1];
        self.lblWC.text=[strValue stringByAppendingString:@"cm"];
        myWC=strValue;
    }
    else if(selectedViewTag == 16)
    {
        NSInteger row1=[self.pickerHC selectedRowInComponent:0];
        NSString *strValue=[aryHC objectAtIndex:row1];
        self.lblHC.text=[strValue stringByAppendingString:@"cm"];
        myHC=strValue;
    }
}

//点击pickerview的取消按钮
- (IBAction)canclePickerSelect:(id)sender
{
    [self showPickerView:NO];
}

-(void)showPickerView:(BOOL)isShow
{
    if (isShow)
    {

        [UIView animateWithDuration:0.5f animations:^{
            self.toumingView.hidden=NO;
            [self.pickerView setFrame:CGRectMake(0, screenHeight-244, SCREEN_WIDTH, 244)];
            
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^{
            self.toumingView.hidden=YES;
            [self.pickerView setFrame:CGRectMake(0, screenHeight, SCREEN_WIDTH, 244)];
        }];
    }
}

//日期picker值变化时的触发函数
- (IBAction)dateValueChange:(id)sender {
    
    NSArray *time=[PublicModule getTimeWithDate:self.datePickerView.date];
    self.lblPickerText.text=[NSString stringWithFormat:@"%@年%@月%@日",time[0],time[1],time[2]];
}

@end

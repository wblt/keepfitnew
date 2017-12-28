#import "GRegisterController.h"
#import "WCAlertView/WCAlertView.h"


@interface GRegisterController ()

@end

@implementation GRegisterController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (BOOL)fd_prefersNavigationBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _delegate= (AppDelegate *)[UIApplication sharedApplication].delegate;
    _delegate.isLogin=YES;


    _registerCTime=[PublicModule getMyTimeInterval:[NSDate date]];
    self.viewCover.hidden=YES;
   
    _qqClick=YES;
    _sinaClick=YES;
    _canGotoMain=YES;
    
    canSendAuthcode=YES;
    iAuthcodeTime=180;
    _db=[[DbModel alloc] init];
    _network=[[NetworkModule alloc] init];

    self.textPhone.delegate=self;
    self.textPwd.delegate=self;
    self.textConfirmPwd.delegate=self;
    
    self.viewTextPhoneLine.frame=CGRectMake(self.viewTextPhoneLine.frame.origin.x, self.viewTextPhoneLine.frame.origin.y, self.viewTextPhoneLine.frame.size.width, 1);
    self.viewTextPhoneLine.backgroundColor=[UIColor lightGrayColor];
    
    self.viewTextPwdLine.frame=CGRectMake(self.viewTextPwdLine.frame.origin.x, self.viewTextPwdLine.frame.origin.y, self.viewTextPwdLine.frame.size.width, 1);
    self.viewTextPwdLine.backgroundColor=[UIColor lightGrayColor];
    
    UIColor *color=[UIColor lightGrayColor];
    self.textPhone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"account_emailinfo", nil) attributes:@{NSForegroundColorAttributeName: color}];
    self.textPwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"account_pwdinfo", nil) attributes:@{NSForegroundColorAttributeName: color}];
    self.textConfirmPwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"account_confirmpwdinfo", nil) attributes:@{NSForegroundColorAttributeName: color}];
    
    self.lblTopTitle.text=NSLocalizedString(@"account_register", nil);
    [self.btnLogin setTitle:self.lblTopTitle.text forState:UIControlStateNormal];
    self.lblMail.text=[NSLocalizedString(@"account_inputemail", nil) stringByAppendingString:@":"];
    self.lblPwd.text=[NSLocalizedString(@"account_inputpwd", nil) stringByAppendingString:@":"];
    self.lblConfirmPwd.text=[NSLocalizedString(@"account_enterpwd", nil) stringByAppendingString:@":"];
    
    self.textPhone.tintColor=UIColorFromRGB(0x0094ff);
    self.textPwd.tintColor=UIColorFromRGB(0x0094ff);
    self.textConfirmPwd.tintColor=UIColorFromRGB(0x0094ff);
    
    [self initView];
    

}

-(void)initView
{
    self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.loginView.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT);

    self.viewCover.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    

    self.btnBack.frame=CGRectMake(0, 20, 70, 44);
    self.lblTopTitle.frame=CGRectMake(0, 20, SCREEN_WIDTH, 44);
    
    
    
    self.textPhone.frame=CGRectMake(self.textPhone.frame.origin.x, self.textPhone.frame.origin.y, SCREEN_WIDTH-self.textPhone.frame.origin.x-15, self.textPhone.frame.size.height);
    
    self.viewTextPhoneLine.frame=CGRectMake(self.textPhone.frame.origin.x, self.textPhone.frame.origin.y+self.textPhone.frame.size.height+3, self.textPhone.frame.size.width, 1);
    
    self.textPwd.frame=CGRectMake(self.textPwd.frame.origin.x, self.textPwd.frame.origin.y, SCREEN_WIDTH-self.textPwd.frame.origin.x-15, self.textPwd.frame.size.height);
    
    self.viewTextPwdLine.frame=CGRectMake(self.textPwd.frame.origin.x, self.textPwd.frame.origin.y+self.textPwd.frame.size.height+3, self.textPwd.frame.size.width, 1);
    
    
    self.textConfirmPwd.frame=CGRectMake(self.textConfirmPwd.frame.origin.x, self.textConfirmPwd.frame.origin.y, SCREEN_WIDTH-self.textConfirmPwd.frame.origin.x-15, self.textConfirmPwd.frame.size.height);
    
    self.viewTextConfirmLine.frame=CGRectMake(self.textConfirmPwd.frame.origin.x, self.textConfirmPwd.frame.origin.y+self.textConfirmPwd.frame.size.height+3, self.textConfirmPwd.frame.size.width, 1);
    
    
    self.btnLogin.frame=CGRectMake(15, self.textConfirmPwd.frame.origin.y+self.textConfirmPwd.frame.size.height+40,SCREEN_WIDTH-30, 0.103125*SCREEN_WIDTH);
    self.btnLogin.layer.masksToBounds=YES;
    self.btnLogin.layer.cornerRadius=3.0f;
    
    self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone5FontSizeTitle];
    if(is_iPhone6)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6FontSizeTitle];
    }
    else if (is_iPhone6P)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6PFontSizeTitle];
    }
    
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.textPhone)
    {
        [self.viewTextPwdLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.viewTextConfirmLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.viewTextPhoneLine setBackgroundColor:UIColorFromRGB(0x00af00)];
    }
    else if (textField == self.textPwd)
    {
        [self.viewTextPwdLine setBackgroundColor:UIColorFromRGB(0x00af00)];
        [self.viewTextPhoneLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.viewTextConfirmLine setBackgroundColor:[UIColor lightGrayColor]];
    }
    else if (textField == self.textConfirmPwd)
    {
        [self.viewTextConfirmLine setBackgroundColor:UIColorFromRGB(0x00af00)];
        [self.viewTextPhoneLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.viewTextPwdLine setBackgroundColor:[UIColor lightGrayColor]];
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.textPhone)
    {
        return [self.textPwd becomeFirstResponder];
    }
    else if(textField == self.textPwd)
    {
        return [self.textConfirmPwd resignFirstResponder];
    }
    
    return YES;
}


-(void)setIsNav:(BOOL)isNav
{
    _isNav=isNav;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
     ((AppDelegate *)[UIApplication sharedApplication].delegate).isLogin=NO;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.textPhone becomeFirstResponder];
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textPhone resignFirstResponder];
    [self.textPwd resignFirstResponder];
    [self.textConfirmPwd resignFirstResponder];
    [self.viewTextPhoneLine setBackgroundColor:[UIColor lightGrayColor]];
    [self.viewTextPwdLine setBackgroundColor:[UIColor lightGrayColor]];
}






- (IBAction)gotoLogin:(id)sender
{
    if([self checkCanRegister])
    {
        /*
        NSString *account=[aryInfo objectAtIndex:0];
        account=[PublicModule base64EncodeWithString:account];
        NSString *password=[aryInfo objectAtIndex:1];
        password=[PublicModule MD5:password];
        
        NSString *height=[aryInfo objectAtIndex:2];
        NSString *age=[aryInfo objectAtIndex:3];
        NSString *sex=[aryInfo objectAtIndex:4];
        */
        
        _registerCTime=[PublicModule getMyTimeInterval:[NSDate date]];
        NSArray *ary=[[NSArray alloc] initWithObjects:self.textPhone.text,self.textPwd.text,[AppDelegate shareUserInfo].userHeight,[AppDelegate shareUserInfo].userAge,[AppDelegate shareUserInfo].sex,_registerCTime,[AppDelegate shareUserInfo].userWC,[AppDelegate shareUserInfo].userHC, nil];
        
        
        NSString *strJson=[_network jsonGRegister:ary];
        if(strJson)
        {
            [SVProgressHUD show];
            self.view.userInteractionEnabled=NO;
            [self doRequestWithURL:[NSURL URLWithString:GURLLogin] andJson:strJson];
        }
        else
        {
            [Dialog simpleToast:@"json解析错误"];
        }
    }
}

-(BOOL)checkCanRegister
{
    if(![PublicModule isValidateEmail:self.textPhone.text])
    {
        [Dialog simpleToast:NSLocalizedString(@"findpwd_errmail", nil)];
        return NO;
    }
    if(![PublicModule checkPassword:self.textPwd.text])
    {
        [Dialog simpleToast:NSLocalizedString(@"register_errpwd", nil)];
        return NO;
    }
    if(![PublicModule checkPassword:self.textConfirmPwd.text])
    {
        [Dialog simpleToast:NSLocalizedString(@"register_errconfirmpwd", nil)];
        return NO;
    }
    if(![self.textPwd.text isEqualToString:self.textConfirmPwd.text])
    {
        [Dialog simpleToast:NSLocalizedString(@"register_errtwopwd", nil)];
        return NO;
    }
    
    return YES;
}

//第三方登陆
-(void)doLogin:(NSArray *)aryInfo
{
    NSString *strJson=[_network jsonDLogin:aryInfo];
    if(strJson)
    {
        NSURL *url=[NSURL URLWithString:URLDAccount];
        
        [self doRequestWithURL:url andJson:strJson];
        [SVProgressHUD show];
    }
}


-(void)getCanRegister
{
    if([PublicModule checkNetworkStatus])
    {
        NSString *strJson=[_network jsonDRegisterLimit];
        if(strJson)
        {
            [self doRequestWithURL:[NSURL URLWithString:URLDAccount] andJson:strJson];
        }
        else
        {
            _canRegister=NO;
        }
    }
    {
        _canRegister=NO;
    }
}


-(void)requestFinished:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    self.view.userInteractionEnabled=YES;
    NSString *responseString=[request responseString];
    NSDictionary *dic=[responseString objectFromJSONString];
    
    if(dic)
    {
        NSString *result=[dic valueForKey:@"result"];
        NSString *operation=[dic valueForKey:@"operation"];
        NSString *resultMsg=[dic valueForKey:@"result_message"];


        if ([operation isEqualToString:GRegister])
        {
            [self processRequestRegister:dic withResult:result andResultMsg:resultMsg];
        }
    }
    else
    {
        [SVProgressHUD dismiss];
        NSString *text = NSLocalizedString(@"auth_network_no", nil);
        [self showWithText:text andHideAfter:3.0f];
        self.view.userInteractionEnabled=YES;
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    self.view.userInteractionEnabled=YES;
    NSString *text = NSLocalizedString(@"auth_network_no", nil);
    [self showWithText:text andHideAfter:3.0f];
}

-(void)requestCanRegister
{
    NSString *strJson=[_network jsonDRegisterLimit];
    if(strJson)
    {
        NSURL *url=[NSURL URLWithString:URLDAccount];
        [self doRequestWithURL:url andJson:strJson];
    }
}

//登陆上传用户信息
-(void)uploadLoginMemberInfoWithUID:(NSString *)uid
{
    NSArray *ary=[[NSArray alloc] initWithObjects:_uname,_upwd,uid, nil];
  
    NSString *strJson=[_network jsonUploadLoginMemberWithUID:ary];
    if(strJson)
    {
        NSURL *url=[NSURL URLWithString:ServiceURL];
        [self doRequestWithURL:url andJson:strJson];
    }
    else if(iOperationType == 1)
    {
        
        [self downloadMemberInfoFromService:_uid];
    }
}


//注册上传用户信息
-(void)uploadMemberInfoWithUID:(NSString *)uid
{
    NSArray *ary=[[NSArray alloc] initWithObjects:_uname,_upwd,uid, nil];
    //2014-07-08
    NSString *strJson=[_network jsonUploadMemberWithUID:ary withType:@"1"];
    if(strJson)
    {
        NSURL *url=[NSURL URLWithString:ServiceURL];
        [self doRequestWithURL:url andJson:strJson];
    }
    else
    {
        NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
        
        NSString *uname=[ud objectForKey:@"u_name"];
        if(uname)
        {
            NSString *ctime=[ud objectForKey:uname];
            if(ctime)
            {
                [ud setObject:ctime forKey:@"userCTime"];
            }
            else
            {
                [ud setObject:@"-1" forKey:@"userCTime"];
            }
        }
        else
        {
            [ud setObject:@"-1" forKey:@"userCTime"];
        }
        
        [ud setObject:@"-1" forKey:@"userCTime"];
    }
}

//下载用户数据
-(void)downloadMemberInfoFromService:(NSString *)u_id
{
    if(u_id)
    {
        NSString *strJson=[_network jsonDownloadMemberWithUID:u_id];
        if(strJson)
        {
            NSURL *url=[NSURL URLWithString:ServiceURL];
            [self doRequestWithURL:url andJson:strJson];
        }
       
    }
}



-(void)processRequestRegister:(NSDictionary *)dic withResult:(NSString *)result andResultMsg:(NSString *)retmsg
{
    [SVProgressHUD dismiss];
    if([result isEqualToString:RespondSuccess])
    {
        NSDictionary *dicData=[dic valueForKey:@"data"];
        NSString *uid=[dicData valueForKey:@"u_id"];
        
        BOOL ret = [self registerMemberWithUID:uid];
        if(ret)
        {
            [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"u_id"];
            [[NSUserDefaults standardUserDefaults] setObject:_registerCTime forKey:@"c_time"];
            [AppDelegate shareUserInfo].uid=uid;
            [[NSUserDefaults standardUserDefaults] synchronize];
            [_delegate setUserInfo];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            [Dialog simpleToast:@"保存用户信息失败"];
        }
    }
    else
    {
        [Dialog simpleToast:retmsg];
    }
}


//注册用户
- (BOOL)registerMemberWithUID:(NSString *)struid
{
    NSString *uname=self.textPhone.text;
    NSString *upwd=self.textConfirmPwd.text;
    NSString *uid=struid;
    NSString *usession=@"";
    NSString *localicon=@"";
    NSString *remoteicon=@"";
    NSString *mySex=@"男";
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
    NSString *userCtime=_registerCTime;
    NSString *doingNum=@"";
    NSString *msign=@"";
    NSString *myOwnness=@"";
    NSString *age=[AppDelegate shareUserInfo].userAge;
    NSString *height=[AppDelegate shareUserInfo].userHeight;
    NSString *myHC=[AppDelegate shareUserInfo].userHC;
    NSString *myWC=[AppDelegate shareUserInfo].userWC;
    
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
    BOOL result=[_db insertAccount:aryMemberInfo];
    return result;
}


-(BOOL)checkPhone:(NSString *)strPhone
{
    if([strPhone isEqualToString:@""])
    {
        [Dialog simpleToast:@"手机号不能为空哦"];
        return NO;
    }
    else
    {
        if(![PublicModule checkTel:strPhone])
        {
            [Dialog simpleToast:@"手机号码格式不对哦"];
            return NO;
        }
        else
        {
            return YES;
        }
    }
}

//发送验证码
-(void)sendAuthCodeFromService:(NSString *)strPhone
{
    NSString *strJson=[_network jsonSendAuthCodeWithPhone:strPhone];
    
    if(strJson)
    {
        NSURL *url=[NSURL URLWithString:ServiceAccountURL];
        
        [self doRequestWithURL:url andJson:strJson];
        
        if(timerAuthcode)
        {
            [timerAuthcode invalidate];
        }
        timerAuthcode=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleMaxShowTimer:) userInfo:nil repeats:YES];
        
        canSendAuthcode=NO;
    }
    
}

//第三方登陆
-(void)thirdLogin:(NSArray *)aryInfo
{
    NSString *strJson=[_network jsonLoginFromService:aryInfo];
    if(strJson)
    {
        NSURL *url=[NSURL URLWithString:ServiceAccountURL];
        
        [self doRequestWithURL:url andJson:strJson];
    }
}

//手机登陆
-(void)loginFromService:(NSString *)type
{
    NSArray *ary=[[NSArray alloc] initWithObjects:self.textPhone.text,self.textPwd.text,type, nil];
    NSString *strJson=[_network jsonLoginFromService:ary];
    if(strJson)
    {
        NSURL *url=[NSURL URLWithString:ServiceAccountURL];
        
        _uname=self.textPhone.text;
        _upwd=self.textPwd.text;
        [self doRequestWithURL:url andJson:strJson];
    }
    
}



- (IBAction)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end

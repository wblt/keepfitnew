#import "GLoginController.h"
#import "WCAlertView/WCAlertView.h"
#import "GForgetPwdController.h"
#import "GRegisterController.h"


@interface GLoginController ()

@end

@implementation GLoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)fd_prefersNavigationBarHidden { return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _delegate= (AppDelegate *)[UIApplication sharedApplication].delegate;
    _delegate.isLogin=YES;

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
    
    self.viewTextPhoneLine.frame=CGRectMake(self.viewTextPhoneLine.frame.origin.x, self.viewTextPhoneLine.frame.origin.y, self.viewTextPhoneLine.frame.size.width, 1);
    self.viewTextPhoneLine.backgroundColor=[UIColor lightGrayColor];
    
    self.viewTextPwdLine.frame=CGRectMake(self.viewTextPwdLine.frame.origin.x, self.viewTextPwdLine.frame.origin.y, self.viewTextPwdLine.frame.size.width, 1);
    self.viewTextPwdLine.backgroundColor=[UIColor lightGrayColor];
    
    UIColor *color=[UIColor lightGrayColor];
    self.textPhone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"account_emailinfo", nil) attributes:@{NSForegroundColorAttributeName: color}];
    self.textPwd.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"account_pwdinfo", nil) attributes:@{NSForegroundColorAttributeName: color}];
    
    self.lblMail.text=[NSLocalizedString(@"account_email", nil) stringByAppendingString:@":"];
    self.lblPwd.text=[NSLocalizedString(@"account_pwd", nil) stringByAppendingString:@":"];
    self.lblTopTitle.text=NSLocalizedString(@"account_login", nil);
    [self.btnLogin setTitle:self.lblTopTitle.text forState:UIControlStateNormal];
    [self.btnFindPwd setTitle:NSLocalizedString(@"findpwd_title", nil) forState:UIControlStateNormal];
    [self.btnRegister setTitle:NSLocalizedString(@"account_register", nil) forState:UIControlStateNormal];

    self.textPhone.tintColor=UIColorFromRGB(0x0094ff);
    self.textPwd.tintColor=UIColorFromRGB(0x0094ff);
    
    [self initView];
    
    NSString *cacheAccount=[[NSUserDefaults standardUserDefaults] valueForKey:@"cache_account"];
    if(cacheAccount)
    {
        self.textPhone.text=cacheAccount;
    }
    
    if(_canGoBack)
    {
        self.btnBack.hidden=YES;
        self.btnBackIcon.hidden=YES;
    }

    
    self.btnFindPwd.hidden=NO;
    self.btnRegister.hidden=NO;
    
    if(self.iShowResiger == 1)
    {
        self.btnFindPwd.hidden=YES;
        self.btnRegister.hidden=YES;
    }
    
    [self forbiddenGesturePop];
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
    self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.loginView.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT);

    self.viewCover.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    

    self.btnBack.frame=CGRectMake(0, 20, 70, 44);
    self.lblTopTitle.frame=CGRectMake(0, 20, SCREEN_WIDTH, 44);
    
    
    
    self.textPhone.frame=CGRectMake(self.textPhone.frame.origin.x, self.textPhone.frame.origin.y, SCREEN_WIDTH-self.textPhone.frame.origin.x-15, self.textPhone.frame.size.height);
    
    self.viewTextPhoneLine.frame=CGRectMake(self.textPhone.frame.origin.x, self.textPhone.frame.origin.y+self.textPhone.frame.size.height+3, self.textPhone.frame.size.width, 1);
    
    self.textPwd.frame=CGRectMake(self.textPwd.frame.origin.x, self.textPwd.frame.origin.y, SCREEN_WIDTH-self.textPwd.frame.origin.x-15, self.textPwd.frame.size.height);
    
    self.viewTextPwdLine.frame=CGRectMake(self.textPwd.frame.origin.x, self.textPwd.frame.origin.y+self.textPwd.frame.size.height+3, self.textPwd.frame.size.width, 1);
    
    self.btnLogin.frame=CGRectMake(15, self.textPwd.frame.origin.y+self.textPwd.frame.size.height+40,SCREEN_WIDTH-30, 0.103125*SCREEN_WIDTH);
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
    
    self.btnFindPwd.frame=CGRectMake(self.btnLogin.frame.origin.x, self.btnLogin.frame.origin.y+self.btnLogin.frame.size.height+15, self.btnFindPwd.frame.size.width, self.btnFindPwd.frame.size.height);
    
    self.btnRegister.frame=CGRectMake(SCREEN_WIDTH-self.btnRegister.frame.size.width-self.btnLogin.frame.origin.x, self.btnLogin.frame.origin.y+self.btnLogin.frame.size.height+15, self.btnRegister.frame.size.width, self.btnRegister.frame.size.height);
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.textPhone)
    {
        [self.viewTextPwdLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.viewTextPhoneLine setBackgroundColor:UIColorFromRGB(0x00af00)];
    }
    else if (textField == self.textPwd)
    {
        [self.viewTextPwdLine setBackgroundColor:UIColorFromRGB(0x00af00)];
        [self.viewTextPhoneLine setBackgroundColor:[UIColor lightGrayColor]];
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
        return [self.textPwd resignFirstResponder];
    }
    return YES;
}


-(void)setCanGoback:(BOOL)aBool
{
    _canGoBack=aBool;
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
    [self.viewTextPhoneLine setBackgroundColor:[UIColor lightGrayColor]];
    [self.viewTextPwdLine setBackgroundColor:[UIColor lightGrayColor]];
}


- (IBAction)gotoLogin:(id)sender
{
    if(![PublicModule isValidateEmail:self.textPhone.text])
    {
        [Dialog simpleToast:NSLocalizedString(@"account_erremail", nil)];
        return;
    }
    if(![PublicModule checkPassword:self.textPwd.text])
    {
        [Dialog simpleToast:NSLocalizedString(@"account_errpwd", nil)];
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:self.textPhone.text forKey:@"cache_account"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSArray *ary=[[NSArray alloc] initWithObjects:self.textPhone.text,self.textPwd.text, nil];
    NSString *strJson=[_network jsonGLogin:ary];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLLogin] andJson:strJson];
    }
    else
    {
        [Dialog simpleToast:@"json解析错误"];
    }
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
    
    NSString *responseString=[request responseString];
    NSDictionary *dic=[responseString objectFromJSONString];
    
    if(dic)
    {
        NSString *result=[dic valueForKey:@"result"];
        NSString *operation=[dic valueForKey:@"operation"];
        NSString *resultMsg=[dic valueForKey:@"result_message"];

        if([operation isEqualToString:GLogin])
        {
            [self processRequestLogin:dic withResult:result andResultMsg:resultMsg];
        }
    }
    else
    {
        [SVProgressHUD dismiss];
        NSString *text = NSLocalizedString(@"auth_network_no", nil);
        [Dialog simpleToast:text];
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
        
        AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
        //上传测量数据
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
        AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
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

-(void)processRequestCanRegister:(NSDictionary *)dic withResult:(NSString *)result andResultMsg:(NSString *)retmsg
{
    if([result isEqualToString:RespondSuccess])
    {
        _canRegister=YES;
    }
    else
    {
        _canRegister=NO;
    }
}


//处理登录操作
-(void)processRequestLogin:(NSDictionary *)dic withResult:(NSString *)result andResultMsg:(NSString *)retmsg
{
    [SVProgressHUD dismiss];
    self.view.userInteractionEnabled=YES;
    if([result isEqualToString:RespondSuccess])
    {
        NSDictionary *dicData=[dic valueForKey:@"data"];
        if(dicData && dicData.count>=2)
        {
            NSString *uid=[dicData valueForKey:@"u_id"];
            NSString *sex=[dicData valueForKey:@"sex"];
            NSString *age=[dicData valueForKey:@"age"];
            NSString *height=[dicData valueForKey:@"height"];
            NSString *ctime=[dicData valueForKey:@"c_time"];
            NSString *wc=[dicData valueForKey:@"wc"];
            NSString *hc=[dicData valueForKey:@"hc"];
            if(wc == nil) wc=@"";
            if(hc == nil) hc=@"";
            
            NSString *uname=self.textPhone.text;
            NSString *upwd=self.textPwd.text;
            NSString *usession=@"";
            NSString *localicon=@"";
            NSString *remoteicon=@"";
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
                                    wc,
                                    hc, nil];
            
            BOOL result=[_db insertAccount:aryMemberInfo];
            if(result)
            {
                [[NSUserDefaults standardUserDefaults] setObject:ctime forKey:@"c_time"];
                [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"u_id"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [_delegate setUserInfo];
                
                //[[NSNotificationCenter defaultCenter] postNotificationName:GNotiUpdateView object:nil];
                
                [_delegate updateDownloadTime];
                [_delegate uploadWeightToService];
                [_delegate uploadStepToService];
                [_delegate uploadTargetToService];
                
                
                //2015-11-06
                NSString *localCtime=[_db selectLocalAccountCTime];
                if(localCtime.length<5)
                {
                    [self registerMemberWithSex:sex Age:age Height:height HC:hc WC:wc];
                }
               
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:GNotiUpdateView object:nil];
                    //GNotiRefreshView
                    [[NSNotificationCenter defaultCenter] postNotificationName:GNotiRefreshView object:nil];
                });
                
                //[Dialog simpleToast:@"登录成功"];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                [Dialog simpleToast:NSLocalizedString(@"login_error", nil)];
            }
        }
    }
    
    else {
        [Dialog simpleToast:NSLocalizedString(@"login_error", nil)];
    }

    
}

 //2015-11-06
- (BOOL)registerMemberWithSex:(NSString *)sex Age:(NSString *)age Height:(NSString *)height HC:(NSString *)hc WC:(NSString *)wc
{
    NSString *uname=@"";
    NSString *upwd=@"";
    NSString *uid=@"";
    NSString *usession=@"";
    NSString *locaticon=@"";
    NSString *remoteicon=@"";
    NSString *ctime = [PublicModule getMyTimeInterval:[NSDate date]];
    
    //NSString *sex=[AppDelegate shareUserInfo].sex;
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
    //NSString *age=[AppDelegate shareUserInfo].userAge;
    //NSString *height=[AppDelegate shareUserInfo].userHeight;
    //NSString *hc = [AppDelegate shareUserInfo].userHC;
    //NSString *wc = [AppDelegate shareUserInfo].userWC;
    
    
    NSArray *aryMemberInfo=[[NSArray alloc] initWithObjects:uname,
                            upwd,
                            uid,
                            usession,
                            locaticon,
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
                            wc,
                            hc, nil];
    BOOL result=[_db updateLocalAccount:aryMemberInfo];
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

- (IBAction)gotoFindPwd:(id)sender {
    
    GForgetPwdController *vc=[[GForgetPwdController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)gotoRegister:(id)sender {
    GRegisterController *vc=[[GRegisterController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
@end

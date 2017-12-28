#import "GForgetPwdController.h"
#import "WCAlertView/WCAlertView.h"


@interface GForgetPwdController ()

@end

@implementation GForgetPwdController

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
    
    self.viewTextPhoneLine.frame=CGRectMake(self.viewTextPhoneLine.frame.origin.x, self.viewTextPhoneLine.frame.origin.y, self.viewTextPhoneLine.frame.size.width, 1);
    self.viewTextPhoneLine.backgroundColor=[UIColor lightGrayColor];
    
    self.viewTextPwdLine.frame=CGRectMake(self.viewTextPwdLine.frame.origin.x, self.viewTextPwdLine.frame.origin.y, self.viewTextPwdLine.frame.size.width, 1);
    self.viewTextPwdLine.backgroundColor=[UIColor lightGrayColor];
    
    UIColor *color=[UIColor lightGrayColor];
    self.textPhone.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"account_emailinfo", nil) attributes:@{NSForegroundColorAttributeName: color}];
    self.lblTopTitle.text=NSLocalizedString(@"findpwd_title", nil);
    self.lblMail.text=[NSLocalizedString(@"account_email", nil) stringByAppendingString:@":"];
    [self.btnLogin setTitle:NSLocalizedString(@"findpwd_info", nil) forState:UIControlStateNormal];
    
    

    self.textPhone.tintColor=UIColorFromRGB(0x0094ff);

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
    

    
    self.btnLogin.frame=CGRectMake(15, self.textPhone.frame.origin.y+self.textPhone.frame.size.height+40,SCREEN_WIDTH-30, 0.103125*SCREEN_WIDTH);
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
    /*
    if (textField == self.textPhone)
    {
        [self.viewTextPwdLine setBackgroundColor:[UIColor lightGrayColor]];
        [self.viewTextPhoneLine setBackgroundColor:UIColorFromRGB(0x00af00)];
    }
*/
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.textPhone)
    {
        return [self.textPhone becomeFirstResponder];
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
    [self.viewTextPhoneLine setBackgroundColor:[UIColor lightGrayColor]];
    [self.viewTextPwdLine setBackgroundColor:[UIColor lightGrayColor]];
}



- (IBAction)gotoLogin:(id)sender
{
    if(![PublicModule isValidateEmail:self.textPhone.text])
    {
        [Dialog simpleToast:NSLocalizedString(@"findpwd_errmail", nil)];
        return;
    }
    
    NSArray *aryAccount=[[NSArray alloc] initWithObjects:self.textPhone.text, nil];
    NSString *strJson=[_network jsonGFindPwd:aryAccount];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLLogin] andJson:strJson];
        [SVProgressHUD show];
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

        if([operation isEqualToString:GFindPwd])
        {
            [self processRequestFindPwd:dic withResult:result andResultMsg:resultMsg];
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
-(void)processRequestFindPwd:(NSDictionary *)dic withResult:(NSString *)result andResultMsg:(NSString *)retmsg
{
    [SVProgressHUD dismiss];
    self.view.userInteractionEnabled=YES;
    if([result isEqualToString:RespondSuccess])
    {
        [Dialog simpleToast:@"密码已发送到你邮箱，请查收"];
        [self goback:nil];
    }
    
    else
    {
        [Dialog simpleToast:retmsg];
    }

    
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
    NSArray *ary=[[NSArray alloc] initWithObjects:self.textPhone.text,@"",type, nil];
    NSString *strJson=[_network jsonLoginFromService:ary];
    if(strJson)
    {
        NSURL *url=[NSURL URLWithString:ServiceAccountURL];
        
        _uname=self.textPhone.text;
        _upwd=@"";
        [self doRequestWithURL:url andJson:strJson];
    }
    
}



- (IBAction)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)gotoFindPwd:(id)sender {
}

- (IBAction)gotoRegister:(id)sender {
}
@end

#import "GEditPwdController.h"


@interface GEditPwdController ()<UIGestureRecognizerDelegate>
{
    AppDelegate *_delegate;
}
@end

@implementation GEditPwdController

- (BOOL)fd_prefersNavigationBarHidden { return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
   
    iTableType=0;
    
    [self initView];
    [self.view insertSubview:self.viewNotiStatus belowSubview:self.viewTop];
    
    self.lblTitle.text=NSLocalizedString(@"editpwd_title", nil);
    [self.btnBack setTitle:NSLocalizedString(@"cancle", nil) forState:UIControlStateNormal];
    [self.btnFinish setTitle:NSLocalizedString(@"enter", nil) forState:UIControlStateNormal];
    
    self.lblNewPwd.text=NSLocalizedString(@"editpwd_newpwd", nil);
    self.lblConfirmPwd.text=NSLocalizedString(@"editpwd_confirmpwd", nil);
    
    self.textNewPwd.placeholder=NSLocalizedString(@"editpwd_newpwdinfo", nil);
    self.textConfirmPwd.placeholder=NSLocalizedString(@"editpwd_confirmpwdinfo", nil);
    
    _delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    _jsonModule=[[NetworkModule alloc] init];
    
    _db=[[DbModel alloc] init];
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
    self.lblTitle.font=[UIFont systemFontOfSize:iPhone5FontSizeTitle];
    [self.btnBack.titleLabel setFont:[UIFont systemFontOfSize:iPhone5FontSizeName]];
    [self.btnFinish.titleLabel setFont:[UIFont systemFontOfSize:iPhone5FontSizeName]];
    self.lblOldPwd.font=[UIFont systemFontOfSize:iPhone5FontSizeName-1];
    self.lblNewPwd.font=self.lblOldPwd.font;
    self.lblConfirmPwd.font=self.lblNewPwd.font;
    self.textOldPwd.font=self.lblOldPwd.font;
    self.textNewPwd.font=self.lblOldPwd.font;
    self.textConfirmPwd.font=self.lblOldPwd.font;
    if(is_iPhone6P)
    {
        [self.lblTitle setFont:[UIFont systemFontOfSize:iPhone6PFontSizeTitle]];
        [self.btnBack.titleLabel setFont:[UIFont systemFontOfSize:iPhone6PFontSizeName]];
        [self.btnFinish.titleLabel setFont:[UIFont systemFontOfSize:iPhone6PFontSizeName]];
        self.lblOldPwd.font=[UIFont systemFontOfSize:iPhone6PFontSizeName-1];
        self.lblNewPwd.font=self.lblOldPwd.font;
        self.lblConfirmPwd.font=self.lblNewPwd.font;
        self.textOldPwd.font=self.lblOldPwd.font;
        self.textNewPwd.font=self.lblOldPwd.font;
        self.textConfirmPwd.font=self.lblOldPwd.font;
    }
    else if(is_iPhone6)
    {
        [self.lblTitle setFont:[UIFont systemFontOfSize:iPhone6FontSizeTitle]];
        [self.btnBack.titleLabel setFont:[UIFont systemFontOfSize:iPhone6FontSizeName]];
        [self.btnFinish.titleLabel setFont:[UIFont systemFontOfSize:iPhone6FontSizeName]];
        self.lblOldPwd.font=[UIFont systemFontOfSize:iPhone6FontSizeName-1];
        self.lblNewPwd.font=self.lblOldPwd.font;
        self.lblConfirmPwd.font=self.lblNewPwd.font;
        self.textOldPwd.font=self.lblOldPwd.font;
        self.textNewPwd.font=self.lblOldPwd.font;
        self.textConfirmPwd.font=self.lblOldPwd.font;
    }
    
    
    self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.viewTop.frame=CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT);
    self.btnBack.frame=CGRectMake(0, 20, 70, 44);
    self.lblTitle.frame=CGRectMake(0, 20, SCREEN_WIDTH, 44);
    self.btnFinish.frame=CGRectMake(SCREEN_WIDTH-70, 20, 70, 44);
    
    CGFloat singleHeight=0.103125*SCREEN_WIDTH;
    
    self.viewContent.frame=CGRectMake(0, 0.040625*SCREEN_WIDTH+NAVBAR_HEIGHT, SCREEN_WIDTH, 0.31875*SCREEN_WIDTH);
    self.viewLine1.frame=CGRectMake(0.14375*SCREEN_WIDTH, singleHeight, 0.853125*SCREEN_WIDTH, 1);
    self.viewLine2.frame=CGRectMake(0.14375*SCREEN_WIDTH, singleHeight*2+1, 0.853125*SCREEN_WIDTH, 1);
    
    self.lblOldPwd.frame=CGRectMake(0.03125*SCREEN_WIDTH, 0, 0.1625*SCREEN_WIDTH, singleHeight);
    self.lblNewPwd.frame=CGRectMake(0.03125*SCREEN_WIDTH, singleHeight+1, 0.1625*SCREEN_WIDTH, singleHeight);
    self.lblConfirmPwd.frame=CGRectMake(0.03125*SCREEN_WIDTH, singleHeight*2+2, 0.1625*SCREEN_WIDTH, singleHeight);
    
    self.textOldPwd.frame=CGRectMake(0.275*SCREEN_WIDTH, 0, SCREEN_WIDTH-0.3*SCREEN_WIDTH, singleHeight);
    self.textNewPwd.frame=CGRectMake(0.275*SCREEN_WIDTH, singleHeight+1, SCREEN_WIDTH-0.3*SCREEN_WIDTH, singleHeight);
    self.textConfirmPwd.frame=CGRectMake(0.275*SCREEN_WIDTH, singleHeight*2+2, SCREEN_WIDTH-0.3*SCREEN_WIDTH, singleHeight);
    
    self.lblConfirmPwd.frame=self.lblNewPwd.frame;
    self.lblNewPwd.frame=self.lblOldPwd.frame;
    self.textConfirmPwd.frame=self.textNewPwd.frame;
    self.textNewPwd.frame=self.textOldPwd.frame;
    self.viewContent.frame=CGRectMake(self.viewContent.frame.origin.x, self.viewContent.frame.origin.y, self.viewContent.frame.size.width, self.viewLine2.frame.origin.y+self.viewLine2.frame.size.height);
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.textOldPwd resignFirstResponder];
    [self.textNewPwd resignFirstResponder];
    [self.textConfirmPwd resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




//异步请求成功
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString=[request responseString];
    NSDictionary *dic=[responseString objectFromJSONString];
    
    [SVProgressHUD dismiss];
    self.view.userInteractionEnabled=YES;
    
    if(dic)
    {
        NSString *result=[dic valueForKey:@"result"];
        NSString *operation=[dic valueForKey:@"operation"];
        NSString *resultmsg=[dic valueForKey:@"result_message"];
        if([operation isEqualToString:GEditPwd])
        {
            [self processRequestEditPwd:dic withResult:result andResultmsg:resultmsg andJson:responseString];
        }
    }
    else
    {
        NSString *text = NSLocalizedString(@"auth_network_no", nil);
        [self showWithText:text andHideAfter:3.0f];
        self.view.userInteractionEnabled=YES;
    }
}


-(void)requestFailed:(ASIHTTPRequest *)request
{
    self.view.userInteractionEnabled=YES;
    [SVProgressHUD dismiss];
    NSString *text = NSLocalizedString(@"auth_network_no", nil);
    [self showWithText:text andHideAfter:3.0f];
}


-(void)processRequestEditPwd:(NSDictionary *)dic withResult:(NSString *)result andResultmsg:(NSString *)resultmsg andJson:(NSString *)json
{
    if([result isEqualToString:RespondSuccess])
    {
        [_db updateAccountWithPwd:self.textConfirmPwd.text andUID:[AppDelegate shareUserInfo].uid];
        [self goback:nil];
        [Dialog simpleToast:NSLocalizedString(@"密码修改成功", nil)];
    }
    else
    {
        [Dialog simpleToast:resultmsg];
    }
}

- (IBAction)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)savePwd:(id)sender
{
    if(![PublicModule checkPassword:self.textNewPwd.text])
    {
        [Dialog simpleToast:NSLocalizedString(@"register_errpwd", nil)];
        [self.textNewPwd becomeFirstResponder];
        return;
    }
    if(![PublicModule checkPassword:self.textConfirmPwd.text])
    {
        [Dialog simpleToast:NSLocalizedString(@"register_errconfirmpwd", nil)];
        [self.textConfirmPwd becomeFirstResponder];
        return;
    }
    if(![self.textNewPwd.text isEqualToString:self.textConfirmPwd.text])
    {
        [Dialog simpleToast:NSLocalizedString(@"register_errtwopwd", nil)];
        return;
    }
    
    NSArray *ary=[[NSArray alloc] initWithObjects:self.textConfirmPwd.text, nil];
    NSString *strJosn=[_jsonModule jsonGEditPwd:ary];
    
    if(strJosn)
    {
        [SVProgressHUD show];
        [self doRequestWithURL:[NSURL URLWithString:GURLLogin] andJson:strJosn];
    }
    else
    {
        [Dialog simpleToast:@"json解析失败"];
    }
    
    //[Dialog simpleToast:@"密码修改成功"];
    //[self goback:nil];
}

-(void)editPwdWithOldPwd:(NSString *)oldpwd andNewPwd:(NSString *)newpwd
{
    if([PublicModule checkNetworkStatus])
    {
        NSString *strJson=[_jsonModule jsonDPwdEditWithOldPwd:oldpwd andNewPwd:newpwd];
        if(strJson)
        {
            [self doRequestWithURL:[NSURL URLWithString:URLDAccount] andJson:strJson];
            self.view.userInteractionEnabled=NO;
            [SVProgressHUD show];
        }
        else
        {
            [self showWithText:@"json error" andHideAfter:3.0f];
        }
    }
    else
    {
        NSString *text = NSLocalizedString(@"auth_network_no", nil);
        [self showWithText:text andHideAfter:3.0f];
    }
}



@end

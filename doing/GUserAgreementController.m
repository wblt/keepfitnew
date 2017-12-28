#import "GUserAgreementController.h"
#import "WCAlertView/WCAlertView.h"
#import "GForgetPwdController.h"
#import "GRegisterController.h"


@interface GUserAgreementController ()

@end

@implementation GUserAgreementController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

   
    
    if([[UIDevice currentDevice] systemVersion].floatValue>=7.0)
    {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    _qqClick=YES;
    _sinaClick=YES;
    _canGotoMain=YES;
    
    canSendAuthcode=YES;
    iAuthcodeTime=180;
    _db=[[DbModel alloc] init];
    _network=[[NetworkModule alloc] init];

    
    [self initView];
    
    if(_canGoBack)
    {
        self.btnBack.hidden=YES;
        self.btnBackIcon.hidden=YES;
    }

    //[self forbiddenGesturePop];
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


    self.viewTop.frame=CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT);
    
    self.btnBack.frame=CGRectMake(0, 20, 70, 44);
    self.lblTopTitle.frame=CGRectMake(0, 20, SCREEN_WIDTH, 44);
    
    
    self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone5FontSizeTitle];
    if(is_iPhone6)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6FontSizeTitle];
    }
    else if (is_iPhone6P)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6PFontSizeTitle];
    }
    
    self.scrollView.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT);
    
    self.lblContent.frame=CGRectMake(15, 30, self.scrollView.frame.size.width-30, MAXFLOAT);
    self.lblContent.numberOfLines=0;
    [self.lblContent sizeToFit];
    
    self.lblContentEnglish.frame=CGRectMake(15, 30, self.scrollView.frame.size.width-30, MAXFLOAT);
    self.lblContentEnglish.numberOfLines=0;
    [self.lblContentEnglish sizeToFit];
    
    self.lblContentEnglish.hidden=YES;
    self.lblContent.hidden=YES;
    
    self.lblTopTitle.text=NSLocalizedString(@"user_agreement_title", nil);
    NSString *userAgreement=NSLocalizedString(@"user_agreement", nil);
    
    if([userAgreement isEqualToString:@"0"])
    {
        self.scrollView.contentSize=CGSizeMake(SCREEN_WIDTH, self.lblContent.frame.size.height+40);
        self.lblContent.hidden=NO;
    }
    else
    {
        self.scrollView.contentSize=CGSizeMake(SCREEN_WIDTH, self.lblContentEnglish.frame.size.height+40);
        self.lblContentEnglish.hidden=NO;
    }
    
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


- (IBAction)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end

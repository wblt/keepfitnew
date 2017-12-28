#import "AuthCommonViewController.h"

@interface AuthCommonViewController ()

@end

@implementation AuthCommonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    _ud=[NSUserDefaults standardUserDefaults];
    
    if([[UIDevice currentDevice] systemVersion].floatValue>=7.0)
    {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
}

-(UIView *)viewNotiStatus
{
    if(!_viewNotiStatus)
    {
        UIView *viewNoti=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        viewNoti.backgroundColor=UIColorFromRGB(0xffdfdf);
        [viewNoti addSubview:self.lblNotiStatus];
        _viewNotiStatus=viewNoti;
    }
    return _viewNotiStatus;
}

-(UILabel *)lblNotiStatus
{
    if(!_lblNotiStatus)
    {
        UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        label.font=[UIFont systemFontOfSize:14];
        label.textAlignment=NSTextAlignmentCenter;
        _lblNotiStatus=label;
    }
    return _lblNotiStatus;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
}

-(void)doRequestWithURL:(NSURL *)url andJson:(NSString *)strJson
{
    @try
    {
        if([PublicModule checkNetworkStatus])
        {
            ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
            [request addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
            [request addRequestHeader:@"Accept" value:@"application/json"];
            [request setRequestMethod:@"GET"];
            
            [request setPostValue:strJson forKey:@"jsonstring"];
            
            __block AuthCommonViewController *weakSelf=self;
            __block ASIFormDataRequest *requestTemp=request;
            
            [request setCompletionBlock:^{
                [weakSelf requestFinished:requestTemp];
            }];
            
            [request setFailedBlock:^{
                [weakSelf requestFailed:requestTemp];
                
            }];
            [request startAsynchronous];
            
        }
        else
        {
            NSLog(@"doRequestWithURL");
            [Dialog simpleToast:NSLocalizedString(@"auth_network_no", nil)];
            [self showWithText:NSLocalizedString(@"auth_network_no", nil) andHideAfter:3.0f];
        }
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"%@",exception);
    }
}

-(void)afnRequestWithURL:(NSString *)strURL andJson:(NSString *)strJson
{
    NSMutableDictionary *dicPrama=[[NSMutableDictionary alloc] init];
    [dicPrama setObject:strJson forKey:@"jsonstring"];
    
    [[AFHTTPRequestOperationManager manager] POST:strURL parameters:dicPrama success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dicResult=(NSDictionary *)responseObject;
        if([self respondsToSelector:@selector(afnRequestFinished:withData:)])
        {
            [self afnRequestFinished:operation withData:dicResult];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if([self respondsToSelector:@selector(afnRequestFailed:withError:)])
        {
            [self afnRequestFailed:operation withError:error];
        }
    }];
}

-(void)afnRequestFinished:(AFHTTPRequestOperation *)operation withData:(NSDictionary *)data
{
    
}

-(void)afnRequestFailed:(AFHTTPRequestOperation *)operation withError:(NSError *)error
{
    
}

-(void)showErrorMessage:(NSString *)msg
{
    
}

-(void)showMessage:(NSString *)msg
{
    
}

-(void)showWithText:(NSString *)text andHideAfter:(NSTimeInterval)timeout
{
    self.lblNotiStatus.text=text;
    [self showNotiView];
    [self performSelector:@selector(hiddenNotiView) withObject:nil afterDelay:timeout];
}

-(void)showNotiWithText:(NSString *)text
{
    self.lblNotiStatus.text=text;
    [self showNotiView];
}

-(void)hideNotiView
{
    [self hiddenNotiView];
}

-(void)showNotiView
{
    [UIView animateWithDuration:0.5f animations:^{
        self.viewNotiStatus.frame=CGRectMake(0, NAVBAR_HEIGHT, self.viewNotiStatus.frame.size.width, self.viewNotiStatus.frame.size.height);
    }];
}

-(void)hiddenNotiView
{
    [UIView animateWithDuration:0.5f animations:^{
        self.viewNotiStatus.frame=CGRectMake(0, 0, self.viewNotiStatus.frame.size.width, self.viewNotiStatus.frame.size.height);
    }];
}
@end

#import "AppDelegate.h"
#import "SDImageCache.h"
#import "OpenUDID.h"
#import "UserInfo.h"
#import "WXApi.h"
#import <QZoneConnection/QZoneConnection.h>
#import "ShareSDK/ShareSDK.framework/Headers/ShareSDK.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WCAlertView/WCAlertView.h"
#import "MainTabController.h"
#import <CoreLocation/CoreLocation.h>
#import <Bugly/CrashReporter.h>
#import "OpenUDID.h"
#import "Bluetooth/DeviceInfo.h"
#import "Bluetooth/CBController.h"

@implementation AppDelegate

@synthesize appId;
@synthesize myUserInfo;
@synthesize iUserIdentifier;

#pragma mark - Network

- (void)doRequestWithURL:(NSURL *)url withJson:(NSString *)strJson
{
    ASIFormDataRequest *formRequest=[ASIFormDataRequest requestWithURL:url];
    [formRequest addRequestHeader:@"Content-Type" value:@"application/json; encoding=utf-8"];
    [formRequest addRequestHeader:@"Accept" value:@"application/json"];
    [formRequest setRequestMethod:@"POST"];
    [formRequest setPostValue:strJson forKey:@"jsonstring"];
    [formRequest setDelegate:self];
    [formRequest startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *responseString=[request responseString];
    NSDictionary *dic=[responseString objectFromJSONString];
    
    if(dic)
    {
        NSString *result=[dic valueForKey:@"result"];
        NSString *operation=[dic valueForKey:@"operation"];
        NSString *resultmsg=[dic valueForKey:@"result_message"];
        if([operation isEqualToString:GLogin])
        {
            [self processRequestLogin:dic withResult:result];
        }
        else if ([operation isEqualToString:GEditProfile])
        {
            [self processRequestEditProfile:dic withResult:result];
        }
        else if ([operation isEqualToString:GUploadWeight])
        {
            [self processRequestUploadWeight:dic withResult:result];
        }
        else if ([operation isEqualToString:GUploadStep])
        {
            [self processRequestUploadStep:dic withResult:result];
        }
        else if ([operation isEqualToString:GUploadTarget])
        {
            [self processRequestUploadTarget:dic withResult:result];
        }
        else if ([operation isEqualToString:GDownloadWeight])
        {
            [self processRequestDownloadWeight:dic withResult:result];
        }
        else if ([operation isEqualToString:GDownloadWeightCallback])
        {
            [self processRequestDownloadWeightCallback:dic withResult:result];
        }
        else if ([operation isEqualToString:GDownloadStep])
        {
            [self processRequestDownloadStep:dic withResult:result];
        }
        else if ([operation isEqualToString:GDownloadStepCallback])
        {
            [self processRequestDownloadStepCallback:dic withResult:result];
        }
        else if ([operation isEqualToString:GDownloadTarget])
        {
            [self processRequestDownloadTarget:dic withResult:result];
        }
        else if ([operation isEqualToString:GDownloadTargetCallback])
        {
            [self processRequestDownloadTargetCallback:dic withResult:result];
        }
        else if ([operation isEqualToString:DUploadDeviceInfo])
        {
            [self processRequestUploadDeviceInfo:dic withResult:result andResultmsg:resultmsg];
        }
    }
    else
    {
        NSLog(@"%@",responseString);
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    
}

-(void)processRequestUploadDeviceInfo:(NSDictionary *)dic withResult:(NSString *)result andResultmsg:(NSString *)resultmsg
{
    if([result isEqualToString:RespondSuccess])
    {
        NSLog(@"发送设备信息成功");
    }
    else
    {
        NSLog(@"%@",dic);
    }
}

-(void)insertJsonTempWithJson:(NSString *)jsonTemp andPage:(int)page andType:(NSString *)jsonType
{
    if(page>=0 && page<=3)
    {
        NSString *strPage=[NSString stringWithFormat:@"%d",page];
        [_db insertJsonTempWithJson:jsonTemp andType:jsonType andPage:strPage andUID:@""];
    }
}

-(void)processRequestUploadWeight:(NSDictionary *)dic withResult:(NSString *)result
{
    if([result isEqualToString:RespondSuccess])
    {
        NSLog(@"上传体重成功");
        [_db finishUploadMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andID:@""];
        [self downloadWeight];
    }
    else
    {
        NSLog(@"上传体重失败");
    }
}

-(void)processRequestUploadStep:(NSDictionary *)dic withResult:(NSString *)result
{
    if([result isEqualToString:RespondSuccess])
    {
        NSLog(@"上传计步成功");
        [_db finishUploadStepDataWithCTime:[AppDelegate shareUserInfo].account_ctime andID:@""];
        [self downloadStep];
    }
    else
    {
        NSLog(@"上传计步失败");
    }
}

-(void)processRequestUploadTarget:(NSDictionary *)dic withResult:(NSString *)result
{
    if([result isEqualToString:RespondSuccess])
    {
        NSLog(@"上传目标成功");
        [_db finishUploadTargetDataWithCTime:[AppDelegate shareUserInfo].account_ctime andID:@""];
        [self downloadTarget];
    }
    else
    {
        NSLog(@"上传目标失败");
    }
}

-(void)processRequestDownloadWeight:(NSDictionary *)dic withResult:(NSString *)result
{
    if([result isEqualToString:RespondSuccess])
    {
        NSArray *array = [dic objectForKey:@"data"];
        NSString *downloadTime=[dic objectForKey:@"download_time"];
        NSString *complete=[dic valueForKey:@"complete"];
        NSString *opcode=[dic valueForKey:@"opcode"];
        
        if(array && array.count>=1)
        {
            NSLog(@"本次更新了体重%ld条",(long)array.count);
            [_db insertDownloadWeightWithAry:array andCTime:[AppDelegate shareUserInfo].account_ctime];
        }

        if([complete isEqualToString:DTrue] && opcode!=nil)
        {
            _downloadtimeWeight=downloadTime;
            [_db insertDownloadTime:_downloadtimeWeight andType:GDownloadtimeWeight];
            [[NSNotificationCenter defaultCenter] postNotificationName:GNotiUpdateView object:nil];
            NSLog(@"更新体重完成:%@",_downloadtimeWeight);
        }
        else
        {
            [self downloadWeightCallback:opcode];
        }
        
    }
    else
    {
        NSLog(@"下载体重失败");
    }
}

-(void)processRequestDownloadWeightCallback:(NSDictionary *)dic withResult:(NSString *)result
{
    if([result isEqualToString:RespondSuccess])
    {
        NSLog(@"下载体重回调成功");
        [self downloadWeight];
    }
    else
    {
        NSLog(@"下载体重回调失败");
    }
}

-(void)processRequestDownloadStep:(NSDictionary *)dic withResult:(NSString *)result
{
    if([result isEqualToString:RespondSuccess])
    {
        
        NSArray *array = [dic objectForKey:@"data"];
        NSString *downloadTime=[dic objectForKey:@"download_time"];
        NSString *complete=[dic valueForKey:@"complete"];
        NSString *opcode=[dic valueForKey:@"opcode"];
        
        if(array && array.count>=1)
        {
            NSLog(@"本次更新了步数%ld条",(long)array.count);
            [_db insertDownloadStepWithAry:array andCTime:[AppDelegate shareUserInfo].account_ctime];
        }
        
        if([complete isEqualToString:DTrue] && opcode!=nil)
        {
            _downloadtimeStep=downloadTime;
            [_db insertDownloadTime:_downloadtimeStep andType:GDownloadtimeStep];
            [[NSNotificationCenter defaultCenter] postNotificationName:GNotiUpdateView object:nil];
            NSLog(@"更新步数完成:%@",_downloadtimeStep);
        }
        else
        {
            [self downloadStepCallback:opcode];
        }
    }
    else
    {
        NSLog(@"下载步数失败");
    }
}

-(void)processRequestDownloadStepCallback:(NSDictionary *)dic withResult:(NSString *)result
{
    if([result isEqualToString:RespondSuccess])
    {
        [self downloadStep];
        NSLog(@"下载步数回调成功");
    }
    else
    {
        NSLog(@"下载步数回调失败");
    }
}

-(void)processRequestDownloadTarget:(NSDictionary *)dic withResult:(NSString *)result
{
    if([result isEqualToString:RespondSuccess])
    {
        
        NSArray *array = [dic objectForKey:@"data"];
        NSString *downloadTime=[dic objectForKey:@"download_time"];
        NSString *complete=[dic valueForKey:@"complete"];
        NSString *opcode=[dic valueForKey:@"opcode"];
        
        if(array && array.count>=1)
        {
            NSLog(@"本次更新了目标%ld条",(long)array.count);
            [_db insertDownloadTargetWithAry:array andCTime:[AppDelegate shareUserInfo].account_ctime];
        }

        if([complete isEqualToString:DTrue] && opcode!=nil)
        {
            _downloadtimeTarget=downloadTime;
            [_db insertDownloadTime:_downloadtimeTarget andType:GDownloadtimeTarget];
            [[NSNotificationCenter defaultCenter] postNotificationName:GNotiUpdateView object:nil];
            NSLog(@"更新目标完成:%@",_downloadtimeTarget);
        }
        else
        {
            [self downloadTargetCallback:opcode];
        }
    }
    else
    {
        NSLog(@"下载目标失败");
    }
}

-(void)processRequestDownloadTargetCallback:(NSDictionary *)dic withResult:(NSString *)result
{
    if([result isEqualToString:RespondSuccess])
    {
        [self downloadTarget];
        NSLog(@"下载目标回调成功");
    }
    else
    {
        NSLog(@"下载目标回调失败");
    }
}


-(void)processRequestEditProfile:(NSDictionary *)dic withResult:(NSString *)result
{
    if([result isEqualToString:RespondSuccess])
    {
        NSLog(@"上传用户信息成功");
    }
    else
    {
        NSLog(@"上传用户信息失败");
    }
}

//处理登录操作
-(void)processRequestLogin:(NSDictionary *)dic withResult:(NSString *)result
{
    NSUserDefaults* ud=[NSUserDefaults standardUserDefaults];
    if([result isEqualToString:RespondSuccess])
    {
        //NSLog(@"自动登录成功");
        NSString *uname=[ud objectForKey:@"u_name"];
        NSString *utype=[ud objectForKey:@"u_type"];
        if([utype isEqualToString:@"1"] || [utype isEqualToString:@"2"])
        {
            uname=[ud objectForKey:@"u_nickname"];
        }
        else if([utype isEqualToString:@"0"])
        {
            NSString *str1=[uname substringToIndex:3];
            NSString *str2=[uname substringFromIndex:7];
            uname=[NSString stringWithFormat:@"%@****%@",str1,str2];
        }

        
        NSString *uid=[dic valueForKey:@"data"];
        if(uid)
        {
            [ud setObject:uid forKey:@"u_id"];
            NSDictionary *dicData=[dic valueForKey:@"data_array"];
            if(dicData)
            {
                NSString *usession=[dicData objectForKey:@"session"];
                NSString *ukey=[dicData objectForKey:@"aes_key"];
                NSString *uiv=[dicData objectForKey:@"aes_iv"];
                if(usession == nil) usession=@"";
                if(ukey == nil) ukey=@"";
                if(uiv == nil) uiv=@"";
                [ud setObject:usession forKey:@"u_session"];
                [ud setObject:ukey forKey:@"u_aeskey"];
                [ud setObject:uiv forKey:@"u_aesiv"];
                
                NSString *ctime=[dicData valueForKey:@"c_time"];
                if(ctime!=nil)
                {
                    [ud setObject:ctime forKey:uname];
                    
                    if(![ctime isEqualToString:@""])
                    {
                        [ud setObject:ctime forKey:@"c_time"];
                    }
                    else
                    {
                        [ud setObject:@"-1" forKey:@"c_time"];
                    }
                    [ud synchronize];
                }
            }
            [ud synchronize];
            self.iNormalLogin=0;
        }
    }
    else
    {
        //NSLog(@"自动登录失败,自动销毁登录信息");
        [ud setObject:@"-1" forKey:@"c_time"];
        [ud removeObjectForKey:@"u_name"];
        [ud removeObjectForKey:@"u_pwd"];
        [ud removeObjectForKey:@"u_id"];
        [ud removeObjectForKey:@"u_type"];
        [ud removeObjectForKey:@"u_session"];
        [ud removeObjectForKey:@"u_aeskey"];
        [ud removeObjectForKey:@"u_aesiv"];
        
        [self gotoLogin];
    }
}

-(void)gAutoLogin
{
    NSString *uname=[_ud objectForKey:@"u_name"];
    NSString *upwd=[_ud objectForKey:@"u_pwd"];

    if(uname.length<1 || upwd.length<1)
    {
        [self gotoLogin];
        return;
    }
    else
    {
        if([PublicModule checkNetworkStatus])
        {
            BOOL isCret=YES;
            
            if(isCret)
            {
                NSURL *url=[NSURL URLWithString:URLDAccount];
                
                NSArray *ary=[[NSArray alloc] initWithObjects:uname,upwd, nil];
                NSString *strJson=[_network jsonGLogin:ary];
                if(strJson)
                {
                    [self doRequestWithURL:url withJson:strJson];
                }
            }
        }
        else
        {
            [self performSelector:@selector(gAutoLogin) withObject:nil afterDelay:1.5f];
        }
    }
}


-(void)applicationWillResignActive:(UIApplication *)application
{
    bMainIn=NO;
}



static UserInfo *DefaultUserInfo = nil;
+(UserInfo *)shareUserInfo
{
    if(!DefaultUserInfo)
    {
        DefaultUserInfo=[[UserInfo alloc] init];
    }
    return DefaultUserInfo;
}

#pragma  mark 程序入口

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[CrashReporter sharedInstance] installWithAppId:TentcentBuglyAppkey];
    
    self.isM7Device = [PublicModule isM7Use];
    
    _downloadtimeTarget=@"0";
    _downloadtimeStep=@"0";
    _downloadtimeWeight=@"0";
    
    //[InternationalModule setUserLanguage:@""];
    //[InternationalModule initUserLanguage];
    
    //NSString *value = LCTLocalizedString(@"体重", nil);
    
    //NSArray *languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    
    //NSLog(@"%@-%@",value,languages);
    
    [AppDelegate shareUserInfo];
    [AppDelegate shareUserInfo].location_address=@"";
    [AppDelegate shareUserInfo].location_country=@"";
    [AppDelegate shareUserInfo].location_province=@"";
    [AppDelegate shareUserInfo].location_city=@"";
    [AppDelegate shareUserInfo].location_latitude=@"";
    [AppDelegate shareUserInfo].location_longitude=@"";
    

    bMainIn=YES;
    self.isLogin=NO;
    self.iNormalLogin=0;
    self.iNotiCount=0;
    self.iPrivateMsgCount=0;
    self.iPraiseCount=0;
    _isShowBleAlert = NO;
    
    self.myUserInfo=[[UserInfo alloc] init];
    publicModule=[[PublicModule alloc] init];
    _ud=[NSUserDefaults standardUserDefaults];

    [self createImgeDir];
    
    _db=[[DbModel alloc] init];
    _network=[[NetworkModule alloc] init];
    [_db isDbExist];
    _arySquareQiniu=nil;
    _arySquareService=nil;
    
    self.AppVersion=[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    application.applicationSupportsShakeToEdit=YES;
    
    [self setWeightDefaultUnit];
    [self setUUID];
    [self Share_API];
    [self startNotiNetwork];
    [self setUserInfo];
    
    NSArray *aryDownloadTime=[_db selectDownloadTimeWithUID:[_ud valueForKey:@"u_id"]];
    if(aryDownloadTime && aryDownloadTime.count>=1)
    {
        NSArray *aryData=[aryDownloadTime objectAtIndex:0];
        NSString *weightTime=[aryData objectAtIndex:0];
        NSString *targetTime=[aryData objectAtIndex:1];
        NSString *stepTime=[aryData objectAtIndex:2];
        if(weightTime.length>=10)
        {
            _downloadtimeWeight=weightTime;
        }
        if(targetTime.length>=10)
        {
            _downloadtimeTarget=targetTime;
        }
        if(stepTime.length>=10)
        {
            _downloadtimeStep=stepTime;
        }
    }
    
    [self uploadWeightToService];
    [self uploadStepToService];
    [self uploadTargetToService];
    
    MainTabController *vc=[[MainTabController alloc] init];
    self.navController=[[UINavigationController alloc] initWithRootViewController:vc];
    self.navController.navigationBarHidden=YES;
    self.navController.fd_prefersNavigationBarHidden = YES;
    self.tabController=vc;
    self.window.rootViewController=self.navController;
    [self.window makeKeyAndVisible];
    
    [self showSplashView];
    [self initBluetoothVar];
    
    return YES;
}


-(void)updateDownloadTime
{
    NSArray *aryDownloadTime=[_db selectDownloadTimeWithUID:[_ud valueForKey:@"u_id"]];
    if(aryDownloadTime && aryDownloadTime.count>=1)
    {
        NSArray *aryData=[aryDownloadTime objectAtIndex:0];
        NSString *weightTime=[aryData objectAtIndex:0];
        NSString *targetTime=[aryData objectAtIndex:1];
        NSString *stepTime=[aryData objectAtIndex:2];
        if(weightTime.length>=10)
        {
            _downloadtimeWeight=weightTime;
        }
        if(targetTime.length>=10)
        {
            _downloadtimeTarget=targetTime;
        }
        if(stepTime.length>=10)
        {
            _downloadtimeStep=stepTime;
        }
    }
}

-(void)stopMotionDetection
{
    [[SOMotionDetector sharedInstance] stopDetection];
}

-(void)startMotionDetection
{
    [SOMotionDetector sharedInstance].accelerationChangedBlock = ^(CMAcceleration acceleration)
    {
        BOOL isShaking = [SOMotionDetector sharedInstance].isShaking;
        if(isShaking)
        {
            //NSLog(@"shaking");
        }
        else
        {
            if( _iStep>1 )
            {
                _stepEndTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
   
                double journey=_iStep*70.0/100;
                double calorie=_iStep*0.04*1000;
                
                NSString *strStepCount=[NSString stringWithFormat:@"%d",_iStep];
                NSString *strJourney=[NSString stringWithFormat:@"%.0f",journey];
                NSString *strCalorie=[NSString stringWithFormat:@"%.0f",calorie];
                NSMutableDictionary *dicStep=[[NSMutableDictionary alloc] init];
                
                [dicStep setObject:strStepCount forKey:ProjectStepCount];
                [dicStep setObject:strCalorie forKey:ProjectStepCalorie];
                [dicStep setObject:strJourney forKey:ProjectStepJourney];
                [dicStep setObject:_stepStartTime forKey:ProjectStepStartTime];
                [dicStep setObject:_stepEndTime forKey:ProjectStepEndTime];
                
                NSString *memberType=[AppDelegate shareUserInfo].account_type;
                NSString *saveTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
                NSArray *aryData=[[NSArray alloc] initWithObjects:saveTime,dicStep,[AppDelegate shareUserInfo].uid,[AppDelegate shareUserInfo].account_ctime,@"0",@"0",@"0",memberType, nil];
                
                if(!self.isM7Device)
                {
                    [_db insertStepInfo:aryData];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NotiAddStep object:nil userInfo:dicStep];
          }
            _iStep=0;
        }
    };
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
    {
        [SOMotionDetector sharedInstance].useM7IfAvailable = YES;
    }
    
    
    [[SOMotionDetector sharedInstance] startDetection];
    [[SOStepDetector sharedInstance] startDetectionWithUpdateBlock:^(NSError *error)
     {
         if (error)
         {
             NSLog(@"%@", error.localizedDescription);
             return;
         }
         
         if(_iStep == 0)
         {
             _stepStartTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
         }
         
         _iStep++;
     }];
}


-(void)startNotiNetwork
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    __weak __typeof(self)weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                weakSelf.iNetworkStats = 0;
                //NSLog(@"%d:无网络",weakSelf.iNetworkStats);
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                weakSelf.iNetworkStats = 1;
                //NSLog(@"%d:wifi网络",weakSelf.iNetworkStats);
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                weakSelf.iNetworkStats = 2;
                //NSLog(@"%d:手机网络",weakSelf.iNetworkStats);
                break;
            case AFNetworkReachabilityStatusUnknown:
                weakSelf.iNetworkStats = -1;
                //NSLog(@"%d:未知网络",weakSelf.iNetworkStats);
                break;
            default:
                break;
        }
    }];
}



-(void)showSplashView
{
    if(iPhone5 || is_iPhone6 || is_iPhone6P)
    {
        _splashView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        UIImage *image=[UIImage imageNamed:@"r5.png"];
        _splashView.image=image;
    }
    else
    {
        _splashView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        UIImage *image=[UIImage imageNamed:@"r4.png"];
        _splashView.image=image;
    }
    
    if(_splashView.image == nil)
    {
        return;
    }
    
    _splashView.userInteractionEnabled=YES;
    [self.window addSubview:_splashView];
    [self.window bringSubviewToFront:_splashView];
    
    [self performSelector:@selector(EndSplashView) withObject:nil afterDelay:1.5];
}

-(void)EndSplashView
{
    [UIView animateWithDuration:.6f animations:^{
        
        _splashView.alpha=0.0;
        
    } completion:^(BOOL finished){
        
        [_splashView removeFromSuperview];
    }];
    
}

-(void)updateHealthKitData
{
    HKSampleType *sampleType=[HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    
    NVDate *startNVDate=[[NVDate alloc] initUsingDate:[NSDate date]];
    [startNVDate previousDays:7];
    
    NSDate *startDate=startNVDate.date;
    NSDate *endDate=[NSDate date];
    
    
    NSArray *aryLastStep=[_db selectLastStepWithCTime:[AppDelegate shareUserInfo].account_ctime];
    if(aryLastStep && aryLastStep.count>=1)
    {
        NSArray *aryData=[aryLastStep objectAtIndex:0];
        NSString *time=[aryData objectAtIndex:2];
        if(time && time.length>=10)
        {
            NSString *strStartDate=[time substringToIndex:10];
            NSString *strDays=[PublicModule getDays:strStartDate withDate:[PublicModule getTimeNow:@"yyyy-MM-dd" withDate:endDate]];
            if(strDays && [strDays intValue]-1<7)
            {
                startDate=[PublicModule getDateWithString:time andFormatter:@"yyyy-MM-dd HH:mm:ss"];
            }
        }
    }
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    
    HKSampleQuery *sampleQuery=[[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:0 sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        
        if (error)
        {
            NSLog(@"An error occured fetching the user's tracked food. In your app, try to handle this gracefully. The error was: %@.", error);
            NSAssert(NO, nil);
        }
        

        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSMutableArray *aryData=[[NSMutableArray alloc] init];
            for(NSInteger i=0;i<results.count;i++)
            {
                HKQuantitySample *sample=[results objectAtIndex:i];
                
                // 一步60cm 一步消耗0.04kcal 一步一秒
                double stepCount=[sample.quantity doubleValueForUnit:[HKUnit countUnit]];
                double journey=stepCount*70/100;
                double calorie=stepCount*0.04*1000;
                
                
                NSString *startTime=[PublicModule getTimeNow:@"" withDate:sample.startDate];
                NSString *endTime=[PublicModule getTimeNow:@"" withDate:sample.endDate];
                NSString *strStepCount=[NSString stringWithFormat:@"%.0f",stepCount];
                NSString *strJourney=[NSString stringWithFormat:@"%.0f",journey];
                NSString *strCalorie=[NSString stringWithFormat:@"%.0f",calorie];
                
                NSArray *ary=[[NSArray alloc] initWithObjects:strStepCount,strCalorie,strJourney,startTime,endTime, nil];
                [aryData addObject:ary];
                
                [self saveStepWithData:ary];
                
            }
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GNotiUpdateView object:nil];
            
            [self uploadStepToService];
            [SVProgressHUD dismiss];
            
        });
    }];
    
    [_healthStore executeQuery:sampleQuery];
}

-(void)saveStepWithData:(NSArray *)ary
{
    
    NSMutableDictionary *dicStep=[[NSMutableDictionary alloc] init];
    
    NSString *step=[ary objectAtIndex:0];
    NSString *calorie=[ary objectAtIndex:1];
    NSString *journey=[ary objectAtIndex:2];
    NSString *starttime=[ary objectAtIndex:3];
    NSString *endtime=[ary objectAtIndex:4];
    
    NSString *time=endtime;
    
    [dicStep setObject:step forKey:ProjectStepCount];
    [dicStep setObject:calorie forKey:ProjectStepCalorie];
    [dicStep setObject:journey forKey:ProjectStepJourney];
    [dicStep setObject:starttime forKey:ProjectStepStartTime];
    [dicStep setObject:endtime forKey:ProjectStepEndTime];
    
    NSString *userID=@"-1";
    
    NSString *memberType=[AppDelegate shareUserInfo].account_type;
    NSArray *aryData=[[NSArray alloc] initWithObjects:time,dicStep,userID,[AppDelegate shareUserInfo].account_ctime,@"0",@"0",@"0",memberType, nil];
    
    if(aryData == nil || aryData.count<6)
    {
        return;
    }
    
    
    BOOL result=[_db insertStepInfo:aryData];
    if(result)
    {
        NSLog(@"步数保存完毕");
    }
}

//上传体重数据
-(void)uploadWeightToService
{
    NSArray *aryUploadData=[_db selectAllUploadMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime];
    NSString *strJson=[_network jsonGUploadMeasureWithData:aryUploadData];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLMeasureSync] withJson:strJson];
    }
    else
    {
        [self downloadWeight];
    }
}


//上传计步数据
-(void)uploadStepToService
{
    
    NSArray *aryUploadData=[_db selectAllUploadStepDataWithCTime:[AppDelegate shareUserInfo].account_ctime];
    NSString *strJson=[_network jsonGUploadStepWithData:aryUploadData];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLMeasureSync] withJson:strJson];
    }
    else
    {
        [self downloadStep];
    }
}

//上传目标
-(void)uploadTargetToService
{
    NSArray *aryUploadData=[_db selectAllUploadTargetDataWithCTime:[AppDelegate shareUserInfo].account_ctime];
    NSString *strJson=[_network jsonGUploadTargetWithData:aryUploadData];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLTargetSync] withJson:strJson];
    }
    else
    {
        [self downloadTarget];
    }
}

-(void)downloadTarget
{
    NSString *strJson=[_network jsonGDownloadTargetWithTime:_downloadtimeTarget];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLTargetSync] withJson:strJson];
    }
}

-(void)downloadTargetCallback:(NSString *)opcode
{
    NSString *strJson=[_network jsonGFinishDownloadTargetWithOPCode:opcode];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLTargetSync] withJson:strJson];
    }
}

-(void)downloadWeight
{
    NSString *strJson=[_network jsonGDownloadMeasureWithTime:_downloadtimeWeight];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLMeasureSync] withJson:strJson];
    }
}

-(void)downloadWeightCallback:(NSString *)opcode
{
    NSString *strJson=[_network jsonGFinishDownloadMeasureWithOPCode:opcode];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLMeasureSync] withJson:strJson];
    }
}

-(void)downloadStep
{
    NSString *strJson=[_network jsonGDownloadStepWithTime:_downloadtimeStep];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLMeasureSync] withJson:strJson];
    }
}

-(void)downloadStepCallback:(NSString *)opcode
{
    NSString *strJson=[_network jsonGFinishDownloadStepWithOPCode:opcode];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLMeasureSync] withJson:strJson];
    }
}

-(void)uploadUserInfoToService:(NSArray *)aryInfo
{
    if(aryInfo == nil || aryInfo.count<3)
    {
        return;
    }
    
    NSString *strJson=[_network jsonGEditProfile:aryInfo];
    if(strJson)
    {
        [self doRequestWithURL:[NSURL URLWithString:GURLUser] withJson:strJson];
    }
}

- (void)refreshLocation
{
    if([CLLocationManager locationServicesEnabled])
    {
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorized ||
           [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedAlways ||
           [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
        {
            if(locationManager == nil)
            {
                locationManager = [[CLLocationManager alloc] init];
                
                if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
                {
                    //[locationManager requestAlwaysAuthorization];
                    [locationManager requestWhenInUseAuthorization];
                }
                
            
                locationManager.delegate = self;
                locationManager.distanceFilter = 100;
                locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            }
            [locationManager startUpdatingLocation];
        }
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *loc = [locations firstObject];
    
    checkinLocation=loc;

    [AppDelegate shareUserInfo].location_latitude=[NSString stringWithFormat:@"%f",loc.coordinate.latitude];
    [AppDelegate shareUserInfo].location_longitude=[NSString stringWithFormat:@"%f",loc.coordinate.longitude];
    
    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    [revGeo reverseGeocodeLocation:loc
                 completionHandler:^(NSArray *placemarks, NSError *error) {
                     if (!error && [placemarks count] > 0)
                     {
                         NSDictionary *dict =[[placemarks objectAtIndex:0] addressDictionary];
                         NSString *strCity=[dict objectForKey:@"City"];
                         NSString *strProvince=[dict valueForKey:@"State"];
                         NSString *strCountry=[dict valueForKey:@"Country"];
                         NSString *strAddress=[dict valueForKey:@"Name"];
                         [AppDelegate shareUserInfo].location_country=strCountry;
                         [AppDelegate shareUserInfo].location_province=strProvince;
                         [AppDelegate shareUserInfo].location_city=strCity;
                         [AppDelegate shareUserInfo].location_address=strAddress;
                         
                         /*
                          NSDictionary *dict =[[placemarks objectAtIndex:0] addressDictionary];
                          
                          NSString *strStreet=[dict objectForKey:@"Street"];
                          NSString *strCity=[dict objectForKey:@"City"];
                          NSString *strCountry=[dict objectForKey:@"Country"];
                          
                          
                          
                          [self.tableview reloadData];
                          NSString *strCountryCode=[dict objectForKey:@"CountryCode"];
                          NSString *strFormattedAddressLines=[dict objectForKey:@"FormattedAddressLines"];
                          NSString *strName=[dict objectForKey:@"Name"];
                          NSString *strState=[dict objectForKey:@"State"];
                          NSString *strSubLocality=[dict objectForKey:@"SubLocality"];
                          
                          NSLog(@"%@,%@,%@,%@,%@,%@,%@,%@",strStreet,strCity,strCountry,strCountryCode,strFormattedAddressLines,strName,strState,strSubLocality);
                          */
                     }
                     
                     else
                     {
                         NSLog(@"ERROR: %@", error); }
                 }];
    
}

//创建图片目录
-(BOOL)createImgeDir
{
    //日记图片目录
    NSString *imageDir = [NSString stringWithFormat:@"%@/Documents/Image/DiaryImage/", NSHomeDirectory()];
    
    BOOL isDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL existed = [fileManager fileExistsAtPath:imageDir isDirectory:&isDir];
    
    if ( !(isDir == YES && existed == YES) )
        
    {
        
        [fileManager createDirectoryAtPath:imageDir withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    //用户图片目录
    NSString *iconDir = [NSString stringWithFormat:@"%@/Documents/Image/UserImage/", NSHomeDirectory()];
    
    
    BOOL isIconDir=NO;
    BOOL existed2 = [fileManager fileExistsAtPath:iconDir isDirectory:&isIconDir];
    
    if ( !(isIconDir == YES && existed2 == YES) )
        
    {
        [fileManager createDirectoryAtPath:iconDir withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    

    NSString *babyDir = [NSString stringWithFormat:@"%@/Documents/videos/", NSHomeDirectory()];
    
    
    BOOL isBabyDir=NO;
    BOOL existed3 = [fileManager fileExistsAtPath:babyDir isDirectory:&isBabyDir];
    
    if ( !(isBabyDir == YES && existed3 == YES) )
        
    {
        [fileManager createDirectoryAtPath:babyDir withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    NSString *squareDir=[NSString stringWithFormat:@"%@/Documents/Image/SquareImage/",NSHomeDirectory()];
    BOOL isSquareDir=NO;
    BOOL existed4=[fileManager fileExistsAtPath:squareDir isDirectory:&isSquareDir];
    if(!(isSquareDir == YES && existed4 == YES))
    {
        [fileManager createDirectoryAtPath:squareDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return YES;
}

#pragma mark 设置体重单位
- (void)setWeightDefaultUnit {
    
    NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
    if (weightUnit) {
        return;
    }
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    
    @try {
        if ([preferredLang containsString:@"en"]) {
            [[NSUserDefaults standardUserDefaults] setObject:@"lb" forKey:@"weight_unit"];
        } else {
            [[NSUserDefaults standardUserDefaults] setObject:@"kg" forKey:@"weight_unit"];
        }
    } @catch (NSException *exception) {
        [[CrashReporter sharedInstance] reportException:exception message:@"errror"];
    } @finally {
        [[NSUserDefaults standardUserDefaults] setObject:@"kg" forKey:@"weight_unit"];
    }
    
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"当前语言:%@", preferredLang);
}

#pragma mark 设置APPID
-(void)setUUID
{
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *uuid=[ud objectForKey:@"app_id"];
    NSString *appver=[ud objectForKey:@"app_ver"];
    
    [ud setObject:self.AppVersion forKey:@"app_ver"];
    if(uuid==nil||[uuid isEqualToString:@""] || appver == nil || [appver isEqualToString:@""])
    {
        NSString *identifierForVendor=[[NSUUID UUID] UUIDString];
        //NSString *identifierForVendor = [[UIDevice currentDevice].identifierForVendor UUIDString];
        [ud setObject:identifierForVendor forKey:@"app_id"];
        [ud setObject:self.AppVersion forKey:@"app_ver"];
        [ud synchronize];
    }
    //NSString *uuid2=[ud objectForKey:@"app_id"];
    //NSLog(@"uuid2:%@",uuid2);
}

-(void)clearLoginStatus
{
    [_ud removeObjectForKey:@"u_name"];
    [_ud removeObjectForKey:@"u_pwd"];
    [_ud removeObjectForKey:@"u_id"];
    [_ud removeObjectForKey:@"u_type"];
    [_ud removeObjectForKey:@"u_session"];
    [_ud removeObjectForKey:@"c_time"];
    [_ud synchronize];
}


-(void)gotoLogin
{
    self.isLoginView=YES;
    
    if(!self.isLoginView)
    {
        [self clearLoginStatus];
        
       
    }
    
    return;
    
    [WCAlertView showAlertWithTitle:@"" message:@"登陆失效，请重新登陆" customizationBlock:^(WCAlertView *alertView) {
        alertView.style = WCAlertViewStyleWhiteHatched;
        
    } completionBlock:^(NSUInteger buttonIndex, WCAlertView *alertView)
     {
         if (buttonIndex == 0)
         {
            
              
        }
              
     } cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
}



-(BOOL)updateUserInfo:(NSDictionary *)dic withData:(NSArray *)aryInfo
{
    BOOL ret=NO;
    if(dic == nil ||dic.count<7 || aryInfo == nil || aryInfo.count<6)
    {
        return ret;
    }
    
    NSString *account=[aryInfo objectAtIndex:0];
    NSString *accountType=[aryInfo objectAtIndex:1];
    NSString *pwd=[aryInfo objectAtIndex:2];
    NSString *address=[aryInfo objectAtIndex:3];
    NSString *lati=[aryInfo objectAtIndex:4];
    NSString *longi=[aryInfo objectAtIndex:5];
    
    NSString *session=[dic valueForKey:@"session"];
    NSDictionary *dicTemp=[dic valueForKey:@"data"];
    if(session == nil || dicTemp == nil || dicTemp.count<7)
    {
        return ret;
    }
    
    NSString *city=[dicTemp valueForKey:@"city"];
    NSString *country=[dicTemp valueForKey:@"country"];
    NSString *doing=[dicTemp valueForKey:@"doing"];
    NSDictionary *dicHeadphoto=[dicTemp valueForKey:@"headphoto_url"];
    NSString *headphoto_url=@"";
    if(dicHeadphoto && [dicHeadphoto isKindOfClass:[NSDictionary class]] && dicHeadphoto.count>=2)
    {
        headphoto_url=[dicHeadphoto valueForKey:@"big_picture"];
    }
    NSString *introduce=[dicTemp valueForKey:@"introduce"];
    introduce=[PublicModule base64DecodeWithString:introduce];
    NSString *nickname=[dicTemp valueForKey:@"nickname"];
    nickname=[PublicModule base64DecodeWithString:nickname];
    NSString *province=[dicTemp valueForKey:@"province"];
    NSString *sex=[dicTemp valueForKey:@"sex"];
    NSString *u_id=[dicTemp valueForKey:@"u_id"];
    NSString *issetPwd=[dicTemp valueForKey:@"isset_pwd"];
    NSString *ownness=[dicTemp valueForKey:@"ownness"];
    
    NSArray *arySave=[[NSArray alloc] initWithObjects:u_id,
                      session,
                      headphoto_url,
                      sex,
                      nickname,
                      country,
                      province,
                      city,
                      doing,
                      introduce,
                      account,
                      pwd,
                      accountType,
                      address,
                      lati,
                      longi,
                      ownness, nil];
    
    ret=[_db updateAccountFromService:arySave];
    if(ret)
    {
        [_ud setObject:u_id forKey:@"u_id"];
        [_ud setObject:session forKey:@"u_session"];
        [_ud setObject:account forKey:@"u_name"];
        [_ud setObject:pwd forKey:@"u_pwd"];
        [_ud setObject:accountType forKey:@"u_type"];
        [_ud synchronize];
        
        NSString *uidTemp=[AppDelegate shareUserInfo].uid;
        
        [self setUserInfo];
        [AppDelegate shareUserInfo].isPwdSet = issetPwd;
        [AppDelegate shareUserInfo].ownness = ownness;
        
        if(![uidTemp isEqualToString:u_id])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotiUpdateUserInfo object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:NotiUpdateData object:nil];
        }
    }
    
    
    return ret;
}

//设置全局用户数据
- (void)setUserInfo
{
    NSString *ctime=[_ud valueForKey:@"c_time"];
    NSMutableArray *ary=[_db selectAccountWithCTime:ctime];
    if(ary && ary.count>=1)
    {
        NSArray *aryData=[ary objectAtIndex:0];
        if(aryData && aryData.count>17)
        {
            [AppDelegate shareUserInfo].account=[aryData objectAtIndex:0];
            [AppDelegate shareUserInfo].account_pwd=[aryData objectAtIndex:1];
            [AppDelegate shareUserInfo].uid=[aryData objectAtIndex:2];
            [AppDelegate shareUserInfo].account_session=[aryData objectAtIndex:3];
            [AppDelegate shareUserInfo].localIconURL=[aryData objectAtIndex:4];
            [AppDelegate shareUserInfo].remoteIconURL=[aryData objectAtIndex:5];
            [AppDelegate shareUserInfo].sex=[aryData objectAtIndex:6];
            [AppDelegate shareUserInfo].nickname=[aryData objectAtIndex:7];
            [AppDelegate shareUserInfo].country=[aryData objectAtIndex:8];
            [AppDelegate shareUserInfo].province=[aryData objectAtIndex:9];
            [AppDelegate shareUserInfo].city=[aryData objectAtIndex:10];
            [AppDelegate shareUserInfo].address=[aryData objectAtIndex:11];
            [AppDelegate shareUserInfo].latitude=[aryData objectAtIndex:12];
            [AppDelegate shareUserInfo].longitude=[aryData objectAtIndex:13];
            [AppDelegate shareUserInfo].account_type=[aryData objectAtIndex:14];
            [AppDelegate shareUserInfo].account_ctime=[aryData objectAtIndex:15];
            [AppDelegate shareUserInfo].account_dnum=[aryData objectAtIndex:16];
            [AppDelegate shareUserInfo].introduce=[aryData objectAtIndex:17];
            [AppDelegate shareUserInfo].ownness=[aryData objectAtIndex:18];
            [AppDelegate shareUserInfo].userAge=[aryData objectAtIndex:19];
            [AppDelegate shareUserInfo].userHeight=[aryData objectAtIndex:20];
            [AppDelegate shareUserInfo].userWC=[aryData objectAtIndex:21];;
            [AppDelegate shareUserInfo].userHC=[aryData objectAtIndex:22];;
            
            NSString *imagePath=[NSString stringWithFormat:@"Image/UserImage/%@.png",[aryData objectAtIndex:15]];
            NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imagePath];
            [AppDelegate shareUserInfo].localIconURL=fullPath;
            
            self.userLoginName=[aryData objectAtIndex:0];
            [_ud setObject:[AppDelegate shareUserInfo].account_ctime forKey:@"c_time"];
            [_ud setObject:[AppDelegate shareUserInfo].account forKey:@"u_name"];
            [_ud setObject:[AppDelegate shareUserInfo].account_pwd forKey:@"u_pwd"];
            [_ud setObject:[AppDelegate shareUserInfo].account_type forKey:@"u_type"];
            [_ud setObject:[AppDelegate shareUserInfo].account_dnum forKey:@"u_doingnum"];
            
            NSString *uid=[_ud valueForKey:@"u_id"];
            if(uid.length>=1 && ![uid isEqualToString:@"-1"])
            {
                [_ud setObject:[AppDelegate shareUserInfo].uid forKey:@"u_id"];
            }
            else
            {
                [AppDelegate shareUserInfo].uid=@"";
            }
            
            [_ud synchronize];
            
            [AppDelegate shareUserInfo].targetWeight=@"0.0";
            [AppDelegate shareUserInfo].targetStep=@"0";
            
            NSArray *aryTargetWeight=[_db selectTargetWithCTime:[AppDelegate shareUserInfo].account_ctime andType:@"1"];
            NSArray *aryTargetStep=[_db selectTargetWithCTime:[AppDelegate shareUserInfo].account_ctime andType:@"2"];
            if(aryTargetWeight && aryTargetWeight.count>=1)
            {
                NSArray *ary=[aryTargetWeight objectAtIndex:0];
                if(ary && ary.count>=2)
                {
                    NSString *targetValue=[ary objectAtIndex:2];
                    [AppDelegate shareUserInfo].targetWeight=targetValue;
                }
            }
            
            if(aryTargetStep && aryTargetStep.count>=1)
            {
                NSArray *ary=[aryTargetStep objectAtIndex:0];
                if(ary && ary.count>=2)
                {
                    NSString *targetValue=[ary objectAtIndex:2];
                    [AppDelegate shareUserInfo].targetStep=[NSString stringWithFormat:@"%d",[targetValue intValue]];
                }
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GNotiUpdateView object:nil];
            
        }
        else
        {
            [_ud removeObjectForKey:@"u_id"];
            [_ud removeObjectForKey:@"u_session"];
            [_ud removeObjectForKey:@"u_name"];
            [_ud removeObjectForKey:@"u_pwd"];
            [_ud removeObjectForKey:@"u_type"];
            [_ud removeObjectForKey:@"c_time"];
            [_ud synchronize];
            [self clearUserInfo];
        }
    }
    else
    {
        [_ud removeObjectForKey:@"u_id"];
        [_ud removeObjectForKey:@"u_session"];
        [_ud removeObjectForKey:@"u_name"];
        [_ud removeObjectForKey:@"u_pwd"];
        [_ud removeObjectForKey:@"u_type"];
        [_ud removeObjectForKey:@"c_time"];
        [_ud synchronize];
        [self clearUserInfo];
    }
    return;
}


-(BOOL)clearUserInfo
{
    [AppDelegate shareUserInfo].account=nil;
    [AppDelegate shareUserInfo].account_pwd=nil;
    [AppDelegate shareUserInfo].uid=nil;
    [AppDelegate shareUserInfo].account_session=nil;
    [AppDelegate shareUserInfo].localIconURL=nil;
    [AppDelegate shareUserInfo].remoteIconURL=nil;
    [AppDelegate shareUserInfo].sex=nil;
    [AppDelegate shareUserInfo].nickname=nil;
    [AppDelegate shareUserInfo].country=nil;
    [AppDelegate shareUserInfo].province=nil;
    [AppDelegate shareUserInfo].city=nil;
    [AppDelegate shareUserInfo].address=nil;
    [AppDelegate shareUserInfo].latitude=nil;
    [AppDelegate shareUserInfo].longitude=nil;
    [AppDelegate shareUserInfo].account_type=nil;
    [AppDelegate shareUserInfo].account_ctime=nil;
    [AppDelegate shareUserInfo].account_dnum=nil;
    [AppDelegate shareUserInfo].introduce=nil;
    
    return YES;
}



//2013-12-11
-(void)Share_API
{
    /*
     微信：
     AppID：wx4be484ebf8a57acb
     AppSecret：8a600001a5b0990839325be25c5fa171
     
     
     QQ：
     AppID：1104434481
     AppSecret：pvebiLzUWsnHXEDl
     */
    
    [ShareSDK importWeChatClass:[WXApi class]];   //导入微信需要的外部库类型
    [ShareSDK importQQClass:[QQApiInterface class]
            tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK registerApp:@"b32321bf16f0"];   //注册sharesdk的appkey
    
    
    //qq
    [ShareSDK connectQQWithQZoneAppKey:@"1104434481" qqApiInterfaceCls:[QQApiInterface class] tencentOAuthCls:[TencentOAuth class]];
    
    //qq空间
    [ShareSDK connectQZoneWithAppKey:@"1104434481" appSecret:@"pvebiLzUWsnHXEDl" qqApiInterfaceCls:[QQApiInterface class] tencentOAuthCls:[TencentOAuth class]];
    

    
    //微信分享
    [ShareSDK connectWeChatWithAppId:@"wx4be484ebf8a57acb" wechatCls:[WXApi class]];
    [ShareSDK connectWeChatWithAppId:@"wx4be484ebf8a57acb" appSecret:@"8a600001a5b0990839325be25c5fa171" wechatCls:[WXApi class]];
    id<ISSQZoneApp> qzoneApp=(id<ISSQZoneApp>)[ShareSDK getClientWithType:ShareTypeQQSpace];
    [qzoneApp setIsAllowWebAuthorize:YES];

}


//2015-10-16 SSO授权
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    //return YES;
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}

//2015-10-16 SSO授权
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                     sourceApplication:sourceApplication
                     annotation:annotation
                     wxDelegate:self];
}


-(void)processLocalNotications:(NSDictionary *)dictionary
{
    
}

//处理远程推送消息
-(void)processRemoteNotifications:(NSDictionary *)dictionary
{
   
    
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    application.applicationIconBadgeNumber--;
}



-(void)processLocalnoticationNumber
{
    NSInteger iconNumber=[UIApplication sharedApplication].applicationIconBadgeNumber;
    if(iconNumber>=1)
    {
        iconNumber=iconNumber-1;
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber=iconNumber;
}

//处理推送的图标
- (void)processNotivicationNumber
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
   
}


- (void)applicationWillTerminate:(UIApplication *)application
{
   
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NotiKeyboardHidden object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self startScan];
    if(self.isThirdLogin)
    {
        self.isThirdLogin=NO;
        return;
    }
}

#pragma mark 蓝牙专用.......
-(void)initBleManager
{
    if(manager == nil)
    {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
}

-(void)initBluetoothVar
{
    if(devicesList == nil)
    {
        devicesList = [[NSMutableArray alloc] init];
    }
    if(_connectedPeripheralList == nil)
    {
        _connectedPeripheralList = [[NSMutableArray alloc] init];
    }
    
    _transServiceUUID = nil;
    _transTxUUID = nil;
    _transRxUUID = nil;
    
    aryHex=[[NSArray alloc] initWithObjects:@"0000",@"0001",@"0010",@"0011",@"0100",@"0101",@"0110",@"0111",@"1000",@"1001",@"1010",@"1011",@"1100",@"1101",@"1110",@"1111",nil];
    
    self.connectionStatus=LE_STATUS_IDLE;
    
    if([connectedDeviceInfo count] == 0)
    {
        [self configureTransparentServiceUUID:nil txUUID:nil rxUUID:nil];
    }
}

//开始扫描外设
- (void)startScan
{
    if(manager == nil)
    {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }

    if([manager state] == CBCentralManagerStatePoweredOff)
    {
        //manager=nil;
        //manager=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    NSMutableDictionary *op=[[NSMutableDictionary alloc] init];
    [op setObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [op setObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnNotificationKey];
    [manager scanForPeripheralsWithServices:nil options:op];
    
    [devicesList removeAllObjects];
    
    if ([connectingList count] > 0)
    {
        for (int i=0; i< [connectingList count]; i++)
        {
            MyPeripheral *connectingPeripheral = [connectingList objectAtIndex:i];
            if (connectingPeripheral.connectStaus == MYPERIPHERAL_CONNECT_STATUS_CONNECTING)
            {
                [devicesList addObject:connectingPeripheral];
            }
            else
            {
                [connectingList removeObjectAtIndex:i];
            }
        }
    }
    self.connectionStatus=LE_STATUS_SCANNING;
}

//停止扫描
- (void) stopScan
{
    NSLog(@"停止搜索蓝牙设备");
    [manager stopScan];
}

-(void)restartScan
{
    if(manager)
    {
        [manager stopScan];
        [self startScan];
    }
}

//发现外设
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *name=[advertisementData valueForKey:CBAdvertisementDataLocalNameKey];
    if ([name isEqualToString:@"YunChen"] ||
        [name isEqualToString:@"LANEIGE"]) {
        if (self.MyCurrentDevice == DeviceTypeWeight) {
            return;
        }
        
        [self addDiscoverPeripheral:aPeripheral advName:[advertisementData valueForKey:CBAdvertisementDataLocalNameKey]];
    }
}

-(void)processTJLData:(NSString *)data
{
    data=[data stringByReplacingOccurrencesOfString:@"<" withString:@""];
    data=[data stringByReplacingOccurrencesOfString:@">" withString:@""];
    data=[data stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(data.length == 24)
    {
        NSString *str1=[data substringWithRange:NSMakeRange(14, 1)];
        str1=[self stringToFourHex:str1];
        NSString *str2=[data substringWithRange:NSMakeRange(16, 1)];
        str2=[self stringToFourHex:str2];
        NSString *str3=[data substringWithRange:NSMakeRange(18, 1)];
        str3=[self stringToFourHex:str3];
        NSString *str4=[data substringWithRange:NSMakeRange(20, 1)];
        str4=[self stringToFourHex:str4];
        
        NSString *str5=[data substringWithRange:NSMakeRange(15, 1)];
        str5=[self stringToFourHex:str5];
        NSString *str6=[data substringWithRange:NSMakeRange(17, 1)];
        str6=[self stringToFourHex:str6];
        NSString *str7=[data substringWithRange:NSMakeRange(19, 1)];
        str7=[self stringToFourHex:str7];
        NSString *str8=[data substringWithRange:NSMakeRange(21, 1)];
        str8=[self stringToFourHex:str8];
        
        NSString *state=[data substringWithRange:NSMakeRange(8, 2)];
        
        NSString *str10=[data substringWithRange:NSMakeRange(10, 1)];
        str10=[self stringToFourHex:str10];
        NSString *str11=[data substringWithRange:NSMakeRange(11, 1)];
        str11=[self stringToFourHex:str11];
        NSString *str12=[data substringWithRange:NSMakeRange(12, 1)];
        str12=[self stringToFourHex:str12];
        NSString *str13=[data substringWithRange:NSMakeRange(13, 1)];
        str13=[self stringToFourHex:str13];
        
        
        double dData1=[self calculateMeasureData:str1];
        double dData2=[self calculateMeasureData:str2];
        double dData3=[self calculateMeasureData:str3];
        double dData4=[self calculateMeasureData:str4];
        double dData5=[self calculateMeasureData:str5];
        double dData6=[self calculateMeasureData:str6];
        double dData7=[self calculateMeasureData:str7];
        double dData8=[self calculateMeasureData:str8];
        
        dData1=dData1+dData5;
        dData2=dData2+dData6;
        dData3=dData3+dData7;
        dData4=dData4+dData8;
        
        if([state isEqualToString:@"02"])
        {
            NSString *weight=[NSString stringWithFormat:@"%@%@%@%@",str10,str11,str12,str13];
            
            double dWeight=[self calculateMeasureData:weight];
            
            NSLog(@"过程:%.1f",dWeight/10);
            
            NSString *showWeight=[NSString stringWithFormat:@"%.1f",dWeight/10];
            if(dWeight<=0)
            {
                return;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setLemonWeight" object:showWeight];
        }
        else if([state isEqualToString:@"03"])
        {
            NSString *weight=[NSString stringWithFormat:@"%@%@%@%@",str10,str11,str12,str13];
            
            double dWeight=[self calculateMeasureData:weight];
            
            NSLog(@"结果%.1f",dWeight/10);
            
            NSString *showWeight=[NSString stringWithFormat:@"%.1f",dWeight/10];
            if(dWeight<=0)
            {
                return;
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setLemonWeightResult" object:showWeight];
        }
    }
}

-(void)processLemonData:(NSString *)data
{
    NSLog(@"%@",data);
    data=[data stringByReplacingOccurrencesOfString:@"<" withString:@""];
    data=[data stringByReplacingOccurrencesOfString:@">" withString:@""];
    data=[data stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if(data.length == 22)
    {
        NSString *str1=[data substringWithRange:NSMakeRange(14, 1)];
        str1=[self stringToFourHex:str1];
        NSString *str2=[data substringWithRange:NSMakeRange(16, 1)];
        str2=[self stringToFourHex:str2];
        NSString *str3=[data substringWithRange:NSMakeRange(18, 1)];
        str3=[self stringToFourHex:str3];
        NSString *str4=[data substringWithRange:NSMakeRange(20, 1)];
        str4=[self stringToFourHex:str4];
        
        NSString *str5=[data substringWithRange:NSMakeRange(15, 1)];
        str5=[self stringToFourHex:str5];
        NSString *str6=[data substringWithRange:NSMakeRange(17, 1)];
        str6=[self stringToFourHex:str6];
        NSString *str7=[data substringWithRange:NSMakeRange(19, 1)];
        str7=[self stringToFourHex:str7];
        NSString *str8=[data substringWithRange:NSMakeRange(21, 1)];
        str8=[self stringToFourHex:str8];
        
        
        double dData1=[self calculateMeasureData:str1];
        double dData2=[self calculateMeasureData:str2];
        double dData3=[self calculateMeasureData:str3];
        double dData4=[self calculateMeasureData:str4];
        double dData5=[self calculateMeasureData:str5];
        double dData6=[self calculateMeasureData:str6];
        double dData7=[self calculateMeasureData:str7];
        double dData8=[self calculateMeasureData:str8];
        
        dData1=dData1+dData5;
        dData2=dData2+dData6;
        dData3=dData3+dData7;
        dData4=dData4+dData8;
        
        
        if(dData1 == 15 && dData2 == 15 && dData3 == 15 && dData4 == 15)
        {
            NSString *weight=[NSString stringWithFormat:@"%@%@%@%@",str1,str2,str3,str4];
            double dWeight=[self calculateMeasureData:weight];
            
            NSLog(@"%.2f",dWeight/10);
            
            NSString *showWeight=[NSString stringWithFormat:@"%.2f",dWeight/10];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setLemonWeight" object:showWeight];
        }
    }
}

-(NSString *)stringToFourHex:(NSString *)num
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
    
    return strRet;
}

-(void)receiceTJLData:(NSData *)data
{
    [self processTJLReceiveData:data];
}

-(void)receiveNewData:(NSData *)data
{
    [self processNewReceiveData:data];
}

-(void)receiveData:(NSData *)data
{
    [self processReceiveData:data];
}

//连接外设
- (void)connectDevice:(MyPeripheral *) myPeripheral
{
    if (myPeripheral.connectStaus != MYPERIPHERAL_CONNECT_STATUS_IDLE)
        return;
    [manager connectPeripheral:myPeripheral.peripheral options:nil];
}

-(void)connectMyDevice
{
    if(controlDevice != nil)
    {
        if (controlPeripheral.connectStaus != MYPERIPHERAL_CONNECT_STATUS_IDLE)
            return;
        [manager connectPeripheral:controlDevice options:nil];
    }
}

//断开外设
- (void)disconnectDevice: (MyPeripheral *)myPeripheral
{
    [manager cancelPeripheralConnection: myPeripheral.peripheral];
}

-(void)disconnectMydevice
{
    if(controlDevice != nil)
    {
        [manager cancelPeripheralConnection:controlDevice];
    }
}



//失去连接
- (void)updateMyPeripheralForDisconnect:(MyPeripheral *)myPeripheral
{
    if (myPeripheral == controlPeripheral)
    {
        NSLog(@"蓝牙断开连接");
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
            NSLog(@"updateMyPeripheralForDisconnect3 %@, %@", tmpPeripheral.advName, myPeripheral.advName);
        }
        
    }
    
    [self startScan];
    self.MyCurrentDevice=DeviceTypeNone;
}

//新连接
- (void)updateMyPeripheralForNewConnected:(MyPeripheral *)myPeripheral
{
    DeviceInfo *tmpDeviceInfo = [[DeviceInfo alloc]init];
    tmpDeviceInfo.mainViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    tmpDeviceInfo.mainViewController.connectedPeripheral = myPeripheral;
    tmpDeviceInfo.myPeripheral = myPeripheral;
    tmpDeviceInfo.myPeripheral.connectStaus = myPeripheral.connectStaus;
    controlDevice=myPeripheral.peripheral;
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
        //NSLog(@"Connected List Filter!");
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
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"setBleStatus" object:@"已成功连接"];
}

- (void)updateDiscoverPeripherals
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
    if (myPeripheral == nil) {
        myPeripheral = [[MyPeripheral alloc] init];
        myPeripheral.peripheral = aPeripheral;
        myPeripheral.advName = advName;
        [devicesList addObject:myPeripheral];
    }
    
    [self updateDiscoverPeripherals];
    if ([advName isEqualToString:@"YunChen"] || [advName isEqualToString:@"LANEIGE"]) {
        [self connectDevice:myPeripheral];
    }
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
        _transTxUUID = [CBUUID UUIDWithString:txUUID];
        _transRxUUID = [CBUUID UUIDWithString:rxUUID];
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
    BOOL bResult;
    switch ([manager state])
    {
            //不支持LBE
        case CBCentralManagerStateUnsupported:
            state = @"本设备不支持BLE";
            bResult=FALSE;
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"此App无法授权使用BLE";
            bResult=FALSE;
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"蓝牙已关闭";
            bResult=FALSE;
            [self stopScan];
            return bResult;
            break;
        case CBCentralManagerStatePoweredOn:
            state=@"蓝牙已打开";
            //[self startScan];
            //[self startScan];
            bResult=TRUE;
            return bResult;
            break;
        case CBCentralManagerStateUnknown:
        default:
            bResult=FALSE;
            break;
            
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth alert"  message:state delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alertView show];
    return bResult;
}

//更新蓝牙状态
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    [self isLECapableHardware];
}


- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    if([peripherals count] >=1)
    {
        [self connectDevice:[peripherals objectAtIndex:0]];
    }
}

//连接外设回调函数
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setBleStatus" object:@"已成功连接"];
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
    [aPeripheral discoverServices:nil];
}

//断开外设回调函数
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    [self startScan];
    [self removeMyPeripheral:aPeripheral];
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    [self removeMyPeripheral:aPeripheral];
}


//发现服务
-   (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    if(error)
    {
        return;
    }
    for (CBService *aService in aPeripheral.services)
    {
        [aPeripheral discoverCharacteristics:nil forService:aService];
    }
}

-(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

//发现特征
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    CBCharacteristic *aChar = nil;
    MyPeripheral *myPeripheral = [self retrieveMyPeripheral:aPeripheral];
    if (myPeripheral == nil)
    {
        return;
    }
    
    if ([service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_GuoSERVICE]])
    {
        isISSCPeripheral = TRUE;
        for (aChar in service.characteristics)
        {
            if ((_transServiceUUID == nil) && [aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_GuoReadNotify]])
            {
                [aPeripheral setNotifyValue:TRUE forCharacteristic:aChar];
            }
            else if ((_transServiceUUID == nil) && [aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_GuoWriteNotify]])
            {
                [aPeripheral setNotifyValue:TRUE forCharacteristic:aChar];
            }
            else if ([aChar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_GuoWriteWithoutNotify]])
            {
                [aPeripheral setNotifyValue:TRUE forCharacteristic:aChar];
            }
        }
    }
    
    isISSCPeripheral = TRUE;
    if (isISSCPeripheral == TRUE)
    {
        [self updateMyPeripheralForNewConnected:myPeripheral];
    }
}

//接收蓝牙外设数据
- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    MyPeripheral *myPeripheral = [self retrieveMyPeripheral:aPeripheral];
    if (myPeripheral == nil)
    {
        return;
    }

    //Guo数据
    if ([characteristic.service.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_GuoSERVICE]])
    {
        //接收数据
        if ((_transServiceUUID == nil) && [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_GuoReadNotify]])
        {
            NSString *str1 = [NSString stringWithFormat:@"%@",characteristic.value];
            str1=[str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
         
            [self processGuoReceiveData:characteristic.value];
            [self sendDataToGuoWithPeripheral:aPeripheral andChar:characteristic];
            
        }
        else if((_transServiceUUID == nil) && [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_GuoWriteNotify]])
        {
            NSString *str1 = [NSString stringWithFormat:@"%@",characteristic.value];
            str1=[str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        else if((_transServiceUUID == nil) && [characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_GuoWriteWithoutNotify]])
        {
            NSString *str1 = [NSString stringWithFormat:@"%@",characteristic.value];
            str1=[str1 stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
}


- (NSString *)pinxCreator:(NSString *)pan withPinv:(NSString *)pinv
{
    if (pan.length != pinv.length)
    {
        return nil;
    }
    
    NSString *temp = [[NSString alloc] init];
    
    unsigned long iPan = strtoul([pan  UTF8String],0,16);
    unsigned long iPin = strtoul([pinv  UTF8String],0,16);
    
    temp= [temp stringByAppendingString:[NSString stringWithFormat:@"%lX",iPan^iPin]];

    if (temp.length != 2) {
        temp = [@"0" stringByAppendingString:temp];
    }
    
    return temp;
}

- (int)charToint:(char)tempChar
{
    if (tempChar >= '0' && tempChar <='9')
    {
        return tempChar - '0';
    }
    else if (tempChar >= 'A' && tempChar <= 'F')
    {
        return tempChar - 'A' + 10;
    }
    else if (tempChar >='a' && tempChar <= 'f')
    {
        return tempChar -'A'+10;
    }
    
    return 0;
}

-(void)sendDataToGuoWithPeripheral:(CBPeripheral *)aPeripheral andChar:(CBCharacteristic *)achar
{
    NSString *sex=@"00";
    if ([[AppDelegate shareUserInfo].sex isEqualToString:@"女"]) {
        sex=@"01";
    }
    
    NSString *age=[AppDelegate shareUserInfo].userAge;
    int iage=[age intValue];
    NSString *height=[AppDelegate shareUserInfo].userHeight;
    int iHeight=[height intValue];
    height=[NSString stringWithFormat:@"%d",iHeight];
    
    NSString *hexHeightString =[NSString stringWithFormat:@"%X",iHeight];
    if(hexHeightString.length==1)
    {
        hexHeightString=[@"0" stringByAppendingString:hexHeightString];
    }
    NSString *hexageString =[NSString stringWithFormat:@"%X",iage];
    if(hexageString.length==1)
    {
        hexageString=[@"0" stringByAppendingString:hexageString];
    }
    NSString *hexWCString=[NSString stringWithFormat:@"%X",80];
    if(hexWCString.length==1)
    {
        hexWCString=[@"0" stringByAppendingString:hexWCString];
    }
    NSString *hexHCString=[NSString stringWithFormat:@"%X",90];
    if(hexHCString.length==1)
    {
        hexHCString=[@"0" stringByAppendingString:hexHCString];
    }
    
    NSString *strEnd=[self pinxCreator:@"A5" withPinv:sex];
    strEnd=[self pinxCreator:strEnd withPinv:hexageString];
    strEnd=[self pinxCreator:strEnd withPinv:hexHeightString];
    strEnd=[self pinxCreator:strEnd withPinv:hexWCString];
    strEnd=[self pinxCreator:strEnd withPinv:hexHCString];
    
    //用户号 性别 年龄 身高
    //NSString *strData=@"83010122a0";
    NSString *strStart=@"A5";
    NSString *strData=[NSString stringWithFormat:@"%@%@%@%@%@%@%@",strStart,sex,hexageString,hexHeightString,hexWCString,hexHCString,strEnd];
    NSData *data=[self stringToByte:strData];
    
    
    
    for(int i=0;i<achar.service.characteristics.count;i++)
    {
        CBCharacteristic *aachar=[achar.service.characteristics objectAtIndex:i];
        if ([aachar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_GuoWriteNotify]] ||
            [aachar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_GuoWriteWithoutNotify]])
        {
            if(data == nil)
            {
                return;
                
                NSString *strData=@"A50019AF505A19";
                data=[self stringToByte:strData];
            }

            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithoutResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithoutResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithoutResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithoutResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithoutResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithoutResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithoutResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithoutResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithoutResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithoutResponse];
            
            
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
        }
    }
}

//发送脂肪指令给TJL的脂肪秤
-(void)sendDataToTJLWithPeripheral:(CBPeripheral *)aPeripheral andChar:(CBCharacteristic *)achar
{
    NSString *sex=@"00";
    if([[AppDelegate shareUserInfo].sex isEqualToString:@"男"])
    {
        sex=@"01";
    }
    
    NSString *age=[AppDelegate shareUserInfo].userAge;
    int iage=[age intValue];
    NSString *height=[AppDelegate shareUserInfo].userHeight;
    int iHeight=[height intValue];
    height=[NSString stringWithFormat:@"%d",iHeight];
    
    NSString *hexHeightString =[NSString stringWithFormat:@"%x",iHeight];
    NSString *hexageString =[NSString stringWithFormat:@"%x",iage];
    
    //用户号 性别 年龄 身高
    //NSString *strData=@"83010122a0";
    NSString *userNum=@"01";
    NSString *strData=[NSString stringWithFormat:@"83%@%@%@%@",userNum,sex,hexageString,hexHeightString];
    NSData *data=[self stringToByte:strData];
    
    for(int i=0;i<achar.service.characteristics.count;i++)
    {
        CBCharacteristic *aachar=[achar.service.characteristics objectAtIndex:i];
        if ([aachar.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_TJLWriteNotify]])
        {
            if(data == nil)
            {
                NSString *strData=@"83010122a0";
                data=[self stringToByte:strData];
            }
            [aPeripheral writeValue:data forCharacteristic:aachar type:CBCharacteristicWriteWithResponse];
        }
    }
}

//16进制数字转化为2进制数字
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
    return strRet;
}



-(void)processGuoReceiveData:(NSData *)data
{
    
    NSString *strData=[NSString stringWithFormat:@"%@",data];
    strData=[strData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    strData=[strData stringByReplacingOccurrencesOfString:@">" withString:@""];
    strData=[strData stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *deviceType=[strData substringWithRange:NSMakeRange(0, 2)];
    NSString *scaleState=[strData substringWithRange:NSMakeRange(2, 2)];
    //设备型号 0 2
    //状态 2 2
    //体重 4 4   /100
    //脂肪含量 8 4  /10
    //水分含量 16 4  /10
    //肌肉 20 4  /10
    //骨骼重量 24 4  /10
    //基础代谢 28 4
    //内脏脂肪 32 2
    //身体年龄 34 2
    //身高 36 2
    //检验 38 2
    
    if ([scaleState isEqualToString:@"00"] && strData.length >= 38) {
        NSString *weight=[strData substringWithRange:NSMakeRange(4, 4)];
        unsigned long iWeight = strtoul([weight  UTF8String],0,16);
        
        weight=[NSString stringWithFormat:@"%.2f",iWeight/100.0];
        if ([weight containsString:@".00"]) {
            weight=[NSString stringWithFormat:@"%.1f",iWeight/100.0];
        }
        
        if([weight floatValue]<0.0 || [weight floatValue]>380.0)
        {
            return;
        }
        
        CGFloat fHeight=[[AppDelegate shareUserInfo].userHeight floatValue]/100;
        CGFloat fBmi=[weight floatValue]/(fHeight*fHeight);
        NSString *bmi=[NSString stringWithFormat:@"%.1f",fBmi];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:weight forKey:ProjectWeight];
        [dic setObject:bmi forKey:ProjectBMI];
        
        //NSLog(strData);
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiGuoFatScale object:nil userInfo:dic];
    } else if ([scaleState isEqualToString:@"01"] && strData.length >= 38) {
        //设备型号 0 2
        //状态 2 2
        //体重4 4   /100
        //脂肪含量 8 4  /10
        //水分含量 16 4  /10
        //肌肉 20 4  /10
        //骨骼重量 24 4  /10
        //基础代谢 28 4
        //内脏脂肪 32 2
        //身体年龄 34 2
        //身高 36 2
        //检验 38 2
        
        //NSLog(@"稳定数据:%@",strData);
        NSString *weight=[strData substringWithRange:NSMakeRange(4, 4)];
        unsigned long iWeight = strtoul([weight  UTF8String],0,16);
        
        weight=[NSString stringWithFormat:@"%.2f",iWeight/100.0];
        if ([weight containsString:@".00"]) {
            weight=[NSString stringWithFormat:@"%.1f",iWeight/100.0];
        }
        
        
        NSString *fat=[strData substringWithRange:NSMakeRange(8, 4)];
        unsigned long iFat = strtoul([fat  UTF8String],0,16);
        
        fat=[NSString stringWithFormat:@"%.1f",iFat/10.0];
        
        if([weight floatValue]<=0.0 || [weight floatValue]>380.0)
        {
            return;
        }
        
        
        //肌肉率
        NSString *muscle=[strData substringWithRange:NSMakeRange(20, 4)];
        unsigned long iMuscle = strtoul([muscle  UTF8String],0,16);
        
        muscle=[NSString stringWithFormat:@"%.1f",iMuscle/10.0];
        
        
        //水分
        NSString *water=[strData substringWithRange:NSMakeRange(16, 4)];
        unsigned long iWater = strtoul([water  UTF8String],0,16);
        
        water=[NSString stringWithFormat:@"%.1f",iWater/10.0];
        
        //基础代谢
        NSString *basic=[strData substringWithRange:NSMakeRange(28, 4)];
        unsigned long iBasic = strtoul([basic  UTF8String],0,16);
        
        basic=[NSString stringWithFormat:@"%ld",iBasic];
        
        //内脏脂肪
        NSString *viscera=[strData substringWithRange:NSMakeRange(32, 2)];
        unsigned long iViscera = strtoul([viscera  UTF8String],0,16);
        CGFloat fVisceralfat=iViscera/10.0;
        fVisceralfat=ceilf(fVisceralfat);
        viscera=[NSString stringWithFormat:@"%.0f",fVisceralfat];
        
        //骨量
        NSString *bone=[strData substringWithRange:NSMakeRange(24, 4)];
        unsigned long iBone = strtoul([bone  UTF8String],0,16);
        
        bone=[NSString stringWithFormat:@"%.1f",iBone/10.0];
        
        //身体年龄
        NSString *bodyage=[strData substringWithRange:NSMakeRange(34, 2)];
        unsigned long iBodyage = strtoul([bodyage  UTF8String],0,16);
 
        if (iBodyage <= 0) {
            if ([[AppDelegate shareUserInfo].sex isEqualToString:@"男"]) {
                float fBodyage = [weight floatValue] / [[AppDelegate shareUserInfo].userHeight intValue] / [[AppDelegate shareUserInfo].userHeight intValue] / 10000 * [[[AppDelegate shareUserInfo] userAge] intValue] / 23.0;
                bodyage = [NSString stringWithFormat:@"%.0f",roundf(fBodyage)];
                iBodyage = [bodyage intValue];
            } else {
                float fBodyage = [weight floatValue] / [[AppDelegate shareUserInfo].userHeight intValue] / [[AppDelegate shareUserInfo].userHeight intValue] / 10000 * [[[AppDelegate shareUserInfo] userAge] intValue] / 21.5;
                bodyage = [NSString stringWithFormat:@"%.0f",roundf(fBodyage)];
                iBodyage = [bodyage intValue];
            }
        }
        
        if (iBodyage <= 0) {
            iBodyage = 1;
        }
        
        bodyage=[NSString stringWithFormat:@"%ld",iBodyage];
        
        //身高
        NSString *height=[strData substringWithRange:NSMakeRange(36, 2)];
        unsigned long iHeight = strtoul([height  UTF8String],0,16);
        height=[NSString stringWithFormat:@"%ld",iHeight];
        
        //bmi
        CGFloat fHeight=[[AppDelegate shareUserInfo].userHeight floatValue]/100;
        CGFloat fBmi=[weight floatValue]/(fHeight*fHeight);
        NSString *bmi=[NSString stringWithFormat:@"%.1f",fBmi];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:weight forKey:ProjectWeight];
        [dic setObject:fat forKey:ProjectFat];
        [dic setObject:water forKey:ProjectWater];
        [dic setObject:basic forKey:ProjectBasic];
        [dic setObject:muscle forKey:ProjectMuscle];
        [dic setObject:viscera forKey:ProjectVisceralFat];
        [dic setObject:bone forKey:ProjectBone];
        [dic setObject:bmi forKey:ProjectBMI];
        [dic setObject:deviceType forKey:ProjectDevice];
        [dic setObject:bodyage forKey:ProjectBodyAge];
        [dic setObject:height forKey:ProjectHeight];
        
        NSLog(@"%@",dic);
        
        if(iFat<=0)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotiGuoWeightScaleResult object:nil userInfo:dic];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotiGuoFatScaleResult object:nil userInfo:dic];
        }
        
        [self startScan];
    }
}



-(void)processTJLReceiveData:(NSData *)data
{
    NSString *strData=[NSString stringWithFormat:@"%@",data];
    strData=[strData stringByReplacingOccurrencesOfString:@"<" withString:@""];
    strData=[strData stringByReplacingOccurrencesOfString:@">" withString:@""];
    strData=[strData stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *weightState=[strData substringWithRange:NSMakeRange(0, 2)];
    if([weightState isEqualToString:@"01"] && strData.length >= 6)
    {
        NSString *weightHeight=[strData substringWithRange:NSMakeRange(2, 2)];
        NSString *weightLow=[strData substringWithRange:NSMakeRange(4, 2)];
        NSString *weight=[weightLow stringByAppendingString:weightHeight];
        weight=[self stringToFourHex:weight];
        double dWeight=[self calculateMeasureData:weight];
        dWeight=dWeight/10;
        weight=[NSString stringWithFormat:@"%.1f",dWeight];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:weight forKey:ProjectWeight];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiGuoFatScale object:nil userInfo:dic];
    }
    else if ([weightState isEqualToString:@"02"] && strData.length>=28)
    {
        //体重3-6
        //秤工作状态 7-8
        //脂肪含量 9-12
        //水分含量 13-16
        //肌肉 17-20
        //基础代谢 21-24
        //骨骼重量 25-26
        //内脏脂肪 27-30
        
        NSLog(strData);
        //体重 3-6
        NSString *weightHigh=[strData substringWithRange:NSMakeRange(2, 2)];
        NSString *weightLow=[strData substringWithRange:NSMakeRange(4, 2)];
        NSString *weight=[weightLow stringByAppendingString:weightHigh];
        weight=[self stringToFourHex:weight];
        double dWeight=[self calculateMeasureData:weight];
        dWeight=dWeight/10;
        weight=[NSString stringWithFormat:@"%.1f",dWeight];
        
        //工作状态 7-8
        NSString *fatState=[strData substringWithRange:NSMakeRange(6, 2)];
        
        //脂肪含量 9-12
        NSString *fatHigh=[strData substringWithRange:NSMakeRange(8, 2)];
        NSString *fatLow=[strData substringWithRange:NSMakeRange(10, 2)];
        NSString *fat=[fatLow stringByAppendingString:fatHigh];
        fat=[self stringToFourHex:fat];
        double dFat=[self calculateMeasureData:fat];
        dFat=dFat/10;
        fat=[NSString stringWithFormat:@"%.1f",dFat];
        
        //水分含量 13-16
        NSString *waterHigh=[strData substringWithRange:NSMakeRange(12, 2)];
        NSString *waterLow=[strData substringWithRange:NSMakeRange(14, 2)];
        NSString *water=[waterLow stringByAppendingString:waterHigh];
        water=[self stringToFourHex:water];
        double dwater=[self calculateMeasureData:water];
        dwater=dwater/10;
        water=[NSString stringWithFormat:@"%.1f",dwater];
        
        //肌肉 17-20
        NSString *muscleHigh=[strData substringWithRange:NSMakeRange(16, 2)];
        NSString *muscleLow=[strData substringWithRange:NSMakeRange(18, 2)];
        NSString *muscle=[muscleLow stringByAppendingString:muscleHigh];
        muscle=[self stringToFourHex:muscle];
        double dmuscle=[self calculateMeasureData:muscle];
        dmuscle=dmuscle/10;
        muscle=[NSString stringWithFormat:@"%.1f",dmuscle];
        
        //基础代谢 21-24
        NSString *basicHigh=[strData substringWithRange:NSMakeRange(20, 2)];
        NSString *basicLow=[strData substringWithRange:NSMakeRange(22, 2)];
        NSString *basic=[basicLow stringByAppendingString:basicHigh];
        basic=[self stringToFourHex:basic];
        double dbasic=[self calculateMeasureData:basic];
        //dbasic=dbasic/10;
        basic=[NSString stringWithFormat:@"%.0f",dbasic];
        
        //骨骼重量 25-26
        NSString *boneHigh=[strData substringWithRange:NSMakeRange(24, 2)];
        NSString *boneLow=[strData substringWithRange:NSMakeRange(26, 2)];
        NSString *bone=[boneLow stringByAppendingString:boneHigh];
        bone=[self stringToFourHex:bone];
        double dbone=[self calculateMeasureData:bone];
        dbone=dbone/10;
        bone=[NSString stringWithFormat:@"%.1f",dbone];
        
        //内脏脂肪 27-30
        NSString *visceraHigh=[strData substringWithRange:NSMakeRange(26, 2)];
        NSString *visceraLow=[strData substringWithRange:NSMakeRange(28, 2)];
        NSString *viscera=[visceraLow stringByAppendingString:visceraHigh];
        viscera=[self stringToFourHex:viscera];
        double dviscera=[self calculateMeasureData:viscera];
        dviscera=dviscera/10;
        viscera=[NSString stringWithFormat:@"%.1f",dviscera];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:weight forKey:ProjectWeight];
        [dic setObject:fat forKey:ProjectFat];
        [dic setObject:water forKey:ProjectWater];
        [dic setObject:basic forKey:ProjectBasic];
        [dic setObject:muscle forKey:ProjectMuscle];
        [dic setObject:viscera forKey:ProjectVisceralFat];
        [dic setObject:bone forKey:ProjectBone];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiGuoFatScaleResult object:nil userInfo:dic];
    }
    
}

//处理蓝牙接受的数据
- (void)processNewReceiveData:(NSData *)data
{
    Byte *testBytes=(Byte *)[data bytes];
    NSMutableArray *tempAry=[[NSMutableArray alloc] init];
    NSString *strStatus=@"";
    if([data length]<6)
    {
        return;
    }
    for(int i=0;i<[data length];i++)
    {
        NSString *hexStr=[NSString stringWithFormat:@"%x",testBytes[i]];
        if(i ==0)
        {
            strStatus=hexStr;
        }
        NSString *temp=[self stringToHexadecimal:hexStr];
        [tempAry addObject:temp];
    }
    
    if(tempAry.count<2)
    {
        return;
    }
    NSString *weight=[NSString stringWithFormat:@"%@%@",tempAry[1],tempAry[2]];
    double dWeight=[self calculateMeasureData:weight];
    //2014-03-18
    NSString *showWeight=[NSString stringWithFormat:@"%.2f",dWeight/100];
    
    
    if([strStatus isEqualToString:@"ce"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMeasureResult" object:showWeight];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setWeight" object:showWeight];
    }
    
}

//处理蓝牙接受的数据
- (void) processReceiveData:(NSData *)data
{
    Byte *testBytes=(Byte *)[data bytes];
    NSMutableArray *tempAry=[[NSMutableArray alloc] init];
    NSString *strStatus=@"";
    for(int i=0;i<[data length];i++)
    {
        NSString *hexStr=[NSString stringWithFormat:@"%x",testBytes[i]];
        if(i ==7)
        {
            strStatus=hexStr;
        }
        NSString *temp=[self stringToHexadecimal:hexStr];
        [tempAry addObject:temp];
    }
    
    if(tempAry.count<9)
    {
        return;
    }
    
    NSString *weight=[NSString stringWithFormat:@"%@%@",tempAry[8],tempAry[9]];
    double dWeight=[self calculateMeasureData:weight];
    NSString *showWeight=[NSString stringWithFormat:@"%.1f",dWeight/10];
    
    /*
     NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
     [ud setObject:showWeight forKey:@"weight"];
     */
    if([strStatus isEqualToString:@"ce"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showMeasureResult" object:showWeight];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setWeight" object:showWeight];
    }
    
}

//将2进制字符串转化为10进制数字
-(double)calculateMeasureData:(NSString *)strData
{
    if([strData length]==0) return -1;
    double iRet=0;
    double dTemp;
    NSInteger dataLength=[strData length];
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
    //NSLog(@"[CBController] didWriteValueForCharacteristic error msg:%d, %@, %@", error.code ,[error localizedFailureReason], [error localizedDescription]);
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
    else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTR_TJLWriteNotify]])
    {
        
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //NSLog(@"[CBController] didDiscoverDescriptorsForCharacteristic error msg:%d, %@, %@", error.code ,[error localizedFailureReason], [error localizedDescription]);
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    //NSLog(@"[CBController] didUpdateValueForDescriptor");
}

//特征值更新回调函数
-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
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

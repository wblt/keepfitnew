#import "GStepController.h"
#import <HealthKit/HealthKit.h>
#import "MDRadialProgressView.h"
#import "MDRadialProgressLabel.h"
#import "MDRadialProgressTheme.h"


@interface GStepController ()<LCActionSheetDelegate>
{
    MDRadialProgressView *_radialViewBottom;
    MDRadialProgressView *_radialViewFront;
    
    NSMutableArray *_aryProjectData;
    
    HKHealthStore *_healthStore;
    
    NSMutableDictionary *_dicStep;
    
}


@end

@implementation GStepController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _isFirstShow=NO;
    _targetStep=@"0";
    
    _isUpdateStep = NO;
    [self initView];
    
    self.lblTimeTitle.text=NSLocalizedString(@"step_time", nil);
    self.lblKMTitle.text=NSLocalizedString(@"step_km", nil);
    self.lblTopTitle.text=NSLocalizedString(@"title_step", nil);

    self.lblStepTitle.text=NSLocalizedString(@"step_todaystep", nil);
    
    //self.lblTargetStep.text=[NSString stringWithFormat:@"目标:%@",_targetStep];
    self.lblTargetStep.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"step_target", nil),_targetStep];
    
    if([_targetStep isEqualToString:@"0"] || _targetStep == nil || _targetStep.length<1)
    {
        //self.lblTargetStep.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"step_target", nil),NSLocalizedString(@"target_set", nil)];
        
        NSString *fullTargetText=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"step_target", nil),NSLocalizedString(@"target_set", nil)];
        NSString *targetText=[NSString stringWithFormat:@"%@",NSLocalizedString(@"target_set", nil)];
        
        NSRange rangeTargetWeight=[fullTargetText rangeOfString:targetText];
        NSMutableAttributedString *aStrTarget=[[NSMutableAttributedString alloc] initWithString:fullTargetText];
        [aStrTarget addAttribute:NSForegroundColorAttributeName
                           value:UIColorFromRGB(0xe9a000)
                           range:rangeTargetWeight];
        
        self.lblTargetStep.attributedText=aStrTarget;
    }
    
    _db=[[DbModel alloc] init];
    _jsonModule=[[NetworkModule alloc] init];

    _delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

    NSArray *aryTarget=[_db selectTargetWithCTime:[AppDelegate shareUserInfo].account_ctime andType:@"2"];
    if(aryTarget && aryTarget.count>=1)
    {
        NSArray *ary=[aryTarget objectAtIndex:0];
        if(ary && ary.count>=2)
        {
            NSString *targetValue=[ary objectAtIndex:2];
            _targetStep=targetValue;
            _targetStep=[NSString stringWithFormat:@"%d",[_targetStep intValue]];
            //self.lblTargetStep.text=[NSString stringWithFormat:@"目标:%@",_targetStep];
            self.lblTargetStep.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"step_target", nil),_targetStep];
            
            NSString *fullTargetText=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"step_target", nil),_targetStep];
            NSString *targetText=[NSString stringWithFormat:@"%@",_targetStep];
            
            NSRange rangeTargetWeight=[fullTargetText rangeOfString:targetText];
            NSMutableAttributedString *aStrTarget=[[NSMutableAttributedString alloc] initWithString:fullTargetText];
            [aStrTarget addAttribute:NSForegroundColorAttributeName
                               value:UIColorFromRGB(0xe9a000)
                               range:rangeTargetWeight];
            
            self.lblTargetStep.attributedText=aStrTarget;
            
            [AppDelegate shareUserInfo].targetStep=_targetStep;
        }
    }
    
    isSelfController=YES;

    [self.view insertSubview:self.viewNotiStatus belowSubview:self.viewTop];
    
    
    [self refreshChartData];
    [_delegate startMotionDetection];
    
    
    if([HKHealthStore isHealthDataAvailable])
    {
        _healthStore=[[HKHealthStore alloc] init];
        //NSSet *writeDataTypes=[self dataTypesToWrite];
        NSSet *readDataTypes=[self dataTypesToRead];
        
        [_healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            
            if (!success)
            {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                return;
            }
            
            //NSTimer *timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(showDialog) userInfo:nil repeats:NO];
            
            NSString *key=[[AppDelegate shareUserInfo].account_ctime stringByAppendingString:@"_switch"];
            [[NSUserDefaults standardUserDefaults] setObject:DTrue forKey:key];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD showWithStatus:NSLocalizedString(@"同步中", nil)];
                
            });
            
            //[SVProgressHUD show];
            if(!_isUpdateStep)
            {
                [self readHealthkitData];
            }
            
        }];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTargetStep:) name:NotiAddTargetStep object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiAddStep:) name:NotiAddStep object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChartData) name:GNotiUpdateView object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshChartData) name:GNotiRefreshView object:nil];
    
}

-(void)showDialog
{
    [SVProgressHUD show];
}

-(void)updateHealthKitData
{
    if([HKHealthStore isHealthDataAvailable])
    {
        _healthStore=[[HKHealthStore alloc] init];
        //NSSet *writeDataTypes=[self dataTypesToWrite];
        NSSet *readDataTypes=[self dataTypesToRead];
        
        [_healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            
            if (!success)
            {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                return;
            }
            
            
            //[SVProgressHUD show];
            
            NSString *key=[[AppDelegate shareUserInfo].account_ctime stringByAppendingString:@"_switch"];
            [[NSUserDefaults standardUserDefaults] setObject:DTrue forKey:key];
            
            [_delegate updateHealthKitData];
            //[self readHealthkitData];
        }];
    }
}

-(void)updateAppleHealth
{
    if(!_isFirstShow)
    {
        return;
    }
    
    //[self refreshChartData];
    if([HKHealthStore isHealthDataAvailable])
    {
        _healthStore=[[HKHealthStore alloc] init];
        //NSSet *writeDataTypes=[self dataTypesToWrite];
        NSSet *readDataTypes=[self dataTypesToRead];
        
        [_healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            
            if (!success)
            {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                return;
            }
            
            NSString *key=[[AppDelegate shareUserInfo].account_ctime stringByAppendingString:@"_switch"];
            [[NSUserDefaults standardUserDefaults] setObject:DTrue forKey:key];
            
            [self updateHealthkitValue];
        }];
    }
}

-(void)notiAddStep:(NSNotification *)noti
{
    if(_delegate.isM7Device)
    {
        [self updateAppleHealth];
        return;
    }
    
    NSDictionary *dic=noti.userInfo;
    if(dic == nil || dic.count<1)
    {
        return;
    }
    
    
    NSString *strStep=[dic valueForKey:ProjectStepCount];
    
    int iAllStep=[self.lblStep.text intValue];
    iAllStep=iAllStep+[strStep intValue];
    CGFloat fkm=iAllStep*0.7/1000;
    int kcal=iAllStep*0.04;
    int iMinute=iAllStep/60;
    
    _radialViewFront.progressTotal = [_targetStep intValue]*4;
    _radialViewFront.progressCounter = 1*3;
    _radialViewFront.progressCounter = iAllStep*3;
    
    
    self.lblStep.text=[NSString stringWithFormat:@"%d",iAllStep];
    
    self.lblKM.text=[NSString stringWithFormat:@"%.1f",fkm];
    self.lblKcal.text=[NSString stringWithFormat:@"%d",kcal];
    self.lblTime.text=[NSString stringWithFormat:@"%d",iMinute];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:GNotiRefreshMineView object:nil];
    });
    
}

-(void)updateTargetStep:(NSNotification *)noti
{
    NSDictionary *dic=noti.userInfo;
    if(dic)
    {
        NSString *target=[dic valueForKey:@"target_step"];
        if(target)
        {
            //self.lblTargetStep.text=[NSString stringWithFormat:@"目标:%@",target];
            self.lblTargetStep.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"step_target", nil),target];
            _targetStep=target;
            
            NSString *fullTargetText=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"step_target", nil),_targetStep];
            NSString *targetText=[NSString stringWithFormat:@"%@",_targetStep];
            
            NSRange rangeTargetWeight=[fullTargetText rangeOfString:targetText];
            NSMutableAttributedString *aStrTarget=[[NSMutableAttributedString alloc] initWithString:fullTargetText];
            [aStrTarget addAttribute:NSForegroundColorAttributeName
                               value:UIColorFromRGB(0xe9a000)
                               range:rangeTargetWeight];
            
            self.lblTargetStep.attributedText=aStrTarget;
            
            [AppDelegate shareUserInfo].targetStep=_targetStep;
            [self refreshChartData];
            
            [_delegate uploadTargetToService];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:GNotiUpdateView object:nil];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:GNotiRefreshMineView object:nil];
            });
            
        }
    }
}

-(void)updateHealthkitValue
{
    if(_isUpdateStep)
    {
        return;
    }
    
    _isUpdateStep = YES;
    
    
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            
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
                
                
            }
            
            for(NSInteger i=0;i<aryData.count;i++)
            {
                NSArray *ary=[aryData objectAtIndex:i];
                [self saveStepWithData:ary];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _isUpdateStep = NO;
                
                [SVProgressHUD dismiss];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:GNotiRefreshMineView object:nil];
            });
            
        });
        
        
    }];
    
    [_healthStore executeQuery:sampleQuery];
}

-(void)readHealthkitData
{
    
    if(_isUpdateStep)
    {
        return;
    }
    
    _isUpdateStep = YES;
    
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            _isUpdateStep = YES;
            
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
                
                
            }
            
            for(NSInteger i=0;i<aryData.count;i++)
            {
                NSArray *ary=[aryData objectAtIndex:i];
                [self saveStepWithData:ary];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self refreshChartData];
                _isUpdateStep = NO;
                [SVProgressHUD dismiss];
                
            });
            
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

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    HKQuantityType *dietaryCalorieEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChloride];
    HKQuantityType *activeEnergyBurnType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    return [NSSet setWithObjects:dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead
{
    //HKQuantityType *dietaryCalorieEnergyType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryChloride];
    //HKQuantityType *activeEnergyBurnType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    //HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    //HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    //HKCharacteristicType *birthdayType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    
    return [NSSet setWithObjects:stepType, nil];
}


-(void)notiKeyboard
{
    isSelfController=YES;
}

- (BOOL)fd_prefersNavigationBarHidden { return YES;
    
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isSelfController=YES;
    if([[UIDevice currentDevice] systemVersion].floatValue>=7.0)
    {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    _isFirstShow=YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    isSelfController=NO;
    
    self.navigationController.navigationBarHidden=NO;

}


-(void)initView
{
    
    self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone5FontSizeTitle];
    if(is_iPhone6P)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6PFontSizeTitle];
    }
    else if(is_iPhone6)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6FontSizeTitle];
    }
    
    //126  210
    
    
    self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, TABBAR_HEIGHT);

    self.viewTop.frame=CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT);
    
    self.viewTop.backgroundColor=NavColor;
    self.view.backgroundColor=CommonBgColor;
    self.lblTopTitle.frame=CGRectMake(0, 20, SCREEN_WIDTH, 44);
    
    //self.viewTop.layer.shadowOffset=CGSizeMake(0, 1);
    //self.viewTop.layer.shadowOpacity=0.08;

    self.imageLine.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, 1);
    self.scrollView.frame=CGRectMake(0, NAVBAR_HEIGHT+1, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-1-TABBAR_HEIGHT);
    
    
    CGFloat widthTemp=SCREEN_WIDTH/3;
    self.lblKMTitle.frame=CGRectMake(0, 35, widthTemp, 30);
    self.lblTimeTitle.frame=CGRectMake(widthTemp, 35, widthTemp, 30);
    self.lblKCalTitle.frame=CGRectMake(widthTemp*2, 35, widthTemp, 30);
    
    self.lblKM.frame=CGRectMake(0, self.lblKMTitle.frame.origin.y+self.lblKMTitle.frame.size.height+5, widthTemp, 30);
    self.lblTime.frame=CGRectMake(widthTemp, self.lblKM.frame.origin.y, widthTemp, 30);
    self.lblKcal.frame=CGRectMake(widthTemp*2, self.lblKM.frame.origin.y, widthTemp, 30);
    
    
    CGRect frame = CGRectMake((SCREEN_WIDTH-0.65625*SCREEN_WIDTH)/2, self.lblKcal.frame.origin.y+self.lblKcal.frame.size.height+50, 0.65625*SCREEN_WIDTH, 0.65625*SCREEN_WIDTH);
    
    
    _radialViewFront = [[MDRadialProgressView alloc] initWithFrame:frame];
    
    _radialViewBottom = [[MDRadialProgressView alloc] initWithFrame:frame];
    
    _radialViewBottom.progressTotal = 4;
    _radialViewBottom.progressCounter = 3;
    _radialViewBottom.theme.thickness = 14;
    _radialViewBottom.theme.incompletedColor = [UIColor clearColor];
    _radialViewBottom.theme.completedColor = UIColorFromRGB(0xd1d1d1);
    _radialViewBottom.theme.sliceDividerHidden = YES;
    _radialViewBottom.label.hidden = YES;
    CGAffineTransform at =CGAffineTransformMakeRotation(225*M_PI/180.0);
    
    [_radialViewBottom setTransform:at];
    [self.scrollView addSubview:_radialViewBottom];
    
    
    _radialViewFront.progressTotal = 5000*4;
    _radialViewFront.progressCounter = 3000*3;
    _radialViewFront.theme.thickness = 14;
    _radialViewFront.theme.incompletedColor = [UIColor clearColor];
    _radialViewFront.theme.completedColor = UIColorFromRGB(0x00af00);
    _radialViewFront.theme.sliceDividerHidden = YES;
    _radialViewFront.label.hidden = YES;
    
    CGAffineTransform atT =CGAffineTransformMakeRotation(225*M_PI/180.0);
    
    [_radialViewFront setTransform:atT];
    
    [self.scrollView addSubview:_radialViewFront];
    
    self.lblStepTitle.frame=CGRectMake(frame.origin.x, frame.origin.y+25, frame.size.width, self.lblStep.frame.size.height);
    
    self.lblStep.frame=CGRectMake(frame.origin.x, frame.origin.y+frame.size.height/3, frame.size.width, self.lblStep.frame.size.height);
    self.lblTargetStep.frame=CGRectMake(frame.origin.x, self.lblStep.frame.origin.y+self.lblStep.frame.size.height+20, frame.size.width, self.lblTargetStep.frame.size.height);
    

    //38 0.11875
    self.viewChart.frame=CGRectMake(0, frame.origin.y+frame.size.height+20, SCREEN_WIDTH, 0.4375*SCREEN_WIDTH);
    self.imageChartLine1.frame=CGRectMake(20, 0.11875*SCREEN_WIDTH, SCREEN_WIDTH-20-20, 1);
    self.imageChartLine2.frame=CGRectMake(20, 0.11875*SCREEN_WIDTH*2, SCREEN_WIDTH-20-20, 1);
    self.viewChartLineBottom.frame=CGRectMake(20, 0.11875*SCREEN_WIDTH*3, SCREEN_WIDTH-20-20, 2);
    
    self.lblChartHigh.frame=CGRectMake(20, self.imageChartLine1.frame.origin.y+self.imageChartLine1.frame.size.height, CGRectGetWidth(self.lblChartHigh.frame), CGRectGetHeight(self.lblChartHigh.frame));
    
    self.lblChartLow.frame=CGRectMake(20, self.imageChartLine2.frame.origin.y+self.imageChartLine2.frame.size.height, CGRectGetWidth(self.lblChartLow.frame), CGRectGetHeight(self.lblChartLow.frame));
    
    
    CGFloat chartTimeWidth=0.2*SCREEN_WIDTH;
    CGFloat chartTimeX=self.viewChartLineBottom.frame.origin.x+self.viewChartLineBottom.frame.size.width;
    
    self.lblChartTime4.frame=CGRectMake(chartTimeX-chartTimeWidth, self.viewChartLineBottom.frame.origin.y+self.viewChartLineBottom.frame.size.height+5, chartTimeWidth, 14);
    self.lblChartTime3.frame=CGRectMake(chartTimeX-chartTimeWidth*2, self.viewChartLineBottom.frame.origin.y+self.viewChartLineBottom.frame.size.height+5, chartTimeWidth, 14);
    self.lblChartTime2.frame=CGRectMake(chartTimeX-chartTimeWidth*3, self.viewChartLineBottom.frame.origin.y+self.viewChartLineBottom.frame.size.height+5, chartTimeWidth, 14);
    self.lblChartTime1.frame=CGRectMake(chartTimeX-chartTimeWidth*4, self.viewChartLineBottom.frame.origin.y+self.viewChartLineBottom.frame.size.height+5, chartTimeWidth, 14);
    
    
    CGFloat chartLineDataHeight=self.viewChartLineBottom.frame.origin.y-self.imageChartLine1.frame.origin.y-self.imageChartLine1.frame.size.height;
    CGFloat chartLineYOrgin=self.imageChartLine1.frame.origin.y+self.imageChartLine1.frame.size.height;
    CGFloat chartLineWidth=3;
    
    
    int iPercent=arc4random()%10;
    CGFloat fPercent=iPercent/10;
    
    self.imageLineData24.frame=CGRectMake(self.lblChartTime4.frame.origin.x+chartTimeWidth/2-chartLineWidth/2, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData18.frame=CGRectMake(self.lblChartTime3.frame.origin.x+chartTimeWidth/2-chartLineWidth/2, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData12.frame=CGRectMake(self.lblChartTime2.frame.origin.x+chartTimeWidth/2-chartLineWidth/2, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData6.frame=CGRectMake(self.lblChartTime1.frame.origin.x+chartTimeWidth/2-chartLineWidth/2, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    
    
    self.imageLineData1.hidden=YES;
    self.imageLineData2.hidden=YES;
    self.imageLineData3.hidden=YES;
    self.imageLineData4.hidden=YES;
    self.imageLineData5.hidden=YES;
    
    

    CGFloat fLineOffset=self.imageLineData12.frame.origin.x-self.imageLineData6.frame.origin.x;
    fLineOffset=(fLineOffset-self.imageLineData6.frame.size.width*6)/6;
    
     //6 7 8 9 10 11 12
    self.imageLineData7.frame=CGRectMake(self.imageLineData6.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData8.frame=CGRectMake(self.imageLineData7.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData9.frame=CGRectMake(self.imageLineData8.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData10.frame=CGRectMake(self.imageLineData9.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData11.frame=CGRectMake(self.imageLineData10.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
   
    //12 13 14 15 16 17 18
    self.imageLineData13.frame=CGRectMake(self.imageLineData12.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData14.frame=CGRectMake(self.imageLineData13.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData15.frame=CGRectMake(self.imageLineData14.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData16.frame=CGRectMake(self.imageLineData15.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData17.frame=CGRectMake(self.imageLineData16.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    
    //18 19 20 21 22 23 24
    self.imageLineData19.frame=CGRectMake(self.imageLineData18.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData20.frame=CGRectMake(self.imageLineData19.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData21.frame=CGRectMake(self.imageLineData20.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData22.frame=CGRectMake(self.imageLineData21.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.imageLineData23.frame=CGRectMake(self.imageLineData22.frame.origin.x+chartLineWidth+fLineOffset, chartLineYOrgin, chartLineWidth, chartLineDataHeight);
    
    self.scrollView.contentSize=CGSizeMake(SCREEN_WIDTH, self.viewChart.frame.origin.y+self.viewChart.frame.size.height+30);
    
}

-(void)refreshChartData
{
    NSArray *aryTarget=[_db selectTargetWithCTime:[AppDelegate shareUserInfo].account_ctime andType:@"2"];
    if(aryTarget && aryTarget.count>=1)
    {
        NSArray *ary=[aryTarget objectAtIndex:0];
        if(ary && ary.count>=2)
        {
            NSString *targetValue=[ary objectAtIndex:2];
            _targetStep=targetValue;
            _targetStep=[NSString stringWithFormat:@"%d",[_targetStep intValue]];
            //self.lblTargetStep.text=[NSString stringWithFormat:@"目标:%@",_targetStep];
            self.lblTargetStep.text=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"step_target", nil),_targetStep];
            
            NSString *fullTargetText=[NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"step_target", nil),_targetStep];
            NSString *targetText=[NSString stringWithFormat:@"%@",_targetStep];
            
            NSRange rangeTargetWeight=[fullTargetText rangeOfString:targetText];
            NSMutableAttributedString *aStrTarget=[[NSMutableAttributedString alloc] initWithString:fullTargetText];
            [aStrTarget addAttribute:NSForegroundColorAttributeName
                               value:UIColorFromRGB(0xe9a000)
                               range:rangeTargetWeight];
            
            self.lblTargetStep.attributedText=aStrTarget;
            
            [AppDelegate shareUserInfo].targetStep=_targetStep;
        }
    }
    
    
    CGFloat chartLineDataHeight=self.viewChartLineBottom.frame.origin.y-self.imageChartLine1.frame.origin.y-self.imageChartLine1.frame.size.height;
    CGFloat chartLineYOrgin=self.imageChartLine1.frame.origin.y+self.imageChartLine1.frame.size.height;
    //CGFloat chartLineWidth=3;
    
    NVDate *dateNow=[[NVDate alloc] initUsingDate:[NSDate date]];
    NSString *strDateNow=[dateNow stringValueWithFormat:@"yyyy-MM-dd"];
    NSArray *aryStep=[_db selectStepWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:[strDateNow stringByAppendingString:@" 00:00:00"] andEndDate:[strDateNow stringByAppendingString:@" 23:59:59"]];
    //NSArray *aryStep=[_db selectAllStepWithCTime:[AppDelegate shareUserInfo].account_ctime];
    if(_dicStep == nil)
    {
        _dicStep=[[NSMutableDictionary alloc] init];
    }
    else
    {
        [_dicStep removeAllObjects];
    }
    for(NSInteger i=0;i<aryStep.count;i++)
    {
        NSArray *aryTemp=[aryStep objectAtIndex:i];
        NSString *strTime=[aryTemp objectAtIndex:2];
        NSString *strStep=[aryTemp objectAtIndex:3];
        
        strTime = [strTime substringWithRange:NSMakeRange(11, 2)];
        if([_dicStep.allKeys containsObject:strTime])
        {
            NSString *stepTemp=[_dicStep valueForKey:strTime];
            stepTemp=[NSString stringWithFormat:@"%d",[stepTemp intValue]+[strStep intValue]];
            [_dicStep setObject:stepTemp forKey:strTime];
        }
        else
        {
            [_dicStep setObject:strStep forKey:strTime];
        }
    }
    
    
    
    int iPercent=arc4random()%11;
    CGFloat fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData1.frame=CGRectMake(self.imageLineData1.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData1.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData2.frame=CGRectMake(self.imageLineData2.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData2.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData3.frame=CGRectMake(self.imageLineData3.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData3.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData4.frame=CGRectMake(self.imageLineData4.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData4.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData5.frame=CGRectMake(self.imageLineData5.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData5.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData6.frame=CGRectMake(self.imageLineData6.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData6.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData7.frame=CGRectMake(self.imageLineData7.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData7.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData8.frame=CGRectMake(self.imageLineData8.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData8.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData9.frame=CGRectMake(self.imageLineData9.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData9.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData10.frame=CGRectMake(self.imageLineData10.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData10.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData11.frame=CGRectMake(self.imageLineData11.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData11.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData12.frame=CGRectMake(self.imageLineData12.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData12.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData13.frame=CGRectMake(self.imageLineData13.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData13.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData14.frame=CGRectMake(self.imageLineData14.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData14.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData15.frame=CGRectMake(self.imageLineData15.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData15.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData16.frame=CGRectMake(self.imageLineData16.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData16.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData17.frame=CGRectMake(self.imageLineData17.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData17.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData18.frame=CGRectMake(self.imageLineData18.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData18.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData19.frame=CGRectMake(self.imageLineData19.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData19.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData20.frame=CGRectMake(self.imageLineData20.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData20.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData21.frame=CGRectMake(self.imageLineData21.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData21.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData22.frame=CGRectMake(self.imageLineData22.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData22.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData23.frame=CGRectMake(self.imageLineData23.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData23.frame.size.width, chartLineDataHeight-fPercent);
    
    iPercent=arc4random()%11;
    fPercent=iPercent/10.0*chartLineDataHeight;
    self.imageLineData24.frame=CGRectMake(self.imageLineData24.frame.origin.x, chartLineYOrgin+fPercent, self.imageLineData24.frame.size.width, chartLineDataHeight-fPercent);
    
    self.imageLineData1.hidden=YES;
    self.imageLineData2.hidden=YES;
    self.imageLineData3.hidden=YES;
    self.imageLineData4.hidden=YES;
    self.imageLineData5.hidden=YES;
    self.imageLineData6.hidden=YES;
    self.imageLineData7.hidden=YES;
    self.imageLineData8.hidden=YES;
    self.imageLineData9.hidden=YES;
    self.imageLineData10.hidden=YES;
    self.imageLineData11.hidden=YES;
    self.imageLineData12.hidden=YES;
    self.imageLineData13.hidden=YES;
    self.imageLineData14.hidden=YES;
    self.imageLineData15.hidden=YES;
    self.imageLineData16.hidden=YES;
    self.imageLineData17.hidden=YES;
    self.imageLineData18.hidden=YES;
    self.imageLineData19.hidden=YES;
    self.imageLineData20.hidden=YES;
    self.imageLineData21.hidden=YES;
    self.imageLineData22.hidden=YES;
    self.imageLineData23.hidden=YES;
    self.imageLineData24.hidden=YES;
    
    
    int iAllStep=0;
    
    NSMutableArray *aryTemp=[[NSMutableArray alloc] init];
    
    
    for(NSInteger i=0;i<_dicStep.allKeys.count;i++)
    {
        NSString *strStep=[_dicStep valueForKey:[_dicStep.allKeys objectAtIndex:i]];
        iAllStep=iAllStep+[strStep intValue];
        [aryTemp addObject:strStep];
    }
    
    NSArray *aryMax=[PublicModule getMaxAndMin:aryTemp];
    
    self.lblChartHigh.text=[NSString stringWithFormat:@"%d",[[aryMax objectAtIndex:1] intValue]];
    self.lblChartLow.text=[NSString stringWithFormat:@"%d",[[aryMax objectAtIndex:1] intValue]/2];
    
    CGFloat fMaxStep=[[aryMax objectAtIndex:1] floatValue];
    for(NSInteger i=0;i<_dicStep.allKeys.count;i++)
    {
        NSString *strStep=[_dicStep valueForKey:[_dicStep.allKeys objectAtIndex:i]];
        NSString *strTime=[_dicStep.allKeys objectAtIndex:i];
        int iStep=[strStep intValue];
        int iTime=[strTime intValue];
        
        UIImageView *imageTemp=nil;
        switch (iTime)
        {
            case 0:
                imageTemp=self.imageLineData1;
                break;
            case 1:
                imageTemp=self.imageLineData2;
                break;
            case 2:
                imageTemp=self.imageLineData3;
                break;
            case 3:
                imageTemp=self.imageLineData4;
                break;
            case 4:
                imageTemp=self.imageLineData5;
                break;
            case 5:
                imageTemp=self.imageLineData6;
                break;
            case 6:
                imageTemp=self.imageLineData7;
                break;
            case 7:
                imageTemp=self.imageLineData8;
                break;
            case 8:
                imageTemp=self.imageLineData9;
                break;
            case 9:
                imageTemp=self.imageLineData10;
                break;
            case 10:
                imageTemp=self.imageLineData11;
                break;
            case 11:
                imageTemp=self.imageLineData12;
                break;
            case 12:
                imageTemp=self.imageLineData13;
                break;
            case 13:
                imageTemp=self.imageLineData14;
                break;
            case 14:
                imageTemp=self.imageLineData15;
                break;
            case 15:
                imageTemp=self.imageLineData16;
                break;
            case 16:
                imageTemp=self.imageLineData17;
                break;
            case 17:
                imageTemp=self.imageLineData18;
                break;
            case 18:
                imageTemp=self.imageLineData19;
                break;
            case 19:
                imageTemp=self.imageLineData20;
                break;
            case 20:
                imageTemp=self.imageLineData21;
                break;
            case 21:
                imageTemp=self.imageLineData22;
                break;
            case 22:
                imageTemp=self.imageLineData23;
                break;
            case 23:
                imageTemp=self.imageLineData24;
                break;
            default:
                break;
        }
        
        if(imageTemp)
        {
            fPercent=iStep/fMaxStep*chartLineDataHeight;
            imageTemp.frame=CGRectMake(imageTemp.frame.origin.x, chartLineYOrgin+(chartLineDataHeight-fPercent), imageTemp.frame.size.width,fPercent);
            imageTemp.hidden=NO;
        }
    }
    
    
    CGFloat fkm=iAllStep*0.7/1000;
    int kcal=iAllStep*0.04;
    int iMinute=iAllStep/60;
    
    int iTargetStep=[_targetStep intValue];
    

    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTarget:)];
    tap.delegate=self;
    [_radialViewFront addGestureRecognizer:tap];
    
    self.lblStep.text=[NSString stringWithFormat:@"%d",iAllStep];
    
    self.lblKM.text=[NSString stringWithFormat:@"%.1f",fkm];
    self.lblKcal.text=[NSString stringWithFormat:@"%d",kcal];
    self.lblTime.text=[NSString stringWithFormat:@"%d",iMinute];
    
   
    if(iAllStep>iTargetStep)
    {
        iAllStep=iTargetStep;
    }
    if(iTargetStep<0)
    {
        iTargetStep=0;
    }
    
    _radialViewFront.progressTotal = iTargetStep*4;
    _radialViewFront.progressCounter = 1*3;
    _radialViewFront.progressCounter = iAllStep*3;
}

-(void)tapTarget:(UITapGestureRecognizer *)tap
{
    [_delegate.tabController showTargetStepPicker:YES withTarget:_targetStep];
}

-(void)refreshGoBack
{
    isSelfController=YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UIResponder
//能否更改FirstResponder,一般视图默认为NO,必须重写为YES
- (BOOL)canBecomeFirstResponder
{
    return YES;
}


//哪些菜单能够显示
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(menuItem:) || action == @selector(menuItem2:))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}


- (void)showDeleteInfo:(NSString *)info
{
    LCActionSheet *sheet = [[LCActionSheet alloc] initWithTitle:nil
                                                   buttonTitles:@[@"删除"]
                                                 redButtonIndex:0
                                                       delegate:self];
    [sheet show];
}


-(void)actionSheet:(LCActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)buttonIndex
{
    //删除
    if(buttonIndex == 0)
    {
        
    }
    else
    {
        return;
    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView.tag == 22)
    {
        
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}


#pragma mark - 网络请求成功
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
        
    }
    else
    {
        NSLog(@"%@",responseString);
        self.view.userInteractionEnabled=YES;
    }
}

#pragma mark - 网络请求失败
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [SVProgressHUD dismiss];
    self.view.userInteractionEnabled=YES;
    NSString *text = NSLocalizedString(@"auth_network_no", nil);
    [self showWithText:text andHideAfter:3.0f];
}

- (IBAction)testUpdate:(id)sender {
}
@end

#import "GMeasureController.h"
#import "MDRadialProgressView.h"
#import "MDRadialProgressLabel.h"
#import "MDRadialProgressTheme.h"
#import "GMeasureCell.h"
#import "GMeasureArrowCell.h"
#import "GLoginController.h"

@interface GMeasureController ()<LCActionSheetDelegate>
{
    MDRadialProgressView *_radialView;
    MDRadialProgressView *_radialViewFront;
    
    NSMutableArray *_aryProjectData;
    
    BOOL _isLbUnit;
}


@end

@implementation GMeasureController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //fat brm water bmi muscle bone visceralfat
    _targetWeight=@"0.0";
    
    [self initData];
    
    [self initView];
    self.lblWeightBig.alpha=0.0;
    
    self.lblTopTitle.text=NSLocalizedString(@"title_measure", nil);

    NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
    if ([weightUnit isEqualToString:@"lb"]) {
        _isLbUnit = YES;
    }
    
    NSString *showTargetWeight = _targetWeight;
    if (_isLbUnit) {
        showTargetWeight = [PublicModule kgToLb:showTargetWeight];
    }
    
    _targetShow = showTargetWeight;
    
    NSString *fullTargetText=[NSString stringWithFormat:@"%@: %@%@",NSLocalizedString(@"target_weight", nil),showTargetWeight,weightUnit];
    NSString *targetText=[NSString stringWithFormat:@"%@%@",showTargetWeight,weightUnit];
    if(_targetWeight.length<1 || [_targetWeight floatValue]<=0.0)
    {
        fullTargetText=[NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"target_weight", nil),NSLocalizedString(@"target_set", nil)];
        targetText=[NSString stringWithFormat:@"%@",NSLocalizedString(@"target_set", nil)];
    }
    
    NSRange rangeTargetWeight=[fullTargetText rangeOfString:targetText];
    NSMutableAttributedString *aStrTarget=[[NSMutableAttributedString alloc] initWithString:fullTargetText];
    [aStrTarget addAttribute:NSForegroundColorAttributeName
                     value:UIColorFromRGB(0xe9a000)
                     range:rangeTargetWeight];

    self.lblTargetWeight.attributedText=aStrTarget;

    _db=[[DbModel alloc] init];
    _jsonModule=[[NetworkModule alloc] init];

    _delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;

    NSArray *aryTarget=[_db selectTargetWithCTime:[AppDelegate shareUserInfo].account_ctime andType:@"1"];
    if(aryTarget && aryTarget.count>=1)
    {
        NSArray *ary=[aryTarget objectAtIndex:0];
        if(ary && ary.count>=2)
        {
            NSString *targetValue=[ary objectAtIndex:2];
            _targetWeight=targetValue;
            
            //NSString *fullTargetText=[NSString stringWithFormat:@"目标体重:%@kg",_targetWeight];
            if (_isLbUnit) {
                showTargetWeight = [PublicModule kgToLb:showTargetWeight];
            }
            
            _targetShow = showTargetWeight;
            
            NSString *fullTargetText=[NSString stringWithFormat:@"%@: %@%@",NSLocalizedString(@"target_weight", nil),showTargetWeight,weightUnit];
            NSString *targetText=[NSString stringWithFormat:@"%@%@",showTargetWeight,weightUnit];
            NSRange rangeTargetWeight=[fullTargetText rangeOfString:targetText];
            NSMutableAttributedString *aStrTarget=[[NSMutableAttributedString alloc] initWithString:fullTargetText];
            [aStrTarget addAttribute:NSForegroundColorAttributeName
                               value:UIColorFromRGB(0xe9a000)
                               range:rangeTargetWeight];
            
            self.lblTargetWeight.attributedText=aStrTarget;
            
            //self.lblTargetWeight.text=[NSString stringWithFormat:@"目标体重:%@kg",_targetWeight];
            [AppDelegate shareUserInfo].targetWeight=_targetWeight;
        }
    }
    
    
    self.tableview.alpha=0.95;
    
    isSelfController=YES;

    [self.view insertSubview:self.viewNotiStatus belowSubview:self.viewTop];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTargetWeight:) name:NotiAddTargetWeight object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMeasureData) name:GNotiRefreshView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMeasureData) name:@"weight_unit" object:nil];
    
    [self refreshMeasureData];
    [self initMeasureNoti];
    
    [_delegate startScan];
    [_delegate stopScan];
    
    [self performSelector:@selector(startScan) withObject:nil afterDelay:1.5f];
    
    
    NSString *uid=[[NSUserDefaults standardUserDefaults] objectForKey:@"u_id"];

    if(uid == nil ||
       [uid isEqualToString:@""] ||
       [uid isEqualToString:@"-1"])
    {
        if([PublicModule checkLoginStatus])
        {
            [self performSelector:@selector(showLoginInfo) withObject:nil afterDelay:1.8f];
        }
    }
}

-(void)showLoginInfo
{
    UIAlertView *alert=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"login_noti", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancle", nil) otherButtonTitles:NSLocalizedString(@"title_setting", nil), nil];
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"取消");
    }
    else if (buttonIndex == 1)
    {
        GLoginController *vc=[[GLoginController alloc] init];
        [_delegate.tabController.navigationController pushViewController:vc animated:YES];
        NSLog(@"设置");
    }
}

-(void)initData
{
    NSDictionary *dic=[PublicModule getFatRangeWithAge:[AppDelegate shareUserInfo].userAge andSex:[AppDelegate shareUserInfo].sex];
    NSArray *aryFat;
    NSArray *aryMuscle;
    NSArray *aryWater;
    NSArray *aryBone;
    NSArray *aryBasic;
    NSArray *aryBmi;
    NSArray *aryVisceralfat;
    
    
    if(dic && dic.count>=6)
    {
        aryFat=[dic valueForKey:ProjectFat];
        aryMuscle=[dic valueForKey:ProjectMuscle];
        aryWater=[dic valueForKey:ProjectWater];
        aryBone=[dic valueForKey:ProjectBone];
        aryBasic=[dic valueForKey:ProjectBasic];
        aryBmi=[dic valueForKey:ProjectBMI];
        aryVisceralfat=[dic valueForKey:ProjectVisceralFat];
    }
    
    NSMutableDictionary *dicTempFat=[[NSMutableDictionary alloc] init];
    [dicTempFat setValue:@"0" forKey:@"type"];
    [dicTempFat setObject:ProjectFatName forKey:@"name"];
    [dicTempFat setObject:@"15%" forKey:@"valueShow"];
    [dicTempFat setObject:@"0" forKey:@"value"];
    if(aryFat && aryFat.count>=2)
    {
        [dicTempFat setObject:aryFat forKey:@"range"];
    }
    
    NSMutableDictionary *dicTempMuscle=[[NSMutableDictionary alloc] init];
    [dicTempMuscle setValue:@"0" forKey:@"type"];
    [dicTempMuscle setObject:ProjectMuscleName forKey:@"name"];
    [dicTempMuscle setObject:@"36.2%" forKey:@"valueShow"];
    [dicTempMuscle setObject:@"0" forKey:@"value"];
    if(aryMuscle && aryMuscle.count>=2)
    {
        [dicTempMuscle setObject:aryMuscle forKey:@"range"];
    }
    
    NSMutableDictionary *dicTempWater=[[NSMutableDictionary alloc] init];
    [dicTempWater setValue:@"0" forKey:@"type"];
    [dicTempWater setObject:ProjectWaterName forKey:@"name"];
    [dicTempWater setObject:@"45%" forKey:@"valueShow"];
    [dicTempWater setObject:@"0" forKey:@"value"];
    if(aryWater && aryWater.count>=2)
    {
        [dicTempWater setObject:aryWater forKey:@"range"];
    }
    
    NSMutableDictionary *dicTempBasic=[[NSMutableDictionary alloc] init];
    [dicTempBasic setValue:@"0" forKey:@"type"];
    [dicTempBasic setObject:ProjectBasicName forKey:@"name"];
    [dicTempBasic setObject:@"1572kcal" forKey:@"valueShow"];
    [dicTempBasic setObject:@"0" forKey:@"value"];
    if(aryBasic && aryBasic.count>=2)
    {
        [dicTempBasic setObject:aryBasic forKey:@"range"];
    }
    
    NSMutableDictionary *dicTempBone=[[NSMutableDictionary alloc] init];
    [dicTempBone setValue:@"0" forKey:@"type"];
    [dicTempBone setObject:ProjectBoneName forKey:@"name"];
    [dicTempBone setObject:@"2.3%" forKey:@"valueShow"];
    [dicTempBone setObject:@"0" forKey:@"value"];
    if(aryBone && aryBone.count>=2)
    {
        [dicTempBone setObject:aryBone forKey:@"range"];
    }
    
    NSMutableDictionary *dicTempBMI=[[NSMutableDictionary alloc] init];
    [dicTempBMI setValue:@"0" forKey:@"type"];
    [dicTempBMI setObject:ProjectBMIName forKey:@"name"];
    [dicTempBMI setObject:@"20.5" forKey:@"valueShow"];
    [dicTempBMI setObject:@"0" forKey:@"value"];
    if(aryBmi && aryBmi.count>=2)
    {
        [dicTempBMI setObject:aryBmi forKey:@"range"];
    }
    
    NSMutableDictionary *dicTempVisceral=[[NSMutableDictionary alloc] init];
    [dicTempVisceral setValue:@"0" forKey:@"type"];
    [dicTempVisceral setObject:ProjectVisceralFatName forKey:@"name"];
    [dicTempVisceral setObject:@"15" forKey:@"valueShow"];
    [dicTempVisceral setObject:@"0" forKey:@"value"];
    if(aryVisceralfat && aryVisceralfat.count>=2)
    {
        [dicTempVisceral setObject:aryVisceralfat forKey:@"range"];
    }
    
    
    NSMutableDictionary *dicTempBodyage=[[NSMutableDictionary alloc] init];
    [dicTempBodyage setValue:@"0" forKey:@"type"];
    [dicTempBodyage setObject:ProjectBodyageName forKey:@"name"];
    [dicTempBodyage setObject:@"22岁" forKey:@"valueShow"];
    [dicTempBodyage setObject:@"0" forKey:@"value"];
    
    /*
    NSMutableDictionary *dicTemp9=[[NSMutableDictionary alloc] init];
    [dicTemp9 setValue:@"0" forKey:@"type"];
    [dicTemp9 setObject:ProjectHeightName forKey:@"name"];
    [dicTemp9 setObject:@"175.0cm" forKey:@"valueShow"];
    [dicTemp9 setObject:@"0.0" forKey:@"value"];
    */
    
    //步行 体重 BMI  脂肪 水分 肌肉 骨量 基础代谢 内脏脂肪 身体年龄
    _aryProjectData=[[NSMutableArray alloc] initWithObjects:dicTempBMI,dicTempFat,dicTempWater,dicTempMuscle,dicTempBone,dicTempBasic,dicTempVisceral,dicTempBodyage, nil];
}

-(void)startScan
{
    [_delegate startScan];
}

#pragma mark 接收蓝牙数据通知
-(void)initMeasureNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setWeightWithNoti:) name:NotiGuoWeightScale object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setWeightResultWithNoti:) name:NotiGuoWeightScaleResult object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFatWithNoti:) name:NotiGuoFatScale object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setFatResultWithNoti:) name:NotiGuoFatScaleResult object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMeasureData) name:GNotiUpdateView object:nil];
}


-(void)setWeightWithNoti:(NSNotification *)noti
{
    NSString *weight=[noti.userInfo valueForKey:ProjectWeight];
    self.lblWeight.text=weight;
    
    if (_isLbUnit) {
        self.lblWeight.text = [PublicModule kgToLb:weight];
    }
    
    _radialView.hidden=YES;
    _lastMeasureFat=@"";
}

-(void)setWeightResultWithNoti:(NSNotification *)noti
{
    NSString *weight=[noti.userInfo valueForKey:ProjectWeight];
    NSString *bmi=[noti.userInfo valueForKey:ProjectBMI];
    NSString *muscle=[noti.userInfo valueForKey:ProjectMuscle];
    NSString *water=[noti.userInfo valueForKey:ProjectWater];
    NSString *fat=[noti.userInfo valueForKey:ProjectFat];
    NSString *basic=[noti.userInfo valueForKey:ProjectBasic];
    NSString *bone=[noti.userInfo valueForKey:ProjectBone];
    NSString *visceralfat=[noti.userInfo valueForKey:ProjectVisceralFat];
    NSString *device=[noti.userInfo valueForKey:ProjectDevice];
    NSString *bodyage=[noti.userInfo valueForKey:ProjectBodyAge];
    NSString *height=[noti.userInfo valueForKey:ProjectHeight];
    
    if(bodyage == nil) bodyage=@"0";
    if(height == nil) height=@"0.0";
    
    self.lblWeight.text=weight;
    self.lblRangeBMI.text=bmi;
    
    if (_isLbUnit) {
        self.lblWeight.text = [PublicModule kgToLb:weight];
    }
    
    if([_lastMeasureFat isEqualToString:weight])
    {
        return;
    }
    
    _radialView.hidden=NO;
    _lastMeasureFat=weight;
    self.lblRangeBMI.text=bmi;
    
    [self setBMILocationWithBMI:bmi];
    
    NSString *time=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
    NSDictionary *dicWeight=noti.userInfo;
    NSString *mid=@"-1";
    NSString *ctime=[AppDelegate shareUserInfo].account_ctime;
    NSString *mtype=@"0";
    NSString *update=@"1";
    NSString *delete=@"0";
    NSString *memberType=@"0";
    NSString *deviceType=device;
    
    
    NSArray *arySave=[[NSArray alloc] initWithObjects:time,dicWeight,mid,ctime,mtype,update,delete,memberType,deviceType, nil];
    BOOL ret=[_db insertMeasureData:arySave];
    
    
    if(ret)
    {
        [self setBMILocationWithBMI:bmi];
        
        CGRect frame=self.lblWeight.frame;
        self.lblWeightBig.alpha=0.0;
        self.lblWeightBig.text=self.lblWeight.text;
        self.lblWeightBig.frame=CGRectMake(frame.origin.x-50, frame.origin.y-50, frame.size.width+100, frame.size.height+100);
        self.lblWeight.alpha=0.5;
        self.lblWeightBig.font=[UIFont systemFontOfSize:90];
        
        [UIView animateWithDuration:0.6f animations:^{
            self.lblWeight.alpha=0.0;
            self.lblWeightBig.alpha=1.0;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.6f animations:^{
                self.lblWeight.alpha=1.0;
                self.lblWeightBig.alpha=0.0;
                [self refreshMeasureData];
            }];
        }];
        
        
        [_delegate uploadWeightToService];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:GNotiRefreshMineView object:nil];
        });
        
    }
    
    
}

-(void)setBMILocationWithBMI:(NSString *)bmi
{
    CGFloat fBMI=[bmi floatValue];
    CGFloat fLocation=self.imageBMIRange.frame.origin.x;
    CGFloat fWidth=self.imageBMIRange.frame.size.width/3;
    
    if(fBMI<18.5)
    {
        fLocation=fBMI/18.5*fWidth-6;
    }
    else if (fBMI>=18.5 && fBMI<=24.0)
    {
        fLocation=(fBMI-18.5)/(24-18.5)*fWidth+fWidth-6;
    }
    else
    {
        fLocation=(fBMI-24.0)/(32.0-24.0)*fWidth+fWidth*2-6;
    }
    
    if(fLocation<self.imageBMIRange.frame.origin.x-6)
    {
        fLocation=self.imageBMIRange.frame.origin.x-6;
    }
    else if (fLocation>self.imageBMIRange.frame.origin.x+self.imageBMIRange.frame.size.width-1)
    {
        fLocation=self.imageBMIRange.frame.origin.x+self.imageBMIRange.frame.size.width-1;
    }
    
    self.lblRangeBMI.text=bmi;
    self.imageRangeLocation.frame=CGRectMake(fLocation, self.imageRangeLocation.frame.origin.y, self.imageRangeLocation.frame.size.width, self.imageRangeLocation.frame.size.height);
    
    [self setBMIShow:YES];
    
}

-(void)setBMIShow:(BOOL)aBool
{
    if(aBool)
    {
        self.imageBMIRange.hidden=NO;
        self.imageRangeLocation.hidden=NO;
        self.lblRangeBMI.hidden=NO;
        self.lblRangeBMITitle.hidden=NO;
        self.lblRangeLow.hidden=NO;
        self.lblRangeNormal.hidden=NO;
        self.lblRangeHigh.hidden=NO;
        
        self.tableview.hidden=YES;
    }
    else
    {
        self.imageBMIRange.hidden=YES;
        self.imageRangeLocation.hidden=YES;
        self.lblRangeBMI.hidden=YES;
        self.lblRangeBMITitle.hidden=YES;
        self.lblRangeLow.hidden=YES;
        self.lblRangeNormal.hidden=YES;
        self.lblRangeHigh.hidden=YES;
        
        self.tableview.hidden=NO;
    }
}

-(void)setFatWithNoti:(NSNotification *)noti
{
    NSString *weight=[noti.userInfo valueForKey:ProjectWeight];
    NSString *bmi=[noti.userInfo valueForKey:ProjectBMI];
    NSString *muscle=[noti.userInfo valueForKey:ProjectMuscle];
    NSString *water=[noti.userInfo valueForKey:ProjectWater];
    NSString *fat=[noti.userInfo valueForKey:ProjectFat];
    NSString *basic=[noti.userInfo valueForKey:ProjectBasic];
    NSString *bone=[noti.userInfo valueForKey:ProjectBone];
    NSString *visceralfat=[noti.userInfo valueForKey:ProjectVisceralFat];
    _lastMeasureFat=@"";
    self.lblWeight.text=weight;
    if (_isLbUnit) {
        self.lblWeight.text = [PublicModule kgToLb:weight];
    }
    _radialView.hidden=YES;
    
    self.lblWeight.font=[UIFont systemFontOfSize:55.0];
    
}

-(void)setFatResultWithNoti:(NSNotification *)noti
{
    NSString *weight=[noti.userInfo valueForKey:ProjectWeight];
    NSString *bmi=[noti.userInfo valueForKey:ProjectBMI];
    NSString *muscle=[noti.userInfo valueForKey:ProjectMuscle];
    NSString *water=[noti.userInfo valueForKey:ProjectWater];
    NSString *fat=[noti.userInfo valueForKey:ProjectFat];
    NSString *basic=[noti.userInfo valueForKey:ProjectBasic];
    NSString *bone=[noti.userInfo valueForKey:ProjectBone];
    NSString *visceralfat=[noti.userInfo valueForKey:ProjectVisceralFat];
    NSString *device=[noti.userInfo valueForKey:ProjectDevice];
    NSString *bodyage=[noti.userInfo valueForKey:ProjectBodyAge];
    NSString *height=[noti.userInfo valueForKey:ProjectHeight];
    if(bodyage == nil) bodyage=@"0";
    if(height == nil) height=@"0.0";
    
    /*
    self.lblWeight.text=weight;
    if (_isLbUnit) {
        self.lblWeight.text = [PublicModule kgToLb:weight];
    }
    */
    
    if([_lastMeasureFat isEqualToString:weight])
    {
        return;
    }
    
    
    _lastMeasureFat=weight;
    _radialView.hidden=NO;
    
    //c1,60.0,19.8,38.1,53.5,22.1,1586,5.8,40
    
    NSDictionary *dic=[PublicModule getFatRangeWithAge:[AppDelegate shareUserInfo].userAge andSex:[AppDelegate shareUserInfo].sex];
    NSArray *aryFat;
    NSArray *aryMuscle;
    NSArray *aryWater;
    NSArray *aryBone;
    NSArray *aryBasic;
    NSArray *aryBmi;
    NSArray *aryVisceralfat;
    
    if(dic && dic.count>=6)
    {
        aryFat=[dic valueForKey:ProjectFat];
        aryMuscle=[dic valueForKey:ProjectMuscle];
        aryWater=[dic valueForKey:ProjectWater];
        aryBone=[dic valueForKey:ProjectBone];
        aryBasic=[dic valueForKey:ProjectBasic];
        aryBmi=[dic valueForKey:ProjectBMI];
        aryVisceralfat=[dic valueForKey:ProjectVisceralFat];
        aryBone = [PublicModule getBoneRangeWithWeight:weight andSex:[AppDelegate shareUserInfo].sex];
    }
    
    
    //BMI  脂肪 水分 肌肉 骨量 基础代谢 内脏脂肪 身体年龄
    
    //脂肪
    NSMutableDictionary *dicTemp1=[_aryProjectData objectAtIndex:1];
    
    [dicTemp1 setValue:@"0" forKey:@"type"];
    if(aryFat)
    {
        [dicTemp1 setValue:aryFat forKey:@"range"];
    }
    [dicTemp1 setObject:ProjectFatName forKey:@"name"];
    [dicTemp1 setObject:[fat stringByAppendingString:@"%"] forKey:@"valueShow"];
    [dicTemp1 setObject:fat forKey:@"value"];
    
    //肌肉
    NSMutableDictionary *dicTemp2=[_aryProjectData objectAtIndex:3];
    [dicTemp2 setValue:@"0" forKey:@"type"];
    if(aryMuscle)
    {
        [dicTemp2 setValue:aryMuscle forKey:@"range"];
    }
    [dicTemp2 setObject:ProjectMuscleName forKey:@"name"];
    [dicTemp2 setObject:[muscle stringByAppendingString:@"%"] forKey:@"valueShow"];
    [dicTemp2 setObject:muscle forKey:@"value"];
    
    //水分
    NSMutableDictionary *dicTemp3=[_aryProjectData objectAtIndex:2];
    [dicTemp3 setValue:@"0" forKey:@"type"];
    if(aryWater)
    {
        [dicTemp3 setValue:aryWater forKey:@"range"];
    }
    [dicTemp3 setObject:ProjectWaterName forKey:@"name"];
    [dicTemp3 setObject:[water stringByAppendingString:@"%"] forKey:@"valueShow"];
    [dicTemp3 setObject:water forKey:@"value"];
    
    //基础代谢
    NSMutableDictionary *dicTemp4=[_aryProjectData objectAtIndex:5];
    [dicTemp4 setValue:@"0" forKey:@"type"];
    if(aryBasic)
    {
        [dicTemp4 setValue:aryBasic forKey:@"range"];
    }
    [dicTemp4 setObject:ProjectBasicName forKey:@"name"];
    
    [dicTemp4 setObject:[basic stringByAppendingString:@"kcal"] forKey:@"valueShow"];
    [dicTemp4 setObject:basic forKey:@"value"];
    
    //骨量
    NSMutableDictionary *dicTemp5=[_aryProjectData objectAtIndex:4];
    [dicTemp5 setValue:@"0" forKey:@"type"];
    if(aryBone)
    {
        [dicTemp5 setValue:aryBone forKey:@"range"];
    }
    [dicTemp5 setObject:ProjectBoneName forKey:@"name"];
    [dicTemp5 setObject:[bone stringByAppendingString:@"%"] forKey:@"valueShow"];
    [dicTemp5 setObject:bone  forKey:@"value"];
    
    //Bmi
    NSMutableDictionary *dicTemp6=[_aryProjectData objectAtIndex:0];
    [dicTemp6 setValue:@"0" forKey:@"type"];
    if(aryBmi)
    {
        [dicTemp6 setValue:aryBmi forKey:@"range"];
    }
    [dicTemp6 setObject:ProjectBMIName forKey:@"name"];
    [dicTemp6 setObject:bmi forKey:@"valueShow"];
    [dicTemp6 setObject:bmi forKey:@"value"];
    
    
    //内脏脂肪
    NSMutableDictionary *dicTemp7=[_aryProjectData objectAtIndex:6];
    [dicTemp7 setValue:@"0" forKey:@"type"];
    if(aryVisceralfat)
    {
        [dicTemp7 setValue:aryVisceralfat forKey:@"range"];
    }
    
    [dicTemp7 setObject:ProjectVisceralFatName forKey:@"name"];
    [dicTemp7 setObject:visceralfat forKey:@"valueShow"];
    [dicTemp7 setObject:visceralfat forKey:@"value"];
    
    
    NSMutableDictionary *dicTemp8=[_aryProjectData objectAtIndex:7];
    [dicTemp8 setValue:@"0" forKey:@"type"];
    [dicTemp8 setObject:ProjectBodyageName forKey:@"name"];
    [dicTemp8 setObject:[bodyage stringByAppendingString:@"岁"] forKey:@"valueShow"];
    [dicTemp8 setObject:bodyage forKey:@"value"];
    

    NSLog(@"测量完毕%@,%@,%@,%@,%@,%@,%@,%@,%@",device,weight,bmi,muscle,water,fat,basic,bone,visceralfat);
    
    
    NSString *time=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
    NSDictionary *dicWeight=noti.userInfo;
    NSString *mid=@"-1";
    NSString *ctime=[AppDelegate shareUserInfo].account_ctime;
    NSString *mtype=@"0";
    NSString *update=@"1";
    NSString *delete=@"0";
    NSString *memberType=@"0";
    NSString *deviceType=device;
    

    NSArray *arySave=[[NSArray alloc] initWithObjects:time,dicWeight,mid,ctime,mtype,update,delete,memberType,deviceType, nil];
    BOOL ret=[_db insertMeasureData:arySave];
    
    if(ret)
    {
        [self setBMIShow:NO];
        
        CGRect frame=self.lblWeight.frame;
        self.lblWeightBig.alpha=0.0;
        self.lblWeightBig.text=self.lblWeight.text;
        self.lblWeightBig.frame=CGRectMake(frame.origin.x-50, frame.origin.y-50, frame.size.width+100, frame.size.height+100);
        self.lblWeight.alpha=0.5;
        self.lblWeightBig.font=[UIFont systemFontOfSize:90];
        
        [UIView animateWithDuration:0.6f animations:^{
            self.lblWeight.alpha=0.0;
            self.lblWeightBig.alpha=1.0;
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.6f animations:^{
                self.lblWeight.alpha=1.0;
                self.lblWeightBig.alpha=0.0;
                [self refreshMeasureData];
            }];
            //self.lblWeight.alpha=1.0;
            //self.lblWeightBig.alpha=0.0;
            //[self refreshMeasureData];
        }];
        
        
        [_delegate uploadWeightToService];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:GNotiRefreshMineView object:nil];
        });
        
        
    }
    
    self.lblWeight.text=weight;
    if (_isLbUnit) {
        self.lblWeight.text = [PublicModule kgToLb:weight];
    }
    [self.tableview reloadData];
}



-(void)refreshMeasureData
{
    self.lblWeightUnit.text = @"kg";
    NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
    _isLbUnit = NO;
    if ([weightUnit isEqualToString:@"lb"]) {
        _isLbUnit = YES;
        self.lblWeightUnit.text = weightUnit;
    }
    
    NSString *kgWeight = @"0.00";
    NSArray *aryTarget=[_db selectTargetWithCTime:[AppDelegate shareUserInfo].account_ctime andType:@"1"];
    if(aryTarget && aryTarget.count>=1)
    {
        NSArray *ary=[aryTarget objectAtIndex:0];
        if(ary && ary.count>=2)
        {
            NSString *targetValue=[ary objectAtIndex:2];
            _targetWeight=targetValue;
            
            //NSString *fullTargetText=[NSString stringWithFormat:@"目标体重:%@kg",_targetWeight];
            NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
            NSString *showTargetWeight = _targetWeight;
            if (_isLbUnit) {
                showTargetWeight = [PublicModule kgToLb:showTargetWeight];
            }
            
            /*
            if ([_targetShow integerValue] >= 30) {
                showTargetWeight = _targetShow;
            } else {
                _targetShow = showTargetWeight;
            }
            */
            
            NSString *fullTargetText=[NSString stringWithFormat:@"%@: %@%@",NSLocalizedString(@"target_weight", nil),showTargetWeight,weightUnit];
            NSString *targetText=[NSString stringWithFormat:@"%@%@",showTargetWeight,weightUnit];
            NSRange rangeTargetWeight=[fullTargetText rangeOfString:targetText];
            NSMutableAttributedString *aStrTarget=[[NSMutableAttributedString alloc] initWithString:fullTargetText];
            [aStrTarget addAttribute:NSForegroundColorAttributeName
                               value:UIColorFromRGB(0xe9a000)
                               range:rangeTargetWeight];
            
            self.lblTargetWeight.attributedText=aStrTarget;
            
            //self.lblTargetWeight.text=[NSString stringWithFormat:@"目标体重:%@kg",_targetWeight];
            [AppDelegate shareUserInfo].targetWeight=_targetWeight;
        }
    }
    
    
    NSArray *aryLastWeight=[_db selectLastWeightWithCTime:[AppDelegate shareUserInfo].account_ctime];
    
    self.lblTargetPlus.hidden=YES;
    
    if(aryLastWeight && aryLastWeight.count>=1)
    {
        NSArray *ary=[aryLastWeight objectAtIndex:0];
        NSDictionary *dicData=[ary objectAtIndex:3];
        if(dicData && dicData.count>=7)
        {
            
            NSString *weight=[dicData valueForKey:ProjectWeight];
            NSString *bmi=[dicData valueForKey:ProjectBMI];
            NSString *muscle=[dicData valueForKey:ProjectMuscle];
            NSString *water=[dicData valueForKey:ProjectWater];
            NSString *fat=[dicData valueForKey:ProjectFat];
            NSString *basic=[dicData valueForKey:ProjectBasic];
            NSString *bone=[dicData valueForKey:ProjectBone];
            NSString *visceralfat=[dicData valueForKey:ProjectVisceralFat];
            NSString *height=[dicData valueForKey:ProjectHeight];
            NSString *bodyage=[dicData valueForKey:ProjectBodyAge];
            
            kgWeight = weight;
            self.lblWeight.text=weight;
            
            if (_isLbUnit) {
                self.lblWeight.text = [PublicModule kgToLb:weight];
            }
            
            [self setBMILocationWithBMI:bmi];
            
            if([fat floatValue]<=0.0)
            {
                [self setBMIShow:YES];
            }
            else
            {
                [self setBMIShow:NO];
            }
            
            NSDictionary *dic=[PublicModule getFatRangeWithAge:[AppDelegate shareUserInfo].userAge andSex:[AppDelegate shareUserInfo].sex];
            NSArray *aryFat;
            NSArray *aryMuscle;
            NSArray *aryWater;
            NSArray *aryBone;
            NSArray *aryBasic;
            NSArray *aryBmi;
            NSArray *aryVisceralfat;
            if(dic && dic.count>=6)
            {
                aryFat=[dic valueForKey:ProjectFat];
                aryMuscle=[dic valueForKey:ProjectMuscle];
                aryWater=[dic valueForKey:ProjectWater];
                aryBone=[dic valueForKey:ProjectBone];
                aryBasic=[dic valueForKey:ProjectBasic];
                aryBmi=[dic valueForKey:ProjectBMI];
                aryVisceralfat=[dic valueForKey:ProjectVisceralFat];
                
                aryBone = [PublicModule getBoneRangeWithWeight:kgWeight andSex:[AppDelegate shareUserInfo].sex];
            }
            
            //BMI  脂肪 水分 肌肉 骨量 基础代谢 内脏脂肪 身体年龄
            
            
            //脂肪
            NSMutableDictionary *dicTemp1=[_aryProjectData objectAtIndex:1];
            if(aryFat)
            {
                [dicTemp1 setValue:aryFat forKey:@"range"];
            }
            [dicTemp1 setObject:ProjectFatName forKey:@"name"];
            [dicTemp1 setObject:[fat stringByAppendingString:@"%"] forKey:@"valueShow"];
            [dicTemp1 setObject:fat forKey:@"value"];
            
            //肌肉
            NSMutableDictionary *dicTemp2=[_aryProjectData objectAtIndex:3];
            if(aryMuscle)
            {
                [dicTemp2 setValue:aryMuscle forKey:@"range"];
            }
            [dicTemp2 setObject:ProjectMuscleName forKey:@"name"];
            [dicTemp2 setObject:[muscle stringByAppendingString:@"%"] forKey:@"valueShow"];
            [dicTemp2 setObject:muscle forKey:@"value"];
            
            //水分
            NSMutableDictionary *dicTemp3=[_aryProjectData objectAtIndex:2];
            if(aryWater)
            {
                [dicTemp3 setValue:aryWater forKey:@"range"];
            }
            [dicTemp3 setObject:ProjectWaterName forKey:@"name"];
            [dicTemp3 setObject:[water stringByAppendingString:@"%"] forKey:@"valueShow"];
            [dicTemp3 setObject:water forKey:@"value"];
            
            //基础代谢
            NSMutableDictionary *dicTemp4=[_aryProjectData objectAtIndex:5];
            if(aryBasic)
            {
                [dicTemp4 setValue:aryBasic forKey:@"range"];
            }
            [dicTemp4 setObject:ProjectBasicName forKey:@"name"];
            [dicTemp4 setObject:[basic stringByAppendingString:@"kcal"] forKey:@"valueShow"];
            [dicTemp4 setObject:basic forKey:@"value"];
            
            //骨量
            NSMutableDictionary *dicTemp5=[_aryProjectData objectAtIndex:4];
            if(aryBone)
            {
                [dicTemp5 setValue:aryBone forKey:@"range"];
            }
            [dicTemp5 setObject:ProjectBoneName forKey:@"name"];
            [dicTemp5 setObject:[bone stringByAppendingString:@"%"] forKey:@"valueShow"];
            [dicTemp5 setObject:bone  forKey:@"value"];
            
            //Bmi
            NSMutableDictionary *dicTemp6=[_aryProjectData objectAtIndex:0];
            if(aryBmi)
            {
                [dicTemp6 setValue:aryBmi forKey:@"range"];
            }
            [dicTemp6 setObject:ProjectBMIName forKey:@"name"];
            [dicTemp6 setObject:bmi forKey:@"valueShow"];
            [dicTemp6 setObject:bmi forKey:@"value"];
            
            
            //内脏脂肪
            NSMutableDictionary *dicTemp7=[_aryProjectData objectAtIndex:6];
            if(aryVisceralfat)
            {
                [dicTemp7 setValue:aryVisceralfat forKey:@"range"];
            }
            [dicTemp7 setObject:ProjectVisceralFatName forKey:@"name"];
            [dicTemp7 setObject:visceralfat forKey:@"valueShow"];
            [dicTemp7 setObject:visceralfat forKey:@"value"];
            
            
            //身体年龄
            NSMutableDictionary *dicTemp8=[_aryProjectData objectAtIndex:7];
            
            [dicTemp8 setObject:ProjectBodyageName forKey:@"name"];
            [dicTemp8 setObject:[bodyage stringByAppendingString:@"岁"] forKey:@"valueShow"];
            [dicTemp8 setObject:bodyage forKey:@"value"];
            
            
            //身高
            /*
            NSMutableDictionary *dicTemp9=[_aryProjectData objectAtIndex:8];

            [dicTemp9 setObject:ProjectHeightName forKey:@"name"];
            [dicTemp9 setObject:[height stringByAppendingString:@"cm"] forKey:@"valueShow"];
            [dicTemp9 setObject:height forKey:@"value"];
            */
            
            [self.tableview reloadData];
        }
        
    }
    else
    {
        kgWeight = @"0.00";
        self.lblWeight.text=@"0.00";
    }
    
    if (_isLbUnit) {
        self.lblWeight.text = [PublicModule kgToLb:kgWeight];
    }
    
    if(_targetWeight && _targetWeight.length>=1 && [_targetWeight floatValue]>=1.0)
    {
        //历史最重跟历史最轻
        NSArray *aryMaxAndMin=[_db selectMaxAndMinProjectValueWithProject:ProjectWeight andCTime:[AppDelegate shareUserInfo].account_ctime];
        
        CGFloat fMax=[kgWeight floatValue];
        CGFloat fMin=[kgWeight floatValue];
        CGFloat fWeight=[kgWeight floatValue];
        
        if(aryMaxAndMin && aryMaxAndMin.count>=2)
        {
            NSArray *aryMin=[aryMaxAndMin objectAtIndex:0];
            NSArray *aryMax=[aryMaxAndMin objectAtIndex:1];
            if(aryMax==nil || aryMax.count <2 || aryMin==nil || aryMin.count<2)
            {
                return;
            }
            fMax=[[aryMax objectAtIndex:0] floatValue];
            fMin=[[aryMin objectAtIndex:0] floatValue];
        }
        
        CGFloat dPlus=[_targetWeight doubleValue]-[kgWeight doubleValue];
        CGFloat fCount=dPlus;
        CGFloat fPercent=0.1;
        if(dPlus>0)
        {
            fCount=[_targetWeight floatValue] - fMin;
            fPercent=(fWeight-fMin)/fCount;
            self.lblTargetLow.text=[NSString stringWithFormat:@"%.1f",fMin];
            self.lblTargetHigh.text=[NSString stringWithFormat:@"%.1f",[_targetWeight floatValue]];
            NSLog(@"增肥");
        }
        else
        {
            fCount=fMax-[_targetWeight floatValue];
            fPercent=(fMax - fWeight)/fCount;
            
            self.lblTargetLow.text=[NSString stringWithFormat:@"%.1f",fMax];
            self.lblTargetHigh.text=[NSString stringWithFormat:@"%.1f",[_targetWeight floatValue]];
            NSLog(@"减肥");
        }
        
        if(fPercent<=0.0) fPercent=0.0;
        if(fPercent>=1.0) fPercent=1.0;
        
        CGFloat fWidth=self.viewTargetLineBottom.frame.size.width*fPercent;
        
        self.viewTargetLineFront.frame=CGRectMake(32, self.viewTargetLineBottom.frame.origin.y, self.viewTargetLineBottom.frame.size.width, self.viewTargetLineBottom.frame.size.height);
        
        [UIView animateWithDuration:2.0f animations:^{
            self.viewTargetLineFront.frame=CGRectMake(self.viewTargetLineBottom.frame.origin.x+fWidth, self.viewTargetLineFront.frame.origin.y, self.viewTargetLineBottom.frame.size.width-fWidth, self.viewTargetLineFront.frame.size.height);
        } completion:^(BOOL finished) {
            self.lblTargetPlus.hidden = NO;
        }];
        
        dPlus = fabs(dPlus);
        //self.lblTargetPlus.text=[NSString stringWithFormat:@"距离目标还有%.1fkg",dPlus];
        NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
        if (_isLbUnit) {
            dPlus = dPlus * 2.204622;
        }

        self.lblTargetPlus.text=[NSString stringWithFormat:@"%@ %.1f%@",NSLocalizedString(@"target_distance", nil),dPlus,weightUnit];
        NSString *isEnglish = NSLocalizedString(@"user_agreement", nil);
        if ([isEnglish isEqualToString:@"1"]) {
            self.lblTargetPlus.text=[NSString stringWithFormat:@"%.1f%@ %@ ",dPlus,weightUnit,NSLocalizedString(@"target_distance", nil)];
        }
    }
}

-(void)updateTargetWeight:(NSNotification *)noti
{
    NSDictionary *dic=noti.userInfo;
    if(dic)
    {
        NSString *target=[dic valueForKey:@"target_weight"];
        NSString *targetShow=[dic valueForKey:@"target_weight_show"];
        if(target)
        {
            //self.lblTargetWeight.text=[NSString stringWithFormat:@"目标体重:%@",target];
            _targetWeight=target;
            
            NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
            
            //NSString *fullTargetText=[NSString stringWithFormat:@"目标体重:%@kg",_targetWeight];
            NSString *showTargetWeight = targetShow;
            _targetShow = showTargetWeight;
            /*
            if (_isLbUnit) {
                showTargetWeight = [PublicModule kgToLb:showTargetWeight];
            }
             */
            
            NSString *fullTargetText=[NSString stringWithFormat:@"%@: %@%@",NSLocalizedString(@"target_weight", nil),showTargetWeight,weightUnit];
            NSString *targetText=[NSString stringWithFormat:@"%@%@",showTargetWeight,weightUnit];
            NSRange rangeTargetWeight=[fullTargetText rangeOfString:targetText];
            NSMutableAttributedString *aStrTarget=[[NSMutableAttributedString alloc] initWithString:fullTargetText];
            [aStrTarget addAttribute:NSForegroundColorAttributeName
                               value:UIColorFromRGB(0xe9a000)
                               range:rangeTargetWeight];
            
            self.lblTargetWeight.attributedText=aStrTarget;
            
            [AppDelegate shareUserInfo].targetWeight=_targetWeight;
            [AppDelegate shareUserInfo].targetWeightShow=targetShow;
            
            [_delegate uploadTargetToService];
            
            [self refreshMeasureData];
        }
    }
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
    
    
    self.lblTargetWeight.frame=CGRectMake(32, 20, SCREEN_WIDTH-32*2, 0.0625*SCREEN_WIDTH);
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTargeTeight:)];
    tap.delegate=self;
    self.lblTargetWeight.userInteractionEnabled=YES;
    [self.lblTargetWeight addGestureRecognizer:tap];
    
    self.lblTargetPlus.frame=CGRectMake(32, self.lblTargetWeight.frame.origin.y+self.lblTargetWeight.frame.size.height+20, SCREEN_WIDTH-32*2, 0.0625*SCREEN_WIDTH);
    
    self.viewTargetLineBottom.frame=CGRectMake(32, self.lblTargetPlus.frame.origin.y+self.lblTargetPlus.frame.size.height+8, SCREEN_WIDTH-32*2, 4);
    self.viewTargetLineFront.frame=CGRectMake(32, self.lblTargetPlus.frame.origin.y+self.lblTargetPlus.frame.size.height+8, SCREEN_WIDTH-32-32, 4);
    
    self.lblTargetLow.frame=CGRectMake(0, self.viewTargetLineFront.frame.origin.y-30, 60, self.lblTargetLow.frame.size.height);
    self.lblTargetHigh.frame=CGRectMake(SCREEN_WIDTH-60, self.viewTargetLineFront.frame.origin.y-30, 60, self.lblTargetLow.frame.size.height);
    
    //CGRect frame = CGRectMake((SCREEN_WIDTH-0.65625*SCREEN_WIDTH)/2, self.viewTargetLineBottom.frame.origin.y+self.viewTargetLineFront.frame.size.height+30, 0.65625*SCREEN_WIDTH, 0.65625*SCREEN_WIDTH);
    CGRect frame = CGRectMake((SCREEN_WIDTH-0.65625*SCREEN_WIDTH)/2, 35+30+5+30+50, 0.65625*SCREEN_WIDTH, 0.65625*SCREEN_WIDTH);
    
    /*
    MDRadialProgressView *radialView2= [[MDRadialProgressView alloc] initWithFrame:frame];
    radialView2.progressTotal = 5000*4;
    radialView2.progressCounter = 3000*3;
    radialView2.theme.thickness = 10;
    radialView2.theme.incompletedColor = [UIColor clearColor];
    radialView2.theme.completedColor = [UIColor orangeColor];
    radialView2.theme.sliceDividerHidden = YES;
    radialView2.label.hidden = YES;
    
    CGAffineTransform at =CGAffineTransformMakeRotation(225*M_PI/180.0);
    [radialView2 setTransform:at];
     */
    
    
    _radialView= [[MDRadialProgressView alloc] initWithFrame:frame];
    _radialView.progressTotal = 4;
    _radialView.progressCounter = 3;
    _radialView.theme.thickness = 14;
    _radialView.theme.incompletedColor = [UIColor clearColor];
    _radialView.theme.completedColor = UIColorFromRGB(0x00af00);
    _radialView.theme.sliceDividerHidden = YES;
    _radialView.label.hidden = YES;
    CGAffineTransform aTransform =CGAffineTransformMakeRotation(225*M_PI/180.0);
    _radialView.hidden=YES;
    [_radialView setTransform:aTransform];
    
    
    
    _radialViewFront = [[MDRadialProgressView alloc] initWithFrame:frame];
    _radialViewFront.progressTotal = 5000*4;
    _radialViewFront.progressCounter = 5000*3;
    _radialViewFront.theme.thickness = 14;
    _radialViewFront.theme.incompletedColor = [UIColor clearColor];
    _radialViewFront.theme.completedColor = UIColorFromRGB(0xd1d1d1);
    _radialViewFront.theme.sliceDividerHidden = YES;
    _radialViewFront.label.hidden = YES;
    
    CGAffineTransform atT =CGAffineTransformMakeRotation(225*M_PI/180.0);
    
    [_radialViewFront setTransform:atT];
    [self.scrollView addSubview:_radialViewFront];
    [self.scrollView addSubview:_radialView];
    
    self.lblWeight.frame=CGRectMake(frame.origin.x, frame.origin.y+frame.size.height/3, frame.size.width, self.lblWeight.frame.size.height);
    self.lblWeightBig.frame=self.lblWeight.frame;
    
    self.lblWeightUnit.frame=CGRectMake(frame.origin.x, self.lblWeight.frame.origin.y+self.lblWeight.frame.size.height+20, frame.size.width, self.lblWeightUnit.frame.size.height);
    
    self.lblWeightUnit.text = @"kg";
    NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
    if ([weightUnit isEqualToString:@"lb"]) {
        self.lblWeightUnit.text = weightUnit;
    }
    
    self.lblRangeBMITitle.frame=CGRectMake(32, frame.origin.y+frame.size.height+15, 100, 50);
    [self.lblRangeBMITitle sizeToFit];
    
    self.lblRangeBMI.frame=CGRectMake(self.lblRangeBMITitle.frame.origin.x+self.lblRangeBMITitle.frame.size.width+8, self.lblRangeBMITitle.frame.origin.y, 200, self.lblRangeBMITitle.frame.size.height);

    self.imageRangeLocation.frame=CGRectMake(32, self.lblRangeBMI.frame.origin.y+self.lblRangeBMI.frame.size.height+30, 12, 20);
    self.imageBMIRange.frame=CGRectMake(32, self.imageRangeLocation.frame.origin.y+self.imageRangeLocation.frame.size.height+2, SCREEN_WIDTH-32*2, 4);
    
    CGFloat lblWidth=(SCREEN_WIDTH-64)/3;
    self.lblRangeLow.frame=CGRectMake(32, self.imageBMIRange.frame.origin.y+self.imageBMIRange.frame.size.height+8, lblWidth, 0.0625*SCREEN_WIDTH);
    self.lblRangeNormal.frame=CGRectMake(32+lblWidth, self.imageBMIRange.frame.origin.y+self.imageBMIRange.frame.size.height+8, lblWidth, 0.0625*SCREEN_WIDTH);
    self.lblRangeHigh.frame=CGRectMake(32+lblWidth*2, self.imageBMIRange.frame.origin.y+self.imageBMIRange.frame.size.height+8, lblWidth, 0.0625*SCREEN_WIDTH);
    
    self.lblRangeLow.text = NSLocalizedString(@"range_low", nil);
    self.lblRangeNormal.text = NSLocalizedString(@"range_normal", nil);
    self.lblRangeHigh.text = NSLocalizedString(@"range_high", nil);
    
    self.scrollView.contentSize=CGSizeMake(SCREEN_WIDTH, self.lblRangeHigh.frame.origin.y+self.lblRangeHigh.frame.size.height+30);
    
    self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    if(self.lblRangeBMITitle.frame.origin.y+NAVBAR_HEIGHT>SCREEN_HEIGHT-TABBAR_HEIGHT)
    {
        _tableviewBottomY=SCREEN_HEIGHT-NAVBAR_HEIGHT-20;
        self.tableview.frame=CGRectMake(0, SCREEN_HEIGHT-NAVBAR_HEIGHT-20, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT);
    }
    else
    {
        _tableviewBottomY=self.lblRangeBMITitle.frame.origin.y+NAVBAR_HEIGHT;
        self.tableview.frame=CGRectMake(0, self.lblRangeBMITitle.frame.origin.y+NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT);
    }
    
    //self.tableview.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-NAVBAR_HEIGHT);
}

-(void)tapTargeTeight:(UITapGestureRecognizer *)tap
{
    [_delegate.tabController showTargetWeighgPicker:YES withTarget:_targetWeight showTarget:_targetShow];
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
 

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _aryProjectData.count+1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 30;
    }
    
    
    NSDictionary *dicTemp=[_aryProjectData objectAtIndex:indexPath.row-1];
    
    
    return [GMeasureCell getCellHeight:dicTemp];
    
    NSString *type=[dicTemp valueForKey:@"type"];
    if([type isEqual:DFalse])
    {
        return 0.1375*SCREEN_WIDTH;
    }
    
    return 0.40625*SCREEN_WIDTH-10;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
    {
        static NSString *cellID=@"GMeasureArrowCell";
        GMeasureArrowCell *cell=(GMeasureArrowCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        if(!cell)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"GMeasureArrowCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        
        return cell;
    }
    
    static NSString *cellID=@"gmeasurecell";
    GMeasureCell *cell=(GMeasureCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"GMeasureCell" owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *dicTemp=[_aryProjectData objectAtIndex:indexPath.row-1];
    [cell configCellWithData:dicTemp];
    
    return cell;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if(indexPath.row == 0)
    {
        [self showTableviewScroll];
        return;
    }
    
    
    NSMutableDictionary *dicTemp=[_aryProjectData objectAtIndex:indexPath.row-1];
    NSString *type=[dicTemp valueForKey:@"type"];
    if([type isEqualToString:DTrue])
    {
        type=DFalse;
    }
    else
    {
        type=DTrue;
    }
    [dicTemp setObject:type forKey:@"type"];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
        CGFloat offsetY=scrollView.contentOffset.y;
        
        CGFloat tableY=self.tableview.frame.origin.y;
        
        CGFloat axisYTemp=NAVBAR_HEIGHT;
        
        if(self.tableview.frame.origin.y <= axisYTemp ||
           self.tableview.frame.origin.y >= _tableviewBottomY - 1)
        {
            _lastContentOffsetY=0;
        }
        
        //up
        if(offsetY-_lastContentOffsetY>=0)
        {
            _iPanState =0;
            if(tableY<=axisYTemp)
            {
                return;
            }
            
            tableY=tableY-offsetY;
            
            if(tableY<=axisYTemp)
            {
                tableY=axisYTemp;
            }
            
            self.tableview.frame=CGRectMake(0, tableY, CGRectGetWidth(self.tableview.frame), CGRectGetHeight(self.tableview.frame));
            
            _lastContentOffsetY=offsetY;
        }
        //down
        else
        {
            _iPanState=1;
            
            
            
            
            if(tableY >= _tableviewBottomY-1)
            {
                return;
            }
            
            _iPanState=1;
            
            tableY=tableY-(offsetY);
            
            if(tableY>=(_tableviewBottomY-1))
            {
                tableY=_tableviewBottomY;
            }
            
            self.tableview.frame=CGRectMake(0, tableY, CGRectGetWidth(self.tableview.frame), CGRectGetHeight(self.tableview.frame));
            
            _lastContentOffsetY=offsetY;
        }
        
        //self.tableview.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT);
    }
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        if(scrollView.tag == 22)
        {
            [self finishTableviewScroll];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.tag == 22)
    {
        [self finishTableviewScroll];
    }
}


-(void)showTableviewScroll
{
    if(self.tableview.frame.origin.y>=(NAVBAR_HEIGHT+150))
    {
        [UIView animateWithDuration:0.3f animations:^{
            [self.tableview setContentOffset:CGPointMake(0, 0)];
            self.tableview.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT);
            
            
        } completion:^(BOOL finished) {
            GMeasureArrowCell *cell=(GMeasureArrowCell *)[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.imageArrow.image=[UIImage imageNamed:@"guo_measure_arrow_down.png"];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            //[self.tableview setContentOffset:CGPointMake(0, 0)];
            //self.tableview.frame=CGRectMake(0, self.lblRangeBMITitle.frame.origin.y+NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT);
            
            [self.tableview setContentOffset:CGPointMake(0, 0)];
            self.tableview.frame=CGRectMake(0, _tableviewBottomY, SCREEN_WIDTH, self.tableview.frame.size.height);
            
        } completion:^(BOOL finished) {
            GMeasureArrowCell *cell=(GMeasureArrowCell *)[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.imageArrow.image=[UIImage imageNamed:@"guo_measure_arrow_up.png"];

        }];
        
    }
}


-(void)finishTableviewScroll
{
 
    if(_iPanState == 1)
    {
        if(self.tableview.frame.origin.y<=(_tableviewBottomY -50))
        {
            [UIView animateWithDuration:0.3f animations:^{
                
                [self.tableview setContentOffset:CGPointMake(0, 0)];
                self.tableview.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, self.tableview.frame.size.height);
                
                GMeasureArrowCell *cell=(GMeasureArrowCell *)[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell.imageArrow.image=[UIImage imageNamed:@"guo_measure_arrow_down.png"];
            }];
            
        }
        else
        {
            [UIView animateWithDuration:0.3f animations:^{
                
                [self.tableview setContentOffset:CGPointMake(0, 0)];
                self.tableview.frame=CGRectMake(0, _tableviewBottomY, SCREEN_WIDTH, self.tableview.frame.size.height);
                
                GMeasureArrowCell *cell=(GMeasureArrowCell *)[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell.imageArrow.image=[UIImage imageNamed:@"guo_measure_arrow_up.png"];
            }];
        }
    }
    else
    {
        if(self.tableview.frame.origin.y>=NAVBAR_HEIGHT+50)
        {
            [UIView animateWithDuration:0.3f animations:^{
                
                [self.tableview setContentOffset:CGPointMake(0, 0)];
                self.tableview.frame=CGRectMake(0, _tableviewBottomY, SCREEN_WIDTH, self.tableview.frame.size.height);
                
                GMeasureArrowCell *cell=(GMeasureArrowCell *)[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell.imageArrow.image=[UIImage imageNamed:@"guo_measure_arrow_up.png"];
            }];
            
        }
        else
        {
            [UIView animateWithDuration:0.3f animations:^{
                [self.tableview setContentOffset:CGPointMake(0, 0)];
                self.tableview.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, self.tableview.frame.size.height);
                
                GMeasureArrowCell *cell=(GMeasureArrowCell *)[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                cell.imageArrow.image=[UIImage imageNamed:@"guo_measure_arrow_down.png"];
            }];
            
            
        }
    }
    /*
    if(self.tableview.frame.origin.y>=(self.tableview.frame.size.height/2))
    {
        [UIView animateWithDuration:0.3f animations:^{
            [self.tableview setContentOffset:CGPointMake(0, 0)];
            self.tableview.frame=CGRectMake(0, self.lblRangeBMITitle.frame.origin.y+NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT);
            
            GMeasureArrowCell *cell=(GMeasureArrowCell *)[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.imageArrow.image=[UIImage imageNamed:@"guo_measure_arrow_up.png"];
        }];
        
        
    }
    else
    {
        if(self.tableview.frame.origin.y<=NAVBAR_HEIGHT)
        {
            return;
        }
        
        
        [UIView animateWithDuration:0.3f animations:^{
            [self.tableview setContentOffset:CGPointMake(0, 0)];
            self.tableview.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-TABBAR_HEIGHT);
            GMeasureArrowCell *cell=(GMeasureArrowCell *)[self.tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            cell.imageArrow.image=[UIImage imageNamed:@"guo_measure_arrow_down.png"];
        } completion:^(BOOL finished) {
            
        }];
        
       
    }
    */
    
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

- (IBAction)testShowMeasure:(id)sender {
    
    CGRect frame=self.lblWeight.frame;
    
    self.lblWeightBig.alpha=0.0;
    self.lblWeightBig.text=self.lblWeight.text;
    self.lblWeightBig.frame=CGRectMake(frame.origin.x-50, frame.origin.y-50, frame.size.width+100, frame.size.height+100);
    self.lblWeight.alpha=0.5;
    self.lblWeightBig.font=[UIFont systemFontOfSize:90];
    
    [UIView animateWithDuration:0.5f animations:^{
        self.lblWeight.alpha=0.0;
        self.lblWeightBig.alpha=1.0;
        
    } completion:^(BOOL finished) {
        self.lblWeight.alpha=1.0;
        self.lblWeightBig.alpha=0.0;
    }];
}
@end

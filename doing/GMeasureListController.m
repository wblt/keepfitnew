#import "GMeasureListController.h"
#import "GStepCell.h"
#import "GWeightCell.h"

@interface GMeasureListController ()
{
    NetworkModule *_jsonModel;
    DbModel *_db;
    NSString *_selectProject;
    
}
@end

@implementation GMeasureListController

- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _jsonModel=[[NetworkModule alloc] init];
    _db=[[DbModel alloc] init];
    
    _delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if(iPhone5)
    {
        self.tableview.frame=CGRectMake(0, 145, 320, 568-145);
        viewHeight=568;
    }
    else
    {
        self.tableview.frame=CGRectMake(0, 145, 320, 480-145);
        viewHeight=480;
    }
    
    //[self.tableview registerClass:[GWeightListCell class] forCellReuseIdentifier:@"gweightListcell"];
    //UINib *nib=[UINib nibWithNibName:@"GWeightListCell" bundle:nil];
    
    //[self.tableview registerNib:nib forCellReuseIdentifier:@"gweightListcell"];
    
    //[self.tableview registerClass:[GStepListCell class] forCellReuseIdentifier:@"gsteplistcell"];
    //UINib *nib1=[UINib nibWithNibName:@"GStepListCell" bundle:nil];
    
    //[self.tableview registerNib:nib1 forCellReuseIdentifier:@"gsteplistcell"];
    
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    
    if([[UIDevice currentDevice] systemVersion].floatValue>=7.0)
    {
        self.automaticallyAdjustsScrollViewInsets=NO;
        //self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.extendedLayoutIncludesOpaqueBars = NO;
        //self.modalPresentationCapturesStatusBarAppearance = NO;
    }
    
    [self initView];
    
    self.lblBMI.text=NSLocalizedString(@"m_bmi", nil);
    self.lblStep.text=NSLocalizedString(@"m_step", nil);
    self.lblWeight.text=NSLocalizedString(@"m_weight", nil);
    self.lblFat.text=NSLocalizedString(@"m_fat", nil);
    self.lblWater.text=NSLocalizedString(@"m_water", nil);
    self.lblMuscle.text=NSLocalizedString(@"m_muscle", nil);
    self.lblBasic.text=NSLocalizedString(@"m_basic", nil);
    self.lblBone.text=NSLocalizedString(@"m_bone", nil);
    self.lblVisceralfat.text=NSLocalizedString(@"m_visceralfat", nil);
    self.lblBodyage.text=NSLocalizedString(@"m_bodyage", nil);
    self.lblHeight.text=NSLocalizedString(@"m_height", nil);
    self.lblTitle.text=NSLocalizedString(@"title_measurelist", nil);
    
    [self changeStep:nil];
    
    
    self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    _jsonModule=[[NetworkModule alloc] init];


    [self initVar];
    
}

-(void)initView
{
    
    self.lblTitle.font=[UIFont systemFontOfSize:iPhone5FontSizeTitle];
    if(is_iPhone6)
    {
        self.lblTitle.font=[UIFont systemFontOfSize:iPhone6FontSizeTitle];
    }
    else if (is_iPhone6P)
    {
        self.lblTitle.font=[UIFont systemFontOfSize:iPhone6PFontSizeTitle];
    }
    
    
    self.viewTop.frame=CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT);
    self.lblTitle.frame=CGRectMake(0, 20, SCREEN_WIDTH, 44);
    
    self.scrollView.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, 80);
    self.imageLine.frame=CGRectMake(15, self.scrollView.frame.origin.y+self.scrollView.frame.size.height, SCREEN_WIDTH-15, 1);
    
    self.tableview.frame=CGRectMake(0, self.imageLine.frame.origin.y+1, SCREEN_WIDTH, SCREEN_HEIGHT-self.imageLine.frame.origin.y-1);

    
    self.scrollView.contentSize=CGSizeMake(80*10, 0);
    self.scrollView.showsHorizontalScrollIndicator=NO;
    self.scrollView.showsVerticalScrollIndicator=NO;
    self.scrollView.contentOffset=CGPointMake(0, 0);
    
    //步行 体重 BMI  脂肪 水分 肌肉 骨量 基础代谢 内脏脂肪 身体年龄
    
    self.viewStep.frame=CGRectMake(0, 0, 80, 80);
    self.viewWeight.frame=CGRectMake(80, 0, 80, 80);
    self.viewBMI.frame=CGRectMake(80*2, 0, 80, 80);
    self.viewFat.frame=CGRectMake(80*3, 0, 80, 80);
    self.viewWater.frame=CGRectMake(80*4, 0, 80, 80);
    self.viewMuscle.frame=CGRectMake(80*5, 0, 80, 80);
    self.viewBone.frame=CGRectMake(80*6, 0, 80, 80);
    self.viewBasic.frame=CGRectMake(80*7, 0, 80, 80);
    self.viewVisceralfat.frame=CGRectMake(80*8, 0, 80, 80);
    self.viewBodyage.frame=CGRectMake(80*9, 0, 80, 80);
    //self.viewHeight.frame=CGRectMake(80*9, 0, 80, 80);
    
}

-(void)initBodyageData
{
    //身体年龄
    NSArray *allBodyAgeInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectBodyAge];
    NSMutableArray *aryTempBodyAge;
    dictBodyAge=[[NSMutableDictionary alloc] init];
    arySectiionBodyAge=[[NSMutableArray alloc] init];
    dicSectionYearBodyAge=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allBodyAgeInfo count];i++)
    {
        NSArray *tempWeightAry=[allBodyAgeInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictBodyAge allKeys] containsObject:strTime2])
        {
            aryTempBodyAge=[[NSMutableArray alloc] init];
            [dictBodyAge setObject:aryTempBodyAge forKey:strTime2];
            [arySectiionBodyAge addObject:strTime2];
        }
        
        
        NSMutableArray *aryNew=[dictBodyAge objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
}

-(void)initVisceralfatData
{
    //内脏脂肪
    NSArray *allVisceralfatInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectVisceralFat];
    NSMutableArray *aryTempVisceralfat;
    dictVisceralfat=[[NSMutableDictionary alloc] init];
    arySectiionVisceralfat=[[NSMutableArray alloc] init];
    dicSectionYearVisceralfat=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allVisceralfatInfo count];i++)
    {
        NSArray *tempWeightAry=[allVisceralfatInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictVisceralfat allKeys] containsObject:strTime2])
        {
            aryTempVisceralfat=[[NSMutableArray alloc] init];
            [dictVisceralfat setObject:aryTempVisceralfat forKey:strTime2];
            [arySectiionVisceralfat addObject:strTime2];
        }
        
        NSMutableArray *aryNew=[dictVisceralfat objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
}

-(void)initVar
{
    if(_db == nil)
    {
        _db=[[DbModel alloc] init];
    }
    
    
    NSArray *allBMIInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectBMI];
    
    NSMutableArray *aryTempBMI;
    dictBMI=[[NSMutableDictionary alloc] init];
    arySectiionBMI=[[NSMutableArray alloc] init];
    dicSectionYearBMI=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allBMIInfo count];i++)
    {
        NSArray *tempBMIAry=[allBMIInfo objectAtIndex:i];
        
        NSString *time=[tempBMIAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictBMI allKeys] containsObject:strTime2])
        {
            aryTempBMI=[[NSMutableArray alloc] init];
            [dictBMI setObject:aryTempBMI forKey:strTime2];
            [arySectiionBMI addObject:strTime2];
        }
        NSMutableArray *aryNew=[dictBMI objectForKey:strTime2];
        [aryNew addObject:[tempBMIAry copy]];
    }
    

    NSArray *allWeightInfo=[_db selectAllWeightWithCTime:[AppDelegate shareUserInfo].account_ctime];
    
    NSMutableArray *aryTemp;
    dictWeight=[[NSMutableDictionary alloc] init];
    arySectiion=[[NSMutableArray alloc] init];
    dicSectionYear=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allWeightInfo count];i++)
    {
        NSArray *tempWeightAry=[allWeightInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictWeight allKeys] containsObject:strTime2])
        {
            aryTemp=[[NSMutableArray alloc] init];
            [dictWeight setObject:aryTemp forKey:strTime2];
            [arySectiion addObject:strTime2];
        }
        NSMutableArray *aryNew=[dictWeight objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
    
    
    NSArray *allFatInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectFat];
    
    NSMutableArray *aryTempFat;
    dictFat=[[NSMutableDictionary alloc] init];
    arySectiionFat=[[NSMutableArray alloc] init];
    dicSectionYearFat=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allFatInfo count];i++)
    {
        NSArray *tempWeightAry=[allFatInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictFat allKeys] containsObject:strTime2])
        {
            aryTempFat=[[NSMutableArray alloc] init];
            [dictFat setObject:aryTempFat forKey:strTime2];
            [arySectiionFat addObject:strTime2];
        }
        NSMutableArray *aryNew=[dictFat objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
    
    
    NSArray *allWaterInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectWater];
    NSMutableArray *aryTempWater;
    dictWater=[[NSMutableDictionary alloc] init];
    arySectiionWater=[[NSMutableArray alloc] init];
    dicSectionYearWater=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allWaterInfo count];i++)
    {
        NSArray *tempWeightAry=[allWaterInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictWater allKeys] containsObject:strTime2])
        {
            aryTempWater=[[NSMutableArray alloc] init];
            [dictWater setObject:aryTempWater forKey:strTime2];
            [arySectiionWater addObject:strTime2];
        }
        NSMutableArray *aryNew=[dictWater objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
    
    
    NSArray *allMuscleInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectMuscle];
    NSMutableArray *aryTempMuscle;
    dictMuscle=[[NSMutableDictionary alloc] init];
    arySectiionMuscle=[[NSMutableArray alloc] init];
    dicSectionYearMuscle=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allMuscleInfo count];i++)
    {
        NSArray *tempWeightAry=[allMuscleInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictMuscle allKeys] containsObject:strTime2])
        {
            aryTempMuscle=[[NSMutableArray alloc] init];
            [dictMuscle setObject:aryTempMuscle forKey:strTime2];
            [arySectiionMuscle addObject:strTime2];
        }
        NSMutableArray *aryNew=[dictMuscle objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
    
    NSArray *allBasicInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectBasic];
    NSMutableArray *aryTempBasic;
    dictBasic=[[NSMutableDictionary alloc] init];
    arySectiionBasic=[[NSMutableArray alloc] init];
    dicSectionYearBasic=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allBasicInfo count];i++)
    {
        NSArray *tempWeightAry=[allBasicInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictBasic allKeys] containsObject:strTime2])
        {
            aryTempBasic=[[NSMutableArray alloc] init];
            [dictBasic setObject:aryTempBasic forKey:strTime2];
            [arySectiionBasic addObject:strTime2];
        }
        NSMutableArray *aryNew=[dictBasic objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
    
    NSArray *allBoneInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectBone];
    NSMutableArray *aryTempBone;
    dictBone=[[NSMutableDictionary alloc] init];
    arySectiionBone=[[NSMutableArray alloc] init];
    dicSectionYearBone=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allBoneInfo count];i++)
    {
        NSArray *tempWeightAry=[allBoneInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictBone allKeys] containsObject:strTime2])
        {
            aryTempBone=[[NSMutableArray alloc] init];
            [dictBone setObject:aryTempBone forKey:strTime2];
            [arySectiionBone addObject:strTime2];
        }
        NSMutableArray *aryNew=[dictBone objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
    
    //内脏脂肪
    NSArray *allVisceralfatInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectVisceralFat];
    NSMutableArray *aryTempVisceralfat;
    dictVisceralfat=[[NSMutableDictionary alloc] init];
    arySectiionVisceralfat=[[NSMutableArray alloc] init];
    dicSectionYearVisceralfat=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allVisceralfatInfo count];i++)
    {
        NSArray *tempWeightAry=[allVisceralfatInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictVisceralfat allKeys] containsObject:strTime2])
        {
            aryTempVisceralfat=[[NSMutableArray alloc] init];
            [dictVisceralfat setObject:aryTempVisceralfat forKey:strTime2];
            [arySectiionVisceralfat addObject:strTime2];
        }
        
        NSMutableArray *aryNew=[dictVisceralfat objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
    
    
    //身体年龄
    NSArray *allBodyAgeInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectBodyAge];
    NSMutableArray *aryTempBodyAge;
    dictBodyAge=[[NSMutableDictionary alloc] init];
    arySectiionBodyAge=[[NSMutableArray alloc] init];
    dicSectionYearBodyAge=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allBodyAgeInfo count];i++)
    {
        NSArray *tempWeightAry=[allBodyAgeInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictBodyAge allKeys] containsObject:strTime2])
        {
            aryTempBodyAge=[[NSMutableArray alloc] init];
            [dictBodyAge setObject:aryTempBodyAge forKey:strTime2];
            [arySectiionBodyAge addObject:strTime2];
        }
        
        
        NSMutableArray *aryNew=[dictBodyAge objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
    
    
    //身高
    NSArray *allHeightInfo=[_db selectAllMeasureDataWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectHeight];
    NSMutableArray *aryTempHeight;
    dictHeight=[[NSMutableDictionary alloc] init];
    arySectiionHeight=[[NSMutableArray alloc] init];
    dicSectionYearHeight=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allHeightInfo count];i++)
    {
        NSArray *tempWeightAry=[allHeightInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictHeight allKeys] containsObject:strTime2])
        {
            aryTempHeight=[[NSMutableArray alloc] init];
            [dictHeight setObject:aryTempHeight forKey:strTime2];
            [arySectiionHeight addObject:strTime2];
        }
        NSMutableArray *aryNew=[dictHeight objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
    
    
    //步数
    NSArray *allStepInfo=[_db selectAllStepWithCTime:[AppDelegate shareUserInfo].account_ctime];
    NSMutableArray *aryTempStep;
    dictStep=[[NSMutableDictionary alloc] init];
    arySectiionStep=[[NSMutableArray alloc] init];
    dicSectionYearStep=[[NSMutableDictionary alloc] init];
    for(int i=0;i<[allStepInfo count];i++)
    {
        NSArray *tempWeightAry=[allStepInfo objectAtIndex:i];
        
        NSString *time=[tempWeightAry objectAtIndex:2];
        
        NSString *strTime2=[time substringToIndex:10];
        if(![[dictStep allKeys] containsObject:strTime2])
        {
            aryTempStep=[[NSMutableArray alloc] init];
            [dictStep setObject:aryTempStep forKey:strTime2];
            [arySectiionStep addObject:strTime2];
        }
        
        NSMutableArray *aryNew=[dictStep objectForKey:strTime2];
        [aryNew addObject:[tempWeightAry copy]];
    }
    
    [self.tableview reloadData];
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


#pragma mark - 键盘处理

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (IBAction)showLeftMenu:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_selectProject isEqualToString:ProjectFat])
    {
        if([arySectiionFat count]<=0) return 0;
        NSString *strTime=[arySectiionFat objectAtIndex:section];
        NSMutableArray *tempAry=[dictFat objectForKey:strTime];
        return [tempAry count];
    }
    else if ([_selectProject isEqualToString:ProjectBMI])
    {
        if([arySectiionBMI count]<=0) return 0;
        NSString *strTime=[arySectiionBMI objectAtIndex:section];
        NSMutableArray *tempAry=[dictBMI objectForKey:strTime];
        return [tempAry count];
    }
    else if ([_selectProject isEqualToString:ProjectMuscle])
    {
        if([arySectiionMuscle count]<=0) return 0;
        NSString *strTime=[arySectiionMuscle objectAtIndex:section];
        NSMutableArray *tempAry=[dictMuscle objectForKey:strTime];
        return [tempAry count];
    }
    else if ([_selectProject isEqualToString:ProjectWater])
    {
        if([arySectiionWater count]<=0) return 0;
        NSString *strTime=[arySectiionWater objectAtIndex:section];
        NSMutableArray *tempAry=[dictWater objectForKey:strTime];
        return [tempAry count];
    }
    else if ([_selectProject isEqualToString:ProjectBone])
    {
        if([arySectiionBone count]<=0) return 0;
        NSString *strTime=[arySectiionBone objectAtIndex:section];
        NSMutableArray *tempAry=[dictBone objectForKey:strTime];
        return [tempAry count];
    }
    else if ([_selectProject isEqualToString:ProjectBasic])
    {
        if([arySectiionBasic count]<=0) return 0;
        NSString *strTime=[arySectiionBasic objectAtIndex:section];
        NSMutableArray *tempAry=[dictBasic objectForKey:strTime];
        return [tempAry count];
    }
    else if([_selectProject isEqualToString:ProjectWeight])
    {
        if([arySectiion count]<=0) return 0;
        NSString *strTime=[arySectiion objectAtIndex:section];
        NSMutableArray *tempAry=[dictWeight objectForKey:strTime];
        return [tempAry count];
    }
    else if([_selectProject isEqualToString:ProjectVisceralFat])
    {
        if([arySectiionVisceralfat count]<=0) return 0;
        NSString *strTime=[arySectiionVisceralfat objectAtIndex:section];
        NSMutableArray *tempAry=[dictVisceralfat objectForKey:strTime];
        return [tempAry count];
    }
    else if([_selectProject isEqualToString:ProjectStepCount])
    {
        if([arySectiionStep count]<=0) return 0;
        NSString *strTime=[arySectiionStep objectAtIndex:section];
        NSMutableArray *tempAry=[dictStep objectForKey:strTime];
        return [tempAry count];
    }
    else if([_selectProject isEqualToString:ProjectBodyAge])
    {
        if([arySectiionBodyAge count]<=0) return 0;
        NSString *strTime=[arySectiionBodyAge objectAtIndex:section];
        NSMutableArray *tempAry=[dictBodyAge objectForKey:strTime];
        return [tempAry count];
    }
    else if([_selectProject isEqualToString:ProjectHeight])
    {
        if([arySectiionHeight count]<=0) return 0;
        NSString *strTime=[arySectiionHeight objectAtIndex:section];
        NSMutableArray *tempAry=[dictHeight objectForKey:strTime];
        return [tempAry count];
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if([_selectProject isEqualToString:ProjectFat])
    {
        if([arySectiionFat count]<=0) return 0;
        return [arySectiionFat count];
    }
    else if ([_selectProject isEqualToString:ProjectBMI])
    {
        if([arySectiionBMI count]<=0) return 0;
        return [arySectiionBMI count];
    }
    else if ([_selectProject isEqualToString:ProjectMuscle])
    {
        if([arySectiionMuscle count]<=0) return 0;
        return [arySectiionMuscle count];
    }
    else if ([_selectProject isEqualToString:ProjectWater])
    {
        if([arySectiionWater count]<=0) return 0;
        return [arySectiionWater count];
    }
    else if ([_selectProject isEqualToString:ProjectBone])
    {
        if([arySectiionBone count]<=0) return 0;
        return [arySectiionBone count];
    }
    else if ([_selectProject isEqualToString:ProjectBasic])
    {
        if([arySectiionBasic count]<=0) return 0;
        return [arySectiionBasic count];
    }
    else if([_selectProject isEqualToString:ProjectWeight])
    {
        if([arySectiion count]<=0) return 0;
        return [arySectiion count];
    }
    else if([_selectProject isEqualToString:ProjectVisceralFat])
    {
        if([arySectiionVisceralfat count]<=0) return 0;
        return [arySectiionVisceralfat count];
    }
    else if([_selectProject isEqualToString:ProjectStepCount])
    {
        if([arySectiionStep count]<=0) return 0;
        return [arySectiionStep count];
    }
    else if([_selectProject isEqualToString:ProjectBodyAge])
    {
        if([arySectiionBodyAge count]<=0) return 0;
        return [arySectiionBodyAge count];
    }
    else if([_selectProject isEqualToString:ProjectHeight])
    {
        if([arySectiionHeight count]<=0) return 0;
        return [arySectiionHeight count];
    }
    return 0;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.1375*SCREEN_WIDTH;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    headView.backgroundColor=[UIColor whiteColor];
    UILabel *label1;
    if(section == 0)
    {
        label1=[[UILabel alloc]initWithFrame:CGRectMake(30, 10, 320, 20)];
    }
    else
    {
        label1=[[UILabel alloc]initWithFrame:CGRectMake(30, 10, 320, 20)];
    }
    
    
    
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(16, 11, 18, 18)];
    imageView.image=[UIImage imageNamed:@"d_clock_black.png"];
    
    
    NSMutableArray *aryTemp=nil;
    NSMutableDictionary *dicTemp=nil;
    if([_selectProject isEqualToString:ProjectFat])
    {
        aryTemp=arySectiionFat;
        dicTemp=dicSectionYearFat;
    }
    else if ([_selectProject isEqualToString:ProjectBMI])
    {
        aryTemp=arySectiionBMI;
        dicTemp=dicSectionYearBMI;
    }
    else if ([_selectProject isEqualToString:ProjectMuscle])
    {
        aryTemp=arySectiionMuscle;
        dicTemp=dicSectionYearMuscle;
    }
    else if ([_selectProject isEqualToString:ProjectWater])
    {
        aryTemp=arySectiionWater;
        dicTemp=dicSectionYearWater;
    }
    else if ([_selectProject isEqualToString:ProjectBone])
    {
        aryTemp=arySectiionBone;
        dicTemp=dicSectionYearBone;
    }
    else if ([_selectProject isEqualToString:ProjectBasic])
    {
        aryTemp=arySectiionBasic;
        dicTemp=dicSectionYearBasic;
    }
    else if([_selectProject isEqualToString:ProjectWeight])
    {
        aryTemp=arySectiion;
        dicTemp=dicSectionYear;
    }
    else if([_selectProject isEqualToString:ProjectVisceralFat])
    {
        aryTemp=arySectiionVisceralfat;
        dicTemp=dicSectionYearVisceralfat;
    }
    else if([_selectProject isEqualToString:ProjectStepCount])
    {
        aryTemp=arySectiionStep;
        dicTemp=dicSectionYearStep;
    }
    else if([_selectProject isEqualToString:ProjectBodyAge])
    {
        aryTemp=arySectiionBodyAge;
        dicTemp=dicSectionYearBodyAge;
    }
    else if([_selectProject isEqualToString:ProjectHeight])
    {
        aryTemp=arySectiionHeight;
        dicTemp=dicSectionYearHeight;
    }
    
    NSString *strTime=[aryTemp objectAtIndex:section];
    NSString *strYear=[strTime substringWithRange:NSMakeRange(0, 4)];
    NSString *strMonth=[strTime substringWithRange:NSMakeRange(5, 2)];
    NSString *strDay=[strTime substringWithRange:NSMakeRange(8, 2)];
    
    NSString *yearTitle=NSLocalizedString(@"weightlist_year", nil);
    NSString *monthTitle=NSLocalizedString(@"weightlist_month", nil);
    NSString *dayTitle=NSLocalizedString(@"weightlist_day", nil);
    
    if([[dicTemp allKeys] containsObject:strYear])
    {
        NSString *strSection=[dicTemp valueForKey:strYear];
        if([strSection intValue] == section)
        {
            label1.text=[NSString stringWithFormat:@"%@%@%@%@%@%@",strYear,yearTitle,strMonth,monthTitle,strDay,dayTitle];
        }
        else
        {
            label1.text=[NSString stringWithFormat:@"%@%@%@%@",strMonth,monthTitle,strDay,dayTitle];
        }
        
    }
    else
    {
        label1.text=[NSString stringWithFormat:@"%@%@%@%@%@%@",strYear,yearTitle,strMonth,monthTitle,strDay,dayTitle];
        NSString *strSection=[NSString stringWithFormat:@"%ld",(long)section];
        [dicTemp setObject:strSection forKey:strYear];
    }
    //label1.text=[arySectiion objectAtIndex:section];
    label1.textColor=[UIColor blackColor];
    label1.font=[UIFont systemFontOfSize:iPhone5FontSizeTitle];
    if(is_iPhone6)
    {
        label1.font=[UIFont systemFontOfSize:iPhone6FontSizeTitle];
    }
    else if (is_iPhone6P)
    {
        label1.font=[UIFont systemFontOfSize:iPhone6PFontSizeTitle];
    }
    
    label1.backgroundColor=[UIColor clearColor];
    [headView addSubview:imageView];
    [headView addSubview:label1];
    return headView ;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *arySectionTemp=nil;
    NSMutableDictionary *dicTemp=nil;
    NSMutableDictionary *dicDataTemp=nil;
    NSString *strUnit=@"kg";
    if([_selectProject isEqualToString:ProjectFat])
    {
        arySectionTemp=arySectiionFat;
        dicTemp=dicSectionYearFat;
        dicDataTemp=dictFat;
        strUnit=@"%";
    }
    else if([_selectProject isEqualToString:ProjectBMI])
    {
        arySectionTemp=arySectiionBMI;
        dicTemp=dicSectionYearBMI;
        dicDataTemp=dictBMI;
        strUnit=@"";
    }
    else if ([_selectProject isEqualToString:ProjectMuscle])
    {
        arySectionTemp=arySectiionMuscle;
        dicTemp=dicSectionYearMuscle;
        dicDataTemp=dictMuscle;
        strUnit=@"%";
    }
    else if ([_selectProject isEqualToString:ProjectWater])
    {
        arySectionTemp=arySectiionWater;
        dicTemp=dicSectionYearWater;
        dicDataTemp=dictWater;
        strUnit=@"%";
    }
    else if ([_selectProject isEqualToString:ProjectBone])
    {
        arySectionTemp=arySectiionBone;
        dicTemp=dicSectionYearBone;
        dicDataTemp=dictBone;
        strUnit=@"%";
        /*
        NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
        if ([weightUnit isEqualToString:@"lb"]) {
            strUnit=@"lb";
        }
         */
    }
    else if ([_selectProject isEqualToString:ProjectBasic])
    {
        arySectionTemp=arySectiionBasic;
        dicTemp=dicSectionYearBasic;
        dicDataTemp=dictBasic;
        strUnit=@"kcal";
    }
    else if ([_selectProject isEqualToString:ProjectVisceralFat])
    {
        arySectionTemp=arySectiionVisceralfat;
        dicTemp=dicSectionYearVisceralfat;
        dicDataTemp=dictVisceralfat;
        strUnit=@"";
    }
    else if([_selectProject isEqualToString:ProjectWeight])
    {
        arySectionTemp=arySectiion;
        dicTemp=dicSectionYear;
        dicDataTemp=dictWeight;
        strUnit=@"kg";
        NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
        if ([weightUnit isEqualToString:@"lb"]) {
            strUnit = @"lb";
        }
    }
    else if([_selectProject isEqualToString:ProjectStepCount])
    {
        arySectionTemp=arySectiionStep;
        dicTemp=dicSectionYearStep;
        dicDataTemp=dictStep;
        strUnit=@"kcal";
    }
    else if([_selectProject isEqualToString:ProjectBodyAge])
    {
        arySectionTemp=arySectiionBodyAge;
        dicTemp=dicSectionYearBodyAge;
        dicDataTemp=dictBodyAge;
        strUnit=NSLocalizedString(@"身体年龄Unit", nil);
    }
    else if([_selectProject isEqualToString:ProjectHeight])
    {
        arySectionTemp=arySectiionHeight;
        dicTemp=dicSectionYearHeight;
        dicDataTemp=dictHeight;
        strUnit=@"cm";
    }
    
     NSString *strTime=[arySectionTemp objectAtIndex:indexPath.section];
    
    NSMutableArray *aryData=[dicDataTemp objectForKey:strTime];
    NSArray *rowData=[aryData objectAtIndex:indexPath.row];
    //double dWeight=0.0;
    
    if([_selectProject isEqualToString:ProjectStepCount])
    {
        static NSString *cellID=@"GStepCell";
        GStepCell *cell=(GStepCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        if(!cell)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"GStepCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }

        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        //cell.backgroundColor=[UIColor clearColor];
        //cell.backgroundView.backgroundColor=[UIColor clearColor];
        
        [cell configCellWithData:rowData];
        return cell;
    }
    else
    {
        static NSString *gcellID=@"gweightcell";
        GWeightCell *cell=(GWeightCell *)[tableView dequeueReusableCellWithIdentifier:gcellID];
        if(!cell)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"GWeightCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        
        NSString *value=[rowData objectAtIndex:3];
        if([_selectProject isEqualToString:ProjectBasic] ||
           [_selectProject isEqualToString:ProjectVisceralFat] ||
           [_selectProject isEqualToString:ProjectBodyAge])
        {
            value=[NSString stringWithFormat:@"%d",[value intValue]];
        }
        
        NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
        if ([weightUnit isEqualToString:@"lb"] && [_selectProject isEqualToString:ProjectWeight]) {
            value = [PublicModule kgToLb:value];
        }
        
        /*
        if ([weightUnit isEqualToString:@"lb"] && [_selectProject isEqualToString:ProjectBone]) {
            value = [PublicModule kgToLb:value];
        }
        */
        
        cell.lblProjectValue.text=[value stringByAppendingString:strUnit];
        
        
        NSString *time=[rowData objectAtIndex:2];
        time=[time substringWithRange:NSMakeRange(11, 5)];
        cell.lblTime.text=time;
        
        return cell;
    }
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        _selectedIndexPath=indexPath;
        [self showDeleteInfo:NSLocalizedString(@"weightlist_deleteinfo", nil)];
    }
}

- (void)showDeleteInfo:(NSString *)info
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:info delegate:self cancelButtonTitle:NSLocalizedString(@"weightlist_ok", nil) otherButtonTitles:NSLocalizedString(@"weightlist_cancle", nil), nil];
    [alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(0 == buttonIndex)
    {
        /*
        [Dialog simpleToast:@"不给删，不给删~~~"];
        self.tableview.editing=NO;
        return;
        */
        
        
        NSMutableArray *arySectionTemp=nil;
        NSMutableDictionary *dicDataTemp=nil;
        if([_selectProject isEqualToString:ProjectFat])
        {
            arySectionTemp=arySectiionFat;
            dicDataTemp=dictFat;
        }
        else if ([_selectProject isEqualToString:ProjectBMI])
        {
            arySectionTemp=arySectiionBMI;
            dicDataTemp=dictBMI;
        }
        else if ([_selectProject isEqualToString:ProjectMuscle])
        {
            arySectionTemp=arySectiionMuscle;
            dicDataTemp=dictMuscle;
        }
        else if ([_selectProject isEqualToString:ProjectWater])
        {
            arySectionTemp=arySectiionWater;
            dicDataTemp=dictWater;
        }
        else if ([_selectProject isEqualToString:ProjectBone])
        {
            arySectionTemp=arySectiionBone;
            dicDataTemp=dictBone;
        }
        else if ([_selectProject isEqualToString:ProjectBasic])
        {
            arySectionTemp=arySectiionBasic;
            dicDataTemp=dictBasic;
        }
        else if ([_selectProject isEqualToString:ProjectWeight])
        {
            arySectionTemp=arySectiion;
            dicDataTemp=dictWeight;
        }
        else if ([_selectProject isEqualToString:ProjectVisceralFat])
        {
            arySectionTemp=arySectiionVisceralfat;
            dicDataTemp=dictVisceralfat;
        }
        else if ([_selectProject isEqualToString:ProjectStepCount])
        {
            arySectionTemp=arySectiionStep;
            dicDataTemp=dictStep;
        }
        else if ([_selectProject isEqualToString:ProjectBodyAge])
        {
            arySectionTemp=arySectiionBodyAge;
            dicDataTemp=dictBodyAge;
        }
        else if ([_selectProject isEqualToString:ProjectHeight])
        {
            arySectionTemp=arySectiionHeight;
            dicDataTemp=dictHeight;
        }
        
        NSString *time=[arySectionTemp objectAtIndex:_selectedIndexPath.section];
        NSMutableArray *aryData=[dicDataTemp objectForKey:time];
        NSMutableArray *rowData=[aryData objectAtIndex:_selectedIndexPath.row];
        NSString *rowID=[rowData objectAtIndex:0];
        NSString *strTime=[rowData objectAtIndex:2];
        
        
        
        BOOL ret=NO;
        if([_selectProject isEqualToString:ProjectStepCount])
        {
            
            ret=[_db deleteStepWithCTime:[AppDelegate shareUserInfo].account_ctime andDate:strTime];
        }
        else
        {
            ret=[_db deleteWeight:rowID];
        }
        
        if(ret)
        {
            if([aryData count] == 1)
            {
                [arySectionTemp removeObjectAtIndex:_selectedIndexPath.section];
                [dicDataTemp removeObjectForKey:time];
                
                [self.tableview deleteSections:[NSIndexSet indexSetWithIndex:_selectedIndexPath.section]
                                    withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                [aryData removeObjectAtIndex:_selectedIndexPath.row];
                [self.tableview deleteRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            [self.tableview reloadData];
        }
    }
    else if(1 == buttonIndex)
    {
        self.tableview.editing=NO;
        return;
    }
    
}



-(void)resetViewTop
{
    self.imageBmi.image=[UIImage imageNamed:@"guo_mine_bmi_black.png"];
    self.imageStep.image=[UIImage imageNamed:@"guo_mine_step_black.png"];
    self.imageVisceralfat.image=[UIImage imageNamed:@"guo_mine_viscerafat_black.png"];
    self.imageWeight.image=[UIImage imageNamed:@"guo_mine_weight_black.png"];
    self.imageFat.image=[UIImage imageNamed:@"guo_mine_fat_black.png"];
    self.imageWater.image=[UIImage imageNamed:@"guo_mine_water_black.png"];
    self.imageMuscle.image=[UIImage imageNamed:@"guo_mine_muscle_black.png"];
    self.imageBasic.image=[UIImage imageNamed:@"guo_mine_bmr_black.png"];
    self.imageBone.image=[UIImage imageNamed:@"guo_mine_bone_black.png"];
    
    self.imageBodyage.image=[UIImage imageNamed:@"guo_mine_bodyage_black.png"];
    self.imageHeight.image=[UIImage imageNamed:@"guo_mine_bone_black.png"];
    
    
    self.lblBMI.textColor=[UIColor blackColor];
    self.lblVisceralfat.textColor=[UIColor blackColor];
    self.lblStep.textColor=[UIColor blackColor];
    self.lblWeight.textColor=[UIColor blackColor];
    self.lblFat.textColor=[UIColor blackColor];
    self.lblWater.textColor=[UIColor blackColor];
    self.lblMuscle.textColor=[UIColor blackColor];
    self.lblBasic.textColor=[UIColor blackColor];
    self.lblBone.textColor=[UIColor blackColor];
    self.lblBodyage.textColor=[UIColor blackColor];
    self.lblHeight.textColor=[UIColor blackColor];
    
}

- (IBAction)changeBMI:(id)sender {
    
    [self resetViewTop];
    _selectProject=ProjectBMI;
    self.lblBMI.textColor=UIColorFromRGB(0x00af00);
    self.imageBmi.image=[UIImage imageNamed:@"guo_mine_bmi_green.png"];
    [self.tableview reloadData];
}

- (IBAction)changeBodyage:(id)sender {
    [self resetViewTop];
    _selectProject=ProjectBodyAge;
    self.lblBodyage.textColor=UIColorFromRGB(0x00af00);
    self.imageBodyage.image=[UIImage imageNamed:@"guo_mine_bodyage_green.png"];
    [self.tableview reloadData];
    /*
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.contentOffset=CGPointMake(400, 0);
    }];
     */
}

- (IBAction)changeHeight:(id)sender {
    [self resetViewTop];
    _selectProject=ProjectHeight;
    self.lblHeight.textColor=UIColorFromRGB(0x00af00);
    self.imageHeight.image=[UIImage imageNamed:@"guo_mine_bone_green.png"];
    [self.tableview reloadData];
}

- (IBAction)changeVisceralfat:(id)sender
{
    [self resetViewTop];
    _selectProject=ProjectVisceralFat;
    self.lblVisceralfat.textColor=UIColorFromRGB(0x00af00);
    self.imageVisceralfat.image=[UIImage imageNamed:@"guo_mine_viscerafat_green.png"];
    [self.tableview reloadData];
  
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.contentOffset=CGPointMake(320, 0);
    }];
}

- (IBAction)changeStep:(id)sender {
    
    [self resetViewTop];
    _selectProject=ProjectStepCount;
    self.lblStep.textColor=UIColorFromRGB(0x00af00);
    self.imageStep.image=[UIImage imageNamed:@"guo_mine_step_green.png"];
    [self.tableview reloadData];
    
}


- (IBAction)changeWeight:(id)sender {
    
    [self resetViewTop];
    _selectProject=ProjectWeight;
    self.lblWeight.textColor=UIColorFromRGB(0x00af00);
    self.imageWeight.image=[UIImage imageNamed:@"guo_mine_weight_green.png"];
    [self.tableview reloadData];
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.contentOffset=CGPointMake(0, 0);
    }];
  
}

- (IBAction)changeFat:(id)sender
{
    [self resetViewTop];
    _selectProject=ProjectFat;
    self.lblFat.textColor=UIColorFromRGB(0x00af00);
    self.imageFat.image=[UIImage imageNamed:@"guo_mine_fat_green.png"];
    [self.tableview reloadData];

    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.contentOffset=CGPointMake(0, 0);
    }];
    
}

- (IBAction)changeWater:(id)sender {
    [self resetViewTop];
    _selectProject=ProjectWater;
    self.lblWater.textColor=UIColorFromRGB(0x00af00);
    self.imageWater.image=[UIImage imageNamed:@"guo_mine_water_green.png"];
    [self.tableview reloadData];

    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.contentOffset=CGPointMake(80, 0);
    }];
}

- (IBAction)changeMuscle:(id)sender {
    [self resetViewTop];
    _selectProject=ProjectMuscle;
    self.lblMuscle.textColor=UIColorFromRGB(0x00af00);
    self.imageMuscle.image=[UIImage imageNamed:@"guo_mine_muscle_green.png"];
    [self.tableview reloadData];

    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.contentOffset=CGPointMake(160, 0);
    }];
}

- (IBAction)changBasic:(id)sender {
    [self resetViewTop];
    _selectProject=ProjectBasic;
    self.lblBasic.textColor=UIColorFromRGB(0x00af00);
    self.imageBasic.image=[UIImage imageNamed:@"guo_mine_bmr_green.png"];
    [self.tableview reloadData];
 
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.contentOffset=CGPointMake(240, 0);
    }];
}

- (IBAction)changeBone:(id)sender
{
    [self resetViewTop];
    _selectProject=ProjectBone;
    self.lblBone.textColor=UIColorFromRGB(0x00af00);
    self.imageBone.image=[UIImage imageNamed:@"guo_mine_bone_green.png"];
    [self.tableview reloadData];
    [UIView animateWithDuration:0.3f animations:^{
        self.scrollView.contentOffset=CGPointMake(240, 0);
    }];
}

- (IBAction)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

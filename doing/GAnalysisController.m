#import "GAnalysisController.h"
#import "GProjectManagerViewController.h"
#import "GMeasureListController.h"
#import "SXLineLayout.h"
#import "FDSlideBar.h"

@interface GAnalysisController ()<LCActionSheetDelegate,CPTBarPlotDataSource,CPTBarPlotDelegate,CPTPlotDataSource,CPTPlotDelegate,CPTAxisDelegate,CPTPlotSpaceDelegate,CPTScatterPlotDelegate>
{
    FDSlideBar *_slidebar;
}

@property (nonatomic, readwrite, strong) CPTPlotSpaceAnnotation *symbolTextAnnotation;

@end

@implementation GAnalysisController


static NSString *const IDImage = @"image";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    kDataLine=@"data";
    kCenterLine=@"center";
    kControlLine=@"control";
    kWarningLine=@"warning";
    kZeroLine=@"zero";
    kBottomLine=@"bottom";
    kDataShowLine=@"datashow";
    kControlPoint=@"controlpoint";
    kBarDataLine=@"bardata";
    
    
    _db=[[DbModel alloc] init];
    _jsonModule=[[NetworkModule alloc] init];
    
    _delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [self initView];
    [self.btnWeek setTitle:NSLocalizedString(@"analysis_week", nil) forState:UIControlStateNormal];
    [self.btnMonth setTitle:NSLocalizedString(@"analysis_month", nil) forState:UIControlStateNormal];
    [self.btnYear setTitle:NSLocalizedString(@"analysis_all", nil) forState:UIControlStateNormal];

    [self setupSlideBar];
    [self weekClick:nil];
    
    UIPanGestureRecognizer *panGestureReconginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContentView:)];
    panGestureReconginzer.delegate = self;
    [self.view addGestureRecognizer:panGestureReconginzer];
    

    isSelfController=YES;

    [self.view insertSubview:self.viewNotiStatus belowSubview:self.viewTop];
    
    [self getChartData];
    [self showChart:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViewData) name:GNotiUpdateView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshWeightUnit) name:@"weight_unit" object:nil];
}

-(void)refreshWeightUnit {
    NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
    if ([_selectProject isEqualToString:ProjectWeight]) {
        self.lblProjectUnit.text = weightUnit;
        [self updateViewData];
    }
}

-(void)updateViewData
{
    [self getChartData];
    [self showChart:YES];
}

- (void)setupSlideBar
{
    
    if(_slidebar != nil)
    {
        [_slidebar removeFromSuperview];
        _slidebar=nil;
    }
    
    FDSlideBar *sliderBar = [[FDSlideBar alloc] initWithFrame:CGRectMake(70, 20, SCREEN_WIDTH - 140, 44)];
    sliderBar.backgroundColor = [UIColor clearColor];
    
    //sliderBar.itemsTitle = @[@"要闻", @"视频", @"上海", @"娱乐", @"体育NBA", @"财经", @"科技", @"社会", @"军事", @"时尚", @"汽车", @"游戏", @"图片", @"股票"];
    
    
    sliderBar.itemColor = [UIColor blackColor];
    sliderBar.itemSelectedColor = UIColorFromRGB(0x00af00);
    sliderBar.sliderColor = UIColorFromRGB(0x00af00);
    
   
    [sliderBar slideBarItemSelectedCallback:^(NSUInteger idx) {
        
        
        NSString *name=[_slidebar.itemsTitle objectAtIndex:idx];
        [self selectProjectWithProjectName:name];
        
        NSString *projectname=NSLocalizedString(name, nil);
        NSString *projectunit=NSLocalizedString([name stringByAppendingString:@"Unit"], nil);
        self.lblProjectUnit.text=projectunit;
        
        NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
        if ([weightUnit isEqualToString:@"lb"] && [_selectProject isEqualToString:ProjectWeight]) {
            self.lblProjectUnit.text=weightUnit;
        }
        
        /*
        if ([weightUnit isEqualToString:@"lb"] && [_selectProject isEqualToString:ProjectBone]) {
            self.lblProjectUnit.text=weightUnit;
        }
        */
        
        [self getChartData];
        [self showChart:YES];
        
        self.lblAvgTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_avg", nil),projectname];
        if([_selectProject isEqualToString:ProjectStepCount] ||
           [_selectProject isEqualToString:ProjectStepCalorie] ||
           [_selectProject isEqualToString:ProjectStepTime] ||
           [_selectProject isEqualToString:ProjectStepJourney])
        {
            self.lblAllTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_total", nil),projectname];
        }
        else
        {
            self.lblAllTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_lowest", nil),projectname];
        }
        
        [self resetBottomTitle];
        //[_slidebar scrollSeeItemWithSelectIndex:idx];
        
    }];
    
    
    [self.viewTop addSubview:sliderBar];
    
    _slidebar = sliderBar;

    NSArray *arySelectProject=[_db getCustomProject:[AppDelegate shareUserInfo].account_ctime];
    NSArray *ary;
    if(arySelectProject && arySelectProject.count>=1)
    {
        NSString *isset=[arySelectProject objectAtIndex:1];
        if(isset && isset.length>=1)
        {
            ary=[isset componentsSeparatedByString:@","];
        }
        
    }
    else
    {
        //NSString *isset=[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",ProjectStepCountName,ProjectStepTimeName,ProjectStepCalorieName,ProjectStepJourneyName,ProjectFatName,ProjectWeightName,ProjectBMIName,ProjectMuscleName,ProjectWaterName,ProjectBoneName,ProjectBasicName,ProjectVisceralFatName,ProjectBodyageName];
        NSString *isset=[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@",
                         ProjectWeightName,
                         ProjectBMIName,
                         ProjectFatName,
                         ProjectStepCountName,
                         ProjectStepJourneyName,
                         ProjectWaterName,
                         ProjectMuscleName,
                         ProjectBoneName,
                         ProjectBasicName,
                         ProjectVisceralFatName,
                         ProjectBodyageName,
                         ProjectStepTimeName,
                         ProjectStepCalorieName];
        
        if(isset && isset.length>=1)
        {
            ary=[isset componentsSeparatedByString:@","];
        }
    }
    
    
    if(ary && ary.count>=1)
    {
        _slidebar.itemsTitle=ary;
        [self selectProjectWithProjectName:[ary objectAtIndex:0]];
    }
    else
    {
        _selectProject=@"";
    }
}

-(void)resetBottomTitle
{
    NSString *name=NSLocalizedString(_projectName, nil);
    self.lblAvgTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_avg", nil),name];
    

    if(_chartType == ChartWeek)
    {
        if([_selectProject isEqualToString:ProjectStepCount] ||
           [_selectProject isEqualToString:ProjectStepCalorie] ||
           [_selectProject isEqualToString:ProjectStepTime] ||
           [_selectProject isEqualToString:ProjectStepJourney])
        {
            self.lblAllTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_total", nil),name];
            self.lblAvgTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_avg", nil),name];
        }
        else
        {
            self.lblAllTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_toweek", nil),@""];
            self.lblAvgTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_avg", nil),name];
        }
    }
    else if (_chartType == ChartMonth)
    {
        if([_selectProject isEqualToString:ProjectStepCount] ||
           [_selectProject isEqualToString:ProjectStepCalorie] ||
           [_selectProject isEqualToString:ProjectStepTime] ||
           [_selectProject isEqualToString:ProjectStepJourney])
        {
            self.lblAllTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_total", nil),name];
            self.lblAvgTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_avg", nil),name];
        }
        else
        {
            self.lblAllTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_tomonth", nil),@""];
            self.lblAvgTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_avg", nil),name];
        }
    }
    else
    {
        if([_selectProject isEqualToString:ProjectStepCount] ||
           [_selectProject isEqualToString:ProjectStepCalorie] ||
           [_selectProject isEqualToString:ProjectStepTime] ||
           [_selectProject isEqualToString:ProjectStepJourney])
        {
            self.lblAllTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_total", nil),name];
            self.lblAvgTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_avg", nil),name];
        }
        else
        {
            self.lblAvgTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_most", nil),name];
            self.lblAllTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_lowest", nil),name];
        }
    }

}

-(void)selectProjectWithProjectName:(NSString *)projectName
{
     //[[NSArray alloc] initWithObjects:@"步行",@"步行时间",@"卡路里",@"步行路程",@"脂肪率",@"体重",@"BMI",@"肌肉",@"水分",@"骨量",@"基础代谢",@"内脏脂肪", nil];
    if([projectName isEqualToString:ProjectStepCountName] ||
       [projectName isEqualToString:ProjectStepCountEnglishName] ||
       [projectName isEqualToString:ProjectStepCountGermanName] ||
       [projectName isEqualToString:ProjectStepCountDutchName])
    {
        _selectProject=ProjectStepCount;
    }
    else if ([projectName isEqualToString:ProjectStepTimeName] ||
             [projectName isEqualToString:ProjectStepTimeEnglishName] ||
             [projectName isEqualToString:ProjectStepTimeGermanName] ||
             [projectName isEqualToString:ProjectStepTimeDutchName])
    {
        _selectProject=ProjectStepTime;
    }
    else if ([projectName isEqualToString:ProjectStepCalorieName] ||
             [projectName isEqualToString:ProjectStepCalorieEnglishName] ||
             [projectName isEqualToString:ProjectStepCalorieGermanName] ||
             [projectName isEqualToString:ProjectStepCalorieDutchName])
    {
        _selectProject=ProjectStepCalorie;
    }
    else if ([projectName isEqualToString:ProjectStepJourneyName] ||
             [projectName isEqualToString:ProjectStepJourneyEnglishName] ||
             [projectName isEqualToString:ProjectStepJourneyGermanName] ||
             [projectName isEqualToString:ProjectStepJourneyDutchName])
    {
        _selectProject=ProjectStepJourney;
    }
    else if ([projectName isEqualToString:ProjectFatName] ||
             [projectName isEqualToString:ProjectFatEnglishName] ||
             [projectName isEqualToString:ProjectFatGermanName] ||
             [projectName isEqualToString:ProjectFatDutchName])
    {
        _selectProject=ProjectFat;
    }
    else if ([projectName isEqualToString:ProjectWeightName] ||
             [projectName isEqualToString:ProjectWeightEnglishName] ||
             [projectName isEqualToString:ProjectWeightGermanName] ||
             [projectName isEqualToString:ProjectWeightDutchName])
    {
        _selectProject=ProjectWeight;
    }
    else if ([projectName isEqualToString:ProjectBMIName] ||
             [projectName isEqualToString:ProjectBMIEnglishName] ||
             [projectName isEqualToString:ProjectBMIGermanName] ||
             [projectName isEqualToString:ProjectBMIDutchName])
    {
        _selectProject=ProjectBMI;
    }
    else if ([projectName isEqualToString:ProjectMuscleName] ||
             [projectName isEqualToString:ProjectMuscleEnglishName] ||
             [projectName isEqualToString:ProjectMuscleGermanName] ||
             [projectName isEqualToString:ProjectMuscleDutchName])
    {
        _selectProject=ProjectMuscle;
    }
    else if ([projectName isEqualToString:ProjectWaterName] ||
             [projectName isEqualToString:ProjectWaterEnglishName] ||
             [projectName isEqualToString:ProjectWaterGermanName] ||
             [projectName isEqualToString:ProjectWaterDutchName])
    {
        _selectProject=ProjectWater;
    }
    else if ([projectName isEqualToString:ProjectBoneName] ||
             [projectName isEqualToString:ProjectBoneEnglishName] ||
             [projectName isEqualToString:ProjectBoneGermanName] ||
             [projectName isEqualToString:ProjectBoneDutchName])
    {
        _selectProject=ProjectBone;
    }
    else if ([projectName isEqualToString:ProjectBasicName] ||
             [projectName isEqualToString:ProjectBasicEnglishName] ||
             [projectName isEqualToString:ProjectBasicGermanName] ||
             [projectName isEqualToString:ProjectBasicDutchName])
    {
        _selectProject=ProjectBasic;
    }
    else if ([projectName isEqualToString:ProjectVisceralFatName] ||
             [projectName isEqualToString:ProjectVisceralFatEnglishName] ||
             [projectName isEqualToString:ProjectVisceralFatGermanName] ||
             [projectName isEqualToString:ProjectVisceralFatDutchName])
    {
        _selectProject=ProjectVisceralFat;
    }
    else if ([projectName isEqualToString:ProjectBodyageName] ||
             [projectName isEqualToString:ProjectBodyageEnglishName] ||
             [projectName isEqualToString:ProjectBodyageGermanName] ||
             [projectName isEqualToString:ProjectBodyageDutchName])
    {
        _selectProject=ProjectBodyAge;
    }
    else if ([projectName isEqualToString:ProjectHeightName] ||
             [projectName isEqualToString:ProjectHeightEnglishName] ||
             [projectName isEqualToString:ProjectHeightGermanName] ||
             [projectName isEqualToString:ProjectHeightDutchName])
    {
        _selectProject=ProjectHeight;
    }
    else
    {
        _selectProject=@"";
    }
    
    _projectName=projectName;
    //NSString *name=NSLocalizedString(projectName, nil);
    NSString *name = projectName;
    NSString *projectunit=NSLocalizedString([name stringByAppendingString:@"Unit"], nil);
    self.lblProjectUnit.text=projectunit;
    
    NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
    if ([weightUnit isEqualToString:@"lb"] && [_selectProject isEqualToString:ProjectWeight]) {
        self.lblProjectUnit.text=weightUnit;
    }
    
    /*
    if ([weightUnit isEqualToString:@"lb"] && [_selectProject isEqualToString:ProjectBone]) {
        self.lblProjectUnit.text=weightUnit;
    }
    */
    
    self.lblAvgTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_avg", nil),name];
    if([_selectProject isEqualToString:ProjectStepCount] ||
       [_selectProject isEqualToString:ProjectStepCalorie] ||
       [_selectProject isEqualToString:ProjectStepTime] ||
       [_selectProject isEqualToString:ProjectStepJourney])
    {
        self.lblAllTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_total", nil),name];
    }
    else
    {
        self.lblAllTitle.text=[NSString stringWithFormat:@"%@%@",NSLocalizedString(@"analysis_lowest", nil),name];
    }
}

//向右拖动界面
- (void)panInContentView:(UIPanGestureRecognizer *)panGestureReconginzer
{
    //NSLog(@"进入滑动");
    CGFloat translation = [panGestureReconginzer translationInView:self.scrollview].x;

    
    
    if (panGestureReconginzer.state == UIGestureRecognizerStateChanged) {
        
    } else if (panGestureReconginzer.state == UIGestureRecognizerStateEnded) {
    
        @try {
            if (translation < 0) {
                [_slidebar scrollToNextAndSelected];
            } else {
                [_slidebar scrollToPreviousAndSelected];
            }
        } @catch (NSException *exception) {
            
        }
    }
}


-(void)notiKeyboard
{
    isSelfController=YES;
}

- (BOOL)fd_prefersNavigationBarHidden
{
    return YES;
    
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
    [self.btnWeek.titleLabel setFont:[UIFont systemFontOfSize:iPhone5FontSizeTitle]];
    [self.btnMonth.titleLabel setFont:[UIFont systemFontOfSize:iPhone5FontSizeTitle]];
    [self.btnYear.titleLabel setFont:[UIFont systemFontOfSize:iPhone5FontSizeTitle]];
    
    if(is_iPhone6P)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6PFontSizeTitle];
        [self.btnWeek.titleLabel setFont:[UIFont systemFontOfSize:iPhone6PFontSizeTitle]];
        [self.btnMonth.titleLabel setFont:[UIFont systemFontOfSize:iPhone6PFontSizeTitle]];
        [self.btnYear.titleLabel setFont:[UIFont systemFontOfSize:iPhone6PFontSizeTitle]];
    }
    else if(is_iPhone6)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6FontSizeTitle];
        [self.btnWeek.titleLabel setFont:[UIFont systemFontOfSize:iPhone6FontSizeTitle]];
        [self.btnMonth.titleLabel setFont:[UIFont systemFontOfSize:iPhone6FontSizeTitle]];
        [self.btnYear.titleLabel setFont:[UIFont systemFontOfSize:iPhone6FontSizeTitle]];
    }
    
    
    self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, TABBAR_HEIGHT);

    self.viewTop.frame=CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT);
    
    self.scrollview.frame=CGRectMake(0, NAVBAR_HEIGHT+1, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT-NAVBAR_HEIGHT);
    
    
    self.viewTop.backgroundColor=NavColor;
    self.view.backgroundColor=CommonBgColor;
    self.lblTopTitle.frame=CGRectMake(0, 20, SCREEN_WIDTH, 44);
    
    self.btnLeftMenu.frame=CGRectMake(17, 20, 44, 44);
    self.btnRightMenu.frame=CGRectMake(SCREEN_WIDTH-17-44, 20, 44, 44);
    
   // self.viewTop.layer.shadowOffset=CGSizeMake(0, 1);
    //self.viewTop.layer.shadowOpacity=0.08;

    self.imageLine.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, 1);
    
    
    CGFloat fWidthOffset=(SCREEN_WIDTH - 0.1875 * 2 * SCREEN_WIDTH - 0.17 * SCREEN_WIDTH * 3)/2;
    self.btnWeek.frame=CGRectMake(0.1875*SCREEN_WIDTH, 32, 0.17*SCREEN_WIDTH,  0.125*SCREEN_WIDTH);
    self.btnMonth.frame=CGRectMake(self.btnWeek.frame.origin.x+fWidthOffset+ 0.17*SCREEN_WIDTH, 32,  0.17*SCREEN_WIDTH,  0.125*SCREEN_WIDTH);
    self.btnYear.frame=CGRectMake(SCREEN_WIDTH-0.1875*SCREEN_WIDTH- 0.17*SCREEN_WIDTH, 32,  0.17*SCREEN_WIDTH,  0.125*SCREEN_WIDTH);
    
    self.btnWeek.layer.masksToBounds=YES;
    self.btnWeek.layer.cornerRadius=3.0f;
    self.btnMonth.layer.masksToBounds=YES;
    self.btnMonth.layer.cornerRadius=3.0f;
    self.btnYear.layer.masksToBounds=YES;
    self.btnYear.layer.cornerRadius=3.0f;
    
    self.lblAvgTitle.frame=CGRectMake(0, 1.171875*SCREEN_WIDTH, SCREEN_WIDTH/2, 0.09375*SCREEN_WIDTH);
    self.lblAllTitle.frame=CGRectMake(self.lblAvgTitle.frame.origin.x+self.lblAvgTitle.frame.size.width, 1.171875*SCREEN_WIDTH, SCREEN_WIDTH/2, 0.09375*SCREEN_WIDTH);
    
    self.lblAvgValue.frame=CGRectMake(self.lblAvgTitle.frame.origin.x, self.lblAvgTitle.frame.origin.y+self.lblAvgTitle.frame.size.height+5, SCREEN_WIDTH/2, 0.125*SCREEN_WIDTH);
    self.lblAllValue.frame=CGRectMake(self.lblAvgValue.frame.origin.x+self.lblAvgValue.frame.size.width, self.lblAvgTitle.frame.origin.y+self.lblAvgTitle.frame.size.height+5, SCREEN_WIDTH/2, 0.125*SCREEN_WIDTH);
    
    self.lblAvgValue.text=@"--";
    self.lblAllValue.text=@"--";
    
    self.scrollview.userInteractionEnabled=YES;
    self.scrollview.scrollEnabled=YES;
    self.scrollview.contentSize=CGSizeMake(0, self.lblAllValue.frame.origin.y+self.lblAllValue.frame.size.height);
    
}


-(void)refreshGoBack
{
    isSelfController=YES;
    [self setupSlideBar];
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

- (IBAction)gotoAnalysisChart:(id)sender {
    GMeasureListController *vc=[[GMeasureListController alloc] init];
    [_delegate.tabController.navigationController pushViewController:vc animated:YES];
}



- (IBAction)gotoProjectManager:(id)sender {
    GProjectManagerViewController *vc=[[GProjectManagerViewController alloc] init];
    vc.GoBack=^{
        [self refreshGoBack];
    };
    [_delegate.tabController.navigationController pushViewController:vc animated:YES];
}

- (IBAction)weekClick:(id)sender
{
    
    [self.btnWeek setBackgroundColor:UIColorFromRGB(0x00af00)];
    [self.btnWeek setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnMonth setBackgroundColor:[UIColor clearColor]];
    [self.btnMonth setTitleColor:UIColorFromRGB(0x00af00) forState:UIControlStateNormal];
    [self.btnYear setBackgroundColor:[UIColor clearColor]];
    [self.btnYear setTitleColor:UIColorFromRGB(0x00af00) forState:UIControlStateNormal];
    
    _chartType=ChartWeek;
    
    [self resetBottomTitle];
    
    [self getChartData];
    [self showChart:YES];
}

- (IBAction)monthClick:(id)sender
{
    [self.btnMonth setBackgroundColor:UIColorFromRGB(0x00af00)];
    [self.btnMonth setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnWeek setBackgroundColor:[UIColor clearColor]];
    [self.btnWeek setTitleColor:UIColorFromRGB(0x00af00) forState:UIControlStateNormal];
    [self.btnYear setBackgroundColor:[UIColor clearColor]];
    [self.btnYear setTitleColor:UIColorFromRGB(0x00af00) forState:UIControlStateNormal];
    
    _chartType=ChartMonth;
    
    [self resetBottomTitle];
    [self getChartData];
    [self showChart:YES];
}

- (IBAction)yearClick:(id)sender
{
    [self.btnYear setBackgroundColor:UIColorFromRGB(0x00af00)];
    [self.btnYear setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnMonth setBackgroundColor:[UIColor clearColor]];
    [self.btnMonth setTitleColor:UIColorFromRGB(0x00af00) forState:UIControlStateNormal];
    [self.btnWeek setBackgroundColor:[UIColor clearColor]];
    [self.btnWeek setTitleColor:UIColorFromRGB(0x00af00) forState:UIControlStateNormal];
    
    _chartType=ChartYear;
    
    [self resetBottomTitle];
    [self getChartData];
    [self showChart:YES];
}


/**
 *@brief 绘制图表
 */
#pragma mark 绘制图表

#pragma mark  获取图标显示数据

-(BOOL)getWeightChartData
{
    NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
    BOOL isLbUnit = NO;
    if ([weightUnit isEqualToString:@"lb"] && [_selectProject isEqualToString:ProjectWeight]) {
        isLbUnit = YES;
    }
    
    /*
    if ([weightUnit isEqualToString:@"lb"] && [_selectProject isEqualToString:ProjectBone]) {
        isLbUnit = YES;
    }
    */
    
    if(_chartType == ChartWeek)
    {
        NVDate *date=[[NVDate alloc] initUsingDate:[NSDate date]];
        NSString *endTime=[date stringValueWithFormat:@"yyyy-MM-dd"];
        [date previousDays:6];
        NSString *startTime=[date stringValueWithFormat:@"yyyy-MM-dd"];
        
        startTime=[startTime stringByAppendingString:@" 00:00:00"];
        endTime=[endTime stringByAppendingString:@" 23:59:59"];
        
        NSArray *allStep=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        
        if(allStep == nil || allStep.count<1)
        {
            return NO;
        }
        
        if(allStep && allStep.count>=1)
        {
            for(int i=0;i<[allStep count];i++)
            {
                NSArray *tempAry=[allStep objectAtIndex:i];
                
                NSString *time=[tempAry objectAtIndex:2];
                NSString *value=[tempAry objectAtIndex:3];
                if (isLbUnit) {
                    value = [PublicModule kgToLb:value];
                }
                
                NSString *strTime=[time substringWithRange:NSMakeRange(0, 10)];
                NVDate *date=[[NVDate alloc] initUsingDate:[NSDate date]];
                NSString *endTime=[date stringValueWithFormat:@"yyyy-MM-dd"];
                NSString *strDays=[PublicModule getDays:strTime withDate:endTime];
                
                if(![[dictWeight allKeys] containsObject:strDays])
                {
                    [_aryMeasureTime addObject:strTime];
                    [dictWeight setObject:value forKey:strDays];
                    [aryMeasureDate addObject:strTime];
                    
                    int dayCount=[strDays intValue]-1;
                    
                    if(dayCount>=0&&dayCount<7)
                    {
                        [aryWeekWeight replaceObjectAtIndex:dayCount withObject:value];
                    }
                    
                }
                else
                {
                    continue;
                }
            }
            
            return YES;
        }
    }
    else if(_chartType == ChartMonth)
    {
        NSArray *aryTime=[PublicModule getChartMonthDayWithDate:nil];
        if(aryTime == nil || aryTime.count<7)
        {
            return NO;
        }

        NSString *startTime=[[aryTime objectAtIndex:0] stringByAppendingString:@" 00:00:00"];
        NSString *endTime=[[aryTime objectAtIndex:1] stringByAppendingString:@" 23:59:59"];

        NSArray *allStep1=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];

        NSString *strAllStep=@"0";
        if(allStep1 && allStep1.count>=1)
        {
            NSArray *tempAry=[allStep1 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryMonthWeight replaceObjectAtIndex:6 withObject:strAllStep];
        
        
        startTime=[[aryTime objectAtIndex:1] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:2] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep2=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep2 && allStep2.count>=1)
        {
            NSArray *tempAry=[allStep2 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryMonthWeight replaceObjectAtIndex:5 withObject:strAllStep];
        
        startTime=[[aryTime objectAtIndex:2] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:3] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep3=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep3 && allStep3.count>=1)
        {
            NSArray *tempAry=[allStep3 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryMonthWeight replaceObjectAtIndex:4 withObject:strAllStep];
        
        startTime=[[aryTime objectAtIndex:3] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:4] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep4=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep4 && allStep4.count>=1)
        {
            NSArray *tempAry=[allStep4 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryMonthWeight replaceObjectAtIndex:3 withObject:strAllStep];
        
        startTime=[[aryTime objectAtIndex:4] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:5] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep5=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep5 && allStep5.count>=1)
        {
            NSArray *tempAry=[allStep5 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryMonthWeight replaceObjectAtIndex:2 withObject:strAllStep];
        
        startTime=[[aryTime objectAtIndex:5] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:6] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep6=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep6 && allStep6.count>=1)
        {
            NSArray *tempAry=[allStep6 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryMonthWeight replaceObjectAtIndex:1 withObject:strAllStep];
        
        startTime=[[aryTime objectAtIndex:6] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:7] stringByAppendingString:@" 23:59:59"];

        NSArray *allStep7=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep7 && allStep7.count>=1)
        {
            NSArray *tempAry=[allStep7 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryMonthWeight replaceObjectAtIndex:0 withObject:strAllStep];
        
        return YES;
        
    }
    else if(_chartType == ChartYear)
    {
        NSArray *aryMaxMinTime=[_db selectMaxAndMinProjectTimeWithProject:_selectProject andCTime:[AppDelegate shareUserInfo].account_ctime];
        if(aryMaxMinTime == nil || aryMaxMinTime.count<2)
        {
            return NO;
        }
        
        NSString *minTime=[aryMaxMinTime objectAtIndex:0];
        NSString *maxTime=[aryMaxMinTime objectAtIndex:1];
        
        
        NSDate *dateStart=[PublicModule getDateWithString:minTime andFormatter:@""];
        NSDate *dateEnd=[PublicModule getDateWithString:maxTime andFormatter:@""];
        
        NSArray *aryTime=[PublicModule getChartAllDayWithStartDate:dateStart andEndDate:dateEnd];
        if(aryTime == nil || aryTime.count<7)
        {
            return NO;
        }
        
        
        NSString *startTime=[[aryTime objectAtIndex:0] stringByAppendingString:@" 00:00:00"];
        NSString *endTime=[[aryTime objectAtIndex:1] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep1=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        
        NSString *strAllStep=@"0";
        if(allStep1 && allStep1.count>=1)
        {
            NSArray *tempAry=[allStep1 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryAllWeight replaceObjectAtIndex:6 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:1] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:2] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep2=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep2 && allStep2.count>=1)
        {
            NSArray *tempAry=[allStep2 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryAllWeight replaceObjectAtIndex:5 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:2] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:3] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep3=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep3 && allStep3.count>=1)
        {
            NSArray *tempAry=[allStep3 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryAllWeight replaceObjectAtIndex:4 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:3] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:4] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep4=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep4 && allStep4.count>=1)
        {
            NSArray *tempAry=[allStep4 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryAllWeight replaceObjectAtIndex:3 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:4] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:5] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep5=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep5 && allStep5.count>=1)
        {
            NSArray *tempAry=[allStep5 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryAllWeight replaceObjectAtIndex:2 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:5] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:6] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep6=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep6 && allStep6.count>=1)
        {
            NSArray *tempAry=[allStep6 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryAllWeight replaceObjectAtIndex:1 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:6] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:7] stringByAppendingString:@" 23:59:59"];
        
        NSArray *allStep7=[_db selectWeightWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:_selectProject andStartDate:startTime endDate:endTime];
        strAllStep=@"0";
        if(allStep7 && allStep7.count>=1)
        {
            NSArray *tempAry=[allStep7 objectAtIndex:0];
            strAllStep=[tempAry objectAtIndex:3];
            if (isLbUnit) {
                strAllStep=[PublicModule kgToLb:strAllStep];
            }
        }
        [aryAllWeight replaceObjectAtIndex:0 withObject:strAllStep];
        
        return YES;
    }
    else
    {
        return NO;
    }
    
    return NO;
}

-(BOOL)getStepChartData
{
    
    if(_chartType == ChartWeek)
    {
        NVDate *date=[[NVDate alloc] initUsingDate:[NSDate date]];
        NSString *endTime=[date stringValueWithFormat:@"yyyy-MM-dd"];
        [date previousDays:6];
        NSString *startTime=[date stringValueWithFormat:@"yyyy-MM-dd"];
        
        startTime=[startTime stringByAppendingString:@" 00:00:00"];
        endTime=[endTime stringByAppendingString:@" 23:59:59"];
        
        NSArray *allStep=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        
        if(allStep == nil || allStep.count<1)
        {
            return NO;
        }
        
        if(allStep && allStep.count>=1)
        {
            for(int i=0;i<[allStep count];i++)
            {
                NSArray *tempAry=[allStep objectAtIndex:i];
                
                NSString *time=[tempAry objectAtIndex:2];
                
                NSString *strTime=[time substringWithRange:NSMakeRange(0, 10)];
                NVDate *date=[[NVDate alloc] initUsingDate:[NSDate date]];
                NSString *endTime=[date stringValueWithFormat:@"yyyy-MM-dd"];
                NSString *strDays=[PublicModule getDays:strTime withDate:endTime];
                
                if(![[dictWeight allKeys] containsObject:strDays])
                {
                    [_aryMeasureTime addObject:strTime];
                    [dictWeight setObject:[tempAry objectAtIndex:3] forKey:strDays];
                    [aryMeasureDate addObject:strTime];
                    
                    int dayCount=[strDays intValue]-1;
                    
                    if(dayCount>=0&&dayCount<7)
                    {
                        //[aryWeekWeight replaceObjectAtIndex:dayCount withObject:[tempAry objectAtIndex:3]];
                        
                        NSString *strStep=[tempAry objectAtIndex:3];
                        
                        if ([_selectProject isEqualToString:ProjectStepCalorie])
                        {
                            strStep=[NSString stringWithFormat:@"%.0f",[strStep floatValue]*0.04];
                        }
                        else if ([_selectProject isEqualToString:ProjectStepTime])
                        {
                            strStep=[NSString stringWithFormat:@"%.0f",[strStep floatValue]/60];
                        }
                        else if ([_selectProject isEqualToString:ProjectStepJourney])
                        {
                            strStep=[NSString stringWithFormat:@"%.0f",[strStep floatValue]*0.7/1000];
                        }
                        
                        [aryWeekWeight replaceObjectAtIndex:dayCount withObject:strStep];
                    }
                    
                }
                else
                {
                    continue;
                }
            }
            
            return YES;
        }
    }
    else if(_chartType == ChartMonth)
    {
        NSArray *aryTime=[PublicModule getChartMonthDayWithDate:nil];
        if(aryTime == nil || aryTime.count<7)
        {
            return NO;
        }
        
        
        NSString *startTime=[[aryTime objectAtIndex:0] stringByAppendingString:@" 00:00:00"];
        NSString *endTime=[[aryTime objectAtIndex:1] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep1=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        int iAllStep=0;
        NSString *strAllStep=@"0";
        if(allStep1 && allStep1.count>=1)
        {
            for(NSInteger i=0;i<allStep1.count;i++)
            {
                NSArray *tempAry=[allStep1 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];

        
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }

        [aryMonthWeight replaceObjectAtIndex:6 withObject:strAllStep];
        
        
        startTime=[[aryTime objectAtIndex:1] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:2] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep2=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep2 && allStep2.count>=1)
        {
            for(NSInteger i=0;i<allStep2.count;i++)
            {
                NSArray *tempAry=[allStep2 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryMonthWeight replaceObjectAtIndex:5 withObject:strAllStep];
        
        startTime=[[aryTime objectAtIndex:2] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:3] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep3=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep3 && allStep3.count>=1)
        {
            for(NSInteger i=0;i<allStep3.count;i++)
            {
                NSArray *tempAry=[allStep3 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryMonthWeight replaceObjectAtIndex:4 withObject:strAllStep];
        
        
        startTime=[[aryTime objectAtIndex:3] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:4] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep4=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep4 && allStep4.count>=1)
        {
            for(NSInteger i=0;i<allStep4.count;i++)
            {
                NSArray *tempAry=[allStep4 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryMonthWeight replaceObjectAtIndex:3 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:4] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:5] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep5=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep5 && allStep5.count>=1)
        {
            for(NSInteger i=0;i<allStep5.count;i++)
            {
                NSArray *tempAry=[allStep5 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryMonthWeight replaceObjectAtIndex:2 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:5] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:6] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep6=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep6 && allStep6.count>=1)
        {
            for(NSInteger i=0;i<allStep6.count;i++)
            {
                NSArray *tempAry=[allStep6 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryMonthWeight replaceObjectAtIndex:1 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:6] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:7] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep7=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep7 && allStep7.count>=1)
        {
            for(NSInteger i=0;i<allStep7.count;i++)
            {
                NSArray *tempAry=[allStep7 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
            
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryMonthWeight replaceObjectAtIndex:0 withObject:strAllStep];
        
        return YES;
        
    }
    else if(_chartType == ChartYear)
    {
        NSArray *aryMaxMinTime=[_db selectMaxAndMinProjectTimeWithProject:ProjectStepCount andCTime:[AppDelegate shareUserInfo].account_ctime];
        if(aryMaxMinTime == nil || aryMaxMinTime.count<2)
        {
            return NO;
        }
        

        NSString *minTime=[aryMaxMinTime objectAtIndex:0];
        NSString *maxTime=[aryMaxMinTime objectAtIndex:1];
            
            
        NSDate *dateStart=[PublicModule getDateWithString:minTime andFormatter:@""];
        NSDate *dateEnd=[PublicModule getDateWithString:maxTime andFormatter:@""];
            
        NSArray *aryTime=[PublicModule getChartAllDayWithStartDate:dateStart andEndDate:dateEnd];
        if(aryTime == nil || aryTime.count<7)
        {
            return NO;
        }

        NSString *startTime=[[aryTime objectAtIndex:0] stringByAppendingString:@" 00:00:00"];
        NSString *endTime=[[aryTime objectAtIndex:1] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep1=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        int iAllStep=0;
        NSString *strAllStep=@"0";
        if(allStep1 && allStep1.count>=1)
        {
            for(NSInteger i=0;i<allStep1.count;i++)
            {
                NSArray *tempAry=[allStep1 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryAllWeight replaceObjectAtIndex:6 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:1] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:2] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep2=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep2 && allStep2.count>=1)
        {
            for(NSInteger i=0;i<allStep2.count;i++)
            {
                NSArray *tempAry=[allStep2 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryAllWeight replaceObjectAtIndex:5 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:2] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:3] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep3=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep3 && allStep3.count>=1)
        {
            for(NSInteger i=0;i<allStep3.count;i++)
            {
                NSArray *tempAry=[allStep3 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryAllWeight replaceObjectAtIndex:4 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:3] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:4] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep4=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep4 && allStep4.count>=1)
        {
            for(NSInteger i=0;i<allStep4.count;i++)
            {
                NSArray *tempAry=[allStep4 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryAllWeight replaceObjectAtIndex:3 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:4] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:5] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep5=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep5 && allStep5.count>=1)
        {
            for(NSInteger i=0;i<allStep5.count;i++)
            {
                NSArray *tempAry=[allStep5 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryAllWeight replaceObjectAtIndex:2 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:5] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:6] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep6=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep6 && allStep6.count>=1)
        {
            for(NSInteger i=0;i<allStep6.count;i++)
            {
                NSArray *tempAry=[allStep6 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryAllWeight replaceObjectAtIndex:1 withObject:strAllStep];
        
        
        
        startTime=[[aryTime objectAtIndex:6] stringByAppendingString:@" 23:59:59"];
        endTime=[[aryTime objectAtIndex:7] stringByAppendingString:@" 23:59:59"];
        NSArray *allStep7=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startTime andEndDate:endTime];
        iAllStep=0;
        strAllStep=@"0";
        if(allStep7 && allStep7.count>=1)
        {
            for(NSInteger i=0;i<allStep7.count;i++)
            {
                NSArray *tempAry=[allStep7 objectAtIndex:i];
                NSString *tempStep=[tempAry objectAtIndex:3];
                iAllStep=iAllStep+[tempStep intValue];
            }
            
        }
        strAllStep=[NSString stringWithFormat:@"%d",iAllStep];
        if ([_selectProject isEqualToString:ProjectStepCalorie])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.04];
        }
        else if ([_selectProject isEqualToString:ProjectStepTime])
        {
            strAllStep=[NSString stringWithFormat:@"%d",iAllStep/60];
        }
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            strAllStep=[NSString stringWithFormat:@"%.0f",iAllStep*0.7/1000];
        }
        [aryAllWeight replaceObjectAtIndex:0 withObject:strAllStep];

        return YES;
    }
    else
    {
        return NO;
    }
    
    return NO;
}


-(void)getChartData
{
    if([_selectProject isEqualToString:ProjectStepCount])
    {
        dControlWeight=[[AppDelegate shareUserInfo].targetStep intValue];
    }
    else if([_selectProject isEqualToString:ProjectWeight])
    {
        dControlWeight=[[AppDelegate shareUserInfo].targetWeight floatValue];
    }
    else
    {
        dControlWeight=0.0;
    }
    
    //初始化或移除已经查询的数据
    [self initChartData];
    
    if([_selectProject isEqualToString:ProjectStepCount] ||
       [_selectProject isEqualToString:ProjectStepCalorie] ||
       [_selectProject isEqualToString:ProjectStepJourney] ||
       [_selectProject isEqualToString:ProjectStepTime])
    {
        if (![self getStepChartData])
        {
            NSMutableArray *ary=[[NSMutableArray alloc] init];
            plotData=ary;
            self.lblAllValue.text=@"--";
            self.lblAvgValue.text=@"--";
            [_xyGraph reloadData];
            return;
        }
    }
    else
    {
        if(![self getWeightChartData])
        {
            NSMutableArray *ary=[[NSMutableArray alloc] init];
            plotData=ary;
            self.lblAllValue.text=@"--";
            self.lblAvgValue.text=@"--";
            [_xyGraph reloadData];
            return;
        }

    }
    
    NSArray *tmpWeight;
    if(_chartType == ChartWeek)
    {
        pointNum=7;
        
        for(NSInteger i=0;i<aryWeekWeight.count;i++)
        {
            if([[aryWeekWeight objectAtIndex:i] isEqualToString:@"0"])
            {
                [aryWeekWeight replaceObjectAtIndex:i withObject:@"-100"];
            }
            else
            {
                break;
            }
        }
        
        tmpWeight=[[aryWeekWeight reverseObjectEnumerator] allObjects];
    }
    else if(_chartType == ChartMonth)
    {
        pointNum=7;
        for(NSInteger i=0;i<aryMonthWeight.count;i++)
        {
            if([[aryMonthWeight objectAtIndex:i] isEqualToString:@"0"])
            {
                [aryMonthWeight replaceObjectAtIndex:i withObject:@"-100"];
            }
            else
            {
                break;
            }
        }
        tmpWeight=[[aryMonthWeight reverseObjectEnumerator] allObjects];
    }
    else
    {
        pointNum=7;
        //NSArray *ary=[[aryAllWeight reverseObjectEnumerator] allObjects];
        //aryAllWeight=[ary mutableCopy];
        for(NSInteger i=0;i<aryAllWeight.count;i++)
        {
            if([[aryAllWeight objectAtIndex:i] isEqualToString:@"0"])
            {
                [aryAllWeight replaceObjectAtIndex:i withObject:@"-100"];
            }
            else
            {
                break;
            }
        }
        tmpWeight=[[aryAllWeight reverseObjectEnumerator] allObjects];
    }
    
    
    NSMutableArray *contentArray=[NSMutableArray array];
    numberOfPoints=[tmpWeight count];
    
    double sum=0;
    int iDay=0;
    for(NSUInteger i=0;i<[tmpWeight count];i++)
    {
        double y=[[tmpWeight objectAtIndex:i] doubleValue];
        if(y>0)
        {
            iDay++;
            sum=sum+y;
        }
        
        [contentArray addObject:[NSNumber numberWithDouble:y]];
    }
    
    
    YRange=[PublicModule getMaxAndMinWithoutZero:contentArray];
    avgValue=[[PublicModule getChartAvgValue:contentArray] doubleValue];
    plotData=contentArray;
    
    if(sum <= 0)
    {
        self.lblAvgValue.text=@"--";
        self.lblAllValue.text=@"--";
    }
    else
    {
    
        if([_selectProject isEqualToString:ProjectStepTime] ||
               [_selectProject isEqualToString:ProjectStepCount] ||
               [_selectProject isEqualToString:ProjectStepCalorie])
        {
            self.lblAllValue.text=[NSString stringWithFormat:@"%.0f",sum];
            self.lblAvgValue.text=[NSString stringWithFormat:@"%.0f",sum/iDay];
        }
        
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            self.lblAllValue.text=[NSString stringWithFormat:@"%.1f",sum];
            self.lblAvgValue.text=[NSString stringWithFormat:@"%.1f",sum/iDay];
        }
        else
        {
            if([_selectProject isEqualToString:ProjectBasic] ||
               [_selectProject isEqualToString:ProjectVisceralFat])
            {
                self.lblAllValue.text=[NSString stringWithFormat:@"%.0f",[[YRange objectAtIndex:0] floatValue]];
                self.lblAvgValue.text=[NSString stringWithFormat:@"%.0f",sum/iDay];
            }
            else if ([_selectProject isEqualToString:ProjectWeight])
            {
                self.lblAllValue.text=[NSString stringWithFormat:@"%.2f",[[YRange objectAtIndex:0] floatValue]];
                self.lblAvgValue.text=[NSString stringWithFormat:@"%.2f",sum/iDay];
            }
            else
            {
                self.lblAllValue.text=[NSString stringWithFormat:@"%.1f",[[YRange objectAtIndex:0] floatValue]];
                self.lblAvgValue.text=[NSString stringWithFormat:@"%.1f",sum/iDay];
            }
            
        }
    }
    

    NSArray *aryTime=[_db selectMaxAndMinProjectTimeWithProject:_selectProject andCTime:[AppDelegate shareUserInfo].account_ctime];
    if(aryTime && aryTime.count>=2 && _chartType != ChartWeek)
    {
        NSString *strMin=[aryTime objectAtIndex:0];
        NSString *strMax=[aryTime objectAtIndex:1];
        
        
        strMin=[strMin substringToIndex:10];
        strMax=[strMax substringToIndex:10];
        
        NSString *strDays=[PublicModule getDays:strMin withDate:strMax];
        int iDays=[strDays intValue];
        
        if(_chartType == ChartMonth)
        {
            NSArray *aryMonthTime=[PublicModule getChartMonthDayWithDate:nil];
            if(aryMonthTime && aryMonthTime.count>=2)
            {
                NSString *strTime1=[aryMonthTime objectAtIndex:1];
                //图表月最早日期
                NSDate *date1=[PublicModule getDateWithString:strTime1 andFormatter:@"yyyy-MM-dd"];
                //测量最早日期
                NSDate *date2=[PublicModule getDateWithString:strMin andFormatter:@"yyyy-MM-dd"];
                if([date1 compare:date2] == NSOrderedDescending)
                {
                    strDays=[PublicModule getDays:strTime1 withDate:strMax];
                    iDays=[strDays intValue];
                }
            }
        }
        
        if([_selectProject isEqualToString:ProjectStepTime] ||
           [_selectProject isEqualToString:ProjectStepCount] ||
           [_selectProject isEqualToString:ProjectStepCalorie])
        {
            //总数
            self.lblAllValue.text=[NSString stringWithFormat:@"%.0f",sum];
            self.lblAvgValue.text=[NSString stringWithFormat:@"%.0f",sum/iDays];
        }
        
        else if ([_selectProject isEqualToString:ProjectStepJourney])
        {
            //总数
            self.lblAllValue.text=[NSString stringWithFormat:@"%.1f",sum];
            self.lblAvgValue.text=[NSString stringWithFormat:@"%.1f",sum/iDays];
        }
        else
        {
            //最低数
            NSArray *aryCount=[_db selectChartAnalysisWithProject:_selectProject andCTime:[AppDelegate shareUserInfo].account_ctime];
            
            if([_selectProject isEqualToString:ProjectBasic] ||
               [_selectProject isEqualToString:ProjectVisceralFat])
            {
                if(aryCount && aryCount.count>=3)
                {
                    self.lblAllValue.text=[NSString stringWithFormat:@"%.0f",[[aryCount objectAtIndex:0] floatValue]];
                    if(_chartType == ChartYear)
                    {
                        self.lblAvgValue.text=[NSString stringWithFormat:@"%.0f",[[aryCount objectAtIndex:1] floatValue]];
                    }
                }
            }
            else if([_selectProject isEqualToString:ProjectWeight])
            {
                if(aryCount && aryCount.count>=3)
                {
                    self.lblAllValue.text=[NSString stringWithFormat:@"%.2f",[[aryCount objectAtIndex:0] floatValue]];
                    if(_chartType == ChartYear)
                    {
                        self.lblAvgValue.text=[NSString stringWithFormat:@"%.2f",[[aryCount objectAtIndex:1] floatValue]];
                    }
                }
            }
            else
            {
                if(aryCount && aryCount.count>=3)
                {
                    self.lblAllValue.text=[NSString stringWithFormat:@"%.1f",[[aryCount objectAtIndex:0] floatValue]];
                    if(_chartType == ChartYear)
                    {
                        self.lblAvgValue.text=[NSString stringWithFormat:@"%.1f",[[aryCount objectAtIndex:1] floatValue]];
                    }
                }
            }
            
        }
        
    }
    
}

-(void)initChartData
{
    if(dictWeight!=nil)
    {
        [dictWeight removeAllObjects];
    }
    else
    {
        dictWeight=[[NSMutableDictionary alloc] init];
    }
    
    if(aryWeekWeight!=nil)
    {
        [aryWeekWeight removeAllObjects];
    }
    else
    {
        aryWeekWeight=[[NSMutableArray alloc] initWithCapacity:7];
    }
    
    
    if([aryWeekWeight count]>=7)
    {
        for(int i=0;i<7;i++)
        {
            [aryWeekWeight replaceObjectAtIndex:i withObject:@"0"];
        }
    }
    else
    {
        for(int i=0;i<7;i++)
        {
            [aryWeekWeight addObject:@"0"];
        }
    }
    
    if(aryMonthWeight!=nil)
    {
        [aryMonthWeight removeAllObjects];
    }
    else
    {
        aryMonthWeight=[[NSMutableArray alloc] initWithCapacity:7];
    }
    
    
    if([aryMonthWeight count]>=7)
    {
        for(int i=0;i<7;i++)
        {
            [aryMonthWeight replaceObjectAtIndex:i withObject:@"0"];
        }
    }
    else
    {
        for(int i=0;i<7;i++)
        {
            [aryMonthWeight addObject:@"0"];
        }
    }
    
    if(aryAllWeight!=nil)
    {
        [aryAllWeight removeAllObjects];
    }
    else
    {
        aryAllWeight=[[NSMutableArray alloc] initWithCapacity:7];
    }
    
    if([aryAllWeight count]>=7)
    {
        for(int i=0;i<7;i++)
        {
            [aryAllWeight replaceObjectAtIndex:i withObject:@"0"];
        }
    }
    else
    {
        for(int i=0;i<7;i++)
        {
            [aryAllWeight addObject:@"0"];
        }
    }
    
    
    if(aryMeasureDate!=nil)
    {
        [aryMeasureDate removeAllObjects];
    }
    else
    {
        aryMeasureDate=[[NSMutableArray alloc] init];
    }
    
    if(_aryMeasureTime != nil)
    {
        [_aryMeasureTime removeAllObjects];
    }
    else
    {
        _aryMeasureTime=[[NSMutableArray alloc] init];
    }
}

-(void)showBarChart:(BOOL)animated
{
    //CGRect frame=CGRectMake(-20, 140, SCREEN_WIDTH+20, 300);
    CGRect frame=CGRectMake(-20, self.btnWeek.frame.origin.y+self.btnWeek.frame.size.height+15, SCREEN_WIDTH+20, self.lblAllTitle.frame.origin.y-self.btnWeek.frame.origin.y-self.btnWeek.frame.size.height-20);
    //CGRect frame=CGRectMake(-20, 135, 340, 230);
    if(_hostView==nil)
    {
        _hostView=[[CPTGraphHostingView alloc] initWithFrame:frame];
        _hostView.tag=300;
        _hostView.userInteractionEnabled=YES;
    }
    if(_xyGraph!=nil)
    {
        [_xyGraph removeFromSuperlayer];
        _xyGraph=nil;
    }
    
    if(_xyGraph == nil)
    {
        _xyGraph=[[CPTXYGraph alloc] initWithFrame:CGRectZero];
    }
    
    _hostView.hostedGraph=_xyGraph;
    //_hostView.collapsesLayers=NO;
    if(_hostView!=nil&&![[self.scrollview subviews] containsObject:_hostView])
    {
        [self.scrollview addSubview:_hostView];
    }
    
    _hostView.backgroundColor=[UIColor clearColor];
    
    
    if(_chartType == ChartWeek)
    {
        _xyGraph.plotAreaFrame.paddingTop    = 10.0;
        _xyGraph.plotAreaFrame.paddingRight  = 10.0;
        _xyGraph.plotAreaFrame.paddingLeft   = 20.0;
        _xyGraph.plotAreaFrame.paddingBottom = 30.0;
    }
    else
    {
        _xyGraph.plotAreaFrame.paddingTop    = 10.0;
        _xyGraph.plotAreaFrame.paddingRight  = 20.0;
        _xyGraph.plotAreaFrame.paddingLeft   = 30.0;
        _xyGraph.plotAreaFrame.paddingBottom = 30.0;
        
        if([_selectProject isEqualToString:ProjectBasic])
        {
            _xyGraph.plotAreaFrame.paddingLeft   = 40.0;
        }
    }
    
    
    CGRect rectGraph=_xyGraph.frame;
    rectGraph.origin.x=rectGraph.origin.x+10;
    
    _xyGraph.frame=rectGraph;
    _xyGraph.delegate=self;

    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_xyGraph.defaultPlotSpace;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth=1.0f;
    axisLineStyle.lineColor=[CPTColor blackColor];
    
    //创建XY轴
    [self createGraphAxis];
    
    /*
     // 上限线
     CPTScatterPlot *centerLinePlot = [[CPTScatterPlot alloc] init];
     centerLinePlot.interpolation=CPTScatterPlotInterpolationCurved;
     centerLinePlot.identifier = kCenterLine;
     
     CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
     lineStyle.lineWidth          = 0.5;
     lineStyle.lineColor          = [CPTColor redColor];
     lineStyle.dashPattern    = [NSArray arrayWithObjects:
     [NSNumber numberWithFloat:3.0f],
     [NSNumber numberWithFloat:3.0f], nil];
     centerLinePlot.dataLineStyle = lineStyle;
     
     centerLinePlot.dataSource = self;
     [_xyGraph addPlot:centerLinePlot];
     */
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth          = 1.5;
    lineStyle.lineColor          = [CPTColor blackColor];
    
    //0度线条
    CPTScatterPlot *zeroLinePlot = [[CPTScatterPlot alloc] init];
    zeroLinePlot.interpolation=CPTScatterPlotInterpolationCurved;
    zeroLinePlot.identifier = kZeroLine;
    lineStyle.dashPattern=nil;
    lineStyle.lineWidth          = 1.5;
    lineStyle.lineColor          = [CPTColor blackColor];
    
    zeroLinePlot.dataLineStyle = lineStyle;
    
    zeroLinePlot.dataSource = self;
    //[_xyGraph addPlot:zeroLinePlot];
    
    
    //目标体重直线
    CPTScatterPlot *controlLinePlot = [[CPTScatterPlot alloc] init];
    controlLinePlot.interpolation=CPTScatterPlotInterpolationCurved;
    controlLinePlot.identifier = kControlLine;
    
    lineStyle                     = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth           = 0.5;
    lineStyle.lineColor           = [CPTColor colorWithCGColor:UIColorFromRGB(0x00a7c9).CGColor];
    
    
    /*
     lineStyle.dashPattern    = [NSArray arrayWithObjects:
     [NSNumber numberWithFloat:3.0f],
     [NSNumber numberWithFloat:3.0f], nil];
     */
    
    controlLinePlot.dataLineStyle = lineStyle;
    
    controlLinePlot.dataSource = self;
    if([_selectProject isEqualToString:ProjectStepCount])
    {
        [_xyGraph addPlot:controlLinePlot];
    }
    
    

    CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
    barLineStyle.lineWidth = 1.0;
    barLineStyle.lineColor = [CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor];
    
    CPTBarPlot *barPlot2 = [CPTBarPlot tubularBarPlotWithColor:[CPTColor yellowColor] horizontalBars:NO];
    //CPTBarPlot *barPlot2 = [[CPTBarPlot alloc] init];
    barPlot2.lineStyle    = barLineStyle;
    barPlot2.fill         = [CPTFill fillWithColor:[CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor]];
    //barPlot2.barBasesVary = YES;
    
    barPlot2.borderColor=[UIColor clearColor].CGColor;
    barPlot2.borderWidth=0.0;
    barPlot2.barWidth        = CPTDecimalFromFloat(0.5f); // bar is full (100%) width
    barPlot2.barCornerRadius = 2.0;
    
    barPlot2.barsAreHorizontal = NO;
    
    barPlot2.delegate   = self;
    barPlot2.dataSource = self;
    barPlot2.identifier = kBarDataLine;
    
    [_xyGraph addPlot:barPlot2];
    
    
    // 目标体重的数值
    CPTScatterPlot *lineControlPlot = [[CPTScatterPlot alloc] init];
    lineControlPlot.interpolation = CPTScatterPlotInterpolationCurved;
    lineControlPlot.identifier = kControlPoint;
    
    lineStyle              = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor colorWithComponentRed:0 green:0 blue:0 alpha:0];
    
    lineStyle.lineWidth    = 0.5;
    lineControlPlot.dataLineStyle = lineStyle;
    
    
    lineControlPlot.dataSource = self;
    if([_selectProject isEqualToString:ProjectWeight])
    {
        [_xyGraph addPlot:lineControlPlot];
    }
    
    
    // 目标体重的圆点
    CPTMutableLineStyle *controlSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    controlSymbolLineStyle.lineColor = [CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor];
    CPTPlotSymbol *controlPlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    controlPlotSymbol.fill      = [CPTFill fillWithColor:[CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor]];
    controlPlotSymbol.lineStyle = controlSymbolLineStyle;
    controlPlotSymbol.size      = CGSizeMake(5.0, 5.0);
    lineControlPlot.plotSymbol  = controlPlotSymbol;
    
    
    // Data line  数据线直线
    CPTScatterPlot *lineShowPlot = [[CPTScatterPlot alloc] init];
    lineShowPlot.interpolation = CPTScatterPlotInterpolationCurved;
    lineShowPlot.identifier = kDataShowLine;
    
    lineStyle              = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor];
    lineStyle.lineWidth    = 0.5;
    lineShowPlot.dataLineStyle = lineStyle;
    
    
    lineShowPlot.dataSource = self;
    //[_xyGraph addPlot:lineShowPlot];
    
    
    // Data line  数据线圆点
    CPTScatterPlot *linePlot = [[CPTScatterPlot alloc] init];
    linePlot.interpolation = CPTScatterPlotInterpolationCurved;
    linePlot.identifier = kDataLine;
    
    lineStyle              = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor colorWithComponentRed:0 green:0 blue:0 alpha:0];
    
    lineStyle.lineWidth    = 0.5;
    linePlot.dataLineStyle = lineStyle;
    
    
    linePlot.dataSource = self;
    //[_xyGraph addPlot:linePlot];
    
    
    if(_chartType == ChartWeek)
    {
        // Add plot symbols  圆点
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = [CPTColor colorWithCGColor:UIColorFromRGB(0x00a0ea).CGColor];
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.fill      = [CPTFill fillWithColor:[CPTColor colorWithCGColor:UIColorFromRGB(0x00a0ea).CGColor]];
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size      = CGSizeMake(5.0, 5.0);
        linePlot.plotSymbol  = plotSymbol;
    }
    
    [self setBarYRange];
    
    
    //移动画布
    plotSpace.allowsUserInteraction=NO;
    plotSpace.delegate=self;
}

-(void)showChart:(BOOL)animated
{
    if([_selectProject isEqualToString:ProjectStepCount] ||
       [_selectProject isEqualToString:ProjectStepJourney] ||
       [_selectProject isEqualToString:ProjectStepTime] ||
       [_selectProject isEqualToString:ProjectStepCalorie])
    {
        [self showBarChart:YES];
        return;
    }
    
    
    CGRect frame=CGRectMake(-20, self.btnWeek.frame.origin.y+self.btnWeek.frame.size.height+15, SCREEN_WIDTH+20, self.lblAllTitle.frame.origin.y-self.btnWeek.frame.origin.y-self.btnWeek.frame.size.height-20);
    
    //CGRect frame=CGRectMake(-20, 135, 340, 230);
    if(_hostView==nil)
    {
        _hostView=[[CPTGraphHostingView alloc] initWithFrame:frame];
        _hostView.tag=300;
        _hostView.userInteractionEnabled=YES;
    }
    if(_xyGraph!=nil)
    {
        [_xyGraph removeFromSuperlayer];
        _xyGraph=nil;
    }
    
    if(_xyGraph == nil)
    {
        _xyGraph=[[CPTXYGraph alloc] initWithFrame:CGRectZero];
    }
    
    _hostView.hostedGraph=_xyGraph;
    //_hostView.collapsesLayers=NO;
    if(_hostView!=nil&&![[self.scrollview subviews] containsObject:_hostView])
    {
        [self.scrollview addSubview:_hostView];
    }
    
    _hostView.backgroundColor=[UIColor clearColor];
    
    
    if(_chartType == ChartWeek)
    {
        _xyGraph.plotAreaFrame.paddingTop    = 10.0;
        _xyGraph.plotAreaFrame.paddingRight  = 10.0;
        _xyGraph.plotAreaFrame.paddingLeft   = 20.0;
        _xyGraph.plotAreaFrame.paddingBottom = 30.0;
    }
    else
    {
        /*
        _xyGraph.plotAreaFrame.paddingTop    = 10.0;
        _xyGraph.plotAreaFrame.paddingRight  = 20.0;
        _xyGraph.plotAreaFrame.paddingLeft   = 30.0;
        _xyGraph.plotAreaFrame.paddingBottom = 30.0;
        */
        
        _xyGraph.plotAreaFrame.paddingTop    = 10.0;
        _xyGraph.plotAreaFrame.paddingRight  = 10.0;
        _xyGraph.plotAreaFrame.paddingLeft   = 20.0;
        _xyGraph.plotAreaFrame.paddingBottom = 30.0;
        
        if([_selectProject isEqualToString:ProjectBasic])
        {
            _xyGraph.plotAreaFrame.paddingLeft   = 40.0;
        }
    }
    
    
    
    CGRect rectGraph=_xyGraph.frame;
    rectGraph.origin.x=rectGraph.origin.x+10;
    
    _xyGraph.frame=rectGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_xyGraph.defaultPlotSpace;
    
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth=1.0f;
    axisLineStyle.lineColor=[CPTColor blackColor];
    
    //创建XY轴
    [self createGraphAxis];
    
    /*
     // 上限线
     CPTScatterPlot *centerLinePlot = [[CPTScatterPlot alloc] init];
     centerLinePlot.interpolation=CPTScatterPlotInterpolationCurved;
     centerLinePlot.identifier = kCenterLine;
     
     CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
     lineStyle.lineWidth          = 0.5;
     lineStyle.lineColor          = [CPTColor redColor];
     lineStyle.dashPattern    = [NSArray arrayWithObjects:
     [NSNumber numberWithFloat:3.0f],
     [NSNumber numberWithFloat:3.0f], nil];
     centerLinePlot.dataLineStyle = lineStyle;
     
     centerLinePlot.dataSource = self;
     [_xyGraph addPlot:centerLinePlot];
     */
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth          = 1.5;
    lineStyle.lineColor          = [CPTColor blackColor];
    
    //0度线条
    CPTScatterPlot *zeroLinePlot = [[CPTScatterPlot alloc] init];
    zeroLinePlot.interpolation=CPTScatterPlotInterpolationCurved;
    zeroLinePlot.identifier = kZeroLine;
    lineStyle.dashPattern=nil;
    lineStyle.lineWidth          = 1.5;
    lineStyle.lineColor          = [CPTColor blackColor];
    
    zeroLinePlot.dataLineStyle = lineStyle;
    
    zeroLinePlot.dataSource = self;
    //[_xyGraph addPlot:zeroLinePlot];
    
    
    //目标体重直线
    CPTScatterPlot *controlLinePlot = [[CPTScatterPlot alloc] init];
    controlLinePlot.interpolation=CPTScatterPlotInterpolationCurved;
    controlLinePlot.identifier = kControlLine;
    
    lineStyle                     = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth           = 0.5;
    lineStyle.lineColor           = [CPTColor colorWithCGColor:UIColorFromRGB(0x00a7c9).CGColor];
    
    
    /*
     lineStyle.dashPattern    = [NSArray arrayWithObjects:
     [NSNumber numberWithFloat:3.0f],
     [NSNumber numberWithFloat:3.0f], nil];
     */
    
    controlLinePlot.dataLineStyle = lineStyle;
    
    controlLinePlot.dataSource = self;
    if([_selectProject isEqualToString:ProjectWeight])
    {
        [_xyGraph addPlot:controlLinePlot];
    }
    
    
    
    // 目标体重的数值
    CPTScatterPlot *lineControlPlot = [[CPTScatterPlot alloc] init];
    lineControlPlot.interpolation = CPTScatterPlotInterpolationCurved;
    lineControlPlot.identifier = kControlPoint;
    
    lineStyle              = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor colorWithComponentRed:0 green:0 blue:0 alpha:0];
    
    lineStyle.lineWidth    = 0.5;
    lineControlPlot.dataLineStyle = lineStyle;
    
    
    lineControlPlot.dataSource = self;
    if([_selectProject isEqualToString:ProjectWeight])
    {
        [_xyGraph addPlot:lineControlPlot];
    }
    
    
    // 目标体重的圆点
    CPTMutableLineStyle *controlSymbolLineStyle = [CPTMutableLineStyle lineStyle];
    controlSymbolLineStyle.lineColor = [CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor];
    CPTPlotSymbol *controlPlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    controlPlotSymbol.fill      = [CPTFill fillWithColor:[CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor]];
    controlPlotSymbol.lineStyle = controlSymbolLineStyle;
    controlPlotSymbol.size      = CGSizeMake(5.0, 5.0);
    lineControlPlot.plotSymbol  = controlPlotSymbol;
    
    
    // Data line  数据线直线
    CPTScatterPlot *lineShowPlot = [[CPTScatterPlot alloc] init];
    lineShowPlot.interpolation = CPTScatterPlotInterpolationCurved;
    lineShowPlot.identifier = kDataShowLine;
    
    lineStyle              = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor];
    lineStyle.lineWidth    = 0.5;
    lineShowPlot.dataLineStyle = lineStyle;
    
    
    lineShowPlot.dataSource = self;
    [_xyGraph addPlot:lineShowPlot];
    
    
    // Data line  数据线圆点
    CPTScatterPlot *linePlot = [[CPTScatterPlot alloc] init];
    linePlot.interpolation = CPTScatterPlotInterpolationCurved;
    linePlot.identifier = kDataLine;
    
    lineStyle              = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor colorWithComponentRed:0 green:0 blue:0 alpha:0];
    
    lineStyle.lineWidth    = 0.5;
    linePlot.dataLineStyle = lineStyle;
    
    
    linePlot.dataSource = self;
    [_xyGraph addPlot:linePlot];
    
    
    if(_chartType == ChartWeek)
    {
        // Add plot symbols  圆点
        CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
        symbolLineStyle.lineColor = [CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor];
        CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
        plotSymbol.fill      = [CPTFill fillWithColor:[CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor]];
        plotSymbol.lineStyle = symbolLineStyle;
        plotSymbol.size      = CGSizeMake(5.0, 5.0);
        linePlot.plotSymbol  = plotSymbol;
    }
    
    [self setYRange];
    
    
    //移动画布
    plotSpace.allowsUserInteraction=NO;
    plotSpace.delegate=self;
}


-(void)setBarYRange
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_xyGraph.defaultPlotSpace;
    if(YRange!=nil  && [YRange count] == 2 )
    {
        maxYValue=[[YRange objectAtIndex:1] floatValue];
        minYValue=[[YRange objectAtIndex:0] floatValue];
        
        CGFloat maxValue=[[YRange objectAtIndex:1] floatValue];
        CGFloat middleValue=maxValue/2;

        if([_selectProject isEqualToString:ProjectStepCount])
        {
            if(dControlWeight>maxYValue)
            {
                maxYValue=dControlWeight;
            }
            
            if(dControlWeight<minYValue)
            {
                minYValue=dControlWeight;
            }
        }
        
        
        middleValue=maxYValue/2;
        maxYValue=maxYValue*1.2;
        minYValue=minYValue*0.9;
        //minYValue=0.0;
        
        maxYValue=maxYValue-minYValue;
        if(maxYValue == 0)
        {
            maxYValue=1.0;
        }
        
        //maxYValue=maxYValue*1.5;
        
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_xyGraph.axisSet;
        CPTXYAxis *axisYNone = axisSet.yAxis;
        NSMutableSet *newAxisYLabels = [NSMutableSet set];
        NSMutableSet *yLocations=[NSMutableSet set];
        int iCount=maxYValue/4;
        //int iMinYValue=round(minYValue);
        
        minYValue=round(minYValue*100)/100;
        if(iCount == 0)
        {
            iCount=1;
        }
        
        if(minYValue < 0)
        {
            minYValue=0;
        }
        
        if(iCount != 0)
        {
            axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(minYValue);
            
            for ( NSUInteger i = 0; i <= 1; i++ )
            {
                int ilabel=0;
                CGFloat fLabel=0.0;
                if(i == 0)
                {
                    ilabel=middleValue;
                    if([_selectProject isEqualToString:ProjectStepCount] ||
                       [_selectProject isEqualToString:ProjectStepCalorie])
                    {
                        fLabel=middleValue/1000.0;
                    }
                    else
                    {
                        fLabel=middleValue;
                    }
                    
                }
                else
                {
                    ilabel=maxValue;
                    if(dControlWeight>maxValue)
                    {
                        ilabel=dControlWeight;
                        maxValue=dControlWeight;
                    }
                    if([_selectProject isEqualToString:ProjectStepCount] ||
                       [_selectProject isEqualToString:ProjectStepCalorie])
                    {
                        fLabel=maxValue/1000.0;
                    }
                    else
                    {
                        fLabel=maxValue;
                    }
                }
                
                CPTAxisLabel *newLabel;
                
                if([_selectProject isEqualToString:ProjectStepCount] || [_selectProject isEqualToString:ProjectStepCalorie])
                {
                    newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%.1fk", fLabel]
                                                        textStyle:axisYNone.labelTextStyle];
                }
                else
                {
                    newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%.1f", fLabel]
                                                        textStyle:axisYNone.labelTextStyle];
                }
                
                
                newLabel.tickLocation = CPTDecimalFromDouble(ilabel);
                newLabel.offset       = axisYNone.labelOffset + axisYNone.majorTickLength / 2.0;
                
                if(newLabel)
                {
                    [yLocations addObject:[NSDecimalNumber numberWithInt:ilabel]];
                    [newAxisYLabels addObject:newLabel];
                }
            }
        }
        else
        {
            float iCount=maxYValue/4;
            for ( NSUInteger i = 1; i <= 5; i++ )
            {
                CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%.1f", i*iCount]
                                                                  textStyle:axisYNone.labelTextStyle];
                
                newLabel.tickLocation = CPTDecimalFromFloat(i * iCount);
                newLabel.offset       = axisYNone.labelOffset + axisYNone.majorTickLength / 2.0;
                
                if(newLabel)
                {
                    [yLocations addObject:[NSDecimalNumber numberWithInt:i*iCount]];
                    [newAxisYLabels addObject:newLabel];
                }
                
            }
        }
        
        
        axisYNone.axisLabels=newAxisYLabels;
        axisYNone.majorTickLocations=yLocations;
        
        if(_chartType == ChartWeek)
        {
            //axisYNone.axisLabels=nil;
            //axisYNone.majorTickLocations=nil;
        }
        
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minYValue) length:CPTDecimalFromFloat(maxYValue)];
        plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minYValue) length:CPTDecimalFromFloat(maxYValue)];
        
        CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
        CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
        
        [xRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
        [yRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
        
        //plotSpace.xRange=xRange;
        //plotSpace.yRange=yRange;
    }
}

-(void)setYRange
{
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_xyGraph.defaultPlotSpace;
    if(YRange!=nil  && [YRange count] == 2 )
    {
        maxYValue=[[YRange objectAtIndex:1] floatValue];
        minYValue=[[YRange objectAtIndex:0] floatValue];
        
        
        if([_selectProject isEqualToString:ProjectWeight])
        {
            if(dControlWeight>maxYValue)
            {
                maxYValue=dControlWeight;
            }
            
            if(dControlWeight<minYValue)
            {
                minYValue=dControlWeight;
            }
        }
        
        
        if([[YRange objectAtIndex:1] floatValue] - [[YRange objectAtIndex:0] floatValue] == 0.0)
        {
            //maxYValue=[[YRange objectAtIndex:1] floatValue];
            //minYValue=maxYValue/2;
        }
        
        if([_selectProject isEqualToString:ProjectBone])
        {
            maxYValue=maxYValue+2;
            minYValue=0.0;
        }
        else
        {
            maxYValue=maxYValue*1.1;
            minYValue=minYValue*0.9;
        }
        
        maxYValue=maxYValue-minYValue;
        if(maxYValue == 0)
        {
            maxYValue=1.0;
        }
        
        //maxYValue=maxYValue*1.5;
        
        CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_xyGraph.axisSet;
        CPTXYAxis *axisYNone = axisSet.yAxis;
        NSMutableSet *newAxisYLabels = [NSMutableSet set];
        NSMutableSet *yLocations=[NSMutableSet set];
        if(maxYValue <4)
        {
            maxYValue = 4;
        }
        int iCount=maxYValue/4;
        //int iMinYValue=round(minYValue);
        minYValue=round(minYValue*100)/100;
        
        if(minYValue < 0)
        {
            minYValue=0;
        }
        if(iCount == 0)
        {
            iCount=1;
        }
        if(iCount != 0)
        {
            axisSet.xAxis.orthogonalCoordinateDecimal = CPTDecimalFromDouble(minYValue);
            
            for ( NSUInteger i = 1; i <= 6; i++ )
            {
                int ilabel=i*iCount+minYValue;
                CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d", ilabel]
                                                                  textStyle:axisYNone.labelTextStyle];
                
                newLabel.tickLocation = CPTDecimalFromDouble(ilabel);
                newLabel.offset       = axisYNone.labelOffset + axisYNone.majorTickLength / 2.0;
                
                if(newLabel)
                {
                    [yLocations addObject:[NSDecimalNumber numberWithInt:ilabel]];
                    [newAxisYLabels addObject:newLabel];
                }
            }
        }
        else
        {
            float iCount=maxYValue/4;
            for ( NSUInteger i = 1; i <= 5; i++ )
            {
                CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%.1f", i*iCount]
                                                                  textStyle:axisYNone.labelTextStyle];
                
                newLabel.tickLocation = CPTDecimalFromFloat(i * iCount);
                newLabel.offset       = axisYNone.labelOffset + axisYNone.majorTickLength / 2.0;
                
                if(newLabel)
                {
                    [yLocations addObject:[NSDecimalNumber numberWithInt:i*iCount]];
                    [newAxisYLabels addObject:newLabel];
                }
                
            }
        }
        
        
        axisYNone.axisLabels=newAxisYLabels;
        axisYNone.majorTickLocations=yLocations;
        
        if(_chartType == ChartWeek)
        {
            //axisYNone.axisLabels=nil;
            //axisYNone.majorTickLocations=nil;
        }
        
        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minYValue) length:CPTDecimalFromFloat(maxYValue)];
        plotSpace.globalYRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(minYValue) length:CPTDecimalFromFloat(maxYValue)];
        
        CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
        CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
        
        [xRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
        [yRange expandRangeByFactor:CPTDecimalFromDouble(1.05)];
        
        //plotSpace.xRange=xRange;
        //plotSpace.yRange=yRange;
    }
}

//绘制XY轴
-(void)createGraphAxis
{
    NSInteger iXLow=0;
    NSInteger iXHight=0;
    NSSet *majorTickLocations=nil;
    if(_chartType == ChartWeek)
    {
        NSDate *date=_lastDayOfWeek.date;
        aryWeekDay=[PublicModule getpreviousWeekDayWithDate:date];
        iXLow=0;
        iXHight=7;
        
        majorTickLocations = [NSSet setWithObjects:[NSDecimalNumber numberWithUnsignedInteger:0],
                              [NSDecimalNumber numberWithUnsignedInteger:1],
                              [NSDecimalNumber numberWithUnsignedInteger:2],
                              [NSDecimalNumber numberWithUnsignedInteger:3],
                              [NSDecimalNumber numberWithUnsignedInteger:4],
                              [NSDecimalNumber numberWithUnsignedInteger:5],
                              [NSDecimalNumber numberWithUnsignedInteger:6],
                              [NSDecimalNumber numberWithUnsignedInteger:7],
                              nil];
    }
    else if(_chartType == ChartMonth)
    {
        NSDate *date=_lastDayOfMonth.date;
        aryMonthDay=[PublicModule getpreviousMonthDayWithDate:date];
        iXLow=0;
        iXHight=7;
        majorTickLocations = [NSSet setWithObjects:[NSDecimalNumber zero],
                              [NSDecimalNumber numberWithUnsignedInteger:1],
                              [NSDecimalNumber numberWithUnsignedInteger:2],
                              [NSDecimalNumber numberWithUnsignedInteger:3],
                              [NSDecimalNumber numberWithUnsignedInteger:4],
                              [NSDecimalNumber numberWithUnsignedInteger:5],
                              [NSDecimalNumber numberWithUnsignedInteger:6],
                              [NSDecimalNumber numberWithUnsignedInteger:7],
                              nil];
    }
    else if(_chartType == ChartYear)
    {
        NSDate *date=_lastDayOfYear.date;
        
        NVDate *dateNow=[[NVDate alloc] initUsingDate:[NSDate date]];
        NSString *endTime=[dateNow stringValueWithFormat:@"yyyy-MM-dd"];
        [dateNow previousDays:7];
        NSString *startTime=[dateNow stringValueWithFormat:@"yyyy-MM-dd"];
        
        NSArray *aryMaxMinTime=[_db selectMaxAndMinProjectTimeWithProject:ProjectStepCount andCTime:[AppDelegate shareUserInfo].account_ctime];
        NSDate *dateStart;
        NSDate *dateEnd;
        if(aryMaxMinTime != nil && aryMaxMinTime.count>=2)
        {
            NSString *minTime=[aryMaxMinTime objectAtIndex:0];
            NSString *maxTime=[aryMaxMinTime objectAtIndex:1];
            
            dateStart=[PublicModule getDateWithString:minTime andFormatter:@""];
            dateEnd=[PublicModule getDateWithString:maxTime andFormatter:@""];
        }
        else
        {
            dateStart=[PublicModule getDateWithString:startTime andFormatter:@"yyyy-MM-dd"];
            dateEnd=[PublicModule getDateWithString:endTime andFormatter:@"yyyy-MM-dd"];
        }
        
        
        aryYearDay=[PublicModule getpreviousAllDayWithStartDate:dateStart andEndDate:dateEnd];
        
        //aryYearDay=[PublicModule getpreviousYearDayWithDate:date];
        iXLow=0;
        iXHight=7;
        majorTickLocations = [NSSet setWithObjects:[NSDecimalNumber zero],
                              [NSDecimalNumber numberWithUnsignedInteger:1],
                              [NSDecimalNumber numberWithUnsignedInteger:2],
                              [NSDecimalNumber numberWithUnsignedInteger:3],
                              [NSDecimalNumber numberWithUnsignedInteger:4],
                              [NSDecimalNumber numberWithUnsignedInteger:5],
                              [NSDecimalNumber numberWithUnsignedInteger:6],
                              [NSDecimalNumber numberWithUnsignedInteger:7],
                              nil];
    }
    
    
    //线条样式
    CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
    axisLineStyle.lineWidth = 1.0;
    axisLineStyle.lineColor=[CPTColor blackColor];
    
    //主刻度
    CPTMutableLineStyle *majorTickLineStyle = [axisLineStyle mutableCopy];
    majorTickLineStyle.lineWidth = 1.0;
    majorTickLineStyle.lineCap   = kCGLineCapRound;
    majorTickLineStyle.lineColor=[CPTColor blackColor];
    
    //主刻度线
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 1;
    majorGridLineStyle.lineColor = [CPTColor blackColor];
    
    
    //线条样式透明
    CPTMutableLineStyle *axisLineStyleNo = [CPTMutableLineStyle lineStyle];
    axisLineStyleNo.lineWidth = 1.0;
    axisLineStyleNo.lineColor=[CPTColor clearColor];
    
    //主刻度透明
    CPTMutableLineStyle *majorTickLineStyleNo = [axisLineStyle mutableCopy];
    majorTickLineStyleNo.lineWidth = 1.0;
    majorTickLineStyleNo.lineCap   = kCGLineCapRound;
    majorTickLineStyleNo.lineColor=[CPTColor clearColor];
    
    //主刻度线透明
    CPTMutableLineStyle *majorGridLineStyleNo = [CPTMutableLineStyle lineStyle];
    majorGridLineStyleNo.lineWidth = 1;
    majorGridLineStyleNo.lineColor = [CPTColor clearColor];
    
    
    //坐标值的字体
    CPTMutableTextStyle *textStyle=[[CPTMutableTextStyle alloc] init];
    textStyle.color=[CPTColor blackColor];
    
    
    //图表的XY轴集合
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)_xyGraph.axisSet;
    
    
    // 自定义X轴
    CPTXYAxis *axisNone = axisSet.xAxis;
    axisNone.plotSpace                   = _xyGraph.defaultPlotSpace;
    axisNone.labelingPolicy              = CPTAxisLabelingPolicyNone;
    axisNone.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    axisNone.tickDirection               = CPTSignNone;
    
    if([_selectProject isEqualToString:ProjectStepCount] ||
       [_selectProject isEqualToString:ProjectStepCalorie] ||
       [_selectProject isEqualToString:ProjectStepJourney] ||
       [_selectProject isEqualToString:ProjectStepTime])
    {
        axisNone.axisLineStyle               = axisLineStyle;
        axisNone.majorTickLength             = 5;
        
        axisNone.majorGridLineStyle              =majorGridLineStyleNo;
        axisNone.majorTickLineStyle          = majorTickLineStyle;
        axisNone.majorTickLocations          = majorTickLocations;
    }
    else
    {
        axisNone.axisLineStyle               = axisLineStyle;
        axisNone.majorTickLength             = 5;
        
        axisNone.majorGridLineStyle              =majorGridLineStyle;
        axisNone.majorTickLineStyle          = majorTickLineStyle;
        axisNone.majorTickLocations          = majorTickLocations;
    }
    
    
    
    
    
    axisNone.labelTextStyle=textStyle;
    NSMutableSet *newAxisLabels = [NSMutableSet set];
    
    if(_chartType == ChartWeek)
    {
        if(aryWeekDay!=nil)
        {
            for ( NSUInteger i = 0; i <= 7; i++ )
            {
                
                NSString *strTime=[aryWeekDay objectAtIndex:i];
                if(strTime == nil)
                {
                    strTime=@"";
                }
                
                
                NSString *strText=strTime;
                CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:strText
                                                                  textStyle:axisNone.  labelTextStyle];
                
                newLabel.tickLocation = CPTDecimalFromUnsignedInteger(i * 1);
                newLabel.offset       = axisNone.labelOffset + axisNone.majorTickLength / 2.0;
                
                [newAxisLabels addObject:newLabel];
            }
        }
        else
        {
            for ( NSUInteger i = 0; i <= 7; i++ )
            {
                
                CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)i+1]
                                                                  textStyle:axisNone.labelTextStyle];
                
                newLabel.tickLocation = CPTDecimalFromUnsignedInteger(i * 1);
                newLabel.offset       = axisNone.labelOffset + axisNone.majorTickLength / 2.0;
                
                [newAxisLabels addObject:newLabel];
            }
        }
        
    }
    else if(_chartType == ChartMonth)
    {
        NSInteger y=0;
        if(aryMonthDay!=nil)
        {
            for ( NSUInteger i = 0; i <= 7; i++ )
            {
                NSString *strTime=[aryMonthDay objectAtIndex:i];
                if(strTime == nil)
                {
                    strTime=@"";
                }
                
                
                NSString *strText=strTime;
                CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:strText
                                                                  textStyle:axisNone.  labelTextStyle];
                
                newLabel.tickLocation = CPTDecimalFromUnsignedInteger(i * 1);
                newLabel.offset       = axisNone.labelOffset + axisNone.majorTickLength / 2.0;
                
                [newAxisLabels addObject:newLabel];
            }
        }
        else
        {
            for ( NSUInteger i = 0; i <= 7; i++ )
            {
                CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)i+1]
                                                                  textStyle:axisNone.labelTextStyle];
                
                newLabel.tickLocation = CPTDecimalFromUnsignedInteger(i * 1);
                newLabel.offset       = axisNone.labelOffset + axisNone.majorTickLength / 2.0;
                
                [newAxisLabels addObject:newLabel];
            }
        }
        
    }
    else if(_chartType == ChartYear)
    {
        if(aryYearDay!=nil)
        {
            for ( NSUInteger i = 0; i <= 7; i++ )
            {
                NSString *strTime=[aryYearDay objectAtIndex:i];
                if(strTime == nil)
                {
                    strTime=@"";
                }
                
                
                NSString *strText=strTime;
                CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:strText
                                                                  textStyle:axisNone.  labelTextStyle];
                
                newLabel.tickLocation = CPTDecimalFromUnsignedInteger(i * 1);
                newLabel.offset       = axisNone.labelOffset + axisNone.majorTickLength / 2.0;
                
                [newAxisLabels addObject:newLabel];
            }
        }
        else
        {
            for ( NSUInteger i = 0; i <= 11; i++ )
            {
                
                CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)i+1]
                                                                  textStyle:axisNone.labelTextStyle];
                
                newLabel.tickLocation = CPTDecimalFromUnsignedInteger(i * 1);
                newLabel.offset       = axisNone.labelOffset + axisNone.majorTickLength / 2.0;
                
                [newAxisLabels addObject:newLabel];
            }
        }
    }
    
    
    axisNone.axisLabels = newAxisLabels;
    //axisNone.majorTickLocations=xLocations;
    
    //自定义Y轴
    
    NSSet *ymajorTickLocations = [NSSet setWithObjects:
                                  [NSDecimalNumber numberWithUnsignedInteger:20],
                                  [NSDecimalNumber numberWithUnsignedInteger:40],
                                  [NSDecimalNumber numberWithUnsignedInteger:60],
                                  [NSDecimalNumber numberWithUnsignedInteger:80],
                                  [NSDecimalNumber numberWithUnsignedInteger:100],
                                  nil];
    
    CPTXYAxis *axisYNone = axisSet.yAxis;
    axisYNone.plotSpace                   = _xyGraph.defaultPlotSpace;
    axisYNone.labelingPolicy              = CPTAxisLabelingPolicyNone;
    axisYNone.orthogonalCoordinateDecimal = CPTDecimalFromUnsignedInteger(0);
    axisYNone.tickDirection               = CPTSignNone;
    axisYNone.axisLineStyle               = axisLineStyle;
    axisYNone.majorTickLength             = 5;
    
    axisYNone.majorGridLineStyle          =nil;
    axisYNone.majorTickLineStyle          = majorTickLineStyle;
    axisYNone.majorTickLocations          = ymajorTickLocations;
    
    axisYNone.labelTextStyle=textStyle;
    NSMutableSet *newAxisYLabels = [NSMutableSet set];
    for ( NSUInteger i = 1; i <= 5; i++ ) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%lu", (unsigned long)i*20]
                                                          textStyle:axisYNone.labelTextStyle];
        
        newLabel.tickLocation = CPTDecimalFromUnsignedInteger(i * 20);
        newLabel.offset       = axisYNone.labelOffset + axisYNone.majorTickLength / 2.0;
        
        [newAxisYLabels addObject:newLabel];
    }
    axisYNone.axisLabels = newAxisYLabels;
    
    axisNone.delegate=self;
    axisYNone.delegate=self;
    
    /*
     if(_chartType == ChartWeek)
     {
     //axisYNone.axisLabels=nil;
     //axisYNone.majorTickLocations=nil;
     }
     */
    
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_xyGraph.defaultPlotSpace;
    
    
    if([_selectProject isEqualToString:ProjectStepCount])
    {
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(iXLow-0.5) length:CPTDecimalFromFloat(iXHight+1.0)];
    }
    else
    {
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(iXLow-0.4) length:CPTDecimalFromFloat(iXHight+0.7)];
    }
    
    /*
    if(_chartType == ChartWeek)
    {
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(iXLow) length:CPTDecimalFromFloat(iXHight+0.3)];
        //plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(iXLow) length:CPTDecimalFromUnsignedInteger(iXHight)];
    }
    else
    {
        plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(iXLow) length:CPTDecimalFromFloat(iXHight+0.3)];
        //plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromUnsignedInteger(iXLow) length:CPTDecimalFromUnsignedInteger(iXHight)];
    }
    */
    
    
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0) length:CPTDecimalFromInteger(105)];
    //_xyGraph.axisSet.axes = [NSArray arrayWithObjects:axisNone,axisYNone, nil];
}


-(CPTPlotRange *)CPTPlotRangeFromFloat:(float)location length:(float)length
{
    return [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(location) length:CPTDecimalFromFloat(length)];
}


-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if([_selectProject isEqualToString:ProjectStepCount])
    {
        return [plotData count]+2;
    }
    if(_chartType == ChartWeek || _chartType == ChartYear)
    {
        if(plotData==nil || plotData.count ==0)
        {
            return 0;
        }
        return [plotData count]+1;
    }
    else if(_chartType == ChartMonth)
    {
        if(plotData==nil || plotData.count ==0)
        {
            return 0;
        }
        return [plotData count]+1;
    }
    return [plotData count]+1;
}

//返回Y轴点的值
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    if(idx == 0)
    {
        return nil;
    }
    
    if([_selectProject isEqualToString:ProjectStepCount] &&idx == plotData.count+1)
    {
        return nil;
    }
    
    if(_chartType == ChartMonth || _chartType == ChartYear)
    {
        return nil;
    }
    if(idx>[plotData count])
    {
        return  nil;
    }
    static CPTMutableTextStyle *whiteText = nil;
    static CPTMutableTextStyle *yellowText=nil;
    
    if ( !whiteText )
    {
        whiteText       = [[CPTMutableTextStyle alloc] init];
        
        whiteText.color = [CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor];
    }
    if( !yellowText)
    {
        yellowText = [[CPTMutableTextStyle alloc] init];
        yellowText.color = [CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor];
    }
    
    CPTTextLayer *newLayer = nil;
    
    if([_selectProject isEqualToString:ProjectStepCount])
    {
        if(plot.identifier==kBarDataLine)
        {
            if([[plotData objectAtIndex:idx-1] intValue]<=0)
            {
                return  nil;
            }
            
            newLayer=[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.0f",[[plotData objectAtIndex:idx-1] doubleValue]] style:whiteText];
            
        }
    }
    else
    {
        if(plot.identifier==kDataLine)
        {
            if([[plotData objectAtIndex:idx-1] intValue]<=0)
            {
                return  nil;
            }
            
            newLayer=[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.1f",[[plotData objectAtIndex:idx-1] doubleValue]] style:whiteText];
            
        }
    }
    
    if(plot.identifier==kControlPoint)
    {
        return nil;
        /*
         if(idx==[plotData count]-1)
         {
         newLayer=[[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%.1f",dControlWeight] style:yellowText];
         }
         else
         {
         return nil;
         }
         */
    }
    
    return newLayer;
}


-(double)doubleForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    double number = NAN;
    
    switch ( fieldEnum )
    {
        case CPTScatterPlotFieldX:
            number = (double)index;
            break;
        case CPTScatterPlotFieldY:
            
            if ( plot.identifier == kDataLine )
            {
                
                if(index == 0 || index == plotData.count+1) return avgValue;
                
                if(index>[plotData count]+1)
                {
                    return  NAN;
                }
                
                number = [[plotData objectAtIndex:index-1] doubleValue];
                
                if(number==0)
                {
                    number=avgValue;
                    if(number == 0)
                    {
                        number = NAN;
                    }
                    number = NAN;
                }
                else if (number == -100)
                {
                    number=NAN;
                }
            }
            
            else if(plot.identifier == kDataShowLine || plot.identifier == kBarDataLine)
            {
                if(index == 0 || index == plotData.count+1)
                {
                    if(plot.identifier == kBarDataLine)
                    {
                        return NAN;
                    }
                    return  avgValue;
                }
                
                if(index>[plotData count]+1)
                {
                    return  NAN;
                }
                
                number = [[plotData objectAtIndex:index-1] doubleValue];
                if(number==0)
                {
                    number=avgValue;
                    if(number == 0)
                    {
                        number = NAN;
                    }
                    if(plot.identifier == kBarDataLine)
                    {
                        number = NAN;
                    }
                }
                else if (number == -100)
                {
                    number=NAN;
                }
            }
            else if(plot.identifier == kControlPoint)
            {
                if(index>[plotData count]+1)
                {
                    return  NAN;
                }
                
                if(index == [plotData count]+1)
                {
                    number=dControlWeight;
                    if(number <= 0)
                    {
                        number = NAN;
                    }
                }
                else
                {
                    number=NAN;
                }
            }
            else if ( plot.identifier == kControlLine)
            {
                number = dControlWeight;
                if(number <= 0)
                {
                    number=NAN;
                }
            }
            
            else if(plot.identifier == kZeroLine)
            {
                number=NAN;
            }
            
            break;
    }
    
    return number;
}


#pragma mark CPTBarPlot delegate methods

-(void)plot:(CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Data label for '%@' was selected at index %d.", plot.identifier, (int)index);
}

-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index
{
    //NSNumber *value = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
    return;
    
    int iValue=[[plotData objectAtIndex:index-1] intValue];
    NSNumber *value =[NSNumber numberWithInt:iValue];
    
    NSLog(@"Bar for '%@' was selected at index %d. Value = %f", plot.identifier, (int)index, [value floatValue]);
    
    //CPTGraph *graph = (_xyGraph)[0];
    
    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;
    if ( annotation ) {
        [_xyGraph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }
    
    // Setup a style for the annotation
    CPTMutableTextStyle *hitAnnotationTextStyle = [CPTMutableTextStyle textStyle];
    hitAnnotationTextStyle.color    = [CPTColor colorWithCGColor:UIColorFromRGB(0x00af00).CGColor];
    hitAnnotationTextStyle.fontSize = 14.0;
    //hitAnnotationTextStyle.fontName = @"Helvetica-Bold";
    
    // Determine point of symbol in plot coordinates
    NSNumber *x = @(index);
    NSNumber *y = value;
    
    NSArray *anchorPoint = (NO ? @[y, x] : @[x, y]);
    
    // Add annotation
    // First make a string for the y value
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    NSString *yString = [formatter stringFromNumber:value];
    
    // Now add the annotation to the plot area
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:yString style:hitAnnotationTextStyle];
    annotation                = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
    annotation.contentLayer   = textLayer;
    annotation.displacement   = CGPointMake(0.0, 0.0);
    self.symbolTextAnnotation = annotation;
    
    [_xyGraph.plotAreaFrame.plotArea addAnnotation:annotation];
}

@end

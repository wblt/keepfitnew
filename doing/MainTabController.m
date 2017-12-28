#import "MainTabController.h"
#import "GUserAddController.h"
#import "GMeasureController.h"
#import "GStepController.h"
#import "GAnalysisController.h"
#import "GMineController.h"
#import "GLoginAddController.h"

#define SELECTED_VIEW_CONTROLLER_TAG 98456345

@interface MainTabController ()
{
    NSArray *_aryControllers;
    long iLastViewTag;
    AppDelegate *_delegate;
    
    DbModel *_db;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageMenuBg;
@property (weak, nonatomic) IBOutlet UIButton *btnClickTrends;
@property (weak, nonatomic) IBOutlet UIButton *btnClickMsg;
@property (weak, nonatomic) IBOutlet UIButton *btnClickSquare;
@property (weak, nonatomic) IBOutlet UIButton *btnClickMine;

@end

@implementation MainTabController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _db=[[DbModel alloc] init];
    
    
    iLastViewTag=-1;
    _aryControllers=[self getViewcontrollers];
    _delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    _delegate.canShowDoingLogin=YES;
    
    [self initPickerData];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    self.navigationController.fd_prefersNavigationBarHidden = YES;
    
    [self initView];
    
    self.lblTrends.text=NSLocalizedString(@"title_measure", nil);
    self.lblMsg.text=NSLocalizedString(@"title_step", nil);
    self.lblSquare.text=NSLocalizedString(@"title_analysis", nil);
    self.lblMine.text=NSLocalizedString(@"title_me", nil);
    
    [self menuClickWithIndex:self.btnClickTrends.tag];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUnreadCount) name:NotiUnreadCount object:nil];
    
}

-(void)initPickerData
{
    aryWeight=[[NSMutableArray alloc] init];
    aryLbWeight = [NSMutableArray new];
    aryWeight2=[[NSMutableArray alloc] init];
    aryStep=[[NSMutableArray alloc] init];
    
    NSString *weight;
    NSString *lbWeight;
    for(int i=30;i<101;i++)
    {
        weight = [NSString stringWithFormat:@"%d",i];
        lbWeight = [PublicModule kgToZeroLb:weight];
        [aryWeight addObject:weight];
        [aryLbWeight addObject:lbWeight];
    }
    
    for(int i=0;i<10;i++)
    {
        [aryWeight2 addObject:[NSString stringWithFormat:@".%d",i]];
    }
    
    for(int i=1;i<32;i++)
    {
        NSString *strStep=[NSString stringWithFormat:@"%d",i*500+1500];
        [aryStep addObject:strStep];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    UIView *view=touch.view;
    if(view.tag == 123)
    {
        [self showTargetWeighgPicker:NO withTarget:@"" showTarget:@""];
    }
}

- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

-(void)initView
{
    CGFloat axisYCancle;
    
    axisYCancle=SCREEN_HEIGHT-SCREEN_WIDTH*0.119-0.540625*SCREEN_WIDTH;
    
    self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    self.viewMenu.frame=CGRectMake(0, SCREEN_HEIGHT-59, SCREEN_WIDTH, 59);
    self.viewBottomBg.frame=CGRectMake(-1, 10, SCREEN_WIDTH+2, 50);
    self.viewBottomBg.layer.borderColor=UIColorFromRGB(0xd3d3d3).CGColor;
    self.viewBottomBg.layer.borderWidth=1.0f;
    
    CGFloat widthTemp=SCREEN_WIDTH/4;
    
    self.btnTrends.frame=CGRectMake((widthTemp-22)/2, 19, 22, 22);
    
    self.btnMsg.frame=CGRectMake((widthTemp-32)/2+widthTemp, 23, 32, 16);
    
    self.btnCreate.frame=CGRectMake(0.4234375*SCREEN_WIDTH, 0, 64, 63);
    
    self.btnSquare.frame=CGRectMake((widthTemp-25)/2+widthTemp*2, 21, 25, 20);
    
    self.btnMine.frame=CGRectMake((widthTemp-22)/2+widthTemp*3, 20, 22, 22);
    
    
    self.lblTrends.frame=CGRectMake(0, 40, widthTemp, 20);
    self.lblMsg.frame=CGRectMake(widthTemp, 40, widthTemp, 20);
    self.lblSquare.frame=CGRectMake(widthTemp*2, 40, widthTemp, 20);
    self.lblMine.frame=CGRectMake(widthTemp*3, 40, widthTemp, 20);
    
    self.btnClickTrends.frame=CGRectMake(0, 10, widthTemp, 49);
    
    self.btnClickMsg.frame=CGRectMake(widthTemp, 10, widthTemp, 49);
    
    self.btnClickSquare.frame=CGRectMake(widthTemp*2, 10, widthTemp, 49);
    
    self.btnClickMine.frame=CGRectMake(widthTemp*3, 10, widthTemp, 49);
    
    frameBtnPhoto=CGRectMake(SCREEN_WIDTH*0.08125, axisYCancle, SCREEN_WIDTH*0.203125, SCREEN_WIDTH*0.203125);
    frameBtnPhotoText=CGRectMake(SCREEN_WIDTH*0.39375, axisYCancle, SCREEN_WIDTH*0.203125, SCREEN_WIDTH*0.203125);
    frameBtnVideo=CGRectMake(SCREEN_WIDTH*0.70625, axisYCancle, SCREEN_WIDTH*0.203125, SCREEN_WIDTH*0.203125);
    
    self.viewCover.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.viewPicker.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.viewPicker.frame.size.height);
    
    self.btnPickerCancle.frame=CGRectMake(0, self.pickerTargetStep.frame.size.height, SCREEN_WIDTH/2, self.viewPicker.frame.size.height-self.pickerTargetStep.frame.size.height);
    self.btnPickerFinish.frame=CGRectMake(SCREEN_WIDTH/2, self.pickerTargetStep.frame.size.height, SCREEN_WIDTH/2, self.viewPicker.frame.size.height-self.pickerTargetStep.frame.size.height);
    self.viewCover.alpha=0.0;
    
    [self.btnPickerCancle setTitle:NSLocalizedString(@"cancle", nil) forState:UIControlStateNormal];
    [self.btnPickerFinish setTitle:NSLocalizedString(@"enter", nil) forState:UIControlStateNormal];
}


-(void)showTargetStepPicker:(BOOL)aBool withTarget:(NSString *)target
{
    if(aBool)
    {
        if(target &&target.length>=1)
        {
            NSUInteger iRow1=0;
                
            iRow1=[aryStep indexOfObject:target];

            if(iRow1>=aryStep.count)
            {
                iRow1=0;
            }

            [self.pickerTargetStep selectRow:iRow1 inComponent:0 animated:NO];

        }
        
        _iPickerType=2;
        [UIView animateWithDuration:0.3f animations:^{
            self.viewCover.alpha=0.5;
            self.pickerTargetWeight.hidden=YES;
            self.pickerTargetStep.hidden=NO;
            self.viewPicker.frame=CGRectMake(0, SCREEN_HEIGHT-self.viewPicker.frame.size.height, SCREEN_WIDTH, self.viewPicker.frame.size.height);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.viewCover.alpha=0.0;
            self.pickerTargetStep.hidden=YES;
            self.pickerTargetWeight.hidden=YES;
            self.viewPicker.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.viewPicker.frame.size.height);
        }];
    }
}

- (IBAction)canclePickerView:(id)sender
{
    [self showTargetWeighgPicker:NO withTarget:@"" showTarget:@""];
}

- (IBAction)finishPickerView:(id)sender
{
    [self showTargetWeighgPicker:NO withTarget:@"" showTarget:@""];
    [self setPickerValue];
}

-(void)setPickerValue
{
    if(_iPickerType == 1)
    {
        NSInteger row=[self.pickerTargetWeight selectedRowInComponent:1];
        NSInteger row2=[self.pickerTargetWeight selectedRowInComponent:2];
        NSString *strWeight=[aryWeight objectAtIndex:row];
        NSString *strWeight2=[aryWeight2 objectAtIndex:row2];
        if (_isLbUnit) {
            strWeight=[aryLbWeight objectAtIndex:row];
        }
        
        NSString *targetWeight=@"40";
        NSString *targetWeightShow=[NSString stringWithFormat:@"%@%@",strWeight,strWeight2];
        if (_isLbUnit) {
            targetWeight = [PublicModule lbToKg:targetWeightShow];
        } else {
            targetWeight=targetWeightShow;
        }
        
        NSString *mid=@"-1";
        NSString *targetValue=targetWeight;
        NSString *ttime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
        NSString *update=@"1";
        NSString *iDelete=@"0";
        NSString *ctime=[AppDelegate shareUserInfo].account_ctime;
        NSString *ifinish=@"0";
        NSString *tfinishtime=@"";
        NSString *ttype=@"0";
        NSString *memberType=@"0";
        NSString *targetType=[NSString stringWithFormat:@"%d",_iPickerType];
        
        NSArray *aryInfo=[[NSArray alloc] initWithObjects:mid,targetValue,ttime,update,iDelete,ctime,ifinish,tfinishtime,ttype,memberType,targetType, nil];
        [_db insertTarget:aryInfo];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:targetWeight forKey:@"target_weight"];
        [dic setObject:targetWeightShow forKey:@"target_weight_show"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiAddTargetWeight object:nil userInfo:dic];
    }
    else if (_iPickerType == 2)
    {
        NSInteger row=[self.pickerTargetStep selectedRowInComponent:0];
        NSString *targetStep=[aryStep objectAtIndex:row];
        
        NSString *mid=@"-1";
        NSString *targetValue=targetStep;
        NSString *ttime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
        NSString *update=@"1";
        NSString *iDelete=@"0";
        NSString *ctime=[AppDelegate shareUserInfo].account_ctime;
        NSString *ifinish=@"0";
        NSString *tfinishtime=@"";
        NSString *ttype=@"0";
        NSString *memberType=@"0";
        NSString *targetType=[NSString stringWithFormat:@"%d",_iPickerType];
        
        NSArray *aryInfo=[[NSArray alloc] initWithObjects:mid,targetValue,ttime,update,iDelete,ctime,ifinish,tfinishtime,ttype,memberType,targetType, nil];
        
        [_db insertTarget:aryInfo];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:targetStep forKey:@"target_step"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NotiAddTargetStep object:nil userInfo:dic];
    }
}

-(void)showTargetWeighgPicker:(BOOL)aBool withTarget:(NSString *)target  showTarget:(NSString *)targetShow
{
    if(aBool)
    {
        NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
        _isLbUnit = NO;
        if ([weightUnit isEqualToString:@"lb"]) {
            _isLbUnit = YES;
        }
        
        NSString *showWeight2=nil;
        if (targetShow && targetShow.length>=1) {
            NSArray *aryTargetTemp=[targetShow componentsSeparatedByString:@"."];
            if(aryTargetTemp && aryTargetTemp.count>=2) {
                showWeight2=[aryTargetTemp objectAtIndex:1];
            }
        }
        [self.pickerTargetWeight reloadComponent:1];
        
        if(target &&target.length>=1)
        {
            NSArray *aryWeightTemp=[target componentsSeparatedByString:@"."];
            NSUInteger iRow1=0;
            NSUInteger iRow2=0;
            if(aryWeightTemp && aryWeightTemp.count>=2)
            {
                NSString *weight1=[aryWeightTemp objectAtIndex:0];
                NSString *weight2=[aryWeightTemp objectAtIndex:1];
                if (showWeight2) {
                    weight2=showWeight2;
                }
                //weight2=[@"." stringByAppendingString:weight2];
                iRow1=[aryWeight indexOfObject:weight1];
                iRow2=[weight2 integerValue];
                
                if(iRow1>=aryWeight.count)
                {
                    iRow1=0;
                }
                if(iRow2>=aryWeight2.count)
                {
                    iRow2=0;
                }
                [self.pickerTargetWeight selectRow:iRow1 inComponent:1 animated:NO];
                [self.pickerTargetWeight selectRow:iRow2 inComponent:2 animated:NO];
            }
        }
        _iPickerType=1;
        [UIView animateWithDuration:0.3f animations:^{
            self.viewCover.alpha=0.5;
            self.pickerTargetWeight.hidden=NO;
            self.pickerTargetStep.hidden=YES;
            self.viewPicker.frame=CGRectMake(0, SCREEN_HEIGHT-self.viewPicker.frame.size.height, SCREEN_WIDTH, self.viewPicker.frame.size.height);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.viewCover.alpha=0.0;
            self.pickerTargetStep.hidden=YES;
            self.pickerTargetWeight.hidden=YES;
            self.viewPicker.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.viewPicker.frame.size.height);
        }];
    }
}

-(void)showUnreadCount
{
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    if(![PublicModule checkLoginStatus])
    {
        [self gotoLogin];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)configureNotification:(BOOL)toAdd
{
    
}


-(void)gotoDLogin
{
    if(_delegate.canShowDoingLogin)
    {
        GLoginAddController *vc = [[GLoginAddController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}




-(NSArray *)getViewcontrollers
{
    NSArray* aryController = nil;
    
    GMeasureController *child1=[[GMeasureController alloc] init];
    //UINavigationController *nav1=[[UINavigationController alloc] initWithRootViewController:child1];
    
    GStepController *child2=[[GStepController alloc] init];
    //DSquareController *child3=[[DSquareController alloc] init];
    GAnalysisController *child3=[[GAnalysisController alloc] init];
    GMineController *child4=[[GMineController alloc] init];
    
    aryController=[[NSArray alloc] initWithObjects:child1,child2,child3,child4, nil];
    return aryController;
    
}

-(void)menuClickWithIndex:(long)index
{
    
    if(index == 0)
    {
        [_delegate stopScan];
        [_delegate startScan];
    }
    else
    {
        [_delegate disconnectMydevice];
        [_delegate stopScan];
    }
    
    if(iLastViewTag == index)
    {
        return;
        
        _delegate.canShowDoingLogin=YES;
        [self gotoDLogin];
        return;
    }
    if(index >=0 && index<=3 )
    {
        UIView* currentView = [self.view viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
        [currentView removeFromSuperview];
        
        
        //UINavigationController* nav = [_aryControllers objectAtIndex:index];
        
        //UIViewController *vc=[nav.childViewControllers objectAtIndex:0];
        UIViewController *vc=[_aryControllers objectAtIndex:index];
         vc.view.tag = SELECTED_VIEW_CONTROLLER_TAG;
        
        
        vc.view.frame = CGRectMake(0,0,self.view.frame.size.width, self.view.frame.size.height- 40);
        
        [self.view insertSubview:vc.view belowSubview:self.viewMenu];
        //[self.view addSubview:vc.view];
        iLastViewTag=index;
        [self changeMenuPicWithIndex:index];
        
        if(index == 1)
        {
            [((GStepController *)vc) updateAppleHealth];
            //[((GStepController *)vc) refreshChartData];
        }
    }
}

-(void)changeMenuPicWithIndex:(long)index
{
    [self.btnTrends setImage:[UIImage imageNamed:@"guo_menu_weight_unselected.png"] forState:UIControlStateNormal];
    //self.btnTrends.frame=CGRectMake(0.06875*SCREEN_WIDTH, 20, 21, 22);
    [self.btnMsg setImage:[UIImage imageNamed:@"guo_menu_foot_unselected.png"] forState:UIControlStateNormal];
    [self.btnSquare setImage:[UIImage imageNamed:@"guo_menu_analysis_unselected.png"] forState:UIControlStateNormal];
    [self.btnMine setImage:[UIImage imageNamed:@"guo_menu_mine_unselected.png"] forState:UIControlStateNormal];
    //c9caca
    self.lblTrends.textColor=UIColorFromRGB(0x6a6a6a);
    self.lblMine.textColor=UIColorFromRGB(0x6a6a6a);
    self.lblMsg.textColor=UIColorFromRGB(0x6a6a6a);
    self.lblSquare.textColor=UIColorFromRGB(0x6a6a6a);
    
    switch (index) {
        case 0:
            [self.btnTrends setImage:[UIImage imageNamed:@"guo_menu_weight_selected.png"] forState:UIControlStateNormal];
            self.lblTrends.textColor=UIColorFromRGB(0x00af00);
            break;
        case 1:
            [self.btnMsg setImage:[UIImage imageNamed:@"guo_menu_foot_selected.png"] forState:UIControlStateNormal];
            self.lblMsg.textColor=UIColorFromRGB(0x00af00);
            break;
        case 2:
            [self.btnSquare setImage:[UIImage imageNamed:@"guo_menu_analysis_selected.png"] forState:UIControlStateNormal];
            self.lblSquare.textColor=UIColorFromRGB(0x00af00);
            break;
        case 3:
            [self.btnMine setImage:[UIImage imageNamed:@"guo_menu_mine_selected.png"] forState:UIControlStateNormal];
            self.lblMine.textColor=UIColorFromRGB(0x00af00);
            break;
        default:
            break;
    }
}

-(void)mainSelectWithController:(UIViewController *)controller
{
    if ([controller isKindOfClass:[UINavigationController class]])
    {
        [(UINavigationController *)controller setDelegate:self];
    }
    if (_currentMainController == nil)
    {
        _currentMainController = controller;
        [self addChildViewController:_currentMainController];
        [_currentMainController didMoveToParentViewController:self];
    }
    else if (_currentMainController != controller && controller !=nil)
    {
        CGRect frameController=controller.view.frame;
        [_currentMainController willMoveToParentViewController:nil];
        [self addChildViewController:controller];
        //self.view.userInteractionEnabled = NO;
        
        [self transitionFromViewController:_currentMainController
                          toViewController:controller
                                  duration:1.0
                                   options:UIViewAnimationOptionTransitionNone
                                animations:^{
                                    
                                }
                                completion:^(BOOL finished){
                                    self.view.userInteractionEnabled = YES;
                                    [_currentMainController removeFromParentViewController];
                                    [controller didMoveToParentViewController:self];
                                    _currentMainController = controller;
                                }
         ];
    }
}

- (IBAction)gotoTrends:(id)sender {
    UIButton *btn=(UIButton *)sender;
    if(btn)
    {
        /*
        TrendsController *vc = [[TrendsController alloc] init];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBarHidden=YES;
        [self mainSelectWithController:nav];
         */
        [self menuClickWithIndex:btn.tag];
    }
}

- (IBAction)gotoMsg:(id)sender {
    UIButton *btn=(UIButton *)sender;
    if(btn)
    {
        [self menuClickWithIndex:btn.tag];
    }
}



- (void)saveImageToAlbum:(UIImage*) image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

//实现imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:方法

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *message = @"呵呵";
    if (!error)
    {
        message = @"成功保存到相册";
    }else
    {
        message = [error description];
    }
    NSLog(@"message is %@",message);
}


- (IBAction)gotoHomePage:(id)sender
{
    /*
    DHomePageController *vc = [[DHomePageController alloc] init];
    vc.vcDelegate=self;
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBarHidden=YES;
    
    //[self.navigationController pushViewController:vc animated:YES];
    [self presentViewController:nav animated:YES completion:nil];
     */
}

- (IBAction)gotoSquare:(id)sender {
    UIButton *btn=(UIButton *)sender;
    if(btn)
    {
        [self menuClickWithIndex:btn.tag];
    }
}

- (IBAction)gotoMine:(id)sender {
    UIButton *btn=(UIButton *)sender;
    if(btn)
    {
        [self menuClickWithIndex:btn.tag];
    }
}

-(void)gotoSearchFriend
{
    
}

-(void)gotoFindFriend
{
    [self menuClickWithIndex:self.btnClickSquare.tag];
}

-(void)gotoFriendProfile:(NSMutableDictionary *)dic
{
    
}

-(void)gotoLogin
{
    GLoginAddController *vc=[[GLoginAddController alloc] init];
    
    [vc setLeftMenuEnable:YES];
    //DLoginController *vc = [[DLoginController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if(pickerView.tag == 11)
    {
        return 4;
    }
    return 1;
}
//picker行高
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35;
}

//picker每一列的数据个数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView.tag == 11)
    {
        if(component == 1)
        {
            return [aryWeight count];
        }
        else if(component == 2)
        {
            return [aryWeight2 count];
        }
        return 1;
    }
    else if (pickerView.tag == 22)
    {
        return [aryStep count];
    }
    return 0;
}

//选择器的标题，也就是显示内容
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView.tag == 11)
    {
        if(component == 1)
        {
            if (_isLbUnit) {
                return [aryLbWeight objectAtIndex:row];
            } 
            return [aryWeight objectAtIndex:row];
        }
        else if(component == 2)
        {
            return [aryWeight2 objectAtIndex:row];
        }
        else if(component == 3)
        {
            return @"";
        }
        else
        {
            return @"";
        }
    }
    else if (pickerView.tag == 22)
    {
        return [aryStep objectAtIndex:row];
    }
    return @"";
}

//选择器选择完之后触发函数
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(pickerView.tag == 11)
    {
        NSInteger row=[self.pickerTargetWeight selectedRowInComponent:1];
        NSInteger row2=[self.pickerTargetWeight selectedRowInComponent:2];
        NSString *strWeight=[aryWeight objectAtIndex:row];
        NSString *strWeight2=[aryWeight2 objectAtIndex:row2];
        NSString *height=[NSString stringWithFormat:@"%@%@",strWeight,strWeight2];
    }
    else if (pickerView.tag == 22)
    {
        NSInteger row=[self.pickerTargetStep selectedRowInComponent:0];
        NSString *strStep=[aryStep objectAtIndex:row];
    }
}
@end

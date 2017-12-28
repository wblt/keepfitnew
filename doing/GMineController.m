#import "GMineController.h"
#import "GMineStepCell.h"
#import "GMineWeightCell.h"
#import "GMineFatTitleCell.h"
#import "GMineFatCell.h"
#import "GSettingController.h"
#import <QuartzCore/QuartzCore.h>

@interface GMineController ()<LCActionSheetDelegate>
{
    NSArray *_aryDate;
    NSMutableArray *_aryProjectData;
    NSMutableDictionary *_dicFootStep;
    NSMutableDictionary *_dicWeight;
    NSInteger _iDateTag;
}

@end

@implementation GMineController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.lblTopTitle.text=NSLocalizedString(@"title_me", nil);
    [self.btnSetting setTitle:NSLocalizedString(@"title_setting", nil) forState:UIControlStateNormal];
    
    [self initView];
    
    [self setViewDateValue];
    _publicModel=[[PublicModule alloc] init];
    _db=[[DbModel alloc] init];
    _jsonModule=[[NetworkModule alloc] init];
    _delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    _aryDate=[PublicModule getBeforeWeekDayWithDate:[NSDate date]];
    
    [self initMeasureData];
    
    if(_dicFootStep.count>=1 ||
       _dicWeight.count>=1 ||
       _aryProjectData.count>=1)
    {
        self.btnShare.hidden=YES;
    }
    else
    {
        self.btnShare.hidden=YES;
    }
    
    [self.tableview reloadData];
    isSelfController=YES;

    [self.view insertSubview:self.viewNotiStatus belowSubview:self.viewTop];
    [self clickDate:self.btnDate7];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotiView) name:GNotiUpdateView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMeasureData) name:GNotiRefreshView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiRefreshMineView) name:GNotiRefreshMineView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotiView) name:@"weight_unit" object:nil];
}


-(void)notiRefreshMineView
{
    if(_iDateTag == self.btnDate7.tag)
    {
        [self clickDate:self.btnDate7];
    }
}

-(void)updateNotiView
{
    [self refreshMeasureData];
    if(_iDateTag == self.btnDate7.tag)
    {
        [self clickDate:self.btnDate7];
    }
}

-(void)initMeasureData
{
    NSMutableDictionary *dicTempBMI=[[NSMutableDictionary alloc] init];
    [dicTempBMI setValue:@"0" forKey:@"type"];
    [dicTempBMI setObject:ProjectBMIName forKey:@"name"];
    [dicTempBMI setObject:@"21.6" forKey:@"value"];
    
    NSMutableDictionary *dicTempMuscle=[[NSMutableDictionary alloc] init];
    [dicTempMuscle setValue:@"1" forKey:@"type"];
    [dicTempMuscle setObject:ProjectMuscleName forKey:@"name"];
    [dicTempMuscle setObject:@"36.2%" forKey:@"value"];
    
    NSMutableDictionary *dicTempFat=[[NSMutableDictionary alloc] init];
    [dicTempFat setValue:@"1" forKey:@"type"];
    [dicTempFat setObject:ProjectFatName forKey:@"name"];
    [dicTempFat setObject:@"18%" forKey:@"value"];
    
    NSMutableDictionary *dicTempWater=[[NSMutableDictionary alloc] init];
    [dicTempWater setValue:@"2" forKey:@"type"];
    [dicTempWater setObject:ProjectWaterName forKey:@"name"];
    [dicTempWater setObject:@"45%" forKey:@"value"];
    
    
    NSMutableDictionary *dicTempBone=[[NSMutableDictionary alloc] init];
    [dicTempBone setValue:@"0" forKey:@"type"];
    [dicTempBone setObject:ProjectBoneName forKey:@"name"];
    [dicTempBone setObject:@"2.3kg" forKey:@"value"];
    
    NSMutableDictionary *dicTempBasic=[[NSMutableDictionary alloc] init];
    [dicTempBasic setValue:@"0" forKey:@"type"];
    [dicTempBasic setObject:ProjectBasicName forKey:@"name"];
    [dicTempBasic setObject:@"1572kcal" forKey:@"value"];
    
    NSMutableDictionary *dicTempVisceral=[[NSMutableDictionary alloc] init];
    [dicTempVisceral setValue:@"2" forKey:@"type"];
    [dicTempVisceral setObject:ProjectVisceralFatName forKey:@"name"];
    [dicTempVisceral setObject:@"15%" forKey:@"value"];
    
    NSMutableDictionary *dicTempBodyage=[[NSMutableDictionary alloc] init];
    [dicTempBodyage setValue:@"2" forKey:@"type"];
    [dicTempBodyage setObject:ProjectBodyageName forKey:@"name"];
    [dicTempBodyage setObject:@"0" forKey:@"value"];
    //步行 体重 BMI  脂肪 水分 肌肉 骨量 基础代谢 内脏脂肪 身体年龄
    
    _aryProjectData=[[NSMutableArray alloc] initWithObjects:dicTempBMI,dicTempFat,dicTempWater,dicTempMuscle,dicTempBone,dicTempBasic,dicTempVisceral,dicTempBodyage, nil];
    
    _dicWeight=[[NSMutableDictionary alloc] init];
    _dicFootStep=[[NSMutableDictionary alloc] init];
    
    NSDictionary *dicRange=[PublicModule getFatRangeWithAge:_delegate.myUserInfo.userAge andSex:_delegate.myUserInfo.sex];
    [_dicWeight setObject:@"65.0" forKey:@"weight"];
    [_dicWeight setObject:@"21.2" forKey:@"bmi"];
    [_dicWeight setObject:[dicRange valueForKey:ProjectBMI] forKey:@"range"];
    
    [_dicFootStep setObject:@"1769" forKey:@"step"];
    [_dicFootStep setObject:[AppDelegate shareUserInfo].targetStep forKey:@"allstep"];
    [_dicFootStep setObject:@"0.4" forKey:@"km"];
    [_dicFootStep setObject:@"20" forKey:@"time"];
    [_dicFootStep setObject:@"1654" forKey:@"kcal"];
    
    
}

-(void)setViewDateValue
{
    _aryDate=[PublicModule getBeforeWeekDayWithDate:[NSDate date]];
    if(_aryDate && _aryDate.count>=7)
    {
        NSString *time1=[_aryDate objectAtIndex:0];
        NSString *time2=[_aryDate objectAtIndex:1];
        NSString *time3=[_aryDate objectAtIndex:2];
        NSString *time4=[_aryDate objectAtIndex:3];
        NSString *time5=[_aryDate objectAtIndex:4];
        NSString *time6=[_aryDate objectAtIndex:5];
        NSString *time7=[_aryDate objectAtIndex:6];
        
        NSString *day1=[[_aryDate objectAtIndex:0] substringWithRange:NSMakeRange(8, 2)];
        NSString *day2=[[_aryDate objectAtIndex:1] substringWithRange:NSMakeRange(8, 2)];
        NSString *day3=[[_aryDate objectAtIndex:2] substringWithRange:NSMakeRange(8, 2)];
        NSString *day4=[[_aryDate objectAtIndex:3] substringWithRange:NSMakeRange(8, 2)];
        NSString *day5=[[_aryDate objectAtIndex:4] substringWithRange:NSMakeRange(8, 2)];
        NSString *day6=[[_aryDate objectAtIndex:5] substringWithRange:NSMakeRange(8, 2)];
        NSString *day7=[[_aryDate objectAtIndex:6] substringWithRange:NSMakeRange(8, 2)];
        
        
        self.lblDay1.text=[NSString stringWithFormat:@"%d",[day1 intValue]];
        self.lblDay2.text=[NSString stringWithFormat:@"%d",[day2 intValue]];
        self.lblDay3.text=[NSString stringWithFormat:@"%d",[day3 intValue]];
        self.lblDay4.text=[NSString stringWithFormat:@"%d",[day4 intValue]];
        self.lblDay5.text=[NSString stringWithFormat:@"%d",[day5 intValue]];
        self.lblDay6.text=[NSString stringWithFormat:@"%d",[day6 intValue]];
        self.lblDay7.text=[NSString stringWithFormat:@"%d",[day7 intValue]];
        
        NSDate *date1=[PublicModule getDateWithString:time1 andFormatter:@"yyyy-MM-dd"];
        NSDate *date2=[PublicModule getDateWithString:time2 andFormatter:@"yyyy-MM-dd"];
        NSDate *date3=[PublicModule getDateWithString:time3 andFormatter:@"yyyy-MM-dd"];
        NSDate *date4=[PublicModule getDateWithString:time4 andFormatter:@"yyyy-MM-dd"];
        NSDate *date5=[PublicModule getDateWithString:time5 andFormatter:@"yyyy-MM-dd"];
        NSDate *date6=[PublicModule getDateWithString:time6 andFormatter:@"yyyy-MM-dd"];
        NSDate *date7=[PublicModule getDateWithString:time7 andFormatter:@"yyyy-MM-dd"];
        
        
        NSDateComponents *componets1 = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date1];
        NSInteger weekday1 = [componets1 weekday];
        self.lblWeekDay1.text=[self getWeekdayName:weekday1];
        
        NSDateComponents *componets2 = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date2];
        NSInteger weekday2 = [componets2 weekday];
        self.lblWeekDay2.text=[self getWeekdayName:weekday2];
        
        NSDateComponents *componets3 = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date3];
        NSInteger weekday3 = [componets3 weekday];
        self.lblWeekDay3.text=[self getWeekdayName:weekday3];
        
        NSDateComponents *componets4 = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date4];
        NSInteger weekday4 = [componets4 weekday];
        self.lblWeekDay4.text=[self getWeekdayName:weekday4];
        
        NSDateComponents *componets5 = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date5];
        NSInteger weekday5 = [componets5 weekday];
        self.lblWeekDay5.text=[self getWeekdayName:weekday5];
        
        NSDateComponents *componets6 = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date6];
        NSInteger weekday6 = [componets6 weekday];
        self.lblWeekDay6.text=[self getWeekdayName:weekday6];
        
        NSDateComponents *componets7 = [[NSCalendar autoupdatingCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date7];
        NSInteger weekday7 = [componets7 weekday];
        self.lblWeekDay7.text=[self getWeekdayName:weekday7];
        
    }
}

-(NSString *)getWeekdayName:(NSInteger )weekday
{
    switch (weekday) {
        case 1:
            return NSLocalizedString(@"周日", nil);
        case 2:
            return NSLocalizedString(@"周一", nil);
        case 3:
            return NSLocalizedString(@"周二", nil);
        case 4:
            return NSLocalizedString(@"周三", nil);
        case 5:
            return NSLocalizedString(@"周四", nil);
        case 6:
            return NSLocalizedString(@"周五", nil);
        default:
            return NSLocalizedString(@"周六", nil);
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
    self.imageLine.frame=CGRectMake(0, NAVBAR_HEIGHT*2, SCREEN_WIDTH, 1);
    
    
    self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone5FontSizeTitle];
    [self.btnSetting.titleLabel setFont:[UIFont systemFontOfSize:iPhone5FontSizeTitle]];
    [self.btnShare.titleLabel setFont:[UIFont systemFontOfSize:iPhone5FontSizeTitle]];
    if(is_iPhone6P)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6PFontSizeTitle];
        [self.btnSetting.titleLabel setFont:[UIFont systemFontOfSize:iPhone6PFontSizeTitle]];
        [self.btnShare.titleLabel setFont:[UIFont systemFontOfSize:iPhone6PFontSizeTitle]];
    }
    else if(is_iPhone6)
    {
        self.lblTopTitle.font=[UIFont systemFontOfSize:iPhone6FontSizeTitle];
        [self.btnSetting.titleLabel setFont:[UIFont systemFontOfSize:iPhone6FontSizeTitle]];
        [self.btnShare.titleLabel setFont:[UIFont systemFontOfSize:iPhone6FontSizeTitle]];
    }
    
    self.view.frame=CGRectMake(0, 0, SCREEN_WIDTH, TABBAR_HEIGHT);
    
    self.viewTop.frame=CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT);
    
    self.viewTop.backgroundColor=NavColor;
    self.viewDate.backgroundColor=NavColor;
    
    self.view.backgroundColor=CommonBgColor;
    self.lblTopTitle.frame=CGRectMake(0, 20, SCREEN_WIDTH, 44);
    self.btnSetting.frame=CGRectMake(SCREEN_WIDTH - 150 - 15, 20, 150, 44);
    
    self.btnShare.frame=CGRectMake(0, 20, 70, 44);
    
    //self.viewDate.layer.shadowOffset=CGSizeMake(0, 1);
    //self.viewDate.layer.shadowOpacity=0.08;
    
    self.viewDate.frame=CGRectMake(0, NAVBAR_HEIGHT, SCREEN_WIDTH, NAVBAR_HEIGHT);
    
    self.tableview.frame=CGRectMake(0, self.viewDate.frame.origin.y+self.viewDate.frame.size.height, SCREEN_WIDTH, SCREEN_HEIGHT-self.viewDate.frame.origin.y-self.viewDate.frame.size.height-NAVBAR_HEIGHT+10);
    self.tableview.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    CGFloat widthTemp=SCREEN_WIDTH/7;
    self.lblWeekDay1.frame=CGRectMake(0, 0, widthTemp, 24);
    self.lblWeekDay2.frame=CGRectMake(widthTemp, 0, widthTemp, 24);
    self.lblWeekDay3.frame=CGRectMake(widthTemp*2, 0, widthTemp, 24);
    self.lblWeekDay4.frame=CGRectMake(widthTemp*3, 0, widthTemp, 24);
    self.lblWeekDay5.frame=CGRectMake(widthTemp*4, 0, widthTemp, 24);
    self.lblWeekDay6.frame=CGRectMake(widthTemp*5, 0, widthTemp, 24);
    self.lblWeekDay7.frame=CGRectMake(widthTemp*6, 0, widthTemp, 24);
    
    self.lblDay1.frame=CGRectMake(self.lblWeekDay1.frame.origin.x, 24, widthTemp, 40);
    self.lblDay2.frame=CGRectMake(self.lblWeekDay2.frame.origin.x, 24, widthTemp, 40);
    self.lblDay3.frame=CGRectMake(self.lblWeekDay3.frame.origin.x, 24, widthTemp, 40);
    self.lblDay4.frame=CGRectMake(self.lblWeekDay4.frame.origin.x, 24, widthTemp, 40);
    self.lblDay5.frame=CGRectMake(self.lblWeekDay5.frame.origin.x, 24, widthTemp, 40);
    self.lblDay6.frame=CGRectMake(self.lblWeekDay6.frame.origin.x, 24, widthTemp, 40);
    self.lblDay7.frame=CGRectMake(self.lblWeekDay7.frame.origin.x, 24, widthTemp, 40);
    
    self.btnDate1.frame=CGRectMake(self.lblWeekDay1.frame.origin.x, 0, widthTemp, NAVBAR_HEIGHT);
    self.btnDate2.frame=CGRectMake(self.lblWeekDay2.frame.origin.x, 0, widthTemp, NAVBAR_HEIGHT);
    self.btnDate3.frame=CGRectMake(self.lblWeekDay3.frame.origin.x, 0, widthTemp, NAVBAR_HEIGHT);
    self.btnDate4.frame=CGRectMake(self.lblWeekDay4.frame.origin.x, 0, widthTemp, NAVBAR_HEIGHT);
    self.btnDate5.frame=CGRectMake(self.lblWeekDay5.frame.origin.x, 0, widthTemp, NAVBAR_HEIGHT);
    self.btnDate6.frame=CGRectMake(self.lblWeekDay6.frame.origin.x, 0, widthTemp, NAVBAR_HEIGHT);
    self.btnDate7.frame=CGRectMake(self.lblWeekDay7.frame.origin.x, 0, widthTemp, NAVBAR_HEIGHT);
    
    self.imageDateLine.frame=CGRectMake(SCREEN_WIDTH-widthTemp, self.viewDate.frame.size.height-2, widthTemp, 2);
    
    self.viewCover.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    self.viewCover.alpha = 0.0;
    
    
    
    self.viewShare.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 0);
    self.lblShareTitle.frame=CGRectMake(0.046875*SCREEN_WIDTH+1, 10, 0.8*SCREEN_WIDTH, 20);
    
    CGFloat imgWidth=0.15625*SCREEN_WIDTH;
    CGFloat imgOffset=0.09375*SCREEN_WIDTH;
    
    self.btnShareTimeline.frame=CGRectMake(0.046875*SCREEN_WIDTH, self.lblShareTitle.frame.origin.y+self.lblShareTitle.frame.size.height+10, imgWidth, imgWidth);
    
    self.btnShareWechatFriend.frame=CGRectMake(self.btnShareTimeline.frame.origin.x+imgWidth+imgOffset, self.btnShareTimeline.frame.origin.y, imgWidth, imgWidth);
    self.btnShareQZone.frame=CGRectMake(self.btnShareWechatFriend.frame.origin.x+imgWidth*2+imgOffset*2,  self.btnShareWechatFriend.frame.origin.y, imgWidth, imgWidth);
    self.btnShareWeibo.frame=CGRectMake(self.btnShareWechatFriend.frame.origin.x+imgWidth*3+imgOffset*3,  self.btnShareWechatFriend.frame.origin.y, imgWidth, imgWidth);
    
    self.lblWechatSquare.frame=CGRectMake(self.btnShareWechatFriend.frame.origin.x, self.btnShareWechatFriend.frame.origin.y+self.btnShareWechatFriend.frame.size.height+2, imgWidth, 0.0625*SCREEN_WIDTH);
    
    
    self.lblWechatFriend.frame=CGRectMake(self.btnShareWechatFriend.frame.origin.x, self.lblWechatSquare.frame.origin.y, imgWidth, self.lblWechatSquare.frame.size.height);
    self.lblQZone.frame=CGRectMake(self.btnShareQZone.frame.origin.x, self.lblWechatSquare.frame.origin.y, imgWidth, self.lblWechatSquare.frame.size.height);
    self.lblWeibo.frame=CGRectMake(self.btnShareWeibo.frame.origin.x, self.lblWechatSquare.frame.origin.y, imgWidth, self.lblWechatSquare.frame.size.height);
    
    self.viewShare.frame=CGRectMake(0, 0, SCREEN_WIDTH, self.lblWeibo.frame.origin.y+self.lblWeibo.frame.size.height);
    
    self.viewShareCancle.frame=CGRectMake(0, self.lblWeibo.frame.size.height+self.lblWeibo.frame.origin.y+14, SCREEN_WIDTH, 40);
    self.btnShareCancle.frame=CGRectMake(0, 0, SCREEN_WIDTH, 40);
    
    self.viewOperation.frame=CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.viewShareCancle.frame.origin.y+self.viewShareCancle.frame.size.height);
    
}



-(void)doShowShare:(NSString *)shareURL
{
    //UIImage *image = [UIImage imageNamed:@"ui_logo.png"];
    
    NSString *imageURL=@"http://yc-scales.im-doing.com/files/images/ui_logo4.png";
    
    NSArray *shareList = [ShareSDK getShareListWithType:ShareTypeWeixiSession, ShareTypeWeixiTimeline, ShareTypeQQ, ShareTypeQQSpace,nil];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"健康生活从测量开始！我用匀称测量得到我的健康数据，小伙伴们也快来测量一下吧！"
                                       defaultContent:@"健康生活从测量开始！我用匀称测量得到我的健康数据，小伙伴们也快来测量一下吧！"
                                                image:[ShareSDK imageWithUrl:imageURL]
                                                title:@"分享我的健康数据"
                                                  url:shareURL
                                          description:@"健康生活从测量开始！我用匀称测量得到我的健康数据，小伙伴们也快来测量一下吧！"
                                            mediaType:SSPublishContentMediaTypeNews];
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:self.btnShare arrowDirect:UIPopoverArrowDirectionUp];
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:shareList
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                  NSLog(@"分享失败,错误码:%ld,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

-(void)showShare:(BOOL)isShow
{
    return;
    
    if(isShow)
    {
        _delegate.tabController.viewMenu.hidden=YES;
        [UIView animateWithDuration:0.3f animations:^{
            self.viewCover.alpha=0.0;
            self.viewOperation.frame=CGRectMake(0, SCREEN_HEIGHT-self.viewOperation.frame.size.height, self.viewOperation.frame.size.width, self.viewOperation.frame.size.height);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            _delegate.tabController.viewMenu.hidden=NO;
            self.viewCover.alpha=0.0;
            self.viewOperation.frame=CGRectMake(0, SCREEN_HEIGHT, self.viewOperation.frame.size.width, self.viewOperation.frame.size.height);
        }];
    }
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
    if(section == 2) {
        return _aryProjectData.count+1;
    }
    
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        if(_dicFootStep.count>=1)
        {
            return 0.4375*SCREEN_WIDTH;
        }
        else
        {
            return 0.4375*SCREEN_WIDTH;
            //return 0;
        }
    }
    else if(indexPath.section == 1)
    {
        if(_dicWeight.count>=1)
        {
           return  [GMineWeightCell getCellHeight];
        }
        else
        {
            //return  [GMineWeightCell getCellHeight];
            return 0;
        }
    }
    else if (indexPath.section == 2) {
        if(_aryProjectData.count >= 1) {
            if (indexPath.row == 0) {
                return 0.2 * SCREEN_WIDTH;
            }
            return 0.1125 * SCREEN_WIDTH;
        } else {
            return 0;
        }
    }
    
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    [view setBackgroundColor:[UIColor clearColor]];
    
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        static NSString *cellID=@"GMineStepCell";
        GMineStepCell *cell=(GMineStepCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        if(!cell)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"GMineStepCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        
        if(_dicFootStep.count>=1)
        {
            [cell configCellWithData:_dicFootStep];
            cell.hidden=NO;
        }
        else
        {
            [cell configCellWithNoData];
            cell.hidden=NO;
        }
        
        return cell;
    }
    else if (indexPath.section == 1)
    {
        static NSString *cellID=@"GMineWeightCell";
        GMineWeightCell *cell=(GMineWeightCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
        if(!cell)
        {
            cell=[[[NSBundle mainBundle] loadNibNamed:@"GMineWeightCell" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        
        if(_dicWeight.count>=1)
        {
            [cell configCellWithData:_dicWeight];
            cell.hidden=NO;
        }
        else
        {
            [cell configCellWithNoData];
            cell.hidden=YES;
        }
        
        return cell;
    }
    else
    {
        if(indexPath.row == 0)
        {
            static NSString *cellID=@"GMineFatTitleCell";
            GMineFatTitleCell *cell=(GMineFatTitleCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            if(!cell)
            {
                cell=[[[NSBundle mainBundle] loadNibNamed:@"GMineFatTitleCell" owner:self options:nil] objectAtIndex:0];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            
            if(_aryProjectData && _aryProjectData.count>=1)
            {
                [cell configCellWithData:_aryProjectData];
                cell.hidden=NO;
            }
            else
            {
                cell.hidden=YES;
            }
            return cell;
        }
        else
        {
            static NSString *cellID=@"GMineFatCell";
            GMineFatCell *cell=(GMineFatCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
            if(!cell)
            {
                cell=[[[NSBundle mainBundle] loadNibNamed:@"GMineFatCell" owner:self options:nil] objectAtIndex:0];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
            }
            
            if(_aryProjectData && _aryProjectData.count>=1)
            {
                NSDictionary *dicTemp = [_aryProjectData objectAtIndex:indexPath.row-1];
                [cell configCellWithData:dicTemp];
                cell.hidden = NO;
            }
            else
            {
                cell.hidden=YES;
            }
            return cell;
        }
    }
    return nil;
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableview deselectRowAtIndexPath:indexPath animated:YES];
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
    
    [self showShare:NO];
    
    if(dic)
    {
        NSString *result=[dic valueForKey:@"result"];
        NSString *operation=[dic valueForKey:@"operation"];
        //NSString *resultmsg=[dic valueForKey:@"result_message"];
        
        if([operation isEqualToString:@"ShareImg-1"])
        {
            if([result isEqualToString:@"0"])
            {
                NSDictionary *dicData=[dic valueForKey:@"data"];
                [self doShowShare:[dicData valueForKey:@"share_url"]];
            }
            else
            {
                [Dialog simpleToast:@"图片上传失败"];
            }
        }
        else if ([operation isEqualToString:@"ShareData-1"])
        {
            if([result isEqualToString:@"0"])
            {
                NSDictionary *dicData=[dic valueForKey:@"data"];
                [self doShowShare:[dicData valueForKey:@"share_url"]];
            }
            else
            {
                [Dialog simpleToast:@"数据上传失败"];
            }

        }
        
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
    [Dialog simpleToast:text];
}

- (IBAction)gotoSetting:(id)sender {
    
    GSettingController *vc=[[GSettingController alloc] init];
    [_delegate.tabController.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)cancleShare:(id)sender {
    
    [self showShare:NO];
}


- (UIImage *)imageWithScreenContents
{
    
    UIGraphicsBeginImageContext(CGSizeMake(self.view.frame.size.width,self.view.frame.size.height));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if(image)
    {
        //NSData *data=UIImageJPEGRepresentation(image, 0.5);
        
        //UIImageView *imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        //imageView.image=image;
        
        //[self.view addSubview:imageView];

        return image;
    }
    
    return nil;
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = self.view.frame.size;
    
    if (NULL != &UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (IBAction)showViewOperation:(id)sender
{
    if(_aryProjectData.count>=1 || _dicFootStep.count>=1 || _dicWeight.count>=1)
    {
        NSString *strJson=[_jsonModule jsonGShareDataWithWeight:_aryProjectData step:_dicFootStep fat:_dicWeight];
        
        if(strJson)
        {
            [self doRequestWithURL:[NSURL URLWithString:@"http://yc-scales.im-doing.com/measure/shareOpt"] andJson:strJson];
            [SVProgressHUD show];
        }
    }
}

- (IBAction)clickDate:(id)sender {
    
    UIButton *btn=(UIButton *)sender;
    NSInteger itag=btn.tag;
    _iDateTag=itag;
    [self resetDateColor];
    switch (itag) {
        case 0:
            self.lblWeekDay1.textColor=UIColorFromRGB(0x00af00);
            self.lblDay1.textColor=UIColorFromRGB(0x00af00);
            break;
        case 1:
            self.lblWeekDay2.textColor=UIColorFromRGB(0x00af00);
            self.lblDay2.textColor=UIColorFromRGB(0x00af00);
            break;
        case 2:
            self.lblWeekDay3.textColor=UIColorFromRGB(0x00af00);
            self.lblDay3.textColor=UIColorFromRGB(0x00af00);
            break;
        case 3:
            self.lblWeekDay4.textColor=UIColorFromRGB(0x00af00);
            self.lblDay4.textColor=UIColorFromRGB(0x00af00);
            break;
        case 4:
            self.lblWeekDay5.textColor=UIColorFromRGB(0x00af00);
            self.lblDay5.textColor=UIColorFromRGB(0x00af00);
            break;
        case 5:
            self.lblWeekDay6.textColor=UIColorFromRGB(0x00af00);
            self.lblDay6.textColor=UIColorFromRGB(0x00af00);
            break;
        case 6:
            self.lblWeekDay7.textColor=UIColorFromRGB(0x00af00);
            self.lblDay7.textColor=UIColorFromRGB(0x00af00);
            break;
        default:
            break;
    }
    
    if(_aryDate && _aryDate.count>=7)
    {
        _selectDate=[_aryDate objectAtIndex:itag];
    }
    
    [self refreshMeasureData];
    
    if(btn)
    {
        [UIView animateWithDuration:0.3f animations:^{
            self.imageDateLine.frame=CGRectMake(btn.frame.origin.x, self.imageDateLine.frame.origin.y, btn.frame.size.width, self.imageDateLine.frame.size.height);
        }];
        
    }
    
    if(_dicFootStep.count>=1 ||
       _dicWeight.count>=1 ||
       _aryProjectData.count>=1)
    {
        self.btnShare.hidden=YES;
    }
    else
    {
        self.btnShare.hidden=YES;
    }
    [self.tableview reloadData];
}


-(void)refreshMeasureData
{
    double dHeight=[_delegate.myUserInfo.userHeight doubleValue];
    if(dHeight<=0)
    {
        dHeight=170.0;
    }
    
    
    int iWeight=arc4random()%20+50;
    int iWeightPoint=arc4random()%10;
    NSString *weight=[NSString stringWithFormat:@"%d.%d",iWeight,iWeightPoint];
    double dBmi=[weight doubleValue]/(dHeight*dHeight/10000);
    NSString *bmi=[NSString stringWithFormat:@"%.1f",dBmi];
    
    
    NSString *startDate=[NSString stringWithFormat:@"%@ 00:00:00",[_selectDate substringToIndex:10]];
    NSString *endDate=[NSString stringWithFormat:@"%@ 23:59:59",[_selectDate substringToIndex:10]];
    
    NSArray *aryWeight=[_db selectMeasureWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectWeight andStartDate:startDate endDate:endDate];
    if(aryWeight && aryWeight.count>=1) {
        NSArray *aryData=[aryWeight objectAtIndex:0];
        NSDictionary *dic=[aryData objectAtIndex:3];
        NSString *weight=[dic valueForKey:ProjectWeight];
        NSString *bmi=[dic valueForKey:ProjectBMI];
        
        [_dicWeight removeAllObjects];
        [_dicWeight setObject:weight forKey:@"weight"];
        [_dicWeight setObject:bmi forKey:@"bmi"];
    }
    else {
        [_dicWeight removeAllObjects];
        //[_dicWeight setObject:@"0.0" forKey:@"weight"];
        //[_dicWeight setObject:@"0.0" forKey:@"bmi"];
    }
    

    NSArray *aryFat=[_db selectMeasureWithCTime:[AppDelegate shareUserInfo].account_ctime andProject:ProjectFat andStartDate:startDate endDate:endDate];
    if(aryFat && aryFat.count>=1) {
        NSArray *aryData=[aryWeight objectAtIndex:0];
        NSDictionary *dic=[aryData objectAtIndex:3];
        NSString *kgWeight=[dic valueForKey:ProjectWeight];
        NSString *bmi=[dic valueForKey:ProjectBMI];
        NSString *fat=[dic valueForKey:ProjectFat];
        NSString *muscle=[dic valueForKey:ProjectMuscle];
        NSString *water=[dic valueForKey:ProjectWater];
        NSString *bone=[dic valueForKey:ProjectBone];
        NSString *basic=[dic valueForKey:ProjectBasic];
        NSString *visceralfat=[dic valueForKey:ProjectVisceralFat];
        NSString *bodyage=[dic valueForKey:ProjectBodyAge];
        //NSString *height=[dic valueForKey:ProjectHeight];
        
        NSDictionary *dicRange=[PublicModule getFatRangeWithAge:[AppDelegate shareUserInfo].userAge andSex:[AppDelegate shareUserInfo].sex];
        NSArray *aryRangeFat=[dicRange valueForKey:ProjectFat];
        NSArray *aryRangeWater=[dicRange valueForKey:ProjectWater];
        NSArray *aryRangeMuscle=[dicRange valueForKey:ProjectMuscle];
        NSArray *aryRangeBone=[dicRange valueForKey:ProjectBone];
        NSArray *aryRangeBasic=[dicRange valueForKey:ProjectBasic];
        NSArray *aryRangeVisceralfat=[dicRange valueForKey:ProjectVisceralFat];
        NSArray *aryRangeBmi=[dicRange valueForKey:ProjectBMI];
        aryRangeBone = [PublicModule getBoneRangeWithWeight:kgWeight andSex:[AppDelegate shareUserInfo].sex];
        
        
        //步行 体重 BMI  脂肪 水分 肌肉 骨量 基础代谢 内脏脂肪 身体年龄
        
        NSMutableDictionary *dicTempBMI=[[NSMutableDictionary alloc] init];
        [dicTempBMI setValue:@"0" forKey:@"type"];
        [dicTempBMI setObject:ProjectBMIName forKey:@"name"];
        [dicTempBMI setObject:aryRangeBmi forKey:@"range"];
        [dicTempBMI setObject:bmi forKey:@"value"];
        
        NSMutableDictionary *dicTempMuscle=[[NSMutableDictionary alloc] init];
        [dicTempMuscle setValue:@"1" forKey:@"type"];
        [dicTempMuscle setObject:ProjectMuscleName forKey:@"name"];
        [dicTempMuscle setObject:aryRangeMuscle forKey:@"range"];
        [dicTempMuscle setObject:muscle forKey:@"value"];
        
        NSMutableDictionary *dicTempFat=[[NSMutableDictionary alloc] init];
        [dicTempFat setValue:@"1" forKey:@"type"];
        [dicTempFat setObject:ProjectFatName forKey:@"name"];
        [dicTempFat setObject:aryRangeFat forKey:@"range"];
        [dicTempFat setObject:fat forKey:@"value"];
        
        NSMutableDictionary *dicTempWater=[[NSMutableDictionary alloc] init];
        [dicTempWater setValue:@"2" forKey:@"type"];
        [dicTempWater setObject:ProjectWaterName forKey:@"name"];
        [dicTempWater setObject:aryRangeWater forKey:@"range"];
        [dicTempWater setObject:water forKey:@"value"];
        
        
        NSMutableDictionary *dicTempBone=[[NSMutableDictionary alloc] init];
        [dicTempBone setValue:@"0" forKey:@"type"];
        [dicTempBone setObject:ProjectBoneName forKey:@"name"];
        [dicTempBone setObject:aryRangeBone forKey:@"range"];
        [dicTempBone setObject:bone forKey:@"value"];
        
        NSMutableDictionary *dicTempBasic=[[NSMutableDictionary alloc] init];
        [dicTempBasic setValue:@"0" forKey:@"type"];
        [dicTempBasic setObject:ProjectBasicName forKey:@"name"];
        [dicTempBasic setObject:aryRangeBasic forKey:@"range"];
        [dicTempBasic setObject:basic forKey:@"value"];
        
        NSMutableDictionary *dicTempVisceral=[[NSMutableDictionary alloc] init];
        [dicTempVisceral setValue:@"2" forKey:@"type"];
        [dicTempVisceral setObject:ProjectVisceralFatName forKey:@"name"];
        [dicTempVisceral setObject:aryRangeVisceralfat forKey:@"range"];
        [dicTempVisceral setObject:visceralfat forKey:@"value"];
        
        NSMutableDictionary *dicTempBodyage=[[NSMutableDictionary alloc] init];
        [dicTempBodyage setValue:@"2" forKey:@"type"];
        [dicTempBodyage setObject:ProjectBodyageName forKey:@"name"];
        [dicTempBodyage setObject:bodyage forKey:@"value"];
        
        //步行 体重 BMI  脂肪 水分 肌肉 骨量 基础代谢 内脏脂肪 身体年龄
        
        [_aryProjectData removeAllObjects];
        _aryProjectData=[[NSMutableArray alloc] initWithObjects:dicTempBMI,dicTempFat,dicTempWater,dicTempMuscle,dicTempBone,dicTempBasic,dicTempVisceral,dicTempBodyage, nil];
        if ([fat floatValue] <= 0.0 && _dicWeight.count > 1) {
            [_aryProjectData removeAllObjects];
        }
    }
    else {
        NSString *bmi=@"0";
        NSString *fat=@"0";
        NSString *muscle=@"0";
        NSString *water=@"0";
        NSString *bone=@"0";
        NSString *basic=@"0";
        NSString *visceralfat=@"0";
        NSString *bodyage=@"0";
        //NSString *height=[dic valueForKey:ProjectHeight];
        
        NSDictionary *dicRange=[PublicModule getFatRangeWithAge:[AppDelegate shareUserInfo].userAge andSex:[AppDelegate shareUserInfo].sex];
        NSArray *aryRangeFat=[dicRange valueForKey:ProjectFat];
        NSArray *aryRangeWater=[dicRange valueForKey:ProjectWater];
        NSArray *aryRangeMuscle=[dicRange valueForKey:ProjectMuscle];
        NSArray *aryRangeBone=[dicRange valueForKey:ProjectBone];
        NSArray *aryRangeBasic=[dicRange valueForKey:ProjectBasic];
        NSArray *aryRangeVisceralfat=[dicRange valueForKey:ProjectVisceralFat];
        NSArray *aryRangeBmi=[dicRange valueForKey:ProjectBMI];
        
        //步行 体重 BMI  脂肪 水分 肌肉 骨量 基础代谢 内脏脂肪 身体年龄
        
        NSMutableDictionary *dicTempBMI=[[NSMutableDictionary alloc] init];
        [dicTempBMI setValue:@"0" forKey:@"type"];
        [dicTempBMI setObject:ProjectBMIName forKey:@"name"];
        [dicTempBMI setObject:aryRangeBmi forKey:@"range"];
        [dicTempBMI setObject:bmi forKey:@"value"];
        
        NSMutableDictionary *dicTempMuscle=[[NSMutableDictionary alloc] init];
        [dicTempMuscle setValue:@"1" forKey:@"type"];
        [dicTempMuscle setObject:ProjectMuscleName forKey:@"name"];
        [dicTempMuscle setObject:aryRangeMuscle forKey:@"range"];
        [dicTempMuscle setObject:muscle forKey:@"value"];
        
        NSMutableDictionary *dicTempFat=[[NSMutableDictionary alloc] init];
        [dicTempFat setValue:@"1" forKey:@"type"];
        [dicTempFat setObject:ProjectFatName forKey:@"name"];
        [dicTempFat setObject:aryRangeFat forKey:@"range"];
        [dicTempFat setObject:fat forKey:@"value"];
        
        NSMutableDictionary *dicTempWater=[[NSMutableDictionary alloc] init];
        [dicTempWater setValue:@"2" forKey:@"type"];
        [dicTempWater setObject:ProjectWaterName forKey:@"name"];
        [dicTempWater setObject:aryRangeWater forKey:@"range"];
        [dicTempWater setObject:water forKey:@"value"];
        
        
        NSMutableDictionary *dicTempBone=[[NSMutableDictionary alloc] init];
        [dicTempBone setValue:@"0" forKey:@"type"];
        [dicTempBone setObject:ProjectBoneName forKey:@"name"];
        [dicTempBone setObject:aryRangeBone forKey:@"range"];
        [dicTempBone setObject:bone forKey:@"value"];
        
        NSMutableDictionary *dicTempBasic=[[NSMutableDictionary alloc] init];
        [dicTempBasic setValue:@"0" forKey:@"type"];
        [dicTempBasic setObject:ProjectBasicName forKey:@"name"];
        [dicTempBasic setObject:aryRangeBasic forKey:@"range"];
        [dicTempBasic setObject:basic forKey:@"value"];
        
        NSMutableDictionary *dicTempVisceral=[[NSMutableDictionary alloc] init];
        [dicTempVisceral setValue:@"2" forKey:@"type"];
        [dicTempVisceral setObject:ProjectVisceralFatName forKey:@"name"];
        [dicTempVisceral setObject:aryRangeVisceralfat forKey:@"range"];
        [dicTempVisceral setObject:visceralfat forKey:@"value"];
        
        NSMutableDictionary *dicTempBodyage=[[NSMutableDictionary alloc] init];
        [dicTempBodyage setValue:@"2" forKey:@"type"];
        [dicTempBodyage setObject:ProjectBodyageName forKey:@"name"];
        [dicTempBodyage setObject:bodyage forKey:@"value"];
        
        //步行 体重 BMI  脂肪 水分 肌肉 骨量 基础代谢 内脏脂肪 身体年龄
        
        [_aryProjectData removeAllObjects];
        _aryProjectData=[[NSMutableArray alloc] initWithObjects:dicTempBMI,dicTempFat,dicTempWater,dicTempMuscle,dicTempBone,dicTempBasic,dicTempVisceral,dicTempBodyage, nil];
        if (_dicWeight.count > 1) {
            [_aryProjectData removeAllObjects];
        }
        
    }
    
    
    int iFoot=arc4random()%10000+1;
    NSString *strFoot=[NSString stringWithFormat:@"%d",iFoot];
    
    int iKM=arc4random()%11;
    int iTime=arc4random()%61;
    int iKcal=arc4random()%1000+1000;
    
    NSString *strKM=[NSString stringWithFormat:@"%d",iKM];
    NSString *strTime=[NSString stringWithFormat:@"%d",iTime];
    NSString *strKcal=[NSString stringWithFormat:@"%d",iKcal];
    
    [_dicFootStep setObject:@"0" forKey:@"step"];
    [_dicFootStep setObject:[AppDelegate shareUserInfo].targetStep forKey:@"allstep"];
    [_dicFootStep setObject:@"0" forKey:@"km"];
    [_dicFootStep setObject:@"0" forKey:@"time"];
    [_dicFootStep setObject:@"0" forKey:@"kcal"];
    
    //NSString *startDate=[NSString stringWithFormat:@"%@ 00:00:00",[_selectDate substringToIndex:10]];
    //NSString *endDate=[NSString stringWithFormat:@"%@ 23:59:59",[_selectDate substringToIndex:10]];
    
    NSArray *aryStep=[_db selectStepDateWithCTime:[AppDelegate shareUserInfo].account_ctime withStartDate:startDate andEndDate:endDate];
    
    if(aryStep && aryStep.count>=1)
    {
        NSArray *aryData=[aryStep objectAtIndex:0];
        NSString *strStep=[aryData objectAtIndex:3];
        int iAllStep=[strStep intValue];
        if(strStep)
        {
            CGFloat fkm=iAllStep*0.7/1000;
            CGFloat kcal=iAllStep*0.04;
            int iMinute=iAllStep/60;
            NSString *strKM=[NSString stringWithFormat:@"%.1f",fkm];
            NSString *strTime=[NSString stringWithFormat:@"%d",iMinute];
            NSString *strKcal=[NSString stringWithFormat:@"%.0f",kcal];
            
            [_dicFootStep removeAllObjects];
            [_dicFootStep setObject:strStep forKey:@"step"];
            [_dicFootStep setObject:[AppDelegate shareUserInfo].targetStep forKey:@"allstep"];
            [_dicFootStep setObject:strKM forKey:@"km"];
            [_dicFootStep setObject:strTime forKey:@"time"];
            [_dicFootStep setObject:strKcal forKey:@"kcal"];
        }
    }
    else
    {
        [_dicFootStep removeAllObjects];
    }
}


-(void)resetDateColor
{
    self.lblWeekDay1.textColor=[UIColor blackColor];
    self.lblWeekDay2.textColor=[UIColor blackColor];
    self.lblWeekDay3.textColor=[UIColor blackColor];
    self.lblWeekDay4.textColor=[UIColor blackColor];
    self.lblWeekDay5.textColor=[UIColor blackColor];
    self.lblWeekDay6.textColor=[UIColor blackColor];
    self.lblWeekDay7.textColor=[UIColor blackColor];
    
    self.lblDay1.textColor=[UIColor blackColor];
    self.lblDay2.textColor=[UIColor blackColor];
    self.lblDay3.textColor=[UIColor blackColor];
    self.lblDay4.textColor=[UIColor blackColor];
    self.lblDay5.textColor=[UIColor blackColor];
    self.lblDay6.textColor=[UIColor blackColor];
    self.lblDay7.textColor=[UIColor blackColor];
    
    
}
@end

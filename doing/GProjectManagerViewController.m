#import "GProjectManagerViewController.h"

@interface GProjectManagerViewController ()

@end

@implementation GProjectManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}


- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
    
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    _delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    //实例化数据库
    _db = [[DbModel alloc] init];
    
    buttonInterval = 10;
    myBtnRow = 0;
    
    //设置project按钮范围
    buttonOffset = [self projectButtonOffset];
    
    //drogView = [[UIView alloc] initWithFrame:buttonOffset];
    drogView = [[UIView alloc] initWithFrame:[self projectButtonLocation]];
    
    unSetArr = [[NSMutableArray alloc] init];
    buttons = [[NSMutableArray alloc] init];
    allButtons = [[NSMutableArray alloc] init];
    allBtnArr = [[self allProjectInit] mutableCopy];
    
    
    self.lblTopTitle.text=NSLocalizedString(@"title_project", nil);

    //project按钮内容up
    NSArray *projectArr = [self getMPorject:[AppDelegate shareUserInfo].account_ctime];
    btnArr = [projectArr mutableCopy];
    
    
    //获取project按钮数组
    [self buttonArrayInit:projectArr allBtn:allBtnArr];
    
    
    //设置可拖动范围
    drogScope = [self buttonDrogScope];
    
    //实例化长按按钮手势
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startDrag:)];
    
    dragGr = lpgr;
    [lpgr setEnabled:YES];
    [lpgr setDelegate:self];
    
    [lpgr setMinimumPressDuration:0.3];
    [self.view addGestureRecognizer:lpgr];
    
    activeCellIndex = -1;
    isBtn = NO;  //点击对象是否为可拖动btn
    [self initView];
}


-(void)initView
{
    self.viewTop.frame=CGRectMake(0, 0, SCREEN_WIDTH, NAVBAR_HEIGHT);
    self.lblTopTitle.frame=CGRectMake(0, 20, SCREEN_WIDTH, 44);
    self.btnBack.frame=CGRectMake(0, 20, 60, 44);
    self.btnBackIcon.frame=CGRectMake(15, 35, 9, 14);
    
    self.interval_middle_label.text=NSLocalizedString(@"project_label", nil);
    self.interval_middle_label.frame=CGRectMake(self.interval_middle_label.frame.origin.x, self.interval_middle_label.frame.origin.y, SCREEN_WIDTH, self.interval_middle_label.frame.size.height);
    
    [self.interval_middle_label sizeToFit];
    
    CGFloat fWidth=(SCREEN_WIDTH-self.interval_middle_label.frame.size.width-4)/2;
    self.interval_left_line.frame=CGRectMake(0, self.interval_left_line.frame.origin.y, fWidth, self.interval_left_line.frame.size.height);
    
    self.interval_middle_label.frame=CGRectMake(self.interval_left_line.frame.origin.x+self.interval_left_line.frame.size.width+2, self.interval_middle_label.frame.origin.y, self.interval_middle_label.frame.size.width, self.interval_middle_label.frame.size.height);
    
    self.interval_right_line.frame=CGRectMake(self.interval_middle_label.frame.origin.x+self.interval_middle_label.frame.size.width+2, self.interval_right_line.frame.origin.y, fWidth, self.interval_right_line.frame.size.height);
    
    //self.interval_middle_label.frame=CGRectMake((SCREEN_WIDTH-138-6)/2, self.interval_middle_label.frame.origin.y, self.interval_middle_label.frame.size.width, self.interval_middle_label.frame.size.height);
    //self.interval_left_line.frame=CGRectMake(0, self.interval_left_line.frame.origin.y, (SCREEN_WIDTH-138)/2, self.interval_left_line.frame.size.height);
    
    //self.interval_right_line.frame=CGRectMake(self.interval_middle_label.frame.origin.x+self.interval_middle_label.frame.size.width+3, self.interval_right_line.frame.origin.y, (SCREEN_WIDTH-138)/2, self.interval_right_line.frame.size.height);
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(self.GoBack)
    {
        self.GoBack();
    }
}

/*
 *  所有项目数组
 */
- (NSArray *)getMPorject:(NSString *)ctime
{
    NSArray *result = [[NSArray alloc] init];
    
    //获取用户设置项目数组
    NSArray *myProjectArr = [_db getCustomProject:ctime];
    
    if ([myProjectArr count] > 0)
    {
        NSString *isset = [myProjectArr objectAtIndex:1];
        NSString *unset = [myProjectArr objectAtIndex:2];
        
        //拆分字符串
        NSArray *array = [isset componentsSeparatedByString:@","];
        for (int i = 0; i < [array count]; i++)
        {
            NSLog(@"设置的项目:%@", [array objectAtIndex:i]);
        }
        
        result = array;
    }
    else
    {
        //用户未设置项目
        //添加新记录
        NSString *isset = @"";
        NSString *unset = @"";
        NSString *diary_open = @"1";
        //默认添加设置项目
        for (int i=0; i < [allBtnArr count]; i++)
        {
            //拼接字符串
            if (i == 0)
            {
                isset = [allBtnArr objectAtIndex:i];
            }
            else
            {
                isset = [isset stringByAppendingFormat:@",%@", [allBtnArr objectAtIndex:i]];
            }
        }
        
        
        NSLog(@"设置的项目:%@", isset);
        
        //保存到数据库
        NSArray *arrData = [[NSArray alloc] initWithObjects:[AppDelegate shareUserInfo].account_ctime,isset,unset,diary_open, nil];
        [_db updateCustomProject:arrData];
        
        result = allBtnArr;
        
    }
    
    return result;
    
}

-(NSString *)getPorjectName:(NSString *)name
{
    /*
     #define ProjectBodyageName  @"身体年龄"
     #define ProjectHeightName   @"身高"
     #define ProjectWeightName @"体重"
     #define ProjectFatName  @"脂肪"
     #define ProjectBasicName @"基础代谢"
     #define ProjectWaterName @"水分"
     #define ProjectBMIName  @"BMI"
     #define ProjectMuscleName @"肌肉"
     #define ProjectBoneName  @"骨量"
     #define ProjectVisceralFatName @"内脏脂肪"
     #define ProjectStepCountName @"步行"
     #define ProjectStepJourneyName   @"步行路程"
     #define ProjectStepCalorieName   @"步行耗能"
     #define ProjectStepTimeName  @"步行时间"
     */
    
    if([name isEqualToString:ProjectHeightName] ||
       [name isEqualToString:ProjectHeightEnglishName] ||
       [name isEqualToString:ProjectHeightGermanName] ||
       [name isEqualToString:ProjectHeightDutchName])
    {
        return ProjectHeightName;
    }
    else if([name isEqualToString:ProjectBodyageName] ||
            [name isEqualToString:ProjectBodyageEnglishName] ||
            [name isEqualToString:ProjectBodyageGermanName] ||
            [name isEqualToString:ProjectBodyageDutchName])
    {
        return ProjectBodyageName;
    }
    else if([name isEqualToString:ProjectWeightName] ||
            [name isEqualToString:ProjectWeightEnglishName] ||
            [name isEqualToString:ProjectWeightGermanName] ||
            [name isEqualToString:ProjectWeightDutchName])
    {
        return ProjectWeightName;
    }
    else if([name isEqualToString:ProjectFatName] ||
            [name isEqualToString:ProjectFatEnglishName] ||
            [name isEqualToString:ProjectFatGermanName] ||
            [name isEqualToString:ProjectFatDutchName])
    {
        return ProjectFatName;
    }
    else if([name isEqualToString:ProjectBasicName] ||
            [name isEqualToString:ProjectBasicEnglishName] ||
            [name isEqualToString:ProjectBasicGermanName] ||
            [name isEqualToString:ProjectBasicDutchName])
    {
        return ProjectBasicName;
    }
    else if([name isEqualToString:ProjectWaterName] ||
            [name isEqualToString:ProjectWaterEnglishName] ||
            [name isEqualToString:ProjectWaterGermanName] ||
            [name isEqualToString:ProjectWaterDutchName])
    {
        return ProjectWaterName;
    }
    else if([name isEqualToString:ProjectBMIName] ||
            [name isEqualToString:ProjectBMIEnglishName] ||
            [name isEqualToString:ProjectBMIGermanName] ||
            [name isEqualToString:ProjectBMIDutchName])
    {
        return ProjectBMIName;
    }
    else if([name isEqualToString:ProjectMuscleName] ||
            [name isEqualToString:ProjectMuscleEnglishName] ||
            [name isEqualToString:ProjectMuscleGermanName] ||
            [name isEqualToString:ProjectMuscleDutchName])
    {
        return ProjectMuscleName;
    }
    else if([name isEqualToString:ProjectBoneName] ||
            [name isEqualToString:ProjectBoneEnglishName] ||
            [name isEqualToString:ProjectBoneGermanName] ||
            [name isEqualToString:ProjectBoneDutchName])
    {
        return ProjectBoneName;
    }
    else if([name isEqualToString:ProjectVisceralFatName] ||
            [name isEqualToString:ProjectVisceralFatEnglishName] ||
            [name isEqualToString:ProjectVisceralFatGermanName] ||
            [name isEqualToString:ProjectVisceralFatDutchName])
    {
        return ProjectVisceralFatName;
    }
    else if([name isEqualToString:ProjectStepCountName] ||
            [name isEqualToString:ProjectStepCountEnglishName] ||
            [name isEqualToString:ProjectStepCountGermanName] ||
            [name isEqualToString:ProjectStepCountDutchName])
    {
        return ProjectStepCountName;
    }
    else if([name isEqualToString:ProjectStepCalorieName] ||
            [name isEqualToString:ProjectStepCalorieEnglishName] ||
            [name isEqualToString:ProjectStepCalorieGermanName] ||
            [name isEqualToString:ProjectStepCalorieDutchName])
    {
        return ProjectStepCalorieName;
    }
    else if([name isEqualToString:ProjectStepJourneyName] ||
            [name isEqualToString:ProjectStepJourneyEnglishName] ||
            [name isEqualToString:ProjectStepJourneyGermanName] ||
            [name isEqualToString:ProjectStepJourneyDutchName])
    {
        return ProjectStepJourneyName;
    }
    else if([name isEqualToString:ProjectStepTimeName] ||
            [name isEqualToString:ProjectStepTimeEnglishName] ||
            [name isEqualToString:ProjectStepTimeGermanName] ||
            [name isEqualToString:ProjectStepTimeDutchName])
    {
        return ProjectStepTimeName;
    }
    else
    {
        return @"";
    }
}

/*
 *  修改用户设置项目
 */
-(void)updateMyProject:(NSArray *)arrData unset:(NSArray *)unSetData
{
    //用户未设置项目
    //添加新记录
    NSString *isset = @"";
    NSString *unset = @"";
    NSString *diary_open = switchValue;
    
    //已选择项目
    for (int i=0; i < [arrData count]; i++)
    {
        //拼接字符串
        if (i == 0)
        {
            isset = [arrData objectAtIndex:i];
        }
        else
        {
            isset = [isset stringByAppendingFormat:@",%@", [arrData objectAtIndex:i]];
        }
    }
    //未选择项目
    for (int n=0; n < [unSetData count]; n++)
    {
        //拼接字符串
        if (n == 0) {
            unset = [unSetData objectAtIndex:n];
        }
        else
        {
            unset = [unset stringByAppendingFormat:@",%@", [unSetData objectAtIndex:n]];
        }
    }
    
    
    NSLog(@"string:%@", unset);
    NSLog(@"ctime:%@",[AppDelegate shareUserInfo].account_ctime);
    //保存到数据库

    NSArray *array = [[NSArray alloc] initWithObjects:[AppDelegate shareUserInfo].account_ctime,isset,unset,diary_open, nil];
    
    bool isUPdate = [_db updateCustomProject:array];
}


/*
 *  所有项目数组
 */
- (NSArray *)allProjectInit
{
    /*
    return [[NSArray alloc] initWithObjects:ProjectStepCountName,
            ProjectStepTimeName,
            ProjectStepCalorieName,
            ProjectStepJourneyName,
            ProjectFatName,
            ProjectWeightName,
            ProjectBMIName,
            ProjectMuscleName,
            ProjectWaterName,
            ProjectBoneName,
            ProjectBasicName,
            ProjectVisceralFatName,
            ProjectBodyageName, nil];
     */
    return [[NSArray alloc] initWithObjects:ProjectWeightName,
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
            ProjectStepCalorieName, nil];
}

/*
 *  手势是否生效
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}



/*
 *  摘要：手势控制，拖动按钮
 *
 */
- (void) startDrag:(UILongPressGestureRecognizer *) lpgr
{
    //可拖动范围
    CGPoint scPt = [lpgr locationInView:self.view];
    
    if(isBtn == NO)
    {
        //判断手势位置是否在可拖拽按钮上
        for (UIButton *button in buttons) {
            
//            NSLog(@"button.x:%f",button.frame.origin.x);
//            NSLog(@"button.y:%f",button.frame.origin.y);
//            NSLog(@"button.w:%f",button.frame.size.width);
//            NSLog(@"button.h:%f",button.frame.size.height);
            
            if(scPt.x >= button.frame.origin.x &&
               scPt.x <= (button.frame.origin.x + button.frame.size.width) &&
               scPt.y >= button.frame.origin.y &&
               scPt.y <= (button.frame.origin.y + button.frame.size.height)
               )
            {
                isBtn = YES;
                break;
            }
            else
            {
                isBtn = NO;
            }
        }
    }
    //判断触发点是否为已设置的按钮
    if (isBtn)
    {
        //判断当前点击坐标是否超出位置
        if(scPt.x >= drogScope.origin.x &&
           scPt.x <= (drogScope.origin.x + drogScope.size.width) &&
           scPt.y >= buttonSize.height/2 &&
           scPt.y <= (self.view.frame.size.height - buttonSize.height/2)
           )
        {
            
            switch (lpgr.state)
            {
                case UIGestureRecognizerStateBegan: //拖拽开始
                {
                    //project按钮列表
                    NSIndexPath *cellIndexPath = [self pointInCell:scPt];
                    int cellIndex = [self indexPathToIndex:cellIndexPath];
            
                    //触点偏移位置
                    touchOffset = [self offsetForPoint:scPt relativeToCell:cellIndexPath];
            
                    //当前拖动的project
                    activeCellIndex = cellIndex;
                    activeCell = (activeCellIndex>=0)?[buttons objectAtIndex:cellIndex]:nil;
            
                    floatingActiveCell = activeCell;
            
                    //控制当前拖动project
                    [self setState:SlidesViewItemStateActive animated:YES];
            
                }   break;
                case UIGestureRecognizerStateChanged:   //拖拽过程
                {
                    //project列表
                    NSIndexPath *cellIndexPath = [self pointInCell:CGPointMake(scPt.x - touchOffset.width + buttonSize.width/2, scPt.y - touchOffset.height + buttonSize.height/2)];
                    //当前project的index
                    int cellIndex = [self indexPathToIndex:cellIndexPath];
            
                    //设置project按钮的位置
                    [activeCell setFrame:CGRectMake(scPt.x - buttonSize.width/2, scPt.y - buttonSize.height/2, buttonSize.width, buttonSize.height)];
            
                    //移动project到project列表布局
                    [self moveCellToIndex:cellIndex];
            
                }   break;
                case UIGestureRecognizerStateEnded:
                {
                    isBtn = NO;
                    
                    //[self updateMyProject:btnArr unset:unSetArr];
                }
                case UIGestureRecognizerStateCancelled:
                {
                    isBtn = NO;
            
                    activeCellIndex = -1;
                    activeCell = nil;
            
                    //修改project布局
                    [self updateLayoutAnimated:YES];
            
                }   break;
                default:
                    isBtn = NO;
                    break;
            }
        }
        else
        {
            [self cancelMoveingBtn];
        }
    }
}

/*
 *  摘要：取消移动按钮
 *
 */
-(void)cancelMoveingBtn
{
    [self setState:SlidesViewItemStateNormal animated:YES];
    
    activeCellIndex = -1;
    activeCell = nil;
    
    //修改project布局
    [self updateLayoutAnimated:YES];
}

/*
 *  摘要：更新用户自定义菜单
 *
 */
-(void)updateMyProjectArray
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSMutableArray *allArray = [[NSMutableArray alloc] init];
    
    for(UIButton *button in buttons)
    {
        NSString *title = button.titleLabel.text;
        
        [button setTitleColor:UIColorFromRGB(0x00af00) forState:0];
        button.layer.borderColor=UIColorFromRGB(0x00af00).CGColor;
        //NSLog(@"button:%@",title);
        
        [array addObject:title];
    }
    
    for(UIButton *allButton in allButtons)
    {
        NSString *title = allButton.titleLabel.text;
        
        //NSLog(@"allButton:%@",title);
        
        [allArray addObject:title];
    }
    
    btnArr = array;
    unSetArr = allArray;
    
    [self updateMyProject:btnArr unset:unSetArr];
}



/*
 *  摘要：获取点击位置按钮tag值
 *
 */
-(NSInteger) pointInCellTag:(CGPoint)pt
{
    NSInteger btnTag = -1;
    
    for (UIButton *button in buttons) {
        
        if(pt.x >= button.frame.origin.x &&
           pt.x <= (button.frame.origin.x + button.frame.size.width) &&
           pt.y >= button.frame.origin.y &&
           pt.y <= (button.frame.origin.y + button.frame.size.height)
           )
        {
            btnTag = button.tag;
        }
    }
    return btnTag;
}

- (NSIndexPath *) pointInCell:(CGPoint)pt
{
    NSUInteger indp[] = {(NSUInteger) MIN(MAX(0, ((pt.x - offset.x )/(buttonSize.width+buttonInterval))), columnCount-1),
        (NSUInteger) MIN(MAX(0, ((pt.y - offset.y)/(buttonSize.height+buttonInterval))), rowCount-1)};
    
    return [NSIndexPath indexPathWithIndexes:indp length:2];
}

- (int) indexPathToIndex:(NSIndexPath *)indp
{
    //NSLog(@"%lu",[indp indexAtPosition:0]);
    //NSLog(@"%lu",[indp indexAtPosition:1]);
    
    NSInteger columnNum = ([indp indexAtPosition:0]>0)?[indp indexAtPosition:0]-0:0;
    NSInteger rowNum = ([indp indexAtPosition:1]>0)?[indp indexAtPosition:1]-0:0;
    
    return [buttons count]?MAX(0, MIN(columnNum + rowNum * columnCount, [buttons count]-1)):-1;
}

- (CGSize) offsetForPoint:(CGPoint)pt relativeToCell:(NSIndexPath*)cell
{
    return CGSizeMake(pt.x - offset.x - (buttonSize.width+buttonInterval)*[cell indexAtPosition:0], pt.y - offset.y - (buttonSize.height)*[cell indexAtPosition:1]);
}

/*
 *  摘要：移动project去到的位置
 *
 */
- (void) moveCellToIndex:(int)cellIndex
{
    if(activeCellIndex == -1)
    {
        [self cancelMoveingBtn];
    }
    else
    {
        //不是原来的位置
        if (activeCellIndex != cellIndex)
        {
            NSLog(@"reorder: %d > %d", activeCellIndex, cellIndex);
        
            //project列表删除当前操作project
            [buttons removeObject:activeCell];
        
            //把当前project插入当前位置
            [buttons insertObject:activeCell atIndex:cellIndex];
        
            //修改插入的位置为操作的project
            activeCellIndex = cellIndex;
        
            //修改project布局
            [self updateLayoutAnimated:YES];
        }
    }
}


/*
 *  摘要：实例化project按钮
 *
 */
- (void)buttonArrayInit:(NSArray *)myBtn allBtn:(NSArray *)allBtn
{
    //NSMutableArray *buttonArray = [[NSMutableArray alloc] initWithArray:myBtn];
    NSMutableArray *allBtnArray = [[NSMutableArray alloc] initWithArray:allBtn];
    
    NSUInteger myBtnCount = [myBtn count];
    if (myBtnCount >0 && ![[myBtn objectAtIndex:0] isEqualToString:@""])
    {
        //自定义项目
        for (int i = 0; i < myBtnCount; i++)
        {
            UIButton *button = [self projectBtnInit:myBtn num:i];
            
            NSString *myBtnObj = button.titleLabel.text;
            
            myBtnObj=[self getPorjectName:myBtnObj];
            
            
            [button addTarget:self action:@selector(removeMyProject:) forControlEvents:UIControlEventTouchUpInside];
            [buttons addObject:button];
            
            
            [allBtnArray removeObject:myBtnObj];
            
            //添加按钮
            [self.view addSubview:button];
        }
        //未设置项目
        for (int n = 0; n < [allBtnArray count]; n++)
        {
            
            UIButton *unsetbtn = [self projectBtnInit:allBtnArray num:n];
            
            [unsetbtn addTarget:self action:@selector(addMyProject:) forControlEvents:UIControlEventTouchUpInside];
            
            [allButtons addObject:unsetbtn];
            
            //添加按钮
            [self.view addSubview:unsetbtn];
        }
        
    }
    else
    {
        for (int i = 0; i < [allBtnArray count]; i++)
        {
            UIButton *button = [self projectBtnInit:allBtnArray num:i];
            
            [button addTarget:self action:@selector(addMyProject:) forControlEvents:UIControlEventTouchUpInside];
            
            [allButtons addObject:button];
            //添加按钮
            [self.view addSubview:button];
            
        }
    }
}


-(UIButton *)projectBtnInit:(NSArray *)btnArr num:(int)i
{
    //设置project按钮大小
    CGSize btnSize = [self projectButtonSize];
    buttonSize = btnSize;
    //按钮字体颜色
    UIColor *color = UIColorFromRGB(0x6a6a6a);
    //按钮背景框
    //UIImage *image = [UIImage imageNamed:@"button_project.png"];
    
    //初始化project按钮
    UIButton *button = [[UIButton alloc] init];
    //设置project名字
    NSString *titleTemp = [btnArr objectAtIndex:i];
    titleTemp=NSLocalizedString(titleTemp, nil);
    [button setTitle:titleTemp forState:0];
    //按钮字体大小
    if (titleTemp.length >3) {
        button.titleLabel.font = [UIFont systemFontOfSize: 11.0];
    }
    else
    {
        button.titleLabel.font = [UIFont systemFontOfSize: 14.0];
    }
    
    //按钮背景图
    //[button setBackgroundImage:image forState:0];
    //按钮字体颜色
    [button setTitleColor:color forState:0];
    button.layer.borderColor=color.CGColor;
    button.layer.borderWidth=1.0f;
    button.layer.masksToBounds=YES;
    button.layer.cornerRadius=3.0f;
    return button;
}


//添加到我的project
- (void)addMyProject:(id) sender
{
    [buttons addObject:sender];
    [allButtons removeObject:sender];
    
    [sender removeTarget:self action:@selector(addMyProject:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(removeMyProject:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateLayoutAnimated:YES];
    
    [self updateMyProject:btnArr unset:unSetArr];
}


//添加到我的project
- (void)removeMyProject:(id) sender
{
    [allButtons addObject:sender];
    [buttons removeObject:sender];
    
    [sender removeTarget:self action:@selector(removeMyProject:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(addMyProject:) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateLayoutAnimated:YES];
    
    [self updateMyProject:btnArr unset:unSetArr];
}



- (void) setFrame:(CGRect)frame
{
    [self updateLayout];
}


//修改project布局
- (void) updateLayout
{
    [self updateLayoutAnimated:NO];
}


/*
 *  修改project布局动画
 *
 */
- (void) updateLayoutAnimated:(BOOL)animated
{
    if (!buttons)
        return;
    if (buttonSize.width > buttonOffset.size.width)
        return;
    
    //NSLog(@"buttonOffset width:%f",buttonOffset.size.width);
    //NSLog(@"buttonOffset height:%f",buttonOffset.size.height);
    
    //offset = CGPointMake(fmod(self.view.frame.size.width, buttonSize.width)/2, fmod(self.view.frame.size.width, buttonSize.width)/2);
    //设置可动范围
    //offset = CGPointMake(fmod(buttonOffset.size.width, buttonSize.width)/2, fmod(buttonOffset.size.width, buttonSize.width)/2);
    offset = CGPointMake(buttonOffset.origin.x, buttonOffset.origin.y);
    
    
    //NSLog(@"offset.x:%f",offset.x);
    //NSLog(@"offset.y:%f",offset.y);
    
    columnCount = (int)floor(buttonOffset.size.width / (buttonSize.width + buttonInterval));
    rowCount = MAX((int)ceil((float)[buttons count]/columnCount), (int)ceil(buttonOffset.size.height / (buttonSize.height+buttonInterval)));
    
    //NSLog(@"columnCount:%d",columnCount);
    //NSLog(@"rowCount:%d",rowCount);
    
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    
    
//    [scroller setFrame:CGRectMake(0, 0, buttonOffset.size.width, buttonOffset.size.height)];
//    [scroller setContentSize:CGSizeMake(buttonOffset.size.width,
//                                        (CGFloat)(ceil([buttons count] / (float)columnCount) * buttonSize.height) + offset.y*2)];
    
    
    [self updateCells];
    
    if (animated)
    {
        [UIView commitAnimations];
    }
}


/*
 *  修改按钮位置，分隔线位置
 *
 */
- (void) updateCells
{
    //排列用户设置的project
    int col = 0;
    int row = 0;
    
    int count = 0;
    //NSInteger sum = [buttons count];
    
    for (UIButton *button in buttons)
    {
        if (button != activeCell)
        {
            [button setFrame:CGRectMake(offset.x + buttonSize.width * col + buttonInterval * col, offset.y + (buttonSize.height+buttonInterval)* row, buttonSize.width, buttonSize.height)];
            //[scroller bringSubviewToFront:button];
        }
        
        if(myBtnRow > 0)
        {
            //设置分割线位置
            [self.interval_left_line setFrame:CGRectMake(self.interval_left_line.frame.origin.x, 160+(buttonSize.height+buttonInterval)* row, self.interval_left_line.frame.size.width, self.interval_left_line.frame.size.height)];
            [self.interval_right_line setFrame:CGRectMake(self.interval_right_line.frame.origin.x, 160+(buttonSize.height+buttonInterval)* row, self.interval_right_line.frame.size.width, self.interval_right_line.frame.size.height)];
            [self.interval_middle_label setFrame:CGRectMake(self.interval_middle_label.frame.origin.x, 151+(buttonSize.height+buttonInterval)* row, self.interval_middle_label.frame.size.width, self.interval_middle_label.frame.size.height)];
            
            //设置分隔线高度
            intervalY = 160+(buttonSize.height+buttonInterval)* row;
        }
        
        count++;
        col++;
        if (col >= columnCount)
        {
            col = 0;
            row++;
        }
        
        myBtnRow = row;
    }
    
    //分割线离容器顶部距离
    NSInteger interval = 15+self.interval_left_line.frame.origin.y - drogView.frame.origin.y;
    
    //排列用户未设置的project
    int col_un = 0;
    int row_un = 0;
    
    int count_un = 0;
    //NSInteger sum_un = [allButtons count];
    
    for (UIButton *button_un in allButtons)
    {
        [button_un setFrame:CGRectMake(offset.x + buttonSize.width * col_un + buttonInterval * col_un, offset.y + (buttonSize.height+buttonInterval)* row_un+interval, buttonSize.width, buttonSize.height)];
        
        //2015-07-18
        [button_un setTitleColor:UIColorFromRGB(0x6a6a6a) forState:0];
        button_un.layer.borderColor=UIColorFromRGB(0x6a6a6a).CGColor;
        count_un++;
        col_un++;
        if (col_un >= columnCount)
        {
            col_un = 0;
            row_un++;
        }
    }
    
    [self updateMyProjectArray];
}


- (void) setState:(SlidesViewItemState)state_ animated:(BOOL)animated_
{
    oldState = state;
    state = state_;
    
    if (animated_)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3f];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    switch (state)
    {
        case SlidesViewItemStateNormal:
        {
//            [removeButton setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
//            [removeButton setCenter:CGPointMake(BTN_SIZE/2, BTN_SIZE/2)];
//            [image setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        }   break;
        case SlidesViewItemStateActive:
        {
//            float dx = (self.frame.size.width - BTN_SIZE) / self.frame.size.width;
//            float dy = (self.frame.size.height - BTN_SIZE) / self.frame.size.height;
//            
//            [removeButton setTransform:CGAffineTransformMakeScale(ZOOM_EFFECT, ZOOM_EFFECT)];
//            [removeButton setCenter:CGPointMake((self.frame.size.width-self.frame.size.width*dx*ZOOM_EFFECT)/2,
//                                                (self.frame.size.height-self.frame.size.height*dy*ZOOM_EFFECT)/2)];
//            [image setTransform:CGAffineTransformMakeScale(ZOOM_EFFECT, ZOOM_EFFECT)];
        }   break;
    }
    if (animated_)
    {
        [UIView setAnimationDelegate:self];
        [UIView commitAnimations];
    }
    else
    {
        oldState = state;
    }
}


/*
 *  摘要：
 */
- (void)setItemMoveDelay:(float)itemMoveDelay
{
    [dragGr setMinimumPressDuration:itemMoveDelay];
}

/*
 *  摘要：
 */
- (float)itemMoveDelay
{
    return [dragGr minimumPressDuration];
}



/*
 *  摘要：返回project按钮大小
 */
- (CGSize) projectButtonSize
{
    return CGSizeMake(0.15625*SCREEN_WIDTH, 0.075*SCREEN_WIDTH);
}


/*
 *  摘要：返回按钮可拖动范围
 */
- (CGRect) buttonDrogScope
{
    CGSize btnSize = [self projectButtonSize];
    
    //return CGRectMake(btnSize.width/2, 95+btnSize.height/2, 320, self.interval_left_line.frame.origin.y - 95 -btnSize.height);
    
    return CGRectMake(btnSize.width/2, btnSize.height/2, SCREEN_WIDTH-btnSize.width, self.view.frame.size.height -btnSize.height);
}


/*
 *  摘要：返回project按钮可部署范围
 */
- (CGRect) projectButtonOffset
{
    if(is_iPhone6)
    {
        return CGRectMake(22, 105, SCREEN_WIDTH, 200);
    }
    else if (is_iPhone6P)
    {
        return CGRectMake(25, 105, SCREEN_WIDTH, 200);
    }
    //return CGRectMake(0, 95, 320, 220);
    return CGRectMake(16, 105, SCREEN_WIDTH, 200);
}


/*
 *  摘要：返回project按钮所在区域范围
 */
- (CGRect) projectButtonLocation
{
    if(is_iPhone6)
    {
        CGRectMake(22, 95, SCREEN_WIDTH, 220);
    }
    else if (is_iPhone6P)
    {
        CGRectMake(25, 95, SCREEN_WIDTH, 220);
    }
    return CGRectMake(16, 95, SCREEN_WIDTH, 220);
}



/*
 *  摘要：屏幕翻转
 */
- (BOOL)shouldAutorotate
{
    return NO;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self updateLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

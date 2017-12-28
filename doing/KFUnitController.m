#import "KFUnitController.h"
#import "KFUnitSetupCell.h"

@interface KFUnitController ()

@end

@implementation KFUnitController

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
    

    self.lblContent.hidden=YES;
    
    self.lblTopTitle.text=NSLocalizedString(@"title_unitsetup", nil);

    self.scrollView.contentSize=CGSizeMake(SCREEN_WIDTH, self.lblContent.frame.size.height+40);
    self.lblContent.hidden=NO;
    
    self.tableView.frame=CGRectMake(0,NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT);
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - TableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 15)];
    headView.backgroundColor=[UIColor clearColor];
    
    return headView ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"KFUnitSetupCell";
    KFUnitSetupCell *cell=(KFUnitSetupCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"KFUnitSetupCell" owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    
    NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
    cell.imageHook.hidden = YES;
    if(indexPath.row == 0)
    {
        cell.titleLabel.text = @"kg";
        if ([weightUnit isEqualToString:@"kg"]) {
            cell.imageHook.hidden = NO;
        }
        
        CALayer *topLayer = [CALayer new];
        topLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, LCTLineHeight);
        topLayer.backgroundColor = CommonLineColor.CGColor;
        
        CALayer *bottomLayer = [CALayer new];
        bottomLayer.frame = CGRectMake(0, 44-0.6, SCREEN_WIDTH, LCTLineHeight);
        bottomLayer.backgroundColor = CommonLineColor.CGColor;
        
        [cell.layer addSublayer:topLayer];
        [cell.layer addSublayer:bottomLayer];
    }
    else if (indexPath.row == 1)
    {
        cell.titleLabel.text = @"lb";
        if ([weightUnit isEqualToString:@"lb"]) {
            cell.imageHook.hidden = NO;
        }
        
        CALayer *bottomLayer = [CALayer new];
        bottomLayer.frame = CGRectMake(0, 44-0.6, SCREEN_WIDTH, LCTLineHeight);
        bottomLayer.backgroundColor = CommonLineColor.CGColor;
        
        [cell.layer addSublayer:bottomLayer];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"kg" forKey:@"weight_unit"];
    } else if (indexPath.row == 1) {
        [[NSUserDefaults standardUserDefaults] setObject:@"lb" forKey:@"weight_unit"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"weight_unit" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

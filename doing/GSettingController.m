#import "GSettingController.h"
#import "GSettingCell.h"
#import "GUserAddController.h"
#import "GLoginController.h"
#import "GEditPwdController.h"
#import <HealthKit/HealthKit.h>
#import "GUserAgreementController.h"
#import "GUserPrivateController.h"
#import "KFUnitController.h"
#import "WebViewController.h"

@interface GSettingController ()<LCActionSheetDelegate>
{
    NetworkModule *_jsonModel;
    DbModel *_db;
    NSString *_selectProject;
    
    HKHealthStore *_healthStore;
    
}
@end

@implementation GSettingController

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
    
    
    [self.tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.tableview.delegate=self;
    self.tableview.dataSource=self;
    [self initView];
    self.lblTitle.text=NSLocalizedString(@"title_setting", nil);
    
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
   

    self.tableview.frame=CGRectMake(0,NAVBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVBAR_HEIGHT);

}

-(void)initVar
{
    if(_db == nil)
    {
        _db=[[DbModel alloc] init];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
       return 1;
    }
    else if (section == 1)
    {
        return 2;
    }
    else if (section == 2)
    {
        return 1;
    }
    else if (section == 3)
    {
        return 2;
    }
    else if (section == 4)
    {
        return 1;
    }
    else if (section == 5)
    {
        return 1;
    }
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    headView.backgroundColor=[UIColor clearColor];

    return headView ;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID=@"GSettingCell";
    GSettingCell *cell=(GSettingCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell)
    {
        cell=[[[NSBundle mainBundle] loadNibNamed:@"GSettingCell" owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle=UITableViewCellSelectionStyleGray;
    }

    cell.selectionStyle=UITableViewCellSelectionStyleGray;
    cell.imageLine.hidden=YES;
    
    if(indexPath.section == 0)
    {
        cell.lblTitle.textColor=UIColorFromRGB(0x00af00);
        cell.lblTitle.text=@"592594110@qq.com";
        cell.mySwitch.hidden=YES;
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.imageLine.hidden=YES;
            
        if([PublicModule checkLogin])
        {
            cell.lblTitle.text=[[NSUserDefaults standardUserDefaults] valueForKey:@"u_name"];
            cell.lblTitle.text=_delegate.userLoginName;
            cell.lblTitle.text=[AppDelegate shareUserInfo].account;
            cell.lblTitle.text=[AppDelegate shareUserInfo].account;
            cell.lblTitle.textColor=UIColorFromRGB(0x00af00);
        }
        else
        {
            cell.lblTitle.textColor=[UIColor blackColor];
            cell.lblTitle.text=NSLocalizedString(@"title_login", nil);
        }
    }
    else if (indexPath.section == 1)
    {
        cell.lblTitle.textColor=[UIColor blackColor];
            
        cell.mySwitch.hidden=YES;
        cell.imageLine.hidden=YES;
        if(indexPath.row == 0)
        {
            cell.lblTitle.text=NSLocalizedString(@"title_profile", nil);
            cell.imageLine.hidden=NO;
        }
        else if (indexPath.row == 1)
        {
            cell.lblTitle.text=NSLocalizedString(@"title_editpwd", nil);
        }
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.section == 2)
    {
        cell.lblTitle.textColor=[UIColor blackColor];
        cell.lblTitle.text=NSLocalizedString(@"title_updatehealth", nil);
        cell.mySwitch.hidden=NO;
        NSString *key=[[AppDelegate shareUserInfo].account_ctime stringByAppendingString:@"_switch"];
        NSString *strOn;
        if(key != nil)
        {
            strOn=[[NSUserDefaults standardUserDefaults] valueForKey:key];
        }
        
        if(strOn.length>=1 && [strOn isEqualToString:DTrue])
        {
            cell.mySwitch.on=YES;
        }
        else
        {
            cell.mySwitch.on=NO;
        }
        cell.SwitchChange=^(BOOL abool)
        {
            if(abool)
            {
                [self updateHealthKitDataWithKey:key];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:DFalse forKey:key];
            }
        };
        cell.accessoryType=UITableViewCellAccessoryNone;
    }
    else if (indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            cell.lblTitle.textColor=[UIColor blackColor];
            cell.lblTitle.text=NSLocalizedString(@"title_useragreement", nil);
            cell.mySwitch.hidden=YES;
            cell.imageLine.hidden=NO;
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
        else
        {
            cell.lblTitle.textColor=[UIColor blackColor];
            cell.lblTitle.text=NSLocalizedString(@"用户隐私", nil);
            cell.mySwitch.hidden=YES;
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else if (indexPath.section == 5)
    {
        cell.lblTitle.textColor=[UIColor blackColor];
        cell.lblTitle.text=NSLocalizedString(@"title_logout", nil);
        cell.mySwitch.hidden=YES;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if([PublicModule checkLogin])
        {
            cell.hidden = NO;
        }
        else
        {
            cell.hidden = YES;
        }
    }
    else if (indexPath.section == 4)
    {
        cell.lblTitle.textColor=[UIColor blackColor];
        cell.lblTitle.text=NSLocalizedString(@"title_unitsetup", nil);
        cell.mySwitch.hidden=YES;
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        cell.hidden=NO;
    }
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0)
    {
        [self gotoLogin];
    }
    else if(indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            [self gotoEditUser];
        }
        else if (indexPath.row == 1)
        {
            [self gotoEditPwd];
        }
    }
    else if (indexPath.section == 3)
    {
        if(indexPath.row == 0)
        {
            [self gotoUserAgreement];
        }
        else if (indexPath.row == 1)
        {
            [self gotoUserPrivate];
        }
        
    }
    else if (indexPath.section == 4)
    {
        [self gotoUnitSetup];
    }
    else if (indexPath.section == 5)
    {
        [self showLogoutWithText:NSLocalizedString(@"logout_info", nil)];
    }
}

- (void)gotoUnitSetup {
    KFUnitController *vc = [[KFUnitController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)gotoUserPrivate
{
    //http://yc-scales.im-doing.com/share/privacyProtection
    NSString *strURL=@"http://yc-scales.im-doing.com/share/privacyProtectionEN";
    
    NSString *value = NSLocalizedString(@"user_agreement", nil);
    if ([value isEqualToString:@"0"]) {
        strURL = @"http://yc-scales.im-doing.com/share/privacyProtection";
    }
    
    /*
    NSString * url = self.textView.text;
    if(!url.length) url = @"m.baidu.com";
    
    if (![url hasPrefix:@"http://"]) {
        url = [NSString stringWithFormat:@"http://%@",url];
    }
    */
    
    WebViewController * web = [[WebViewController alloc]init];
    web.url = strURL;
    web.title = @"";
    [self.navigationController pushViewController:web animated:YES];
    
    //GUserPrivateController *vc=[[GUserPrivateController alloc] init];
    //[self.navigationController pushViewController:vc animated:YES];
}

-(void)gotoUserAgreement
{
    GUserAgreementController *vc=[[GUserAgreementController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)updateHealthKitDataWithKey:(NSString *)key
{
    
    //[[NSUserDefaults standardUserDefaults] setObject:DTrue forKey:key];
    
    if([HKHealthStore isHealthDataAvailable])
    {
        _healthStore=[[HKHealthStore alloc] init];
        //NSSet *writeDataTypes=[self dataTypesToWrite];
        NSSet *readDataTypes=[self dataTypesToRead];
        
        [_healthStore requestAuthorizationToShareTypes:nil readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            
            if (!success)
            {
                //NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                return;
            }
            [[NSUserDefaults standardUserDefaults] setObject:DTrue forKey:key];
            
            //[_delegate updateHealthKitData];
        }];
    }
}

- (NSSet *)dataTypesToRead
{
    
    HKQuantityType *stepType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];

    return [NSSet setWithObjects:stepType, nil];
}

-(void)showLogoutWithText:(NSString *)text
{
    LCActionSheet *sheet = [[LCActionSheet alloc] initWithTitle:text
                                                   buttonTitles:@[NSLocalizedString(@"quit", nil)]
                                                 redButtonIndex:0
                                                       delegate:self];
    [sheet show];
}

-(void)actionSheet:(LCActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)buttonIndex
{
    //删除
    if(buttonIndex == 0)
    {
        /*
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"u_id"];
        [AppDelegate shareUserInfo].uid=@"";
        
        GLoginController *vc=[[GLoginController alloc] init];
        [vc setCanGoback:YES];
         */
        
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"u_id"];
        [AppDelegate shareUserInfo].uid=@"";
        
        NSString *ctime=[_db selectLocalAccountCTime];
        if(ctime.length>9)
        {
            [[NSUserDefaults standardUserDefaults] setObject:ctime forKey:@"c_time"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            //2015-11-06
            NSString *newUserCTime = [PublicModule getMyTimeInterval:[NSDate date]];
            BOOL ret=[self registerMemberWithCTime:newUserCTime];
            if(ret)
            {
                [[NSUserDefaults standardUserDefaults] setObject:newUserCTime forKey:@"c_time"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        [self.tableview reloadData];
        [_delegate setUserInfo];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        return;
    }
}



- (BOOL)registerMemberWithCTime:(NSString *)ctime
{
    NSString *uname=@"";
    NSString *upwd=@"";
    NSString *uid=@"";
    NSString *usession=@"";
    NSString *locaticon=@"";
    NSString *remoteicon=@"";

    NSString *sex=[AppDelegate shareUserInfo].sex;
    NSString *nickname=@"";
    NSString *country=@"";
    NSString *province=@"";
    NSString *city=@"";
    NSString *address=@"";
    NSString *latitude=@"";
    NSString *longitude=@"";
    NSString *utype=@"0";
    NSString *userCtime=ctime;
    NSString *doingNum=@"";
    NSString *msign=@"";
    NSString *myOwnness=@"";
    NSString *age=[AppDelegate shareUserInfo].userAge;
    NSString *height=[AppDelegate shareUserInfo].userHeight;
    NSString *hc = [AppDelegate shareUserInfo].userHC;
    NSString *wc = [AppDelegate shareUserInfo].userWC;
    
    
    NSArray *aryMemberInfo=[[NSArray alloc] initWithObjects:uname,
                            upwd,
                            uid,
                            usession,
                            locaticon,
                            remoteicon,
                            sex,
                            nickname,
                            country,
                            province,
                            city,
                            address,
                            latitude,
                            longitude,
                            utype,
                            userCtime,
                            doingNum,
                            msign,
                            myOwnness,
                            age,
                            height,
                            wc,
                            hc, nil];
    BOOL result=[_db updateLocalAccount:aryMemberInfo];
    return result;
}


-(void)gotoEditPwd
{
    NSString *uid=[[NSUserDefaults standardUserDefaults] valueForKey:@"u_id"];
    if(uid == nil || uid.length<1)
    {
        return;
    }
    
    GEditPwdController *vc=[[GEditPwdController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)gotoLogin
{
    NSString *uid=[[NSUserDefaults standardUserDefaults] valueForKey:@"u_id"];
    //NSString *uname=[[NSUserDefaults standardUserDefaults] valueForKey:@"u_name"];
    if(uid == nil || uid.length<1)
    {
        GLoginController *vc=[[GLoginController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

-(void)gotoEditUser
{
    GUserAddController *vc=[[GUserAddController alloc] init];
    vc.iEditStyle=1;
    [vc setLeftMenuEnable:YES];
    [self.navigationController pushViewController:vc animated:YES];
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
        [self showDeleteInfo:@"是否删除此记录?"];
    }
}

- (void)showDeleteInfo:(NSString *)info
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:info delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    [alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(0 == buttonIndex)
    {
        [Dialog simpleToast:@"不给删，不给删~~~"];
        self.tableview.editing=NO;
        return;
        
        NSMutableArray *arySectionTemp=nil;
        NSMutableDictionary *dicDataTemp=nil;
        if([_selectProject isEqualToString:ProjectFat])
        {
            arySectionTemp=arySectiionFat;
            dicDataTemp=dictFat;
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
        else if ([_selectProject isEqualToString:ProjectStepCount])
        {
            arySectionTemp=arySectiionStep;
            dicDataTemp=dictStep;
        }
        
        NSString *time=[arySectionTemp objectAtIndex:_selectedIndexPath.section];
        NSMutableArray *aryData=[dicDataTemp objectForKey:time];
        NSMutableArray *rowData=[aryData objectAtIndex:_selectedIndexPath.row];
        NSString *rowID=[rowData objectAtIndex:0];
        NSString *memberType=[rowData objectAtIndex:9];
        int iRowID=[rowID intValue];
        BOOL ret=[_db deleteWeightInfo:iRowID andMemberType:memberType];
        
        
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





- (IBAction)goback:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end

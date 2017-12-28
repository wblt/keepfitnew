#import "DbModel.h"

@implementation DbModel

- (void)initModule
{
    _publicModule=[[PublicModule alloc] init];
}

- (BOOL)isDbExist
{
    [self createDb];
    
    return YES;
}

- (void)createDb
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask,
                                                       YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    NSString *dbPath=[documentDirectory stringByAppendingPathComponent:@"healthhut.db"];
    DB=[FMDatabase databaseWithPath:dbPath];
    if(![DB open])
    {
        NSLog(@"Could not open db");
        return;
    }
    [self createTables];
}

- (BOOL)connectToDb
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                       NSUserDomainMask,
                                                       YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    NSString *dbPath=[documentDirectory stringByAppendingPathComponent:@"healthhut.db"];
    DB=[FMDatabase databaseWithPath:dbPath];
    if(![DB open])
    {
        NSLog(@"Could not open db");
        return NO;
    }

    return YES;
}

-(void)createTables
{
    BOOL ret;
   
    if(![self isTableOK:@"d_account"])
    {
        ret=[DB executeUpdate:@"CREATE TABLE d_account (t_id integer PRIMARY KEY NOT NULL,u_name varchar(256),u_pwd varchar(256),u_id varchar(50),u_session varchar(50),local_icon text,remote_icon text,m_sex varchar(10),m_nickname varchar(50),m_sign text,m_country varchar(256),m_province varchar(256),m_city varchar(256),m_address text,m_latitude varchar(100),m_longitude varchar(100),u_type varchar(10),c_time varchar(20),doing_num varchar(100),m_ownness varchar(10),m_age varchar(20),m_height varchar(20),m_hc varchar(20),m_wc varchar(20))"];
    }

    if(![self isTableOK:@"g_target"])
    {
        ret=[DB executeUpdate:@"CREATE TABLE g_target (t_id INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL,m_id int,target_value double,t_time varchar(30),t_update int,t_delete int,c_time varchar(30),t_finish int,t_finishtime varchar(30),target_type int,update_time varchar(30))"];
    }
    
    
    if(![self isTableOK:@"m_weight"])
    {
        ret=[DB executeUpdate:@"CREATE TABLE m_weight (id integer PRIMARY KEY AUTOINCREMENT  NOT NULL,m_id integer,weight double,fat double,muscle double,water double,basic double,bone double,bmi double,visceralfat double,bodyage double,height double,m_time text,m_update integer,m_result varchar(10),m_delete integer,c_time text,m_type integer,update_time text,member_type integer,device_type varchar(200))"];
        //m_delete 0:没有删除  1：已删除
    }
    
    if(![self isTableOK:@"m_step"])
    {
        ret=[DB executeUpdate:@"CREATE TABLE m_step (id integer PRIMARY KEY AUTOINCREMENT  NOT NULL,m_id integer,step int,calorie int,journey double,time_start varchar(30),time_end varchar(30),m_time varchar(30),m_update int,m_delete int,c_time varchar(30),m_type int,update_time varchar(30),member_type int)"];
        //m_delete 0:没有删除  1：已删除
    }
    //项目设置
    if(![self isTableOK:@"m_project"])
    {
        ret=[DB executeUpdate:@"CREATE TABLE m_project (id INTEGER PRIMARY KEY AUTOINCREMENT, c_time varchar(15) NOT NULL, 'isset' TEXT, 'unset' TEXT, diary_open INTEGER NOT NULL DEFAULT 1)"];
    }
    if(![self isTableOK:@"user_downloadtime"])
    {
        ret=[DB executeUpdate:@"CREATE TABLE user_downloadtime (t_id integer PRIMARY KEY AUTOINCREMENT  NOT NULL,u_id text,record_downloadtime varchar(50))"];
    }
    if(![self isTableOK:@"guser_downloadtime"])
    {
        ret=[DB executeUpdate:@"CREATE TABLE guser_downloadtime (t_id integer PRIMARY KEY AUTOINCREMENT  NOT NULL,u_id varchar(100),c_time varchar(100),weight_downloadtime varchar(50),target_downloadtime varchar(50),step_downloadtime varchar(50))"];
    }
    if(![self isTableOK:@"m_jsontemp"])
    {
        ret=[DB executeUpdate:@"CREATE TABLE m_jsontemp (id integer PRIMARY KEY AUTOINCREMENT  NOT NULL,u_id varchar(20) NOT NULL,json_type text,json_temp text,json_time varchar(30),json_operation varchar(100),json_page varchar(10))"];
    }
}


- (BOOL)isTableOK:(NSString *)tableName
{
    FMResultSet *rs=[DB executeQuery:@"select count(*) as 'count' from sqlite_master where type='table' and name=?",tableName];
    while([rs next])
    {
        NSInteger count=[rs intForColumn:@"count"];
        if(0 == count)
        {
            return NO;
        }
        else
        {
           return YES;
         }
    }
    [rs close];
    return NO;
}

-(BOOL)updateAccountFromService:(NSArray *)aryInfo
{
    BOOL ret=NO;
    if(aryInfo == nil || aryInfo.count < 16)
    {
        return ret;
    }
    
    if(DB.open)
    {
        [DB close];
    }
    [self connectToDb];
    if(DB)
    {
        NSString *uid=[aryInfo objectAtIndex:0];
        NSString *usession=[aryInfo objectAtIndex:1];
        NSString *remoteicon=[aryInfo objectAtIndex:2];
        NSString *sex=[aryInfo objectAtIndex:3];
        NSString *nickname=[aryInfo objectAtIndex:4];
        NSString *country=[aryInfo objectAtIndex:5];
        NSString *province=[aryInfo objectAtIndex:6];
        NSString *city=[aryInfo objectAtIndex:7];
       
        NSString *doingNum=[aryInfo objectAtIndex:8];
        NSString *msign=[aryInfo objectAtIndex:9];
        
        NSString *uname=[aryInfo objectAtIndex:10];
        NSString *upwd=[aryInfo objectAtIndex:11];
        NSString *utype=[aryInfo objectAtIndex:12];
        NSString *address=[aryInfo objectAtIndex:13];
        NSString *latitude=[aryInfo objectAtIndex:14];
        NSString *longitude=[aryInfo objectAtIndex:15];
        NSString *ownness=[aryInfo objectAtIndex:16];

        NSString *ctime=[PublicModule getMyTimeInterval:[NSDate date]];
        NSString *locaticon=@"";
        
        FMResultSet *rs;
        
        rs=[DB executeQuery:@"SELECT u_id FROM d_account where u_id=?",uid];
        BOOL isExist=NO;
        while([rs next])
        {
            NSString *uidTemp=[rs stringForColumn:@"u_id"];
            
            if(uidTemp && ![uidTemp isEqualToString:@""])
            {
                isExist=YES;
            }
        }
        
        [rs close];
        
        if(isExist)
        {
            ret=[DB executeUpdate:@"update d_account set u_session=?,local_icon=?,remote_icon=?,m_sex=?,m_nickname=?,m_country=?,m_province=?,m_city=?,m_address=?,m_latitude=?,m_longitude=?,doing_num=?,m_ownness=?,m_sign=?,u_name=?,u_pwd=?,u_type=? where u_id=?",usession,locaticon,remoteicon,sex,nickname,country,province,city,address,latitude,longitude,doingNum,ownness,msign,uname,upwd,utype,uid];
        }
        else
        {
            ret=[DB executeUpdate:@"INSERT INTO d_account (u_id,u_name,u_pwd,u_session,local_icon,remote_icon,m_sex,m_nickname,m_country,m_province,m_city,m_address,m_latitude,m_longitude,u_type,c_time,doing_num,m_sign,m_ownness) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",uid,uname,upwd,usession,locaticon,remoteicon,sex,nickname,country,province,city,address,latitude,longitude,utype,ctime,doingNum,msign,ownness];
        }
        
    }
    [DB close];
    return ret;
    
}

-(BOOL)updateAccountWithPwd:(NSString *)pwd andUID:(NSString *)uid
{
    if(pwd==nil||pwd.length<1 ||
       uid == nil || uid.length<1)
    {
        return NO;
    }
    BOOL ret=NO;
    if(DB.open)
    {
        [DB close];
    }
    [self connectToDb];
    if(DB)
    {
        
        ret=[DB executeUpdate:@"update d_account set u_pwd=? where u_id=?",pwd,uid];
    }
    [DB close];
    return ret;
}

-(BOOL)updateAccountWithCTime:(NSString *)ctime andUID:(NSString *)uid andUName:(NSString *)uname andUPwd:(NSString *)upwd
{
    if(ctime==nil||ctime.length<1 ||
       uid == nil || uid.length<1 ||
       uname == nil || uname.length<1 ||
       upwd == nil || upwd.length<1)
    {
        return NO;
    }
    BOOL ret=NO;
    if(DB.open)
    {
        [DB close];
    }
    [self connectToDb];
    if(DB)
    {
        
        ret=[DB executeUpdate:@"update d_account set u_id=?,u_name=?,u_pwd=? where c_time=?",uid,uname,upwd,ctime];
    }
    [DB close];
    return ret;
}

-(BOOL)updateAccount:(NSArray *)aryInfo withType:(int)type
{
    if(aryInfo==nil||aryInfo.count<8)
    {
        return NO;
    }
    BOOL ret=NO;
    if(DB.open)
    {
        [DB close];
    }
    [self connectToDb];
    if(DB)
    {
        NSString *uid=[aryInfo objectAtIndex:0];
        NSString *remoteicon=[aryInfo objectAtIndex:1];
        NSString *sex=[aryInfo objectAtIndex:2];
        NSString *nickname=[aryInfo objectAtIndex:3];
        NSString *country=[aryInfo objectAtIndex:4];
        NSString *province=[aryInfo objectAtIndex:5];
        NSString *city=[aryInfo objectAtIndex:6];
        NSString *msign=[aryInfo objectAtIndex:7];
        NSString *ownness=[aryInfo objectAtIndex:8];
        
        if(type == AccountTypeNickname)
        {
            ret=[DB executeUpdate:@"update d_account set m_nickname=? where u_id=?",nickname,uid];
        }
        else if (type == AccountTypeHeadphoto)
        {
            ret=[DB executeUpdate:@"update d_account set remote_icon=? where u_id=?",remoteicon,uid];
        }
        else if(type == AccountTypeSex)
        {
            ret=[DB executeUpdate:@"update d_account set m_sex=? where u_id=?",sex,uid];
        }
        else if(type == AccountTypeAddress)
        {
            ret=[DB executeUpdate:@"update d_account set m_province=?,m_city=? where u_id=?",province,city,uid];
        }
        else if(type == AccountTypeSign)
        {
            ret=[DB executeUpdate:@"update d_account set m_sign=? where u_id=?",msign,uid];
        }
        else if (type == AccountTypeOwnness)
        {
            ret=[DB executeUpdate:@"update d_account set m_ownness=? where u_id=?",ownness,uid];
        }
    }
    [DB close];
    return ret;
}

-(NSMutableArray *)selectAccountWithCTime:(NSString *)strCTime
{
    if(strCTime  == nil)
    {
        return nil;
    }
    
    NSMutableArray *aryReturn=[[NSMutableArray alloc] init];
    if(DB.open)
    {
        [DB close];
    }
    [self connectToDb];
    if(DB)
    {
        
        FMResultSet *rs;
        
        rs=[DB executeQuery:@"SELECT * FROM d_account where c_time=?",strCTime];
        
        while([rs next])
        {
            NSString *uid=[rs stringForColumn:@"u_id"];
            NSString *uname=[rs stringForColumn:@"u_name"];
            NSString *upwd=[rs stringForColumn:@"u_pwd"];
            NSString *usession=[rs stringForColumn:@"u_session"];
            NSString *localicon=[rs stringForColumn:@"local_icon"];
            NSString *remoteicon=[rs stringForColumn:@"remote_icon"];
            NSString *msex=[rs stringForColumn:@"m_sex"];
            NSString *mnickname=[rs stringForColumn:@"m_nickname"];
            NSString *mcountry=[rs stringForColumn:@"m_country"];
            NSString *mprovince=[rs stringForColumn:@"m_province"];
            NSString *mcity=[rs stringForColumn:@"m_city"];
            NSString *maddress=[rs stringForColumn:@"m_address"];
            NSString *mlati=[rs stringForColumn:@"m_latitude"];
            NSString *mlongi=[rs stringForColumn:@"m_longitude"];
            NSString *utype=[rs stringForColumn:@"u_type"];
            NSString *ctime=[rs stringForColumn:@"c_time"];
            NSString *doingnum=[rs stringForColumn:@"doing_num"];
            NSString *msign=[rs stringForColumn:@"m_sign"];
            NSString *ownness=[rs stringForColumn:@"m_ownness"];
            NSString *age=[rs stringForColumn:@"m_age"];
            NSString *height=[rs stringForColumn:@"m_height"];
            NSString *wc=[rs stringForColumn:@"m_wc"];
            NSString *hc=[rs stringForColumn:@"m_hc"];
            
            if(wc == nil) wc=@"";
            if(hc == nil) hc=@"";
            
            NSArray *aryTemp=[[NSArray alloc] initWithObjects:uname,
                              upwd,
                              uid,
                              usession,
                              localicon,
                              remoteicon,
                              msex,
                              mnickname,
                              mcountry,
                              mprovince,
                              mcity,
                              maddress,
                              mlati,
                              mlongi,
                              utype,
                              ctime,
                              doingnum,
                              msign,
                              ownness,
                              age,
                              height,wc,hc, nil];
            [aryReturn addObject:aryTemp];
        }
        
        [rs close];
        [DB close];
        
    }
    
    return aryReturn;
}

-(NSString *)selectLocalAccountCTime
{
    NSString *strReturn=@"";
    if(DB.open)
    {
        [DB close];
    }
    [self connectToDb];
    if(DB)
    {
        
        FMResultSet *rs;
        
        rs=[DB executeQuery:@"SELECT * FROM d_account"];
        
        while([rs next])
        {
            NSString *uid=[rs stringForColumn:@"u_id"];
            NSString *ctime=[rs stringForColumn:@"c_time"];
            if(uid == nil ||
               [uid isEqualToString:@""] ||
               [uid isEqualToString:@"-1"])
            {
                strReturn=ctime;
                return strReturn;
            }
        }
        
        [rs close];
        [DB close];
        
    }
    
    return strReturn;
}

-(BOOL)updateLocalAccount:(NSArray *)aryInfo
{
    if(aryInfo==nil||aryInfo.count<18)
    {
        return NO;
    }
    BOOL ret=NO;
    if(DB.open)
    {
        [DB close];
    }
    [self connectToDb];
    if(DB)
    {
        NSString *uname=[aryInfo objectAtIndex:0];
        NSString *upwd=[aryInfo objectAtIndex:1];
        NSString *uid=[aryInfo objectAtIndex:2];
        NSString *usession=[aryInfo objectAtIndex:3];
        NSString *localicon=[aryInfo objectAtIndex:4];
        NSString *remoteicon=[aryInfo objectAtIndex:5];
        NSString *sex=[aryInfo objectAtIndex:6];
        NSString *nickname=[aryInfo objectAtIndex:7];
        NSString *country=[aryInfo objectAtIndex:8];
        NSString *province=[aryInfo objectAtIndex:9];
        NSString *city=[aryInfo objectAtIndex:10];
        NSString *address=[aryInfo objectAtIndex:11];
        NSString *latitude=[aryInfo objectAtIndex:12];
        NSString *longitude=[aryInfo objectAtIndex:13];
        NSString *utype=[aryInfo objectAtIndex:14];
        NSString *ctime=[aryInfo objectAtIndex:15];
        NSString *doingNum=[aryInfo objectAtIndex:16];
        NSString *msign=[aryInfo objectAtIndex:17];
        NSString *myOwnness=[aryInfo objectAtIndex:18];
        NSString *age=[aryInfo objectAtIndex:19];
        NSString *height=[aryInfo objectAtIndex:20];
        NSString *wc=[aryInfo objectAtIndex:21];
        NSString *hc=[aryInfo objectAtIndex:22];
        
        FMResultSet *rs;
        
        rs=[DB executeQuery:@"SELECT c_time FROM d_account where c_time=?",ctime];
        BOOL isExist=NO;
        while([rs next])
        {
            NSString *uidTemp=[rs stringForColumn:@"c_time"];
            
            if(uidTemp && ![uidTemp isEqualToString:@""])
            {
                isExist=YES;
            }
        }
        [rs close];
        
        if(isExist)
        {
            ret=[DB executeUpdate:@"update d_account set m_sex=?,m_age=?,m_height=?,m_wc=?,m_hc=? where c_time=?",sex,age,height,wc,hc,ctime];
        }
        else
        {
            ret=[DB executeUpdate:@"INSERT INTO d_account (u_id,u_name,u_pwd,u_session,local_icon,remote_icon,m_sex,m_nickname,m_country,m_province,m_city,m_address,m_latitude,m_longitude,u_type,c_time,doing_num,m_sign,m_ownness,m_age,m_height,m_wc,m_hc) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",uid,uname,upwd,usession,localicon,remoteicon,sex,nickname,country,province,city,address,latitude,longitude,utype,ctime,doingNum,msign,myOwnness,age,height,wc,hc];
        }
        
    }
    [DB close];
    return ret;
}

-(BOOL)insertAccount:(NSArray *)aryInfo
{
    if(aryInfo==nil||aryInfo.count<18)
    {
        return NO;
    }
    BOOL ret=NO;
    if(DB.open)
    {
        [DB close];
    }
    [self connectToDb];
    if(DB)
    {
        NSString *uname=[aryInfo objectAtIndex:0];
        NSString *upwd=[aryInfo objectAtIndex:1];
        NSString *uid=[aryInfo objectAtIndex:2];
        NSString *usession=[aryInfo objectAtIndex:3];
        NSString *localicon=[aryInfo objectAtIndex:4];
        NSString *remoteicon=[aryInfo objectAtIndex:5];
        NSString *sex=[aryInfo objectAtIndex:6];
        NSString *nickname=[aryInfo objectAtIndex:7];
        NSString *country=[aryInfo objectAtIndex:8];
        NSString *province=[aryInfo objectAtIndex:9];
        NSString *city=[aryInfo objectAtIndex:10];
        NSString *address=[aryInfo objectAtIndex:11];
        NSString *latitude=[aryInfo objectAtIndex:12];
        NSString *longitude=[aryInfo objectAtIndex:13];
        NSString *utype=[aryInfo objectAtIndex:14];
        NSString *ctime=[aryInfo objectAtIndex:15];
        NSString *doingNum=[aryInfo objectAtIndex:16];
        NSString *msign=[aryInfo objectAtIndex:17];
        NSString *myOwnness=[aryInfo objectAtIndex:18];
        NSString *age=[aryInfo objectAtIndex:19];
        NSString *height=[aryInfo objectAtIndex:20];
        NSString *wc=[aryInfo objectAtIndex:21];
        NSString *hc=[aryInfo objectAtIndex:22];
        
        FMResultSet *rs;
        
        rs=[DB executeQuery:@"SELECT c_time FROM d_account where c_time=?",ctime];
        BOOL isExist=NO;
        while([rs next])
        {
            NSString *uidTemp=[rs stringForColumn:@"c_time"];
            
            if(uidTemp && ![uidTemp isEqualToString:@""])
            {
                isExist=YES;
            }
        }
        [rs close];
        
        if(isExist)
        {
            //ret=[DB executeUpdate:@"update d_account set u_name=?,u_pwd=?,u_session=?,remote_icon=?,m_sex=?,m_nickname=?,m_country=?,m_province=?,m_city=?,m_address=?,m_latitude=?,m_longitude=?,u_type=?,c_time=?,doing_num=?,m_sign=?,m_ownness=? where u_id=?",uname,upwd,usession,remoteicon,sex,nickname,country,province,city,address,latitude,longitude,utype,ctime,doingNum,msign,myOwnness,uid];
            ret=[DB executeUpdate:@"update d_account set m_sex=?,m_age=?,m_height=?,u_name=?,u_pwd=?,m_wc=?,m_hc=? where c_time=?",sex,age,height,uname,upwd,wc,hc,ctime];
        }
        else
        {
            ret=[DB executeUpdate:@"INSERT INTO d_account (u_id,u_name,u_pwd,u_session,local_icon,remote_icon,m_sex,m_nickname,m_country,m_province,m_city,m_address,m_latitude,m_longitude,u_type,c_time,doing_num,m_sign,m_ownness,m_age,m_height,m_wc,m_hc) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",uid,uname,upwd,usession,localicon,remoteicon,sex,nickname,country,province,city,address,latitude,longitude,utype,ctime,doingNum,msign,myOwnness,age,height,wc,hc];
        }
        
    }
    [DB close];
    return ret;
}

-(BOOL)insertMemberUpdateWithCTime:(NSString *)ctime andTime:(NSString *)downloadTime andGMID:(NSString *)gmid
{
    if(ctime == nil || gmid == nil)
    {
        return NO;
    }
    BOOL isExistUpdate=[self checkMemberUpdateExistWithCTime:ctime];
    BOOL ret=YES;
    if(!isExistUpdate)
    {
        NSString *emptyUpdateTime=@"1900-01-01 00:00:00";
        ret=[DB executeUpdate:@"INSERT INTO member_update (c_time,gm_id,alert_update_time,measure_update_time,diary_update_time,target_update_time,babyphoto_update_time,measure_download_time,alert_download_time,diary_download_time,target_download_time,babyphoto_download_time) values (?,?,?,?,?,?,?,?,?,?,?,?)",ctime,gmid,emptyUpdateTime,emptyUpdateTime,emptyUpdateTime,emptyUpdateTime,emptyUpdateTime,emptyUpdateTime,emptyUpdateTime,emptyUpdateTime,emptyUpdateTime,emptyUpdateTime];
    }
    else
    {
        //ret=[DB executeUpdate:@"update member_update set measure_download_time=?,alert_download_time=?,diary_download_time=?,target_doanload_time=?,babyphoto_download_time=? where c_time=?",downloadTime,downloadTime,downloadTime,downloadTime,downloadTime,ctime];
    }
    return ret;
}

-(BOOL)checkMemberUpdateExistWithCTime:(NSString *)ctime
{
    if(!DB.open)
    {
        [self connectToDb];
    }
    
    FMResultSet *rs;
    
    rs=[DB executeQuery:@"SELECT * FROM member_update where c_time=?",ctime];
    
    while([rs next])
    {
        NSString *muid=[rs stringForColumn:@"mu_id"];
        if(muid!=nil && ![muid isEqualToString:@""])
        {
            return YES;
        }
    }

    [rs close];
    return NO;
}

-(NSArray *)selectMemberUpdateWithCTime:(NSString *)ctime
{
    if(!DB.open)
    {
        [self connectToDb];
    }
    
    FMResultSet *rs;
    
    rs=[DB executeQuery:@"SELECT * FROM member_update where c_time=?",ctime];
    
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *muid=[rs stringForColumn:@"mu_id"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *gmid=[rs stringForColumn:@"gm_id"];
        NSString *alertupdatetime=[rs stringForColumn:@"alert_update_time"];
        NSString *measureupdatetime=[rs stringForColumn:@"measure_update_time"];
        NSString *diaryupdatetime=[rs stringForColumn:@"diary_update_time"];
        
        NSString *targetupdatetime=[rs stringForColumn:@"target_update_time"];
        NSString *babyphotoupdatetime=[rs stringForColumn:@"babyphoto_update_time"];
        NSString *measuredownloadtime=[rs stringForColumn:@"measure_download_time"];
        
        NSString *alertdownloadtime=[rs stringForColumn:@"alert_download_time"];
        NSString *diarydownloadtime=[rs stringForColumn:@"diary_download_time"];
        NSString *targetdownloadtime=[rs stringForColumn:@"target_download_time"];
        NSString *babyphotodownloadtime=[rs stringForColumn:@"babyphoto_download_time"];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:muid,
                         ctime,
                         gmid,
                         alertupdatetime,
                         measureupdatetime,
                         diaryupdatetime,
                         targetupdatetime,
                         babyphotoupdatetime,
                         measuredownloadtime,
                         alertdownloadtime,
                         diarydownloadtime,
                         targetdownloadtime,
                         babyphotodownloadtime,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    return retAry;
}

-(NSArray *)selectUserUpdateWithUID:(NSString *)uid
{
    if(uid == nil)
    {
        return NO;
    }
    if(!DB.open)
    {
        [self connectToDb];
    }
    
    FMResultSet *rs;
    
    rs=[DB executeQuery:@"SELECT * FROM user where u_id=?",uid];
    
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *u_id=[rs stringForColumn:@"u_id"];
        NSString *u_name=[rs stringForColumn:@"u_name"];
        NSString *u_pwd=[rs stringForColumn:@"u_password"];
        NSString *downloadtime=[rs stringForColumn:@"download_time"];
        NSString *umember=[rs stringForColumn:@"u_member"];
        NSString *utype=[rs stringForColumn:@"u_type"];
        NSString *measure_download_time=[rs stringForColumn:@"measure_download_time"];
        
        NSString *updatetime=[rs stringForColumn:@"update_time"];
        if(updatetime == nil)
        {
            updatetime=@"1900-01-01 00:00:00";
        }
        if(measure_download_time == nil)
        {
            measure_download_time=@"1900-01-01 00:00:00";
        }
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:u_id,
                         u_name,
                         u_pwd,
                         downloadtime,
                         umember,
                         utype,
                         updatetime,
                         measure_download_time,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    return retAry;
}

-(BOOL)isExistYunfuAlertWithCTime:(NSString *)ctime andWeek:(NSString *)week;
{
    if(ctime == nil || week == nil)
    {
        return NO;
    }
    if(![DB open])
    {
        [self connectToDb];
    }
    
    
    FMResultSet *rs=[DB executeQuery:@"select * from yf_alert where c_time=? and alert_week=?",ctime,week];
    while ([rs next])
    {
        NSString *ctime=[rs stringForColumn:@"c_time"];
        if(ctime) return YES;
        return NO;
    }
    [rs close];
    //[DB close];
    return NO;
}

-(BOOL)isExistYunfuAlertWithCTime:(NSString *)ctime andDataKey:(NSString *)datakey
{
    if(ctime == nil || time == nil)
    {
        return NO;
    }
    if(![DB open])
    {
        [self connectToDb];
    }
    
    
    FMResultSet *rs=[DB executeQuery:@"select * from yf_alert where c_time=? and data_key=?",ctime,datakey];
    while ([rs next])
    {
        NSString *ctime=[rs stringForColumn:@"c_time"];
        if(ctime) return YES;
        return NO;
    }
    [rs close];
    //[DB close];
    return NO;
}

-(BOOL)isExistYunfuDiaryWithCTime:(NSString *)ctime andTime:(NSString *)time
{
    if(ctime == nil || time == nil)
    {
        return NO;
    }
    if(![DB open])
    {
        [self connectToDb];
    }
    
    
    FMResultSet *rs=[DB executeQuery:@"select * from yf_diary where c_time=? and m_time=?",ctime,time];
    while ([rs next])
    {
        NSString *ctime=[rs stringForColumn:@"c_time"];
        if(ctime) return YES;
        return NO;
    }
    [rs close];
    //[DB close];
    return NO;
}

-(BOOL)isExistDownloadTimeWithUID:(NSString *)uid
{
    if(uid == nil)
    {
        return NO;
    }
    if(![DB open])
    {
        [self connectToDb];
    }
    
    
    FMResultSet *rs=[DB executeQuery:@"select record_downloadtime from user_downloadtime where u_id=?",uid];
    while ([rs next])
    {
        NSString *value=[rs stringForColumn:@"record_downloadtime"];
        if(value) return YES;
        return NO;
    }
    [rs close];
    return NO;
}

-(BOOL)isExistBabyPhotoWithCTime:(NSString *)ctime andTime:(NSString *)time
{
    if(ctime == nil || time == nil)
    {
        return NO;
    }
    if(![DB open])
    {
        [self connectToDb];
    }
    
    
    FMResultSet *rs=[DB executeQuery:@"select * from baby_time where c_time=? and b_time=?",ctime,time];
    while ([rs next])
    {
        NSString *ctime=[rs stringForColumn:@"c_time"];
        if(ctime) return YES;
        return NO;
    }
    [rs close];
    //[DB close];
    return NO;
}

-(BOOL)isExistWeightWithCTime:(NSString *)ctime andTime:(NSString *)m_time
{
    if(ctime == nil || m_time == nil)
    {
        return NO;
    }
    if(![DB open])
    {
        [self connectToDb];
    }
    
    FMResultSet *rs=[DB executeQuery:@"select * from m_weight where c_time=? and m_time=?",ctime,m_time];
    while ([rs next])
    {
        NSString *ctime=[rs stringForColumn:@"c_time"];
        if(ctime) return YES;
        return NO;
    }
    [rs close];
    return NO;
}

-(BOOL)isExistStepWithCTime:(NSString *)ctime andTime:(NSString *)m_time
{
    if(ctime == nil || m_time == nil)
    {
        return NO;
    }
    if(![DB open])
    {
        [self connectToDb];
    }
    
    FMResultSet *rs=[DB executeQuery:@"select * from m_step where c_time=? and m_time=?",ctime,m_time];
    while ([rs next])
    {
        NSString *ctime=[rs stringForColumn:@"c_time"];
        if(ctime) return YES;
        return NO;
    }
    [rs close];
    return NO;
}

-(BOOL)isExisTargetWithCTime:(NSString *)ctime andTime:(NSString *)m_time andType:(NSString *)type
{
    if(ctime == nil || m_time == nil || type == nil)
    {
        return NO;
    }
    if(![DB open])
    {
        [self connectToDb];
    }
    
    FMResultSet *rs=[DB executeQuery:@"select * from g_target where c_time=? and t_time=? and target_type",ctime,m_time,type];
    while ([rs next])
    {
        NSString *ctime=[rs stringForColumn:@"c_time"];
        if(ctime) return YES;
        return NO;
    }
    [rs close];
    return NO;
}


//查询是否有此条测量记录
-(BOOL)isExistMeasureDataWithCTime:(NSString *)ctime andTime:(NSString *)m_time
{
    if(ctime == nil || m_time == nil)
    {
        return NO;
    }
    if(![DB open])
    {
        [self connectToDb];
    }

    FMResultSet *rs=[DB executeQuery:@"select * from m_weight where c_time=? and m_time=?",ctime,m_time];
    while ([rs next])
    {
        //NSInteger count=[rs intForColumn:@"count"];
        
        //if( count == 0) return NO;
        //else return YES;
        NSString *ctime=[rs stringForColumn:@"c_time"];
        if(ctime) return YES;
        return NO;
    }
    [rs close];
    //[DB close];
    return NO;
}

-(BOOL)isExistUserStatusWithUID:(NSString *)uid
{
    if(![DB open])
    {
        [self connectToDb];
    }
    FMResultSet *rs=[DB executeQuery:@"select count(*) as 'count' from user_status where u_id=?",[NSNumber numberWithInt:[uid intValue]]];
    while ([rs next])
    {
        NSInteger count=[rs intForColumn:@"count"];
        if( count == 0) return NO;
        else return YES;
    }
    [rs close];
    return NO;
}

-(NSArray *)selectLastMeasureDataWithCTime:(NSString *)ctime andProject:(NSString *)project
{
    if(ctime == nil || project == nil)
    {
        return nil;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"select * from m_weight where c_time=%@ and m_delete=0 and %@>0 order by m_time desc limit 0,1",ctime,project];

    FMResultSet *rs=[DB executeQuery:strSQL];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *weight=[rs stringForColumn:@"weight"];
        NSString *fat=[rs stringForColumn:@"fat"];
        NSString *muscle=[rs stringForColumn:@"muscle"];
        NSString *water=[rs stringForColumn:@"water"];
        NSString *bone=[rs stringForColumn:@"bone"];
        NSString *basic=[rs stringForColumn:@"basic"];
        NSString *bmi=[rs stringForColumn:@"bmi"];
        NSString *visceralfat=[rs stringForColumn:@"visceralfat"];
        NSString *bodyage=[rs stringForColumn:@"bodyage"];
        NSString *height=[rs stringForColumn:@"height"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *myresult=[rs stringForColumn:@"m_result"];
        NSString *upateTime=[rs stringForColumn:@"update_time"];
        NSString *memberType=[rs stringForColumn:@"member_type"];
        
        
        if(!fat) fat=@"0.0";
        if(!muscle) muscle=@"0.0";
        if(!water) water=@"0.0";
        if(!basic) basic=@"0.0";
        if(!bone) bone=@"0.0";
        if(!bmi) bmi=@"0.0";
        if(!visceralfat) visceralfat=@"0.0";
        if(!bodyage) bodyage=@"0.0";
        if(!height) height=@"0.0";
        
        //weight = [NSString stringWithFormat:@"%.2f",[weight floatValue]];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:weight forKey:ProjectWeight];
        [dic setObject:fat forKey:ProjectFat];
        [dic setObject:muscle forKey:ProjectMuscle];
        [dic setObject:water forKey:ProjectWater];
        [dic setObject:basic forKey:ProjectBasic];
        [dic setObject:bone forKey:ProjectBone];
        [dic setObject:bmi forKey:ProjectBMI];
        [dic setObject:visceralfat forKey:ProjectVisceralFat];
        [dic setObject:bodyage forKey:ProjectBodyAge];
        [dic setObject:height forKey:ProjectHeight];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,
                         mid,
                         time,
                         dic,
                         ctime,
                         myupdate,
                         mydelete,
                         myresult,
                         upateTime,
                         memberType,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectFirstMeasureDataWithCTime:(NSString *)ctime andProject:(NSString *)project
{
    if(ctime == nil || project == nil)
    {
        return nil;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"select * from m_weight where c_time=%@ and m_delete=0 and %@>0 order by m_time asc limit 0,1",ctime,project];
    
    FMResultSet *rs=[DB executeQuery:strSQL];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *weight=[rs stringForColumn:@"weight"];
        NSString *fat=[rs stringForColumn:@"fat"];
        NSString *muscle=[rs stringForColumn:@"muscle"];
        NSString *water=[rs stringForColumn:@"water"];
        NSString *bone=[rs stringForColumn:@"bone"];
        NSString *basic=[rs stringForColumn:@"basic"];
        NSString *bmi=[rs stringForColumn:@"bmi"];
        NSString *visceralfat=[rs stringForColumn:@"visceralfat"];
        NSString *bodyage=[rs stringForColumn:@"bodyage"];
        NSString *height=[rs stringForColumn:@"height"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *myresult=[rs stringForColumn:@"m_result"];
        NSString *upateTime=[rs stringForColumn:@"update_time"];
        NSString *memberType=[rs stringForColumn:@"member_type"];
        
        
        if(!fat) fat=@"0.0";
        if(!muscle) muscle=@"0.0";
        if(!water) water=@"0.0";
        if(!basic) basic=@"0.0";
        if(!bone) bone=@"0.0";
        if(!bmi) bmi=@"0.0";
        if(!visceralfat) visceralfat=@"0.0";
        if(!bodyage) bodyage=@"0.0";
        if(!height) height=@"0.0";
        
        //weight = [NSString stringWithFormat:@"%.2f",[weight floatValue]];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:weight forKey:ProjectWeight];
        [dic setObject:fat forKey:ProjectFat];
        [dic setObject:muscle forKey:ProjectMuscle];
        [dic setObject:water forKey:ProjectWater];
        [dic setObject:basic forKey:ProjectBasic];
        [dic setObject:bone forKey:ProjectBone];
        [dic setObject:bmi forKey:ProjectBMI];
        [dic setObject:visceralfat forKey:ProjectVisceralFat];
        [dic setObject:bodyage forKey:ProjectBodyAge];
        [dic setObject:height forKey:ProjectHeight];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,
                         mid,
                         time,
                         dic,
                         ctime,
                         myupdate,
                         mydelete,
                         myresult,
                         upateTime,
                         memberType,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectLastStepWithCTime:(NSString *)ctime
{
    if(ctime==nil)
    {
        return nil;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    FMResultSet *rs=[DB executeQuery:@"select * from m_step where c_time=?  order by m_time desc limit 0,1",ctime];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *step=[rs stringForColumn:@"step"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,
                         mid,
                         time,
                         step,
                         ctime
                         ,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectLastWeightWithCTime:(NSString *)ctime
{
    if(ctime==nil)
    {
        return nil;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    FMResultSet *rs=[DB executeQuery:@"select * from m_weight where c_time=? and m_delete=0 order by m_time desc limit 0,1",ctime];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *weight=[rs stringForColumn:@"weight"];
        NSString *fat=[rs stringForColumn:@"fat"];
        NSString *muscle=[rs stringForColumn:@"muscle"];
        NSString *water=[rs stringForColumn:@"water"];
        NSString *bone=[rs stringForColumn:@"bone"];
        NSString *basic=[rs stringForColumn:@"basic"];
        NSString *bmi=[rs stringForColumn:@"bmi"];
        NSString *visceralfat=[rs stringForColumn:@"visceralfat"];
        NSString *bodyage=[rs stringForColumn:@"bodyage"];
        NSString *height=[rs stringForColumn:@"height"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *myresult=[rs stringForColumn:@"m_result"];
        NSString *upateTime=[rs stringForColumn:@"update_time"];
        NSString *memberType=[rs stringForColumn:@"member_type"];
        
        
        if(!fat) fat=@"0.0";
        if(!muscle) muscle=@"0.0";
        if(!water) water=@"0.0";
        if(!basic) basic=@"0.0";
        if(!bone) bone=@"0.0";
        if(!bmi) bmi=@"0.0";
        if(!visceralfat) visceralfat=@"0.0";
        if(!bodyage) bodyage=@"0.0";
        if(!height) height=@"0.0";
        
        //weight = [NSString stringWithFormat:@"%.2f",[weight floatValue]];
        
        NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
        [dic setObject:weight forKey:ProjectWeight];
        [dic setObject:fat forKey:ProjectFat];
        [dic setObject:muscle forKey:ProjectMuscle];
        [dic setObject:water forKey:ProjectWater];
        [dic setObject:basic forKey:ProjectBasic];
        [dic setObject:bone forKey:ProjectBone];
        [dic setObject:bmi forKey:ProjectBMI];
        [dic setObject:visceralfat forKey:ProjectVisceralFat];
        [dic setObject:bodyage forKey:ProjectBodyAge];
        [dic setObject:height forKey:ProjectHeight];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,
                         mid,
                         time,
                         dic,
                         ctime,
                         myupdate,
                         mydelete,
                         myresult,
                         upateTime,
                         memberType,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}


-(NSArray *)selectWeightWithCTime:(NSString *)ctime andStartDate:(NSString *)startDate endDate:(NSString *)endDate
{
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    FMResultSet *rs=[DB executeQuery:@"SELECT * FROM m_weight where c_time=? and m_delete=? and m_time>=? and m_time<? order by m_time desc",ctime,[NSNumber numberWithInt:0],startDate,endDate];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        //NSString *mid=[rs stringForColumn:@"m_id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *weight=[rs stringForColumn:@"weight"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *myresult=[rs stringForColumn:@"m_result"];
        
        //weight = [NSString stringWithFormat:@"%.2f",[weight floatValue]];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,mid,time,weight,ctime,myupdate,mydelete,myresult,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

- (NSArray *)selectAllMeasureDataWithCTime:(NSString *)ctime andProject:(NSString *)project
{
    if(ctime == nil || project == nil)
    {
        return nil;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"SELECT * FROM m_weight where c_time=%@ and m_delete=0 and %@>0 order by m_time desc",ctime,project];

    FMResultSet *rs=[DB executeQuery:strSQL];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *weight=[rs stringForColumn:@"weight"];
        
        NSString *fat=[rs stringForColumn:@"fat"];
        NSString *muscle=[rs stringForColumn:@"muscle"];
        NSString *water=[rs stringForColumn:@"water"];
        NSString *basic=[rs stringForColumn:@"basic"];
        NSString *bone=[rs stringForColumn:@"bone"];
        NSString *bmi=[rs stringForColumn:@"bmi"];
        NSString *viceralfat=[rs stringForColumn:@"visceralfat"];
        NSString *bodyage=[rs stringForColumn:@"bodyage"];
        NSString *height=[rs stringForColumn:@"height"];
        
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *myresult=[rs stringForColumn:@"m_result"];
        NSString *updateTime=[rs stringForColumn:@"update_time"];
        NSString *memberType=[rs stringForColumn:@"member_type"];
        
        //weight = [NSString stringWithFormat:@"%.2f",[weight floatValue]];
        
        NSString *returnVale=nil;
        if([project isEqualToString:ProjectWeight])
        {
            returnVale=weight;
        }
        else if ([project isEqualToString:ProjectFat])
        {
            returnVale=fat;
        }
        else if ([project isEqualToString:ProjectMuscle])
        {
            returnVale=muscle;
        }
        else if ([project isEqualToString:ProjectWater])
        {
            returnVale=water;
        }
        else if ([project isEqualToString:ProjectBasic])
        {
            returnVale=basic;
        }
        else if ([project isEqualToString:ProjectBone])
        {
            returnVale=bone;
        }
        else if ([project isEqualToString:ProjectVisceralFat])
        {
            returnVale=viceralfat;
        }
        else if ([project isEqualToString:ProjectBMI])
        {
            returnVale=bmi;
        }
        else if ([project isEqualToString:ProjectBodyAge])
        {
            returnVale=bodyage;
        }
        else if ([project isEqualToString:ProjectHeight])
        {
            returnVale=height;
        }
        if(returnVale == nil || [returnVale doubleValue]<=0)
        {
            continue;
        }
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,
                         mid,
                         time,
                         returnVale,
                         ctime,
                         myupdate,
                         mydelete,
                         myresult,
                         updateTime,
                         memberType,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectStepDateWithCTime:(NSString *)ctime withStartDate:(NSString *)startDate andEndDate:(NSString *)endDate
{
    if(ctime == nil || startDate == nil || endDate == nil)
    {
        return nil;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"SELECT * FROM m_step where c_time=%@ and m_delete=0 and m_time>='%@' and m_time<='%@' order by m_time desc",ctime,startDate,endDate];
    
    FMResultSet *rs=[DB executeQuery:strSQL];
    
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    NSMutableDictionary *dicTimeData=[[NSMutableDictionary alloc] init];
    NSMutableArray *aryTime=[[NSMutableArray alloc] init];
    while([rs next])
    {
        //NSMutableDictionary *dicTemp=[[NSMutableDictionary alloc] init];
        NSMutableArray *aryTemp=[[NSMutableArray alloc] init];
        
        NSString *myid=[rs stringForColumn:@"id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *step=[rs stringForColumn:@"step"];
        NSString *calorie=[rs stringForColumn:@"calorie"];
        NSString *journey=[rs stringForColumn:@"journey"];
        NSString *timeStart=[rs stringForColumn:@"time_start"];
        NSString *timeEnd=[rs stringForColumn:@"time_end"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *myresult=@"";
        NSString *updateTime=[rs stringForColumn:@"update_time"];
        NSString *memberType=[rs stringForColumn:@"member_type"];
        
        if(time == nil || time.length < 10)
        {
            continue;
        }
        
        NSString *date=[time substringToIndex:10];
        if([aryTime containsObject:date])
        {
            aryTemp=[dicTimeData valueForKey:date];
            NSString *strStep=[aryTemp objectAtIndex:3];
            NSString *strStepNew=[NSString stringWithFormat:@"%d",[strStep intValue]+[step intValue]];
            [aryTemp replaceObjectAtIndex:3 withObject:strStepNew];
            
            /*
             dicTemp=[dicTimeData valueForKey:date];
             NSString *strStep=[dicTemp valueForKey:@"step"];
             
             NSString *strStepNew=[NSString stringWithFormat:@"%d",[strStep intValue]+[step intValue]];
             [dicTemp setObject:strStepNew forKey:@"step"];
             */
        }
        else
        {
            /*
             [dicTemp setObject:myid forKey:@"tid"];
             [dicTemp setObject:mid forKey:@"mid"];
             [dicTemp setObject:time forKey:@"time"];
             [dicTemp setObject:step forKey:@"step"];
             [dicTemp setObject:ctime forKey:@"ctime"];
             [dicTemp setObject:myupdate forKey:@"myupdate"];
             [dicTemp setObject:mydelete forKey:@"mydelete"];
             [dicTemp setObject:myresult forKey:@"myresult"];
             [dicTemp setObject:updateTime forKey:@"updateTime"];
             [dicTemp setObject:memberType forKey:@"memberType"];
             */
            NSMutableArray *tmpAry=[[NSMutableArray alloc] initWithObjects:myid,
                                    mid,
                                    time,
                                    step,
                                    ctime,
                                    myupdate,
                                    mydelete,
                                    myresult,
                                    updateTime,
                                    memberType,nil];
            
            [aryTime addObject:date];
            [dicTimeData setObject:tmpAry forKey:date];
        }
        
        /*
         NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,
         mid,
         time,
         step,
         calorie,
         journey,
         timeStart,
         timeEnd,
         ctime,
         myupdate,
         mydelete,
         myresult,
         updateTime,
         memberType,nil];
         [muArray addObject:tmpAry];
         */
    }
    
    for(NSInteger i=0;i<aryTime.count;i++)
    {
        NSMutableArray *aryTemp=[dicTimeData valueForKey:[aryTime objectAtIndex:i]];
        if(aryTemp)
        {
            [muArray addObject:aryTemp];
        }
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectStepWithCTime:(NSString *)ctime withStartDate:(NSString *)startDate andEndDate:(NSString *)endDate
{
    if(ctime == nil || startDate == nil || endDate == nil)
    {
        return nil;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"SELECT * FROM m_step where c_time=%@ and m_delete=0 and m_time>='%@' and m_time<='%@' order by m_time desc",ctime,startDate,endDate];
    
    //FMResultSet *rs=[DB executeQuery:@"SELECT * FROM m_step where c_time=? and m_delete=0 time_start>= order by m_time desc",ctime];
    FMResultSet *rs=[DB executeQuery:strSQL];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid = [rs stringForColumn:@"id"];
        NSString *mid = @"";
        NSString *time = [rs stringForColumn:@"m_time"];
        NSString *step = [rs stringForColumn:@"step"];
        NSString *calorie = [rs stringForColumn:@"calorie"];
        NSString *journey = [rs stringForColumn:@"journey"];
        NSString *timeStart = [rs stringForColumn:@"time_start"];
        NSString *timeEnd = [rs stringForColumn:@"time_end"];
        NSString *ctime = [rs stringForColumn:@"c_time"];
        NSString *myupdate = [rs stringForColumn:@"m_update"];
        NSString *mydelete = [rs stringForColumn:@"m_delete"];
        NSString *myresult = @"";
        NSString *updateTime = [rs stringForColumn:@"update_time"];
        NSString *memberType = [rs stringForColumn:@"member_type"];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,
                         mid,
                         time,
                         step,
                         calorie,
                         journey,
                         timeStart,
                         timeEnd,
                         ctime,
                         myupdate,
                         mydelete,
                         myresult,
                         updateTime,
                         memberType,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectMeasureWithCTime:(NSString *)ctime andProject:(NSString *)project andStartDate:(NSString *)startDate endDate:(NSString *)endDate
{
    if(project == nil || startDate == nil || endDate == nil)
    {
        return nil;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"SELECT * FROM m_weight where c_time=%@ and m_delete=0 and %@>0 and m_time>='%@' and m_time<='%@' order by m_time desc limit 0,1",ctime,project,startDate,endDate];
    FMResultSet *rs=[DB executeQuery:strSQL];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        //NSString *mid=[rs stringForColumn:@"m_id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *weight=[rs stringForColumn:@"weight"];
        NSString *fat=[rs stringForColumn:@"fat"];
        NSString *muscle=[rs stringForColumn:@"muscle"];
        NSString *water=[rs stringForColumn:@"water"];
        NSString *bone=[rs stringForColumn:@"bone"];
        NSString *basic=[rs stringForColumn:@"basic"];
        NSString *bmi=[rs stringForColumn:@"bmi"];
        NSString *visceralfat=[rs stringForColumn:@"visceralfat"];
        NSString *bodyage=[rs stringForColumn:@"bodyage"];
        NSString *height=[rs stringForColumn:@"height"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *myresult=[rs stringForColumn:@"m_result"];
        
        if(weight == nil) weight=@"0.0";
        if(fat == nil) fat=@"0.0";
        if(muscle == nil) muscle=@"0.0";
        if(water == nil) water=@"0.0";
        if(bone == nil) bone=@"0.0";
        if(basic == nil) basic=@"0.0";
        if(bmi == nil) bmi=@"0.0";
        if(visceralfat == nil) visceralfat=@"0.0";
        if(bodyage == nil) bodyage=@"0.0";
        if(height == nil) height=@"0.0";
        
        //weight = [NSString stringWithFormat:@"%.2f",[weight floatValue]];
        
        NSMutableDictionary *dicData=[[NSMutableDictionary alloc] init];
        [dicData setObject:weight forKey:ProjectWeight];
        [dicData setObject:fat forKey:ProjectFat];
        [dicData setObject:muscle forKey:ProjectMuscle];
        [dicData setObject:water forKey:ProjectWater];
        [dicData setObject:bone forKey:ProjectBone];
        [dicData setObject:basic forKey:ProjectBasic];
        [dicData setObject:bmi forKey:ProjectBMI];
        [dicData setObject:visceralfat forKey:ProjectVisceralFat];
        [dicData setObject:bodyage forKey:ProjectBodyAge];
        [dicData setObject:height forKey:ProjectHeight];
        
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,mid,time,dicData,ctime,myupdate,mydelete,myresult,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectWeightWithCTime:(NSString *)ctime andProject:(NSString *)project andStartDate:(NSString *)startDate endDate:(NSString *)endDate
{
    if(project == nil || startDate == nil || endDate == nil || project.length<1 || startDate.length<1 || endDate.length<1)
    {
        return nil;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"SELECT * FROM m_weight where c_time=%@ and m_delete=0 and %@>0 and m_time>='%@' and m_time<='%@' order by m_time desc",ctime,project,startDate,endDate];
    FMResultSet *rs=[DB executeQuery:strSQL];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        //NSString *mid=[rs stringForColumn:@"m_id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *weight=[rs stringForColumn:@"weight"];
        NSString *fat=[rs stringForColumn:@"fat"];
        NSString *muscle=[rs stringForColumn:@"muscle"];
        NSString *water=[rs stringForColumn:@"water"];
        NSString *bone=[rs stringForColumn:@"bone"];
        NSString *basic=[rs stringForColumn:@"basic"];
        NSString *bmi=[rs stringForColumn:@"bmi"];
        NSString *visceralfat=[rs stringForColumn:@"visceralfat"];
        NSString *bodyage=[rs stringForColumn:@"bodyage"];
        NSString *height=[rs stringForColumn:@"height"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *myresult=[rs stringForColumn:@"m_result"];
        
        //weight = [NSString stringWithFormat:@"%.2f",[weight floatValue]];
        
        NSString *value=weight;
        if([project isEqualToString:ProjectFat])
        {
            value=fat;
        }
        else if ([project isEqualToString:ProjectMuscle])
        {
            value=muscle;
        }
        else if ([project isEqualToString:ProjectWater])
        {
            value=water;
        }
        else if ([project isEqualToString:ProjectBone])
        {
            value=bone;
        }
        else if ([project isEqualToString:ProjectBasic])
        {
            value=basic;
        }
        else if ([project isEqualToString:ProjectBMI])
        {
            value=bmi;
        }
        else if ([project isEqualToString:ProjectWeight])
        {
            value=weight;
        }
        else if ([project isEqualToString:ProjectVisceralFat])
        {
            value=visceralfat;
        }
        else if ([project isEqualToString:ProjectBodyAge])
        {
            value=bodyage;
        }
        else if ([project isEqualToString:ProjectHeight])
        {
            value=height;
        }
        
        if(value == nil)
        {
            continue;
        }
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,mid,time,value,ctime,myupdate,mydelete,myresult,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectChartAnalysisWithProject:(NSString *)project andCTime:(NSString *)ctime
{
    if(ctime == nil || project == nil)
    {
        return nil;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    FMResultSet *rs;
    if(DB)
    {
        
        if(![DB open])
        {
            [self connectToDb];
        }
        
        
        NSString *strSQL;
        if([project isEqualToString:ProjectStepCount] ||
           [project isEqualToString:ProjectStepCalorie] ||
           [project isEqualToString:ProjectStepJourney] ||
           [project isEqualToString:ProjectStepTime])
        {
            strSQL=[NSString stringWithFormat:@"select min(step) as minvalue,max(step) as maxvalue,avg(step) as avgvalue  from m_step where c_time=%@ and m_delete=0 and step>0",ctime];
        }
        else
        {
            strSQL=[NSString stringWithFormat:@"select min(%@) as minvalue,max(%@) as maxvalue,avg(%@) as avgvalue  from m_weight where c_time=%@ and m_delete=0 and %@>0",project,project,project,ctime,project];
        }
        
        rs=[DB executeQuery:strSQL];
        while([rs next])
        {
            NSString *minvalue=[rs stringForColumn:@"minvalue"];
            NSString *maxvalue=[rs stringForColumn:@"maxvalue"];
            NSString *avgvalue=[rs stringForColumn:@"avgvalue"];
            if(minvalue == nil || maxvalue ==nil || avgvalue == nil)
            {
                continue;
            }
            
            NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
            if ([weightUnit isEqualToString:@"lb"] && [project isEqualToString:ProjectWeight]) {
                minvalue = [PublicModule kgToLb:minvalue];
                maxvalue = [PublicModule kgToLb:maxvalue];
                avgvalue = [PublicModule kgToLb:avgvalue];
            }
            
            [muArray addObject:minvalue];
            [muArray addObject:maxvalue];
            [muArray addObject:avgvalue];
        }
        
    }
    
    [DB close];
    [rs close];
    return muArray;
}

-(NSArray *)selectMaxAndMinProjectTimeWithProject:(NSString *)project andCTime:(NSString *)ctime
{
    if(ctime == nil || project == nil)
    {
        return nil;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    FMResultSet *rs;
    if(DB)
    {
        
        if(![DB open])
        {
            [self connectToDb];
        }
        
        
        NSString *strSQL;
        if([project isEqualToString:ProjectStepCount] ||
           [project isEqualToString:ProjectStepCalorie] ||
           [project isEqualToString:ProjectStepJourney] ||
           [project isEqualToString:ProjectStepTime])
        {
            strSQL=[NSString stringWithFormat:@"select min(m_time) as mintime,max(m_time) as maxtime  from m_step where c_time=%@ and m_delete=0 and step>0",ctime];
        }
        else
        {
            strSQL=[NSString stringWithFormat:@"select min(m_time) as mintime,max(m_time) as maxtime  from m_weight where c_time=%@ and m_delete=0 and %@>0",ctime,project];
        }
        
        rs=[DB executeQuery:strSQL];
        while([rs next])
        {
            NSString *mintime=[rs stringForColumn:@"mintime"];
            NSString *maxtime=[rs stringForColumn:@"maxtime"];
            if(maxtime == nil || mintime ==nil)
            {
                continue;
            }
            [muArray addObject:mintime];
            [muArray addObject:maxtime];
        }
        
    }
    
    [DB close];
    [rs close];
    return muArray;
}

-(NSArray *)selectMaxAndMinProjectValueWithProject:(NSString *)project andCTime:(NSString *)ctime
{
    if(ctime == nil || project == nil)
    {
        return nil;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    
    [self connectToDb];
    
    NSMutableArray *muArray;
    NSMutableArray *ary1=[[NSMutableArray alloc] init];
    NSMutableArray *ary2=[[NSMutableArray alloc] init];
    FMResultSet *rs;
    if(DB)
    {
        
        if(![DB open])
        {
            [self connectToDb];
        }
        
        
        NSString *strSQL;
        //历史最轻
        strSQL=[NSString stringWithFormat:@"select min(%@) as weight,m_time  from m_weight where c_time=%@ and m_delete=0 and %@>0",project,ctime,project];
        rs=[DB executeQuery:strSQL];
        while([rs next])
        {
            NSString *weight=[rs stringForColumn:@"weight"];
            NSString *mtime=[rs stringForColumn:@"m_time"];
            if(weight == nil || mtime ==nil)
            {
                continue;
            }
            [ary1 addObject:weight];
            [ary1 addObject:mtime];
        }
        
        if(![DB open])
        {
            [self connectToDb];
        }
        
        //历史最重
        strSQL=[NSString stringWithFormat:@"select max(%@) as weight,m_time  from m_weight where c_time=%@ and m_delete=0 and %@>0",project,ctime,project];
        rs=[DB executeQuery:strSQL];
        while([rs next])
        {
            NSString *weight=[rs stringForColumn:@"weight"];
            NSString *mtime=[rs stringForColumn:@"m_time"];
            if(weight == nil || mtime ==nil)
            {
                continue;
            }
            [ary2 addObject:weight];
            [ary2 addObject:mtime];
        }
        
        
        if(![DB open])
        {
            [self connectToDb];
        }
        
        
        
    }
    muArray=[[NSMutableArray alloc] initWithObjects:ary1,ary2, nil];
    [DB close];
    [rs close];
    return muArray;
}

-(NSArray *)selectTargetWithCTime:(NSString *)ctime andType:(NSString *)type
{
    if(ctime==nil || type == nil)
    {
        return  nil;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    FMResultSet *rs;
    
    if(DB)
    {
        rs=[DB executeQuery:@"SELECT * FROM g_target where c_time=? and target_type=? order by t_time desc limit 0,1",ctime,type];
        
        while([rs next])
        {
            /*
             0: 目标id
             1：用户id
             2：目标值
             3：目标设立时间
             4：是否需要上传到服务器
             5：是否已经删除
             6：用户citme
             7：是否完成
             8：完成时间
             9: 目标类型
             10:更新时间
             11:用户类型
             */
            NSString *tid=[rs stringForColumn:@"t_id"];
            NSString *mid=[rs stringForColumn:@"m_id"];
            if(mid == nil)
            {
                mid=@"";
            }
            NSString *targetValue=[rs stringForColumn:@"target_value"];
            NSString *ttime=[rs stringForColumn:@"t_time"];
            NSString *tupdate=[rs stringForColumn:@"t_update"];
            NSString *tdelete=[rs stringForColumn:@"t_delete"];
            NSString *ctime=[rs stringForColumn:@"c_time"];
            NSString *tfinish=[rs stringForColumn:@"t_finish"];
            NSString *tfinishtime=[rs stringForColumn:@"t_finishtime"];
            NSString *ttype=[rs stringForColumn:@"target_type"];
            NSString *updateTime=[rs stringForColumn:@"update_time"];
            
            NSArray *tmpAry=[[NSArray alloc] initWithObjects:tid,mid,targetValue,ttime,tupdate,tdelete,ctime,tfinish,tfinishtime,ttype,updateTime,nil];
            [muArray addObject:tmpAry];
        }
    }
    [DB close];
    [rs close];
    return muArray;
}

-(BOOL)insertTarget:(NSArray *)aryInfo
{
    if(aryInfo==nil||aryInfo.count<8)
    {
        return NO;
    }
    BOOL ret=NO;
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    if(DB)
    {
        NSString *mid=[aryInfo objectAtIndex:0];
        NSNumber *iMID=[NSNumber numberWithInt:[mid intValue]];
        
        NSString *targetValue=[aryInfo objectAtIndex:1];

        
        NSString *ttime=[aryInfo objectAtIndex:2];
        NSNumber *iUpdate=[NSNumber numberWithInt:1];
        
        NSNumber *iDelete=[NSNumber numberWithInt:0];
        NSString *ctime=[aryInfo objectAtIndex:5];
        NSNumber *ifinish=[NSNumber numberWithInt:0];
        NSString *tfinishtime=[aryInfo objectAtIndex:7];
        //NSString *ttype=[aryInfo objectAtIndex:8];
        //NSNumber *iType=[NSNumber numberWithInt:[ttype intValue]];
        
        NSString *updateTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
        NSString *memberType=[aryInfo objectAtIndex:9];
        //NSNumber *iMemberType=[NSNumber numberWithInt:[memberType intValue]];
        NSString *targetType=[aryInfo objectAtIndex:10];
        
        ret=[DB executeUpdate:@"INSERT INTO g_target (m_id,target_value,t_time,t_update,t_delete,c_time,t_finish,t_finishtime,target_type,update_time) values (?,?,?,?,?,?,?,?,?,?)",iMID,targetValue,ttime,iUpdate,iDelete,ctime,ifinish,tfinishtime,targetType,updateTime];
    }
    [DB close];
    return ret;
}

-(BOOL)updateTarget:(NSArray *)aryInfo
{
    if(aryInfo==nil || aryInfo.count < 9)
    {
        return NO;
    }
    BOOL ret=NO;
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    if(DB)
    {
        NSString *tid=[aryInfo objectAtIndex:0];
        NSNumber *iID=[NSNumber numberWithInt:[tid intValue]];
        NSString *mid=[aryInfo objectAtIndex:1];
        NSNumber *iMID=[NSNumber numberWithInt:[mid intValue]];
        
        NSString *targetvalue=[aryInfo objectAtIndex:2];

        
        NSString *ttime=[aryInfo objectAtIndex:3];
        NSNumber *iUpdate=[NSNumber numberWithInt:1];
        
        NSNumber *iDelete=[NSNumber numberWithInt:0];
        NSString *ctime=[aryInfo objectAtIndex:6];
        NSNumber *ifinish=[NSNumber numberWithInt:0];
        NSString *tfinishtime=[aryInfo objectAtIndex:8];
        NSString *ttype=[aryInfo objectAtIndex:9];
        
        NSString *updateTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
        
        NSString *targetType=[aryInfo objectAtIndex:10];
        
        ret=[DB executeUpdate:@"update g_target set m_id=?,target_value=?,t_time=?,t_update=?,t_delete=?,t_finish=?,t_finishtime=?,update_time=? where c_time=? and target_type=?",iMID,targetvalue,ttime,iUpdate,iDelete,ifinish,tfinishtime,updateTime,ctime,targetType];
    }
    [DB close];
    return ret;
}

-(NSArray *)selectDownloadTimeWithUID:(NSString *)uid
{
    if(uid.length<1)
    {
        return nil;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    FMResultSet *rs=[DB executeQuery:@"SELECT * FROM guser_downloadtime where u_id=?",uid];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *weight=[rs stringForColumn:@"weight_downloadtime"];
        NSString *target=[rs stringForColumn:@"target_downloadtime"];
        NSString *step=[rs stringForColumn:@"step_downloadtime"];
        if(weight == nil) weight=@"0";
        if(target == nil) target=@"0";
        if(step == nil) step=@"0";
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:weight,
                         target,
                         step,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectAllStepWithCTime:(NSString *)ctime
{
    if(ctime == nil)
    {
        return nil;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    
    [self connectToDb];
    FMResultSet *rs=[DB executeQuery:@"SELECT * FROM m_step where c_time=? and m_delete=0 order by m_time desc",ctime];
    
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    NSMutableDictionary *dicTimeData=[[NSMutableDictionary alloc] init];
    NSMutableArray *aryTime=[[NSMutableArray alloc] init];
    while([rs next])
    {
        //NSMutableDictionary *dicTemp=[[NSMutableDictionary alloc] init];
        NSMutableArray *aryTemp=[[NSMutableArray alloc] init];
        
        NSString *myid=[rs stringForColumn:@"id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *step=[rs stringForColumn:@"step"];
        NSString *calorie=[rs stringForColumn:@"calorie"];
        NSString *journey=[rs stringForColumn:@"journey"];
        NSString *timeStart=[rs stringForColumn:@"time_start"];
        NSString *timeEnd=[rs stringForColumn:@"time_end"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *myresult=@"";
        NSString *updateTime=[rs stringForColumn:@"update_time"];
        NSString *memberType=[rs stringForColumn:@"member_type"];
        
        if(time == nil || time.length < 10)
        {
            continue;
        }
        
        NSString *date=[time substringToIndex:10];
        if([aryTime containsObject:date])
        {
            aryTemp=[dicTimeData valueForKey:date];
            NSString *strStep=[aryTemp objectAtIndex:3];
            NSString *strStepNew=[NSString stringWithFormat:@"%d",[strStep intValue]+[step intValue]];
            [aryTemp replaceObjectAtIndex:3 withObject:strStepNew];
            
            /*
            dicTemp=[dicTimeData valueForKey:date];
            NSString *strStep=[dicTemp valueForKey:@"step"];
            
            NSString *strStepNew=[NSString stringWithFormat:@"%d",[strStep intValue]+[step intValue]];
            [dicTemp setObject:strStepNew forKey:@"step"];
             */
        }
        else
        {
            /*
            [dicTemp setObject:myid forKey:@"tid"];
            [dicTemp setObject:mid forKey:@"mid"];
            [dicTemp setObject:time forKey:@"time"];
            [dicTemp setObject:step forKey:@"step"];
            [dicTemp setObject:ctime forKey:@"ctime"];
            [dicTemp setObject:myupdate forKey:@"myupdate"];
            [dicTemp setObject:mydelete forKey:@"mydelete"];
            [dicTemp setObject:myresult forKey:@"myresult"];
            [dicTemp setObject:updateTime forKey:@"updateTime"];
            [dicTemp setObject:memberType forKey:@"memberType"];
            */
            NSMutableArray *tmpAry=[[NSMutableArray alloc] initWithObjects:myid,
                             mid,
                             time,
                             step,
                             ctime,
                             myupdate,
                             mydelete,
                             myresult,
                             updateTime,
                             memberType,nil];
            
            [aryTime addObject:date];
            [dicTimeData setObject:tmpAry forKey:date];
        }
        
        /*
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,
                         mid,
                         time,
                         step,
                         calorie,
                         journey,
                         timeStart,
                         timeEnd,
                         ctime,
                         myupdate,
                         mydelete,
                         myresult,
                         updateTime,
                         memberType,nil];
        [muArray addObject:tmpAry];
         */
    }
    
    for(NSInteger i=0;i<aryTime.count;i++)
    {
        NSMutableArray *aryTemp=[dicTimeData valueForKey:[aryTime objectAtIndex:i]];
        if(aryTemp)
        {
            [muArray addObject:aryTemp];
        }
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(BOOL)finishUploadMeasureDataWithCTime:(NSString *)ctime andID:(NSString *)strID
{
    if(ctime.length<1)
    {
        return NO;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"update m_weight set m_update=0 where c_time=%@ and m_update=1",ctime];
    BOOL ret=[DB executeUpdate:strSQL];
    
    [DB close];
    return ret;
}

-(BOOL)finishUploadStepDataWithCTime:(NSString *)ctime andID:(NSString *)strID
{
    if(ctime.length<1)
    {
        return NO;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"update m_step set m_update=0 where c_time=%@ and m_update=1",ctime];
    BOOL ret=[DB executeUpdate:strSQL];
    
    [DB close];
    return ret;
}

-(BOOL)finishUploadTargetDataWithCTime:(NSString *)ctime andID:(NSString *)strID
{
    if(ctime.length<1)
    {
        return NO;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"update g_target set t_update=0 where c_time=%@ and t_update=1",ctime];
    BOOL ret=[DB executeUpdate:strSQL];

    [DB close];
    return ret;
}

-(NSArray *)selectAllUploadTargetDataWithCTime:(NSString *)ctime
{
    if(ctime.length<1)
    {
        return nil;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"SELECT * FROM g_target where c_time=%@ and t_update=1  order by t_id desc",ctime];
    FMResultSet *rs=[DB executeQuery:strSQL];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"t_id"];
        NSString *mid=@"";
        NSString *mtime=[rs stringForColumn:@"t_time"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *targetValue=[rs stringForColumn:@"target_value"];
        NSString *targetType=[rs stringForColumn:@"target_type"];
        NSString *mydelete=[rs stringForColumn:@"t_delete"];
        NSString *mupdate=[rs stringForColumn:@"t_update"];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,mid,mtime,targetValue,targetType,ctime,mydelete,mupdate,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectAllUploadStepDataWithCTime:(NSString *)ctime
{
    if(ctime.length<1)
    {
        return nil;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"SELECT * FROM m_step where c_time=%@ and m_update=1  order by id desc",ctime];
    FMResultSet *rs=[DB executeQuery:strSQL];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        NSString *mid=@"";
        NSString *mtime=[rs stringForColumn:@"m_time"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *step=[rs stringForColumn:@"step"];
        NSString *starttime=[rs stringForColumn:@"time_start"];
        NSString *enttime=[rs stringForColumn:@"time_end"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *mupdate=[rs stringForColumn:@"m_update"];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,mid,mtime,step,starttime,enttime,ctime,mydelete,mupdate,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

- (NSArray *)selectAllUploadMeasureDataWithCTime:(NSString *)ctime
{
    if(ctime.length<1)
    {
        return nil;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSString *strSQL=[NSString stringWithFormat:@"SELECT * FROM m_weight where c_time=%@ and m_update=1  order by id desc",ctime];
    FMResultSet *rs=[DB executeQuery:strSQL];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        //NSString *mid=[rs stringForColumn:@"m_id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *weight=[rs stringForColumn:@"weight"];
        NSString *fat=[rs stringForColumn:@"fat"];
        NSString *muscle=[rs stringForColumn:@"muscle"];
        NSString *water=[rs stringForColumn:@"water"];
        NSString *bone=[rs stringForColumn:@"bone"];
        NSString *basic=[rs stringForColumn:@"basic"];
        NSString *bmi=[rs stringForColumn:@"bmi"];
        NSString *visceralfat=[rs stringForColumn:@"visceralfat"];
        NSString *bodyage=[rs stringForColumn:@"bodyage"];
        NSString *height=[rs stringForColumn:@"height"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *device=[rs stringForColumn:@"device_type"];
        //NSString *myresult=[rs stringForColumn:@"m_result"];
        
        if(weight == nil) weight=@"0.0";
        if(fat == nil) fat=@"0.0";
        if(muscle == nil) muscle=@"0.0";
        if(water == nil) water=@"0.0";
        if(bone == nil) bone=@"0.0";
        if(basic == nil) basic=@"0.0";
        if(bmi == nil) bmi=@"0.0";
        if(visceralfat == nil) visceralfat=@"0.0";
        if(bodyage == nil) bodyage=@"0.0";
        if(height == nil) height=@"0.0";
        if(device == nil) device=@"";
        
        //weight = [NSString stringWithFormat:@"%.2f",[weight floatValue]];
        
        NSMutableDictionary *dicData=[[NSMutableDictionary alloc] init];
        [dicData setObject:weight forKey:ProjectWeight];
        [dicData setObject:fat forKey:ProjectFat];
        [dicData setObject:muscle forKey:ProjectMuscle];
        [dicData setObject:water forKey:ProjectWater];
        [dicData setObject:bone forKey:ProjectBone];
        [dicData setObject:basic forKey:ProjectBasic];
        [dicData setObject:bmi forKey:ProjectBMI];
        [dicData setObject:visceralfat forKey:ProjectVisceralFat];
        [dicData setObject:bodyage forKey:ProjectBodyAge];
        [dicData setObject:height forKey:ProjectHeight];
        
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,mid,time,dicData,ctime,myupdate,mydelete,device,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

//查询所有体重数据
- (NSArray *)selectAllWeightWithCTime:(NSString *)ctime
{
    if(ctime == nil)
    {
        return nil;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    
    
    [self connectToDb];
    FMResultSet *rs=[DB executeQuery:@"SELECT * FROM m_weight where c_time=? and m_delete=? order by m_time desc",ctime,[NSNumber numberWithInt:0]];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *myid=[rs stringForColumn:@"id"];
        NSString *mid=@"";
        NSString *time=[rs stringForColumn:@"m_time"];
        NSString *weight=[rs stringForColumn:@"weight"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *myupdate=[rs stringForColumn:@"m_update"];
        NSString *mydelete=[rs stringForColumn:@"m_delete"];
        NSString *myresult=[rs stringForColumn:@"m_result"];
        NSString *updateTime=[rs stringForColumn:@"update_time"];
        NSString *memberType=[rs stringForColumn:@"member_type"];
        
        //weight = [NSString stringWithFormat:@"%.2f",[weight floatValue]];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:myid,
                         mid,
                         time,
                         weight,
                         ctime,
                         myupdate,
                         mydelete,
                         myresult,
                         updateTime,
                         memberType,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(BOOL)deleteStepWithCTime:(NSString *)ctime andDate:(NSString *)strDate
{
    if(ctime.length<1 || strDate.length<10)
    {
        return NO;
    }
    if (![DB open])
    {
        [self connectToDb];
    }
    
    if(!DB)
    {
        return NO;
    }
    
    BOOL ret;
    
    NSString *startDate=[[strDate substringWithRange:NSMakeRange(0, 10)] stringByAppendingString:@" 00:00:00"];
    NSString *endDate=[[strDate substringWithRange:NSMakeRange(0, 10)] stringByAppendingString:@" 23:59:59"];
    
    NSString *strSQL=[NSString stringWithFormat:@"update m_step set m_delete=1 where c_time=%@ and m_time>='%@' and m_time <='%@'",ctime,startDate,endDate];
    
    ret=[DB executeUpdate:strSQL];

    
    return ret;
}

-(BOOL)deleteWeight:(NSString *)weightID
{
    if(weightID.length<1)
    {
        return NO;
    }
    if (![DB open])
    {
        [self connectToDb];
    }
    
    if(!DB)
    {
        return NO;
    }
    
    BOOL ret;

    ret=[DB executeUpdate:@"update m_weight set m_delete=1 where id=?",weightID];
    
    return ret;
}

-(BOOL)insertDownloadTime:(NSString *)downloadTime andType:(NSString *)type
{
    if(downloadTime.length<1 || type.length<1)
    {
        return NO;
    }
    
    if (![DB open])
    {
        [self connectToDb];
    }
    
    if(!DB)
    {
        return NO;
    }
    
    BOOL ret;
    

    NSString *ctime=[AppDelegate shareUserInfo].account_ctime;
    NSString *uid=[[NSUserDefaults standardUserDefaults] valueForKey:@"u_id"];
    if(uid.length<1)
    {
        uid=@"";
    }
    bool isExist = NO;
    FMResultSet *rs = [DB executeQuery:@"select u_id from guser_downloadtime where u_id=?",uid];
    
    while([rs next])
    {
        NSString *value=[rs stringForColumn:@"u_id"];
        if(value != nil)
        {
            isExist = YES;
        }
        else
        {
            isExist = NO;
        }
    }
    
    NSString *strSQL=@"";
    if(!isExist)
    {
        strSQL=[NSString stringWithFormat:@"insert into guser_downloadtime (u_id,c_time,%@) values (%@,%@,%@)",type,uid,ctime,downloadTime];
    }
    else
    {
        strSQL=[NSString stringWithFormat:@"update guser_downloadtime set  %@=%@ where u_id=%@",type,downloadTime,uid];
        ret=YES;
    }
    
    ret=[DB executeUpdate:strSQL];
    return ret;
}

-(BOOL)insertStepInfo:(NSArray *)aryInfo
{
    if(aryInfo == nil || aryInfo.count<6)
    {
        return NO;
    }
    
    if (![DB open])
    {
        [self connectToDb];
    }
    
    if(!DB)
    {
        return NO;
    }
    
    BOOL ret;
    
    NSString *time=[aryInfo objectAtIndex:0];
    NSDictionary *dicStep=[aryInfo objectAtIndex:1];
    
    NSString *stepcount=[dicStep valueForKey:ProjectStepCount];
    NSString *calorie=[dicStep valueForKey:ProjectStepCalorie];
    NSString *journey=[dicStep valueForKey:ProjectStepJourney];
    NSString *starttime=[dicStep valueForKey:ProjectStepStartTime];
    NSString *endtime=[dicStep valueForKey:ProjectStepEndTime];

    NSString *mid=[aryInfo objectAtIndex:2];
    int imid=[mid intValue];
    
    NSString *ctime=[aryInfo objectAtIndex:3];
    NSString *mtype=[aryInfo objectAtIndex:4];
    NSNumber *iType=[NSNumber numberWithInt:[mtype intValue]];
    
    NSString *memberType=[aryInfo objectAtIndex:7];
    NSNumber *iMemberType=[NSNumber numberWithInt:[memberType intValue]];
    
    NSString *updateTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
    
    NSString *delete=@"0";
    
    bool isExist = NO;
    FMResultSet *rs = [DB executeQuery:@"select c_time from m_step where c_time=? and m_time=?",ctime,time];
    
    while([rs next])
    {
        NSString *c_time=[rs stringForColumn:@"c_time"];
        if(c_time != nil)
        {
            isExist = YES;
        }
        else
        {
            isExist = NO;
        }
    }
    
   // ret=[DB executeUpdate:@"CREATE TABLE m_step (id integer PRIMARY KEY AUTOINCREMENT  NOT NULL,m_id integer,step int,calorie int,journey double,time_start varchar(30),time_end varchar(30),m_time varchar(30),m_update int,m_delete int,c_time varchar(30),m_type int,update_time varchar(30),member_type int)"];
    
    if(!isExist)
    {
       ret=[DB executeUpdate:@"INSERT INTO m_step (m_id,m_time,c_time,m_update,m_delete,m_type,update_time,member_type,step,calorie,journey,time_start,time_end) values (?,?,?,?,?,?,?,?,?,?,?,?,?)",[NSNumber numberWithInt:imid],time,ctime,[NSNumber numberWithInt:1],delete,iType,updateTime,iMemberType,stepcount,calorie,journey,starttime,endtime];
    }
    else
    {
        ret=[DB executeUpdate:@"update m_step set m_delete=0 where c_time=? and m_time=?",ctime,time];
        ret=YES;
    }
    
    return ret;
}

//保存体重数据
-(BOOL)insertMeasureData:(NSArray *)ary
{
    if(ary == nil || ary.count<7)
    {
        return NO;
    }
    BOOL ret=NO;
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    if(DB)
    {
        NSString *time=[ary objectAtIndex:0];
        NSDictionary *dicWeight=[ary objectAtIndex:1];
        
        NSString *weight=[dicWeight valueForKey:ProjectWeight];
        NSString *fat=[dicWeight valueForKey:ProjectFat];
        NSString *muscle=[dicWeight valueForKey:ProjectMuscle];
        NSString *water=[dicWeight valueForKey:ProjectWater];
        NSString *basic=[dicWeight valueForKey:ProjectBasic];
        NSString *bone=[dicWeight valueForKey:ProjectBone];
        NSString *bmi=[dicWeight valueForKey:ProjectBMI];
        NSString *visceralfat=[dicWeight valueForKey:ProjectVisceralFat];
        NSString *bodyage=[dicWeight valueForKey:ProjectBodyAge];
        NSString *height=[dicWeight valueForKey:ProjectHeight];
        
        NSString *mid=[ary objectAtIndex:2];
        int imid=[mid intValue];
        
        NSString *ctime=[ary objectAtIndex:3];
        NSString *mtype=[ary objectAtIndex:4];
        NSNumber *iType=[NSNumber numberWithInt:[mtype intValue]];
        
        NSString *memberType=[ary objectAtIndex:7];
        NSNumber *iMemberType=[NSNumber numberWithInt:[memberType intValue]];
        NSString *deviceType=[ary objectAtIndex:8];
        
        NSString *updateTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
        
        FMResultSet *rs = [DB executeQuery:@"select c_time from m_weight where c_time=? and m_time=?",ctime,time];
        BOOL isExist=NO;
        while([rs next])
        {
            NSString *_ctime=[rs stringForColumn:@"c_time"];
            if(_ctime!=nil)
            {
                isExist = YES;
            }
        }
        
        if(isExist)
        {
            ret=[DB executeUpdate:@"update m_weight set weight=?,fat=?,muscle=?,water=?,basic=?,bone=?,bmi=?,visceralfat=?,bodyage=?,height=?,device_type=?,bodyage=?,height=?  where c_time=? and m_time=?",weight,fat,muscle,water,basic,bone,bmi,visceralfat,bodyage,height,deviceType,bodyage,height,ctime,time];
        }
        else
        {
            ret=[DB executeUpdate:@"INSERT INTO m_weight (m_id,m_time,weight,c_time,m_update,m_delete,m_type,update_time,member_type,fat,muscle,water,basic,bone,bmi,visceralfat,device_type,bodyage,height) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",[NSNumber numberWithInt:imid],time,weight,ctime,[NSNumber numberWithInt:1],[NSNumber numberWithInt:0],iType,updateTime,iMemberType,fat,muscle,water,basic,bone,bmi,visceralfat,deviceType,bodyage,height];
        }
        
        
        
    }
    [DB close];
    return ret;
}


-(BOOL)updateUploadMeasureDataWithCTime:(NSArray *)aryCTime
{
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];

    BOOL ret=NO;
    if(aryCTime && [aryCTime count]>=1)
    {
        for(int i=0;i<aryCTime.count;i++)
        {
            if(![DB open])
            {
                [self connectToDb];
            }
            
            NSString *ctime=[aryCTime objectAtIndex:i];
            ret=[DB executeUpdate:@"update m_weight set m_update=0 where c_time=?",ctime];
        }
    }
    
    [DB close];
    return ret;
}

-(BOOL)updateUploadMeasureDataWithUID:(NSString *)uid
{
    
    NSArray *aryCTime=[self selectMemberCtimeWithUID:uid];
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    BOOL ret=NO;
    if(aryCTime && [aryCTime count]>=1)
    {
        for(int i=0;i<aryCTime.count;i++)
        {
            if(![DB open])
            {
                [self connectToDb];
            }
            
            NSString *ctime=[aryCTime objectAtIndex:i];
            ret=[DB executeUpdate:@"update m_weight set m_update=0 where c_time=?",ctime];
        }
    }
    
    [DB close];
    return ret;
    
}


-(NSArray *)selectMemberCtimeWithUID:(NSString *)uid
{
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    FMResultSet *rs;
    
    NSNumber *iUID=[NSNumber numberWithInt:[uid intValue]];
    
    rs=[DB executeQuery:@"SELECT c_time,gm_id from member where u_id=?",iUID];
    
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *gmid=[rs stringForColumn:@"gm_id"];
        NSArray *aryMember=[[NSArray alloc] initWithObjects:ctime,gmid, nil];
        [muArray addObject:aryMember];
    }

    [rs close];
    [DB close];
    return muArray;
}

-(NSString *)selectGMIDWithCTime:(NSString *)ctime
{
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    FMResultSet *rs;

    rs=[DB executeQuery:@"select gm_id from member where c_time=?",ctime];
    
    while([rs next])
    {
        NSString *gmid=[rs stringForColumn:@"gm_id"];
        if(gmid) return gmid;
    }

    [rs close];
    [DB close];
    return nil;
}



//查询所有此账号下所有未更新的用户信息
-(NSArray *)selectAllUploadMemberWithMID:(NSString *)uid
{
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    FMResultSet *rs;
    
    NSNumber *iUID=[NSNumber numberWithInt:[uid intValue]];
    
    rs=[DB executeQuery:@"SELECT * FROM member where u_id=? and m_update=1",iUID];
    
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *nickname=[rs stringForColumn:@"m_nickname"];
        NSString *pregnancy=[rs stringForColumn:@"m_pregnancy"];
        NSString *bmi=[rs stringForColumn:@"m_bmi"];
        NSString *height=[rs stringForColumn:@"m_height"];
        NSString *weight=[rs stringForColumn:@"m_weight"];
        
        NSString *birthday=[rs stringForColumn:@"m_birthday"];
        NSString *sex=[rs stringForColumn:@"m_sex"];
        NSString *type=[rs stringForColumn:@"m_type"];
        
        NSString *photoPath=[rs stringForColumn:@"m_photo"];
        NSString *photoUpdate=[rs stringForColumn:@"photo_update"];
        NSString *operation=@"0";
        NSString *mdelete=[rs stringForColumn:@"m_delete"];
        NSString *mid=[rs stringForColumn:@"m_id"];
        if(mid == nil)
        {
            mid=@"";
        }
        NSString *uid=[rs stringForColumn:@"u_id"];
        NSString *gmid=[rs stringForColumn:@"gm_id"];
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:ctime,nickname,pregnancy,bmi,height,weight,birthday,sex,type,photoPath,photoUpdate,operation,mdelete,mid,uid,gmid,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}


//查询未上传的用户
-(NSArray *)selectUploadMemberWithMID:(NSString *)mid
{
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    FMResultSet *rs;

    NSNumber *iMid=[NSNumber numberWithInt:[mid intValue]];
    

    rs=[DB executeQuery:@"SELECT * FROM member where u_id=? and m_update=1",iMid];
    

    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *nickname=[rs stringForColumn:@"m_nickname"];
        NSString *pregnancy=[rs stringForColumn:@"m_pregnancy"];
        NSString *bmi=[rs stringForColumn:@"m_bmi"];
        NSString *height=[rs stringForColumn:@"m_height"];
        NSString *weight=[rs stringForColumn:@"m_weight"];
        
        NSString *birthday=[rs stringForColumn:@"m_birthday"];
        NSString *sex=[rs stringForColumn:@"m_sex"];
        NSString *type=[rs stringForColumn:@"m_type"];
    
        NSString *photoPath=[rs stringForColumn:@"m_photo"];
        NSString *photoUpdate=[rs stringForColumn:@"photo_update"];
        NSString *operation=@"0";
        NSString *mdelete=[rs stringForColumn:@"m_delete"];
        NSString *mid=[rs stringForColumn:@"m_id"];
        if(mid == nil)
        {
            mid=@"";
        }
        NSString *uid=[rs stringForColumn:@"u_id"];
        NSString *gmid=[rs stringForColumn:@"gm_id"];
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:ctime,nickname,pregnancy,bmi,height,weight,birthday,sex,type,photoPath,photoUpdate,operation,mdelete,mid,uid,gmid,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

-(NSArray *)selectMember:(NSString *)ctime
{
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    FMResultSet *rs;

    rs=[DB executeQuery:@"SELECT * FROM member where c_time=? and m_delete=0",ctime];
    
    
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    
    while([rs next])
    {
        NSString *mid=[rs stringForColumn:@"m_id"];
        if(mid == nil)
        {
            mid=@"";
        }
        NSString *nickname=[rs stringForColumn:@"m_nickname"];
        NSString *photoPath=[rs stringForColumn:@"m_photo"];
        NSString *pregnancy=[rs stringForColumn:@"m_pregnancy"];
        NSString *bmi=[rs stringForColumn:@"m_bmi"];
        NSString *weight=[rs stringForColumn:@"m_weight"];
        NSString *height=[rs stringForColumn:@"m_height"];
        NSString *birthday=[rs stringForColumn:@"m_birthday"];
        NSString *sex=[rs stringForColumn:@"m_sex"];
        NSString *type=[rs stringForColumn:@"m_type"];
        NSString *ctime=[rs stringForColumn:@"c_time"];
        NSString *mupdate=[rs stringForColumn:@"m_update"];
        NSString *gmid=[rs stringForColumn:@"gm_id"];
        NSString *uid=[rs stringForColumn:@"u_id"];
        NSString *photoUpdate=[rs stringForColumn:@"photo_update"];
        NSString *update_time=[rs stringForColumn:@"update_time"];
        NSString *memberType=[rs stringForColumn:@"member_type"];
        
        NSArray *tmpAry=[[NSArray alloc] initWithObjects:mid,
                         nickname,
                         photoPath,
                         pregnancy,
                         bmi,
                         weight,
                         height,
                         birthday,
                         sex,
                         type,
                         ctime,
                         mupdate,
                         gmid,
                         uid,
                         photoUpdate,
                         update_time,
                         memberType,nil];
        [muArray addObject:tmpAry];
    }
    NSArray *retAry;
    retAry=muArray;
    [rs close];
    [DB close];
    return retAry;
}

- (BOOL)insertMember:(NSArray *)aryInfo
{
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    if(DB)
    {
        NSString *nickname=[aryInfo objectAtIndex:0];  //1
        NSString *photopath=[aryInfo objectAtIndex:1]; //2
        NSString *pregnancy=[aryInfo objectAtIndex:2]; //3
        
        NSString *strBmi=[aryInfo objectAtIndex:3];
        NSNumber *dBmi=[NSNumber numberWithDouble:[strBmi doubleValue]]; //4
        
        NSString *strWeight=[aryInfo objectAtIndex:4];
        NSNumber *dWeight=[NSNumber numberWithDouble:[strWeight doubleValue]]; //5
        
        NSString *strHeight=[aryInfo objectAtIndex:5];
        NSNumber *dHeight=[NSNumber numberWithDouble:[strHeight doubleValue]]; //6
        
        NSString *birthday=[aryInfo objectAtIndex:6]; //7
        
        NSString *sex=[aryInfo objectAtIndex:7];  //8
        
        NSString *strType=[aryInfo objectAtIndex:8];  //9
        NSNumber *iType=[NSNumber numberWithInt:[strType intValue]];
        
        NSString *ctime=ctime=[aryInfo objectAtIndex:9];
        
        NSString *strUpdate=[aryInfo objectAtIndex:10];
        NSNumber *iUpdate=[NSNumber numberWithInt:[strUpdate intValue]];  //
        
        NSString *strDelete=[aryInfo objectAtIndex:11];
        NSNumber *iDelete=[NSNumber numberWithInt:[strDelete intValue]];  //
        
        NSString *strUID=[aryInfo objectAtIndex:12];
        NSNumber *iUID=[NSNumber numberWithInt:[strUID intValue]];  //
        
        NSString *strGMID=[aryInfo objectAtIndex:13];
        NSNumber *iGMID=[NSNumber numberWithInt:[strGMID intValue]];  //
        
        NSString *photoUpdate=[aryInfo objectAtIndex:14];
        NSNumber *iPhotoUpdate=[NSNumber numberWithInt:[photoUpdate intValue]];

        NSString *updateTime=[aryInfo objectAtIndex:15];
        
        NSString *memberType=[aryInfo objectAtIndex:16];
        NSNumber *iMemberType=[NSNumber numberWithInt:[memberType intValue]];
        
        NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
        NSString *uid=[ud objectForKey:@"u_id"];
        if(uid)
        {
            iUID=[NSNumber numberWithInt:[uid intValue]];
        }
        BOOL ret=[DB executeUpdate:@"INSERT INTO member (m_nickname,m_photo,m_pregnancy,m_bmi,m_weight,m_height,m_birthday,m_sex,m_type,m_update,c_time,m_delete,u_id,gm_id,photo_update,update_time,member_type) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",nickname,photopath,pregnancy,dBmi,dWeight,dHeight,birthday,sex,iType,iUpdate,ctime,iDelete,iUID,iGMID,iPhotoUpdate,updateTime,iMemberType];
        
        if([memberType intValue] == 1)
        {
            NSString *nowtime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
            [self insertMemberUpdateWithCTime:ctime andTime:nowtime andGMID:@"-1"];
        }
        [DB close];
        return ret;
    }
    else
    {
        [DB close];
        return NO;
    }
}


//查询账号信息
-(NSArray *)selectUserWithUName:(NSString *)uname
{
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    if(DB)
    {
        FMResultSet *rs;
        
        rs=[DB executeQuery:@"SELECT * FROM user where u_name=?",uname];
    
        while([rs next])
        {
            NSString *uid=[rs stringForColumn:@"u_id"];
            NSString *uname=[rs stringForColumn:@"u_name"];
            NSString *upwd=[rs stringForColumn:@"u_password"];
            NSString *downloadtime=[rs stringForColumn:@"download_time"];
            NSString *umember=[rs stringForColumn:@"u_member"];
            
            NSArray *tmpAry=[[NSArray alloc] initWithObjects:uid,uname,upwd,downloadtime,umember,nil];
            [muArray addObject:tmpAry];
        }
        [rs close];
    }
    [DB close];
    return muArray;
}

-(BOOL)insertUser:(NSArray *)aryInfo
{
    if(aryInfo == nil || aryInfo.count<4)
    {
        return NO;
    }

    NSString *uid=[aryInfo objectAtIndex:0];  //1
    NSNumber *iUID=[NSNumber numberWithInt:[uid intValue]];
        
    NSString *uname=[aryInfo objectAtIndex:1]; //2
    NSString *upwd=[aryInfo objectAtIndex:2]; //3
    NSString *downloadtime=[aryInfo objectAtIndex:3];
        
    NSString *utype=[aryInfo objectAtIndex:4];
    NSNumber *iType=[NSNumber numberWithInt:[utype intValue]];
        
    NSArray *aryUSerInfo=[self selectUserWithUName:uname];
        
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
        
    if(DB)
    {
        BOOL ret=NO;
        if(aryUSerInfo!=nil && [aryUSerInfo count]>=1)
        {
            ret=[DB executeUpdate:@"update  user set u_name=?,u_password=?,u_type=?,u_id=? where u_name=?",uname,upwd,iType,iUID,uname];
        }
        else
        {
            ret=[DB executeUpdate:@"INSERT INTO user (u_id,u_name,u_password,download_time,u_type,u_member,update_time,measure_download_time) values (?,?,?,?,?,?,?,?)",iUID,uname,upwd,@"1900-01-01 00:00:00",iType,@"",@"1900-01-01 00:00:00",@"1900-01-01 00:00:00"];
        }
        [DB close];
        return ret;
    }
    else
    {
        [DB close];
        return NO;
    }
}

-(BOOL)insertDownloadWeightWithAry:(NSArray *)aryInfo andCTime:(NSString *)ctime
{
    BOOL ret;
    if(aryInfo == nil || [aryInfo count]<1 || ctime.length<1)
    {
        return NO;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    [DB beginTransaction];
    @try
    {
        NSString *updateTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
        NSNumber *iMemberType=[NSNumber numberWithInt:1];
        
        
        if(aryInfo && [aryInfo count]>=1)
        {
            for(int i=0;i<[aryInfo count];i++)
            {
                NSDictionary *dictTemp=[aryInfo objectAtIndex:i];
                NSDictionary *dictData=[dictTemp valueForKey:@"data_value"];
                if(dictData == nil || dictData.count<5)
                {
                    continue;
                }
                
                
                NSString *mtime=[dictData valueForKey:@"m_time"];
                
                NSString *weight=[dictData valueForKey:@"weight"];
                double dweight=[weight doubleValue];
                
                NSString *bmi=[dictData valueForKey:@"bmi"];
                double dbmi=[bmi doubleValue];
                
                NSString *basic=[dictData valueForKey:@"bmr"];
                double dbasic=[basic doubleValue];
                
                NSString *bodyage=[dictData valueForKey:@"bodyage"];
                double dbodyage=[bodyage doubleValue];
                
                NSString *bone=[dictData valueForKey:@"bone"];
                double dbone=[bone doubleValue];
                
                NSString *fat=[dictData valueForKey:@"fat"];
                double dfat=[fat doubleValue];
                
                NSString *muscle=[dictData valueForKey:@"muscle"];
                double dmuscle=[muscle doubleValue];
                
                NSString *visceralfat=[dictData valueForKey:@"visceralfat"];
                double dvisceralfat=[visceralfat doubleValue];
                
                NSString *water=[dictData valueForKey:@"water"];
                double dwater=[water doubleValue];
                
                NSString *height=[dictData valueForKey:@"height"];
                double dheight=[height doubleValue];
                
                NSString *delete=[dictData valueForKey:@"is_delete"];
                NSString *device=[dictData valueForKey:@"device_info"];
                
                NSString *iType=@"0";
                
                NSString *iUpdate=@"0";
                
                NSString *result=@"";
                
                NSString *strSQL=@"";
                
                if([self isExistWeightWithCTime:ctime andTime:mtime])
                {
                    if([delete isEqualToString:@"1"])
                    {
                        strSQL=[NSString stringWithFormat:@"update m_weight set m_delete=1 where c_time='%@' and m_time='%@'",ctime,mtime];
                        ret=[DB executeUpdate:strSQL];
                    }
                    else
                    {
                        strSQL=[NSString stringWithFormat:@"update m_weight set weight=%.1f,fat=%.1f,muscle=%.1f,water=%.1f,basic=%.1f,bone=%.1f,bmi=%.1f,visceralfat=%.1f,height=%.1f,bodyage=%.1f,device_type='%@',m_delete=%@,update_time='%@' where c_time='%@' and m_time='%@'",dweight,dfat,dmuscle,dwater,dbasic,dbone,dbmi,dvisceralfat,dheight,dbodyage,device,delete,updateTime,ctime,mtime];
                        ret=[DB executeUpdate:strSQL];
                    }
                    
                }
                else
                {
                    if(![delete isEqualToString:@"1"])
                    {
                        strSQL=[NSString stringWithFormat:@"INSERT INTO m_weight (weight,fat,muscle,water,basic,bone,bmi,visceralfat,height,bodyage,device_type,m_time,m_update,m_result,m_delete,c_time,m_type,update_time,member_type) values (%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,%.1f,'%@','%@',%@,'%@',%@,'%@',%@,'%@',%@)",dweight,dfat,dmuscle,dwater,dbasic,dbone,dbmi,dvisceralfat,dheight,dbodyage,device,mtime,iUpdate,result,delete,ctime,iType,updateTime,iMemberType];
                        ret=[DB executeUpdate:strSQL];
                    }
                    
                }
                
            }
        }

    }
    @catch (NSException *exception)
    {
        [DB rollback];
        NSLog(@"%@",exception);
        [DB close];
        return NO;
    }
    @finally
    {
        [DB commit];
        [DB close];
        return YES;
    }
}

-(BOOL)insertDownloadStepWithAry:(NSArray *)aryInfo andCTime:(NSString *)ctime
{
    BOOL ret;
    if(aryInfo == nil || [aryInfo count]<1 || ctime.length<1)
    {
        return NO;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    [DB beginTransaction];
    @try
    {
        NSString *updateTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
        NSNumber *iMemberType=[NSNumber numberWithInt:1];
        
        
        if(aryInfo && [aryInfo count]>=1)
        {
            for(int i=0;i<[aryInfo count];i++)
            {
                /*
                "data_value" =     {
                    "device_info" = "";
                    "end_time" = "2015-07-29 22:12:48";
                    "is_delete" = 0;
                    "m_time" = "2015-07-29 22:12:48";
                    "measure_id" = 1;
                    "start_time" = "2015-07-29 22:09:41";
                    "step_count" = 203;
                    "u_id" = 2;
                   */
                NSDictionary *dictTemp=[aryInfo objectAtIndex:i];
                NSDictionary *dictData=[dictTemp valueForKey:@"data_value"];
                if(dictData == nil || dictData.count<5)
                {
                    continue;
                }
                
                
                NSString *mtime=[dictData valueForKey:@"m_time"];
                
                NSString *step=[dictData valueForKey:@"step_count"];
                
                NSString *startTime=[dictData valueForKey:@"start_time"];
                
                NSString *endTime=[dictData valueForKey:@"end_time"];
                
                NSString *delete=[dictData valueForKey:@"is_delete"];
                NSString *device=[dictData valueForKey:@"device_info"];
                
                NSString *iType=@"0";
                
                NSString *iUpdate=@"0";
                
                NSString *result=@"";
                
                NSString *strSQL=@"";
                
                if([self isExistStepWithCTime:ctime andTime:mtime])
                {
                    if([delete isEqualToString:@"1"])
                    {
                        strSQL=[NSString stringWithFormat:@"update m_step set m_delete=1,m_update=0 where c_time='%@' and m_time='%@'",ctime,mtime];
                        ret=[DB executeUpdate:strSQL];
                    }
                    else
                    {
                        strSQL=[NSString stringWithFormat:@"update m_step set step=%@,time_start='%@',time_end='%@',m_update=0 where c_time='%@' and m_time='%@'",step,startTime,endTime,ctime,mtime];
                        ret=[DB executeUpdate:strSQL];
                    }
                    
                }
                else
                {
                    if(![delete isEqualToString:@"1"])
                    {
                        strSQL=[NSString stringWithFormat:@"INSERT INTO m_step (step,time_start,time_end,m_time,m_update,m_delete,c_time,m_type,update_time,member_type) values (%@,'%@','%@','%@',%@,%@,'%@',%@,'%@',%@)",step,startTime,endTime,mtime,iUpdate,delete,ctime,iType,updateTime,@"1"];
                        ret=[DB executeUpdate:strSQL];
                    }
                    
                }
                
            }
        }
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"~~~~~~~~~~~添加服务器步数失败~~~~~~~~~~~");
        [DB rollback];
        NSLog(@"%@",exception);
        [DB close];
        return NO;
    }
    @finally
    {
        NSLog(@"~~~~~~~~~~~添加服务器步数成功~~~~~~~~~~~");
        [DB commit];
        [DB close];
        return YES;
    }
}

-(BOOL)insertDownloadTargetWithAry:(NSArray *)aryInfo andCTime:(NSString *)ctime
{
    BOOL ret;
    if(aryInfo == nil || [aryInfo count]<1 || ctime.length<1)
    {
        return NO;
    }
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    [DB beginTransaction];
    @try
    {
        NSString *updateTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
        //NSNumber *iMemberType=[NSNumber numberWithInt:1];
        
        
        if(aryInfo && [aryInfo count]>=1)
        {
            for(int i=0;i<[aryInfo count];i++)
            {
                /*
                "data_value" =     {
                    "is_delete" = 0;
                    "m_time" = "2015-07-29 20:13:36";
                    target = "54.0";
                    "target_id" = 3;
                    type = 0;
                    "u_id" = 2;
                };
                */
                
                NSDictionary *dictTemp=[aryInfo objectAtIndex:i];
                NSDictionary *dictData=[dictTemp valueForKey:@"data_value"];
                if(dictData == nil || dictData.count<5)
                {
                    continue;
                }
                
                
                NSString *mtime=[dictData valueForKey:@"m_time"];
                NSString *targetValue=[dictData valueForKey:@"target"];
                NSString *targetType=[dictData valueForKey:@"type"];
                NSString *delete=[dictData valueForKey:@"is_delete"];
                
                if([targetType isEqualToString:@"0"])
                {
                    targetType=@"1";
                }
                else
                {
                    targetType=@"2";
                }
                
                NSString *uid=[[NSUserDefaults standardUserDefaults] valueForKey:@"u_id"];
                if(uid == nil) uid=@"-1";
                NSString *iUpdate=@"0";
                
                
                NSString *strSQL=@"";
                
                if([self isExisTargetWithCTime:ctime andTime:mtime andType:targetType])
                {
                    if([delete isEqualToString:@"1"])
                    {
                        strSQL=[NSString stringWithFormat:@"update g_target set t_delete=1,t_update=0 where c_time='%@' and t_time='%@' and target_type=%@",ctime,mtime,targetType];
                        ret=[DB executeUpdate:strSQL];
                    }
                    else
                    {
                        strSQL=[NSString stringWithFormat:@"update g_target set target_value=%@,t_delete=%@,update_time='%@',t_update=0 where c_time='%@' and t_time='%@' and target_type=%@",targetValue,delete,updateTime,ctime,mtime,targetType];
                        ret=[DB executeUpdate:strSQL];
                    }
                    
                }
                else
                {
                    if(![delete isEqualToString:@"1"])
                    {
                        strSQL=[NSString stringWithFormat:@"INSERT INTO g_target (m_id,target_value,t_time,t_update,t_delete,c_time,target_type,update_time) values (%@,%@,'%@',%@,%@,'%@',%@,'%@')",uid,targetValue,mtime,iUpdate,delete,ctime,targetType,updateTime];
                        ret=[DB executeUpdate:strSQL];
                    }
                    
                }
                
            }
        }
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"~~~~~~~~~~保存服务器目标失败~~~~~~~~~~~~~");
        [DB rollback];
        NSLog(@"%@",exception);
        [DB close];
        return NO;
    }
    @finally
    {
        NSLog(@"~~~~~~~~~~保存服务器目标成功~~~~~~~~~~~~~");
        [DB commit];
        [DB close];
        return YES;
    }
}

-(NSString *)saveImagesWithImage:(NSData *)imageData withCTime:(NSString *)ctime andTime:(NSString *)time andRect:(CGSize)smallSize
{
    NSString *ret=@"";
    //NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    // 获取沙盒目录
    time=[time stringByReplacingOccurrencesOfString:@" " withString:@""];
    time=[time stringByReplacingOccurrencesOfString:@"-" withString:@""];
    time=[time stringByReplacingOccurrencesOfString:@":" withString:@""];
    NSString *imagePath=[NSString stringWithFormat:@"Image/BabyImage/%@%@.png",ctime,time];
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imagePath];
    // 将图片写入文件
    BOOL result=[imageData writeToFile:fullPath atomically:YES];
    if(result)
    {
        //2014-11-04
        //ret=fullPath;
        ret=imagePath;
    }
    
    UIImage *image=[UIImage imageWithData:imageData];
    //保存小图
    NSString *smallImagePath=[NSString stringWithFormat:@"Image/BabyImage/%@%@_small.png",ctime,time];
    
    CGRect smallCGRect=CGRectMake(0, 0, image.size.width, image.size.width*smallSize.height/smallSize.width);
    UIImage *smallImage=[PublicModule getSubImage:smallCGRect withImage:image];
    NSData *smallImageData=UIImageJPEGRepresentation(smallImage, 0.3);
    NSString *smallFullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:smallImagePath];
    BOOL smallResult=[smallImageData writeToFile:smallFullPath atomically:YES];
    
    
    return ret;
}

- (BOOL)editMember:(NSArray *)aryInfo
{
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    if(DB)
    {
        NSString *nickname=[aryInfo objectAtIndex:0];  //1
        NSString *photopath=[aryInfo objectAtIndex:1]; //2
        NSString *pregnancy=[aryInfo objectAtIndex:2]; //3
        
        NSString *strBmi=[aryInfo objectAtIndex:3];
        NSNumber *dBmi=[NSNumber numberWithDouble:[strBmi doubleValue]]; //4
        
        NSString *strWeight=[aryInfo objectAtIndex:4];
        NSNumber *dWeight=[NSNumber numberWithDouble:[strWeight doubleValue]]; //5
        
        NSString *strHeight=[aryInfo objectAtIndex:5];
        NSNumber *dHeight=[NSNumber numberWithDouble:[strHeight doubleValue]]; //6
        
        NSString *birthday=[aryInfo objectAtIndex:6]; //7
        
        NSString *sex=[aryInfo objectAtIndex:7];  //8
        
        NSString *strType=[aryInfo objectAtIndex:8];
        NSNumber *iType=[NSNumber numberWithInt:[strType intValue]];
        
        NSString *strCTime=[aryInfo objectAtIndex:9];
        
        NSString *strUpdate=[aryInfo objectAtIndex:10];
        NSNumber *iUpdate=[NSNumber numberWithInt:[strUpdate intValue]];  //1代表需要上传到服务器
        
        NSString *strDelete=[aryInfo objectAtIndex:11];
        NSNumber *iDelete=[NSNumber numberWithInt:[strDelete intValue]];  //0代表没有删除
        
        NSString *strUID=[aryInfo objectAtIndex:12];
        NSNumber *iUID=[NSNumber numberWithInt:[strUID intValue]];
        
        NSString *strGMID=[aryInfo objectAtIndex:13];
        NSNumber *iGMID=[NSNumber numberWithInt:[strGMID intValue]];
        
        NSString *strPhotoUpdate=[aryInfo objectAtIndex:14];
        NSNumber *iPhotoUpdate=[NSNumber numberWithInt:[strPhotoUpdate intValue]];  //0代表没有删除

        NSString *memberType=[aryInfo objectAtIndex:15];
        NSNumber *iMemberType=[NSNumber numberWithInt:[memberType intValue]];
        
        NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
        NSString *uid=[ud objectForKey:@"u_id"];
        BOOL ret;
        
        if(uid)
        {
            iUID=[NSNumber numberWithInt:[uid intValue]];
        }

        if([memberType isEqualToString:@"0"])
        {
            NSString *updateTime=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
            ret=[DB executeUpdate:@"update  member set m_nickname=?,m_photo=?,m_pregnancy=?,m_bmi=?,m_weight=?,m_height=?,m_birthday=?,m_sex=?,m_type=?,m_update=?,m_delete=?,photo_update=?,update_time=? where c_time=?",nickname,photopath,pregnancy,dBmi,dWeight,dHeight,birthday,sex,iType,iUpdate,iDelete,iPhotoUpdate,updateTime,strCTime];
        }
        else
        {
            ret=[DB executeUpdate:@"update  member set m_nickname=?,m_photo=?,m_pregnancy=?,m_bmi=?,m_weight=?,m_height=?,m_birthday=?,m_sex=?,m_type=?,m_update=?,m_delete=?,photo_update=? where c_time=?",nickname,photopath,pregnancy,dBmi,dWeight,dHeight,birthday,sex,iType,iUpdate,iDelete,iPhotoUpdate,strCTime];
        }
        
        [DB close];
        return ret;
    }
    else
    {
        [DB close];
        return NO;
    }
    
}

-(NSArray *)selectSettintWithCTime:(NSString *)ctime
{
    if(ctime==nil || [ctime isEqualToString:@""])
    {
        return nil;
    }
    
    if(DB.open)
    {
        [DB close];
        DB=nil;
    }
    [self connectToDb];
    
    NSMutableArray *muArray=[[NSMutableArray alloc] init];
    FMResultSet *rs;
    if(DB)
    {
        
        
        rs=[DB executeQuery:@"SELECT * FROM member_setting where c_time=? order by s_time desc",ctime];
        
        while([rs next])
        {
            /*
             0: 密码id
             1：用户ctime
             2：测量类型
             3：时间
             */
            NSString *pwdID=[rs stringForColumn:@"s_id"];
            NSString *ctime=[rs stringForColumn:@"c_time"];
            NSString *type=[rs stringForColumn:@"measure_type"];
            NSString *time=[rs stringForColumn:@"s_time"];
            
            NSArray *tmpAry=[[NSArray alloc] initWithObjects:ctime,type,time,nil];
            [muArray addObject:tmpAry];
        }
    }
    [DB close];
    [rs close];
    return muArray;
}

-(NSArray *)getCustomProject:(NSString *)ctime
{
    if (![DB open]) {
        [self connectToDb];
    }
    
    FMResultSet *result = [DB executeQuery:@"select * from m_project where c_time=?",ctime];
    
    
    NSString *isset;
    NSString *unset;
    NSString *diary_open;
    
    NSMutableArray *projectArr = [[NSMutableArray alloc] init];
    
    while([result next])
    {
        isset=[result stringForColumn:@"isset"];
        unset=[result stringForColumn:@"unset"];
        diary_open= (NSString *)[result stringForColumn:@"diary_open"];
        
        [projectArr addObject:ctime];
        [projectArr addObject:isset];
        [projectArr addObject:unset];
        [projectArr addObject:diary_open];
        break;
    }
    return projectArr;
    
}

/*
 *  摘要：添加用户自定义菜单
 */
-(BOOL)updateCustomProject:(NSArray *)arrData
{
    NSString *ctime = [arrData objectAtIndex:0];    //用户CTIME
    NSString *isset = [arrData objectAtIndex:1];    //用户设置的项目
    NSString *unset = [arrData objectAtIndex:2];    //用户未设置的项目
    
    NSArray *arySet;
    NSArray *aryUnSet;
    
    if(isset.length>1)
    {
        arySet=[isset componentsSeparatedByString:@","];
    }
    if(unset.length>1)
    {
       aryUnSet=[unset componentsSeparatedByString:@","];
    }
    
    NSMutableArray *aryIsSet=[[NSMutableArray alloc] init];
    
    if(arySet && arySet.count>=1)
    {
        isset=@"";
        for(NSInteger i=0;i<arySet.count;i++)
        {
            NSString *str=[arySet objectAtIndex:i];
            str=[self getPorjectName:str];

            if([aryIsSet containsObject:str])
            {
                continue;
            }
            if(str.length>=1)
            {
                [aryIsSet addObject:str];
                isset=[isset stringByAppendingString:str];
                if(i != arySet.count-1)
                {
                    isset=[isset stringByAppendingString:@","];
                }
            }
        }
    }
    if(aryUnSet && aryUnSet.count>=1)
    {
        unset=@"";
        for(NSInteger i=0;i<aryUnSet.count;i++)
        {
            NSString *str=[aryUnSet objectAtIndex:i];
            
            str=[self getPorjectName:str];
            if([aryIsSet containsObject:str])
            {
                continue;
            }
            if(str.length>=1)
            {
                unset=[unset stringByAppendingString:str];
                if(i != aryUnSet.count-1)
                {
                    unset=[unset stringByAppendingString:@","];
                }
            }
        }
    }
    
    NSString *diary_open = @"0";    //孕妇日记是否开启
    NSNumber *iOpen=[NSNumber numberWithInt:[diary_open intValue]];
    if (![DB open]) {
        [self connectToDb];
    }
    
    bool isExist = NO;
    //判断用户数据是否已存在
    FMResultSet *rs = [DB executeQuery:@"select * from m_project where c_time=?",ctime];
    while([rs next])
    {
        NSString *_set=[rs stringForColumn:@"isset"];
        if(_set!=nil)
        {
            isExist = YES;   //不存在
        }
        else
        {
            isExist = NO;  //已存在
        }
    }
    
    if(isExist)
    {
        //update
        return [DB executeUpdate:@"update m_project set isset=?,unset=?,diary_open=? where c_time=?",isset,unset,iOpen,ctime];
    }
    else
    {
        //insert
        return [DB executeUpdate:@"INSERT INTO m_project (c_time,isset,unset,diary_open) values (?,?,?,?)",ctime,isset,unset,iOpen];
    }
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
            [name isEqualToString:ProjectBasicEnglishName]||
            [name isEqualToString:ProjectBasicGermanName] ||
            [name isEqualToString:ProjectBasicDutchName])
    {
        return ProjectBasicName;
    }
    else if([name isEqualToString:ProjectWaterName] ||
            [name isEqualToString:ProjectWaterEnglishName] ||
            [name isEqualToString:ProjectWaterGermanName] ||
            [name isEqualToString:ProjectWaterDutchName] ||
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

-(BOOL)insertJsonTempWithJson:(NSString *)jsonTemp andType:(NSString *)jsonType andPage:(NSString *)jsonPage andUID:(NSString *)uid
{
    
    NSString *json_time=[PublicModule getTimeNow:@"" withDate:[NSDate date]];
    
    if(uid == nil || uid.length<1)
    {
        uid=[[NSUserDefaults standardUserDefaults] objectForKey:@"u_id"];
    }
    
    if(uid == nil || jsonType == nil || jsonTemp == nil || jsonPage == nil)
    {
        return NO;
    }
    
    if (![DB open]) {
        [self connectToDb];
    }
    
    bool isExist = NO;
    //判断用户数据是否已存在
    FMResultSet *rs = [DB executeQuery:@"select u_id from m_jsontemp where u_id=? and json_type=? and json_page=?",uid,jsonType,jsonPage];
    while([rs next])
    {
        NSString *_set=[rs stringForColumn:@"u_id"];
        if(_set!=nil)
        {
            isExist = YES;
        }
        else
        {
            isExist = NO;
        }
    }
    
    if(isExist)
    {
        //update
        return [DB executeUpdate:@"update m_jsontemp set json_temp=?,json_time=?,json_operation=? where u_id=? and json_type=? and json_page=?",jsonTemp,json_time,jsonType,uid,jsonType,jsonPage];
    }
    else
    {
        //insert
        return [DB executeUpdate:@"INSERT INTO m_jsontemp (u_id,json_type,json_temp,json_time,json_operation,json_page) values (?,?,?,?,?,?)",uid,jsonType,jsonTemp,json_time,jsonType,jsonPage];
    }
}

@end

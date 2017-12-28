#import "NetworkModule.h"
#import "GTMBase64.h"

@implementation NetworkModule

-(id)init
{
    self=[super init];
    if(self)
    {
        _db=[[DbModel alloc] init];
    }
    return self;
}

-(NSString *)jsonUploadLoginMemberWithUID:(NSArray *)aryUser
{
    if(aryUser==nil||[aryUser count]<3)
    {
        return @"";
    }
    NSString* uname=[aryUser objectAtIndex:0];
    NSString *upwd=[aryUser objectAtIndex:1];
    NSString *uid=[aryUser objectAtIndex:2];
    
    NSMutableArray *aryUploadMember=[[NSMutableArray alloc] init];
    
    NSArray  *aryUIDMember=[_db selectAllUploadMemberWithMID:uid];
    for(int i=0;i<aryUIDMember.count;i++)
    {
        [aryUploadMember addObject:[aryUIDMember objectAtIndex:i]];
    }
    
    NSString *strJson=nil;

    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *aeskey=[ud objectForKey:@"u_aeskey"];
    NSString *aesiv=[ud objectForKey:@"u_aesiv"];
    if(aeskey == nil || aesiv == nil || aeskey.length!=16 || aesiv.length!=16)
    {
        return strJson;
    }
    
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    
    if([PublicModule checkNetworkStatus] && [aryUploadMember count]>=1)
    {
        NSMutableArray *aryMemberJson=[[NSMutableArray alloc] init];
        for(int i=0;i<[aryUploadMember count];i++)
        {
            NSArray *aryTemp=[aryUploadMember objectAtIndex:i];
            
            NSString *strImage=@"";
            
            NSString *photoPath=[aryTemp objectAtIndex:9];
            NSString *photoUpdate=[aryTemp objectAtIndex:10];
            if(photoPath != nil && ![photoPath isEqualToString:@""]&&[photoUpdate isEqualToString:@"1"])
            {
                photoPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:photoPath];
                UIImage *imageIcon=[UIImage imageWithContentsOfFile:photoPath];
                NSData *dataPic=UIImageJPEGRepresentation(imageIcon, 0.4);
                strImage=[dataPic base64Encoding];
            }
            NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
            NSString *appid=[ud objectForKey:@"app_id"];
            NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:
                                    [aryTemp objectAtIndex:0],@"c_time",
                                    [aryTemp objectAtIndex:1],@"m_nickname",
                                    [aryTemp objectAtIndex:2],@"m_pregnancy",
                                    [aryTemp objectAtIndex:3],@"m_bmi",
                                    [aryTemp objectAtIndex:4],@"m_height",
                                    [aryTemp objectAtIndex:5],@"m_weight",
                                    [aryTemp objectAtIndex:6],@"m_birthday",
                                    [aryTemp objectAtIndex:7],@"m_sex",
                                    [aryTemp objectAtIndex:8],@"m_type",
                                    strImage,@"m_photo",
                                    [aryTemp objectAtIndex:10],@"photo_update",
                                    [aryTemp objectAtIndex:11],@"operation",
                                    [aryTemp objectAtIndex:12],@"show",
                                    appid,@"app_id",nil];
            [aryMemberJson addObject:dictTemp];
        }
        
        NSString *strMemberJson=[PublicModule DataTOjsonString:aryMemberJson];
        strMemberJson=[PublicModule AES128EncryptWithKey:aeskey andIV:aesiv andText:strMemberJson];
        
        if(strMemberJson == nil)
        {
            return nil;
        }
        
        strJson=[NSString stringWithFormat:@"{\"u_name\":\"%@\",\"u_password\":\"%@\",\"m_id\":\"%@\",\"operation\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"session\":\"%@\",\"data\":\"%@\"}",uname,upwd,uid,Auth_UploadMember,Client_Type,appID,appVer,usession,strMemberJson];
        
    }
    return strJson;
}

-(NSString *)jsonDownloadYunfuDiaryWithGMID:(NSString *)gmid andCTime:(NSString *)ctime
{
    
    NSString *strJson=nil;
    if(gmid == nil || [gmid isEqualToString:@""] || ctime == nil || [ctime isEqualToString:@""])
    {
        return strJson;
    }
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    NSArray *aryUpdateTime=[_db selectMemberUpdateWithCTime:ctime];
    
    if(aryUpdateTime == nil || aryUpdateTime.count<1)
    {
        return nil;
    }
    NSArray *aryTime=[aryUpdateTime objectAtIndex:0];
    if(aryTime == nil || aryTime.count<11)
    {
        return nil;
    }
    NSString *downloadTime=[aryTime objectAtIndex:10];
    strJson=[NSString stringWithFormat:@"{\"u_name\":\"%@\",\"u_password\":\"%@\",\"operation\":\"%@\",\"client_type\":\"%@\",\"m_id\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"session\":\"%@\",\"data\":{\"gm_id\":\"%@\",\"app_id\":\"%@\",\"download_time\":\"%@\"}}",@"",@"",Yunfu_DownloadYunfuDiary,Client_Type,uid,appID,appVer,usession,gmid,appID,downloadTime];
    
    return strJson;
}

-(NSString *)jsonUploadMemberWithUID:(NSArray *)aryUser withType:(NSString *)type
{
    if(aryUser==nil||[aryUser count]<3)
    {
        return @"";
    }
    NSString* uname=[aryUser objectAtIndex:0];
    NSString *upwd=[aryUser objectAtIndex:1];
    NSString *uid=[aryUser objectAtIndex:2];
    
    NSArray *aryUploadMember;
    
    if([type isEqualToString:@"-1"])
    {
       aryUploadMember=[_db selectUploadMemberWithMID:@"-1"];
    }
    else
    {
        aryUploadMember=[_db selectAllUploadMemberWithMID:uid];
    }
   
    NSString *strJson=nil;
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *aeskey=[ud objectForKey:@"u_aeskey"];
    NSString *aesiv=[ud objectForKey:@"u_aesiv"];
    if(aeskey == nil || aesiv == nil || aeskey.length!=16 || aesiv.length!=16)
    {
        return strJson;
    }
    
    if([PublicModule checkNetworkStatus] && [aryUploadMember count]>=1)
    {
        NSMutableArray *aryMemberJson=[[NSMutableArray alloc] init];
        for(int i=0;i<[aryUploadMember count];i++)
        {
            NSArray *aryTemp=[aryUploadMember objectAtIndex:i];
            
            NSString *strImage=@"";
            
            NSString *photoPath=[aryTemp objectAtIndex:9];
            NSString *photoUpdate=[aryTemp objectAtIndex:10];
            if(photoPath != nil && ![photoPath isEqualToString:@""]&&[photoUpdate isEqualToString:@"1"])
            {
                //2014-11-05
                photoPath=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:photoPath];
                UIImage *imageIcon=[UIImage imageWithContentsOfFile:photoPath];
                NSData *dataPic=UIImageJPEGRepresentation(imageIcon, 0.4);
                strImage=[dataPic base64Encoding];
            }
            NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
            NSString *appid=[ud objectForKey:@"app_id"];
            NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:
                                    [aryTemp objectAtIndex:0],@"c_time",
                                    [aryTemp objectAtIndex:1],@"m_nickname",
                                    [aryTemp objectAtIndex:2],@"m_pregnancy",
                                    [aryTemp objectAtIndex:3],@"m_bmi",
                                    [aryTemp objectAtIndex:4],@"m_height",
                                    [aryTemp objectAtIndex:5],@"m_weight",
                                    [aryTemp objectAtIndex:6],@"m_birthday",
                                    [aryTemp objectAtIndex:7],@"m_sex",
                                    [aryTemp objectAtIndex:8],@"m_type",
                                     strImage,@"m_photo",
                                    [aryTemp objectAtIndex:10],@"photo_update",
                                    [aryTemp objectAtIndex:11],@"operation",
                                    [aryTemp objectAtIndex:12],@"show",
                                    appid,@"app_id",nil];
            [aryMemberJson addObject:dictTemp];
        }
        
        NSString *strMemberJson=[PublicModule DataTOjsonString:aryMemberJson];
        strMemberJson=[PublicModule AES128EncryptWithKey:aeskey andIV:aesiv andText:strMemberJson];
        if(strMemberJson == nil)
        {
            return nil;
        }
        
        NSString *usession=[ud objectForKey:@"u_session"];
        NSString *appVer=[ud objectForKey:@"app_ver"];
        NSString *appID=[ud objectForKey:@"app_id"];
        
        if(usession == nil) usession=@"";
        if(appVer == nil) appVer=@"";
        if(appID == nil) appID=@"";
        
        strJson=[NSString stringWithFormat:@"{\"u_name\":\"%@\",\"u_password\":\"%@\",\"m_id\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"session\":\"%@\",\"operation\":\"%@\",\"client_type\":\"%@\",\"data\":\"%@\"}",uname,upwd,uid,appID,appVer,usession,Auth_UploadMember,Client_Type,strMemberJson];
    }
    return strJson;
}

-(NSString *)jsonDownloadMemberWithUID:(NSString *)uid
{
    NSString *retJson=nil;
    if(uid)
    {
        NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
        NSString *usession=[ud objectForKey:@"u_session"];
        NSString *appVer=[ud objectForKey:@"app_ver"];
        NSString *appID=[ud objectForKey:@"app_id"];
        if(usession == nil) usession=@"";
        if(appVer == nil) appVer=@"";
        if(appID == nil) appID=@"";
        NSArray *aryUserDownloadTime=[_db selectUserUpdateWithUID:uid];
        
        
        if(aryUserDownloadTime == nil || aryUserDownloadTime.count<1)
        {
            return nil;
        }
        
        NSArray *aryDownloadTime=[aryUserDownloadTime objectAtIndex:0];
        if(aryDownloadTime==nil || aryDownloadTime.count<3)
        {
            return nil;
        }
        NSString *downloadTime=[aryDownloadTime objectAtIndex:3];
        retJson=[NSString stringWithFormat:@"{\"u_name\":\"\",\"u_password\":\"\",\"operation\":\"%@\",\"client_type\":\"%@\",\"m_id\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"session\":\"%@\",\"data\":{\"app_id\":\"%@\",\"download_time\":\"%@\"}}",Auth_DownloadMember,Client_Type,uid,appID,appVer,usession,appID,downloadTime];
    }
    return retJson;
}

-(NSString *)jsonSendAuthCodeWithPhone:(NSString *)phone
{
    NSString *retJson=nil;
    if(phone)
    {
        NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
        NSString *appID=[ud objectForKey:@"app_id"];
        NSString *appVer=[ud objectForKey:@"app_ver"];
        NSString *session=[ud objectForKey:@"u_session"];
        if(appID ==nil) appID=@"";
        if(appVer == nil) appVer=@"";
        if(session == nil) session=@"";
        
        retJson=[NSString stringWithFormat:@"{\"u_name\":\"\",\"u_password\":\"\",\"operation\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"session\":\"%@\",\"data\":{\"phone\":\"%@\"}}",Auth_GetAuthcode,Client_Type,appID,appVer,session,phone];
    }
    return retJson;
}

-(NSString *)jsonLoginFromService:(NSArray *)aryInfo
{
    NSString *retJson=nil;
    if(aryInfo&&[aryInfo count]>=3)
    {
        NSString *account=[aryInfo objectAtIndex:0];
        NSString *pwd=[aryInfo objectAtIndex:1];
        NSString *type=[aryInfo objectAtIndex:2];
        NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
        NSString *appID=[ud objectForKey:@"app_id"];
        NSString *appVer=[ud objectForKey:@"app_ver"];
        NSString *session=[ud objectForKey:@"u_session"];
        NSString *mid=[ud objectForKey:@"u_id"];
        if(appID ==nil) appID=@"";
        if(appVer == nil) appVer=@"";
        if(session == nil) session=@"";
        if(mid == nil) mid=@"";
        
        pwd=[PublicModule MD5:pwd];
        
        retJson=[NSString stringWithFormat:@"{\"u_name\":\"\",\"u_password\":\"\",\"operation\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"session\":\"%@\",\"m_id\":\"%@\",\"data\":{\"account\":\"%@\",\"password\":\"%@\",\"type\":\"%@\"}}",Auth_Login,Client_Type,appID,appVer,session,mid,account,pwd,type];
    }
    return retJson;
}

-(NSString *)jsonGUploadMeasureWithData:(NSArray *)aryInfo
{
    NSString *strJson=nil;
    if(aryInfo == nil || aryInfo.count<1)
    {
        return strJson;
    }
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GUploadWeight,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil || [uid isEqualToString:@""] || [uid isEqualToString:@"-1"])
    {
        return nil;
    }
    
    NSString *strData=@"";
    NSMutableArray *aryDataJson=[[NSMutableArray alloc] init];
    
    for(NSInteger i=0;i<aryInfo.count;i++)
    {
        NSArray *aryTemp=[aryInfo objectAtIndex:i];
        if(aryTemp == nil || aryTemp.count<7)
        {
            continue;
        }
        
        NSDictionary *dicMeasureData=[aryTemp objectAtIndex:3];

        NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:
                                [aryTemp objectAtIndex:2],@"m_time",
                                [dicMeasureData valueForKey:ProjectWeight],@"weight",
                                [dicMeasureData valueForKey:ProjectFat],@"fat",
                                [dicMeasureData valueForKey:ProjectBMI],@"bmi",
                                [dicMeasureData valueForKey:ProjectMuscle],@"muscle",
                                [dicMeasureData valueForKey:ProjectBone],@"bone",
                                [dicMeasureData valueForKey:ProjectVisceralFat],@"visceralfat",
                                [dicMeasureData valueForKey:ProjectBasic],@"bmr",
                                [dicMeasureData valueForKey:ProjectWater],@"water",
                                [dicMeasureData valueForKey:ProjectBMI],@"bmi",
                                [dicMeasureData valueForKey:ProjectBodyAge],@"bodyage",
                                [dicMeasureData valueForKey:ProjectHeight],@"height",
                                [aryTemp objectAtIndex:7],@"device_info",
                                [aryTemp objectAtIndex:6],@"is_delete"
                                ,nil];
        [aryDataJson addObject:dictTemp];
    }
    
    if(aryDataJson.count>=1)
    {
        strData = [PublicModule DataTOjsonString:aryDataJson];
    }
    
    if(strData.length<1)
    {
        return strJson;
    }
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":%@}",opcode,uid,usession,Client_Type,appID,appVer,GUploadWeight,strData];
    
    return strJson;
}

-(NSString *)jsonGUploadStepWithData:(NSArray *)aryInfo
{
    NSString *strJson=nil;
    if(aryInfo == nil || aryInfo.count<1)
    {
        return strJson;
    }
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GUploadStep,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil || [uid isEqualToString:@""] || [uid isEqualToString:@"-1"])
    {
        return nil;
    }
    
    NSString *strData=@"";
    NSMutableArray *aryDataJson=[[NSMutableArray alloc] init];
    
    for(NSInteger i=0;i<aryInfo.count;i++)
    {
        NSArray *aryTemp=[aryInfo objectAtIndex:i];
        if(aryTemp == nil || aryTemp.count<7)
        {
            continue;
        }
        
        
        NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:
                                [aryTemp objectAtIndex:2],@"m_time",
                                [aryTemp objectAtIndex:3],@"step_count",
                                [aryTemp objectAtIndex:4],@"start_time",
                                [aryTemp objectAtIndex:5],@"end_time",
                                @"",@"device_info",
                                [aryTemp objectAtIndex:7],@"is_delete"
                                ,nil];
        [aryDataJson addObject:dictTemp];
    }
    
    if(aryDataJson.count>=1)
    {
        strData = [PublicModule DataTOjsonString:aryDataJson];
    }
    
    if(strData.length<1)
    {
        return strJson;
    }
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":%@}",opcode,uid,usession,Client_Type,appID,appVer,GUploadStep,strData];
    
    return strJson;
}

-(NSString *)jsonGUploadTargetWithData:(NSArray *)aryInfo
{
    NSString *strJson=nil;
    if(aryInfo == nil || aryInfo.count<1)
    {
        return strJson;
    }
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GUploadTarget,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil || [uid isEqualToString:@""] || [uid isEqualToString:@"-1"])
    {
        return nil;
    }
    
    NSString *strData=@"";
    NSMutableArray *aryDataJson=[[NSMutableArray alloc] init];
    
    for(NSInteger i=0;i<aryInfo.count;i++)
    {
        NSArray *aryTemp=[aryInfo objectAtIndex:i];
        if(aryTemp == nil || aryTemp.count<7)
        {
            continue;
        }
        
        NSString *targetType=[aryTemp objectAtIndex:4];
        if([targetType isEqualToString:@"1"])
        {
            targetType=@"0";
        }
        else
        {
            targetType=@"1";
        }
        NSDictionary *dictTemp=[NSDictionary dictionaryWithObjectsAndKeys:
                                [aryTemp objectAtIndex:2],@"m_time",
                                [aryTemp objectAtIndex:3],@"target",
                                targetType,@"type",
                                [aryTemp objectAtIndex:6],@"is_delete"
                                ,nil];
        [aryDataJson addObject:dictTemp];
    }
    
    if(aryDataJson.count>=1)
    {
        strData = [PublicModule DataTOjsonString:aryDataJson];
    }
    
    if(strData.length<1)
    {
        return strJson;
    }
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":%@}",opcode,uid,usession,Client_Type,appID,appVer,GUploadTarget,strData];
    
    return strJson;
}

-(NSString *)jsonGShareDataWithWeight:(NSMutableArray *)aryWeight step:(NSMutableDictionary *)dicStep fat:(NSMutableDictionary *)dicFat
{
    NSString *strJson=nil;
    if(aryWeight == nil || dicStep == nil || dicFat == nil)
    {
        return strJson;
    }
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",@"ShareData-1",[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    NSString *strStepTemp=@"\"\"";
    NSString *strWeight=@"\"\"";
    NSString *strFat=@"\"\"";
    
    if(aryWeight.count>=1)
    {
        NSMutableDictionary *jsonFat= [[NSMutableDictionary alloc] init];
        
        NSInteger iCountAll=aryWeight.count;
        NSInteger iCountNoti=0;
        
        
        for(NSInteger i=0;i<aryWeight.count;i++)
        {
            NSDictionary *dicTemp=[aryWeight objectAtIndex:i];
            NSString *name=[dicTemp valueForKey:@"name"];
            NSString *value=[dicTemp valueForKey:@"value"];
            NSArray *aryRange=[dicTemp valueForKey:@"range"];
            
            NSString *range=NSLocalizedString(@"range_normal", nil);
            
            NSString *color=@"green";
            if(aryRange && aryRange.count>=2)
            {
                if(![name isEqualToString:ProjectHeightName] &&
                   ![name isEqualToString:ProjectBodyageName])
                {
                    CGFloat fLow=[[aryRange objectAtIndex:0] floatValue];
                    CGFloat fHigh=[[aryRange objectAtIndex:1] floatValue];
                    CGFloat fValue=[value floatValue];
                    if(fValue<fLow)
                    {
                        iCountNoti++;
                        color = @"blue";
                        range = NSLocalizedString(@"range_low", nil);
                    }
                    else if (fValue >= fLow && fValue<= fHigh)
                    {
                        color = @"green";
                        range = NSLocalizedString(@"range_normal", nil);
                    }
                    else
                    {
                        iCountNoti++;
                        color = @"red";
                        range = NSLocalizedString(@"range_high", nil);
                    }
                }
            }

            if([name isEqualToString:ProjectBMIName])
            {
                [jsonFat setObject:NSLocalizedString(@"m_bmi", nil) forKey:@"bmiName"];
                [jsonFat setObject:value forKey:@"bmiCount"];
                [jsonFat setObject:range forKey:@"bmiEval"];
                [jsonFat setObject:color forKey:@"bmiColor"];
            }
            else if ([name isEqualToString:ProjectFatName])
            {
                [jsonFat setObject:NSLocalizedString(@"m_fat", nil) forKey:@"fatName"];
                [jsonFat setObject:[value stringByAppendingString:@"%"] forKey:@"fatCount"];
                [jsonFat setObject:range forKey:@"fatEval"];
                [jsonFat setObject:color forKey:@"fatColor"];
            }
            else if ([name isEqualToString:ProjectMuscleName])
            {
                [jsonFat setObject:NSLocalizedString(@"m_muscle", nil) forKey:@"muscleName"];
                [jsonFat setObject:[value stringByAppendingString:@"%"] forKey:@"muscleCount"];
                [jsonFat setObject:range forKey:@"muscleEval"];
                [jsonFat setObject:color forKey:@"muscleColor"];
            }
            else if ([name isEqualToString:ProjectWaterName])
            {
                [jsonFat setObject:NSLocalizedString(@"m_water", nil) forKey:@"waterName"];
                [jsonFat setObject:[value stringByAppendingString:@"%"] forKey:@"waterCount"];
                [jsonFat setObject:range forKey:@"waterEval"];
                [jsonFat setObject:color forKey:@"waterColor"];
            }
            else if ([name isEqualToString:ProjectBoneName])
            {
                [jsonFat setObject:NSLocalizedString(@"m_bone", nil) forKey:@"boneName"];
                [jsonFat setObject:[value stringByAppendingString:@"%"] forKey:@"boneCount"];
                [jsonFat setObject:range forKey:@"boneEval"];
                [jsonFat setObject:color forKey:@"boneColor"];
            }
            else if ([name isEqualToString:ProjectBasicName])
            {
                [jsonFat setObject:NSLocalizedString(@"m_basic", nil) forKey:@"bmrName"];
                [jsonFat setObject:[NSString stringWithFormat:@"%.0f",[value floatValue]] forKey:@"bmrCount"];
                [jsonFat setObject:range forKey:@"bmrEval"];
                [jsonFat setObject:color forKey:@"bmrColor"];
            }
            else if ([name isEqualToString:ProjectVisceralFatName])
            {
                [jsonFat setObject:NSLocalizedString(@"m_visceralfat", nil) forKey:@"viscerafatName"];
                [jsonFat setObject:[NSString stringWithFormat:@"%.0f",[value floatValue]] forKey:@"viscerafatCount"];
                [jsonFat setObject:range forKey:@"viscerafatEval"];
                [jsonFat setObject:color forKey:@"viscerafatColor"];
            }
            else if ([name isEqualToString:ProjectBodyageName])
            {
                CGFloat fValue=[value floatValue];
                NSString *bodyageResult=@"";
                if(fValue<18)
                {
                    bodyageResult=NSLocalizedString(@"少年", nil);
                }
                else if (fValue>=18 && fValue<35)
                {
                    bodyageResult=NSLocalizedString(@"青年", nil);
                }
                else if (fValue>=35 && fValue<65)
                {
                   bodyageResult=NSLocalizedString(@"中年", nil);
                }
                else
                {
                    bodyageResult=NSLocalizedString(@"老年", nil);
                }
                
                [jsonFat setObject:NSLocalizedString(@"m_bodyage", nil) forKey:@"bodyageName"];
                [jsonFat setObject:[NSString stringWithFormat:@"%.0f",fValue] forKey:@"bodyageCount"];
                [jsonFat setObject:bodyageResult forKey:@"bodyageEval"];
                [jsonFat setObject:color forKey:@"bodyageColor"];
            }

            
        }
        
        
        NSString *textTitle=[NSString stringWithFormat:@"%@%ld%@",NSLocalizedString(@"bodyfat_bodyfat", nil),(long)iCountAll,NSLocalizedString(@"bodyfat_item", nil)];
        NSString *textTitleValue=[NSString stringWithFormat:@"%ld%@",(long)iCountNoti,NSLocalizedString(@"bodyfat_item", nil)];
        
        [jsonFat setObject:textTitle forKey:@"titleStr_1"];
        [jsonFat setObject:textTitleValue forKey:@"titleWarm"];
        [jsonFat setObject:NSLocalizedString(@"bodyfat_attention",nil) forKey:@"titleStr_2"];

        strFat = [PublicModule DataTOjsonString:[jsonFat copy]];
    }
    if(dicFat.count>=1)
    {
        NSMutableDictionary *jsonWeight= [[NSMutableDictionary alloc] init];
        NSString *weight=[dicFat valueForKey:@"weight"];
        NSString *bmi=[dicFat valueForKey:@"bmi"];
        if(weight == nil) weight=@"";
        if(bmi == nil) bmi=@"";
        [jsonWeight setObject:NSLocalizedString(@"weight_todayweight", nil) forKey:@"title"];
        [jsonWeight setObject:weight forKey:@"weightCount"];
        [jsonWeight setObject:@"kg" forKey:@"weightUnit"];
        [jsonWeight setObject:@"BMI" forKey:@"bmiStr"];
        [jsonWeight setObject:bmi forKey:@"bmiCount"];
        strWeight = [PublicModule DataTOjsonString:[jsonWeight copy]];
        
        
    }
    
    if(dicStep.count>=1)
    {
        NSMutableDictionary *jsonStep= [[NSMutableDictionary alloc] init];
        NSString *strStep=[dicStep valueForKey:@"step"];
        NSString *strStepAll=[dicStep valueForKey:@"allstep"];
        NSString *strKM=[dicStep valueForKey:@"km"];
        NSString *strTime=[dicStep valueForKey:@"time"];
        NSString *strKcal=[dicStep valueForKey:@"kcal"];
        
        
        if(strStep == nil) strStep=@"0";
        if(strStepAll == nil) strStepAll=@"1";
        if(strKM == nil) strKM=@"0";
        if(strTime == nil) strTime=@"0";
        if(strKcal == nil) strKcal=@"0";
        
        float fPercent=[strStep floatValue]/[strStepAll floatValue]*100.0;
        if(fPercent>=100.0) fPercent = 100.0;

        NSString *textPercent=[NSString stringWithFormat:@"%.0f",fPercent];
        textPercent=[textPercent stringByAppendingString:@"%"];
        
        [jsonStep setObject:strStep forKey:@"stepCount"];
        [jsonStep setObject:NSLocalizedString(@"step_unit", nil) forKey:@"stepUnit"];
        [jsonStep setObject:NSLocalizedString(@"step_finish", nil) forKey:@"finishStr"];
        [jsonStep setObject:textPercent forKey:@"finishPct"];
        [jsonStep setObject:[@"of " stringByAppendingString:strStepAll] forKey:@"finishAll"];
        [jsonStep setObject:strKM forKey:@"distCount"];
        [jsonStep setObject:NSLocalizedString(@"step_km", nil) forKey:@"distUnit"];
        [jsonStep setObject:strTime forKey:@"timeCount"];
        [jsonStep setObject:NSLocalizedString(@"step_time", nil) forKey:@"timeUnit"];
        [jsonStep setObject:strKcal forKey:@"kcalCount"];
        [jsonStep setObject:@"kcal" forKey:@"kcalUnit"];
        
        strStepTemp = [PublicModule DataTOjsonString:[jsonStep copy]];
    }
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"step\":%@,\"weight\":%@,\"fat\":%@}}",opcode,uid,usession,Client_Type,appID,appVer,@"ShareData-1",strStepTemp,strWeight,strFat];
    
    return strJson;
}

-(NSString *)jsonGShareImgae:(NSString *)strImage
{
    NSString *strJson=nil;
    if(strImage == nil)
    {
        return strJson;
    }
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",@"ShareImg-1",[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"photoData\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,@"ShareImg-1",strImage];
    
    return strJson;
}

-(NSString *)jsonGRegister:(NSArray *)aryInfo
{
    NSString *strJson=nil;
    
    if(aryInfo == nil || aryInfo.count<5)
    {
        return strJson;
    }
    
    NSString *account=[aryInfo objectAtIndex:0];
    account=[PublicModule base64EncodeWithString:account];
    NSString *password=[aryInfo objectAtIndex:1];
    password=[PublicModule MD5:password];
    
    NSString *height=[aryInfo objectAtIndex:2];
    NSString *age=[aryInfo objectAtIndex:3];
    NSString *sex=[aryInfo objectAtIndex:4];
    NSString *ctime=[aryInfo objectAtIndex:5];
    NSString *wc=@"";
    NSString *hc=@"";
    
    if(aryInfo.count>=7)
    {
        wc=[aryInfo objectAtIndex:6];
        hc=[aryInfo objectAtIndex:7];
    }
    
    
    if(account.length<1 || password.length<1)
    {
        return strJson;
    }
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GRegister,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"account\":\"%@\",\"password\":\"%@\",\"height\":\"%@\",\"sex\":\"%@\",\"age\":\"%@\",\"headphoto\":\"\",\"account_type\":\"0\",\"c_time\":\"%@\",\"wc\":\"%@\",\"hc\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,GRegister,account,password,height,sex,age,ctime,wc,hc];
    
    return strJson;
}

-(NSString *)jsonDRegister:(NSArray *)aryInfo
{
    NSString *strJson=nil;
    
    if(aryInfo == nil || aryInfo.count<10)
    {
        return strJson;
    }
    
    NSString *nickname=[aryInfo objectAtIndex:0];
    nickname=[PublicModule base64EncodeWithString:nickname];
    NSString *sex=[aryInfo objectAtIndex:1];
    NSString *mysign=[aryInfo objectAtIndex:2];
    mysign=[PublicModule base64EncodeWithString:mysign];
    NSString *city=[aryInfo objectAtIndex:3];
    NSString *country=[aryInfo objectAtIndex:4];
    NSString *province=[aryInfo objectAtIndex:5];
    NSString *headphoto=[aryInfo objectAtIndex:6];
    NSString *accountType=[aryInfo objectAtIndex:7];
    NSString *account=[aryInfo objectAtIndex:8];
    NSString *ownness=[aryInfo objectAtIndex:9];
    NSString *password=[aryInfo objectAtIndex:10];
    password=[PublicModule MD5:password];
    
    if(nickname == nil || sex == nil  || city == nil ||
       province == nil || headphoto == nil || accountType == nil ||
       account == nil || ownness == nil)
    {
        return strJson;
    }
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",DRegisterAccount,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"nickname\":\"%@\",\"sex\":\"%@\",\"introduce\":\"%@\",\"city\":\"%@\",\"country\":\"%@\",\"province\":\"%@\",\"headphoto_url\":\"%@\",\"account_type\":\"%@\",\"account\":\"%@\",\"ownness\":\"%@\",\"password\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,DRegisterAccount,nickname,sex,mysign,city,country,province,headphoto,accountType,account,ownness,password];
    
    return strJson;
}

-(NSString *)jsonGEditProfile:(NSArray *)aryInfo
{
    NSString *strJson=nil;
    
    if(aryInfo == nil || aryInfo.count < 3)
    {
        return strJson;
    }
    
    NSString *sex=[aryInfo objectAtIndex:0];
    NSString *height=[aryInfo objectAtIndex:1];
    NSString *age=[aryInfo objectAtIndex:2];
    NSString *wc=[aryInfo objectAtIndex:3];
    NSString *hc=[aryInfo objectAtIndex:4];
    
    if(sex.length<1 || height.length<1 || age.length<1 || wc.length<1 || hc.length<1)
    {
        return strJson;
    }
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GEditProfile,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil || [uid isEqualToString:@""] || [uid isEqualToString:@"-1"])
    {
        return nil;
    }
    
    if(uid.length<1 || [uid isEqualToString:@"-1"])
    {
        return strJson;
    }
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"height\":\"%@\",\"sex\":\"%@\",\"age\":\"%@\",\"wc\":\"%@\",\"hc\":\"%@\",\"headphoto\":\"\"}}",opcode,uid,usession,Client_Type,appID,appVer,GEditProfile,height,sex,age,wc,hc];
    
    return strJson;
}

-(NSString *)jsonGEditPwd:(NSArray *)aryInfo
{
    NSString *strJson=nil;
    
    if(aryInfo == nil || aryInfo.count < 1)
    {
        return strJson;
    }
    
    NSString *pwd=[aryInfo objectAtIndex:0];
    pwd=[PublicModule MD5:pwd];
    
    if(pwd.length<1)
    {
        return strJson;
    }
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GEditPwd,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"new_pwd\":\"%@\",\"old_pwd\":\"\"}}",opcode,uid,usession,Client_Type,appID,appVer,GEditPwd,pwd];
    
    return strJson;
}

-(NSString *)jsonGFinishDownloadMeasureWithOPCode:(NSString *)OPCode
{
    NSString *strJson=nil;
    
    if(OPCode == nil || OPCode.length<1)
    {
        return strJson;
    }
    
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GDownloadWeightCallback,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) return strJson;
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"callback_opcode\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,GDownloadWeightCallback,OPCode];
    
    return strJson;
}

-(NSString *)jsonGFinishDownloadStepWithOPCode:(NSString *)OPCode
{
    NSString *strJson=nil;
    
    if(OPCode == nil || OPCode.length<1)
    {
        return strJson;
    }
    
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GDownloadStepCallback,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) return strJson;
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"callback_opcode\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,GDownloadStepCallback,OPCode];
    
    return strJson;
}

-(NSString *)jsonGFinishDownloadTargetWithOPCode:(NSString *)OPCode
{
    NSString *strJson=nil;
    
    if(OPCode == nil || OPCode.length<1)
    {
        return strJson;
    }
    
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GDownloadTargetCallback,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) return strJson;
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"callback_opcode\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,GDownloadTargetCallback,OPCode];
    
    return strJson;
}

-(NSString *)jsonGDownloadMeasureWithTime:(NSString *)downloadTime
{
    NSString *strJson=nil;
    
    if(downloadTime == nil || downloadTime.length<1)
    {
        return strJson;
    }
    
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GDownloadWeight,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil || uid.length<1) return strJson;
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"download_time\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,GDownloadWeight,downloadTime];
    
    return strJson;
}

-(NSString *)jsonGDownloadStepWithTime:(NSString *)downloadTime
{
    NSString *strJson=nil;
    
    if(downloadTime == nil || downloadTime.length<1)
    {
        return strJson;
    }
    
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GDownloadStep,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil || uid.length<1) return strJson;
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"download_time\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,GDownloadStep,downloadTime];
    
    return strJson;
}

-(NSString *)jsonGDownloadTargetWithTime:(NSString *)downloadTime
{
    NSString *strJson=nil;
    
    if(downloadTime == nil || downloadTime.length<1)
    {
        return strJson;
    }
    
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GDownloadTarget,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil || uid.length<1) return strJson;
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"download_time\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,GDownloadTarget,downloadTime];
    
    return strJson;
}

-(NSString *)jsonGFindPwd:(NSArray *)aryInfo
{
    NSString *strJson=nil;
    
    if(aryInfo == nil || aryInfo.count < 1)
    {
        return strJson;
    }
    
    NSString *account=[aryInfo objectAtIndex:0];
    account=[PublicModule base64EncodeWithString:account];

    if(account.length<1)
    {
        return strJson;
    }
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GFindPwd,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"account\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,GFindPwd,account];
    
    return strJson;
}

-(NSString *)jsonGLogin:(NSArray *)aryInfo
{
    NSString *strJson=nil;
    
    if(aryInfo == nil || aryInfo.count < 2)
    {
        return strJson;
    }
    
    NSString *account=[aryInfo objectAtIndex:0];
    account=[PublicModule base64EncodeWithString:account];
    NSString *pwd=[aryInfo objectAtIndex:1];
    pwd=[PublicModule MD5:pwd];
    if(account.length<1 || pwd.length<1)
    {
        return strJson;
    }
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",GLogin,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"account\":\"%@\",\"password\":\"%@\",\"account_type\":\"0\"}}",opcode,uid,usession,Client_Type,appID,appVer,GLogin,account,pwd];
    
    return strJson;
}

-(NSString *)jsonDLogin:(NSArray *)aryInfo
{
    NSString *strJson=nil;
    
    if(aryInfo == nil || aryInfo.count < 6)
    {
        return strJson;
    }
    
    NSString *account=[aryInfo objectAtIndex:0];
    NSString *accountType=[aryInfo objectAtIndex:1];
    NSString *pwd=[aryInfo objectAtIndex:2];
    NSString *address=[aryInfo objectAtIndex:3];
    NSString *lati=[aryInfo objectAtIndex:4];
    NSString *longi=[aryInfo objectAtIndex:5];
    
    if(account == nil || accountType == nil)
    {
        return strJson;
    }
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",DLogin,[PublicModule getMyTimeInterval:[NSDate date]]];
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"account\":\"%@\",\"account_type\":\"%@\",\"password\":\"%@\",\"location\":\"%@\",\"latitude\":\"%@\",\"longitude\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,DLogin,account,accountType,pwd,address,lati,longi];
    
    return strJson;
}

-(NSString *)jsonDPwdEditWithOldPwd:(NSString *)oldPwd andNewPwd:(NSString *)newPwd
{
    NSString *strJson=nil;
    
    
    if(oldPwd == nil || newPwd == nil)
    {
        return strJson;
    }
    
    oldPwd=[PublicModule MD5:oldPwd];
    newPwd=[PublicModule MD5:newPwd];
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",DPwdEdit,[PublicModule getMyTimeInterval:[NSDate date]]];
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{\"old_pwd\":\"%@\",\"new_pwd\":\"%@\"}}",opcode,uid,usession,Client_Type,appID,appVer,DPwdEdit,oldPwd,newPwd];
    
    return strJson;
}

-(NSString *)jsonDRegisterLimit
{
    NSString *strJson=nil;
    
    NSString *opcode=[NSString stringWithFormat:@"%@_%@",DCanRegister,[PublicModule getMyTimeInterval:[NSDate date]]];
    
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *usession=[ud objectForKey:@"u_session"];
    NSString *appVer=[ud objectForKey:@"app_ver"];
    NSString *appID=[ud objectForKey:@"app_id"];
    NSString *uid=[ud objectForKey:@"u_id"];
    if(usession == nil) usession=@"";
    if(appVer == nil) appVer=@"";
    if(appID == nil) appID=@"";
    if(uid == nil) uid=@"";
    
    uid=@"";
    usession=@"";
    
    
    strJson=[NSString stringWithFormat:@"{\"opcode\":\"%@\",\"u_id\":\"%@\",\"session\":\"%@\",\"client_type\":\"%@\",\"app_id\":\"%@\",\"app_ver\":\"%@\",\"operation\":\"%@\",\"data\":{}}",opcode,uid,usession,Client_Type,appID,appVer,DCanRegister];
    
    return strJson;
}

@end

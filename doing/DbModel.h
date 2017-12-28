#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "PublicModule.h"
#import "UserInfo.h"

@interface DbModel : NSObject
{
    FMDatabase *DB;
    PublicModule *_publicModule;
}

- (void)initModule;

- (BOOL)isDbExist;
- (BOOL)insertUser:(NSArray *)aryInfo;
- (BOOL)insertMember:(NSArray *)aryInfo;
- (BOOL)editMember:(NSArray *)aryInfo;
- (BOOL)insertTarget:(NSArray *)aryInfo;
- (BOOL)updateTarget:(NSArray *)aryInfo;
- (BOOL)insertDownloadWeightWithAry:(NSArray *)aryInfo andCTime:(NSString *)ctime;
- (BOOL)insertDownloadStepWithAry:(NSArray *)aryInfo andCTime:(NSString *)ctime;
- (BOOL)insertDownloadTargetWithAry:(NSArray *)aryInfo andCTime:(NSString *)ctime;
- (BOOL)finishUploadMeasureDataWithCTime:(NSString *)ctime andID:(NSString *)strID;
- (BOOL)finishUploadStepDataWithCTime:(NSString *)ctime andID:(NSString *)strID;
- (BOOL)finishUploadTargetDataWithCTime:(NSString *)ctime andID:(NSString *)strID;
- (BOOL)insertStepInfo:(NSArray *)aryInfo;
- (BOOL)insertDownloadTime:(NSString *)downloadTime andType:(NSString *)type;
- (BOOL)deleteWeight:(NSString *)weightID;
- (BOOL)deleteStepWithCTime:(NSString *)ctime andDate:(NSString *)strDate;
- (BOOL)insertMeasureData:(NSArray *)ary;
- (BOOL)updateCustomProject:(NSArray *)arrData;
- (BOOL)insertAccount:(NSArray *)aryInfo;
- (BOOL)updateLocalAccount:(NSArray *)aryInfo;
- (BOOL)updateAccountWithCTime:(NSString *)ctime andUID:(NSString *)uid andUName:(NSString *)uname andUPwd:(NSString *)upwd;
- (BOOL)updateAccountWithPwd:(NSString *)pwd andUID:(NSString *)uid;
- (BOOL)updateAccount:(NSArray *)aryInfo withType:(int)type;
- (BOOL)updateAccountFromService:(NSArray *)aryInfo;
- (BOOL)insertJsonTempWithJson:(NSString *)jsonTemp andType:(NSString *)jsonType andPage:(NSString *)jsonPage andUID:(NSString *)uid;
- (BOOL)updateUploadMeasureDataWithUID:(NSString *)uid;
- (BOOL)updateUploadMeasureDataWithCTime:(NSArray *)aryCTime;
- (BOOL)updateUploadMeasureDataWithCTime:(NSArray *)aryCTime andProjectType:(NSString *)type;
- (BOOL)deleteWeightInfo:(int)weightID andMemberType:(NSString *)memberType;
- (BOOL)checkMemberUpdateExistWithCTime:(NSString *)ctime
;
- (BOOL)insertMemberUpdateWithCTime:(NSString *)ctime andTime:(NSString *)downloadTime andGMID:(NSString *)gmid;

- (NSArray *)selectTargetWithCTime:(NSString *)ctime andType:(NSString *)type;
- (NSArray *)selectMaxAndMinProjectValueWithProject:(NSString *)project andCTime:(NSString *)ctime;
- (NSArray *)selectMaxAndMinProjectTimeWithProject:(NSString *)project andCTime:(NSString *)ctime;
- (NSArray *)selectChartAnalysisWithProject:(NSString *)project andCTime:(NSString *)ctime;
- (NSArray *)selectWeightWithCTime:(NSString *)ctime  andProject:(NSString *)project andStartDate:(NSString *)startDate endDate:(NSString *)endDate;
- (NSArray *)selectMeasureWithCTime:(NSString *)ctime  andProject:(NSString *)project andStartDate:(NSString *)startDate endDate:(NSString *)endDate;
- (NSArray *)selectAllUploadMeasureDataWithCTime:(NSString *)ctime;
- (NSArray *)selectAllUploadStepDataWithCTime:(NSString *)ctime;
- (NSArray *)selectAllUploadTargetDataWithCTime:(NSString *)ctime;
- (NSArray *)selectAllStepWithCTime:(NSString *)ctime;
- (NSArray *)selectStepWithCTime:(NSString *)ctime withStartDate:(NSString *)startDate andEndDate:(NSString *)endDate;
- (NSArray *)selectStepDateWithCTime:(NSString *)ctime withStartDate:(NSString *)startDate andEndDate:(NSString *)endDate;
- (NSArray *)selectDownloadTimeWithUID:(NSString *)uid;
- (NSArray *)selectAllWeightWithCTime:(NSString *)ctime;
- (NSArray *)selectAllMeasureDataWithCTime:(NSString *)ctime andProject:(NSString *)project;
- (NSArray *)selectLastWeightWithCTime:(NSString *)ctime;
- (NSArray *)selectLastStepWithCTime:(NSString *)ctime;
- (NSArray *)selectLastMeasureDataWithCTime:(NSString *)ctime andProject:(NSString *)project;
- (NSArray *)selectFirstMeasureDataWithCTime:(NSString *)ctime andProject:(NSString *)project;
- (NSArray *)getCustomProject:(NSString *)ctime;
- (NSMutableArray *)selectAccountWithCTime:(NSString *)strCTime;
- (NSString *)selectLocalAccountCTime;
- (NSArray *)selectMemberCtimeWithUID:(NSString *)uid;
- (NSArray *)selectAllUploadMemberWithMID:(NSString *)uid;
- (NSArray *)selectAllUploadMeasureDataWithCTime:(NSString *)ctime andProjectType:(int)type;
- (NSArray *)selectUploadMemberWithMID:(NSString *)mid;
- (NSArray *)selectWeightWithCTime:(NSString *)ctime andStartDate:(NSString *)startDate endDate:(NSString *)endDate;
- (NSArray *)selectWeightWithCTime:(NSString *)ctime andDate:(NSString *)date;
- (NSArray *)selectAllMeasureDataWithCTime:(NSString *)ctime andType:(int)type;
- (NSArray *)selectMemberUpdateWithCTime:(NSString *)ctime;
- (NSArray *)selectUserUpdateWithUID:(NSString *)uid;
- (NSArray *)selectUserWithUName:(NSString *)uname;
- (NSArray *)selectMember:(NSString *)ctime;
@end

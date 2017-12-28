#import <Foundation/Foundation.h>

@interface NetworkModule : NSObject
{
    DbModel *_db;
}

- (NSString *)jsonGShareDataWithWeight:(NSMutableArray *)aryWeight step:(NSMutableDictionary *)dicStep fat:(NSMutableDictionary *)dicFat;
-(NSString *)jsonGShareImgae:(NSString *)strImage;
-(NSString *)jsonGRegister:(NSArray *)aryInfo;
-(NSString *)jsonGLogin:(NSArray *)aryInfo;
-(NSString *)jsonGEditPwd:(NSArray *)aryInfo;
-(NSString *)jsonGEditProfile:(NSArray *)aryInfo;
-(NSString *)jsonGFindPwd:(NSArray *)aryInfo;
-(NSString *)jsonGUploadMeasureWithData:(NSArray *)aryInfo;
-(NSString *)jsonGUploadStepWithData:(NSArray *)aryInfo;
-(NSString *)jsonGUploadTargetWithData:(NSArray *)aryInfo;
-(NSString *)jsonGDownloadMeasureWithTime:(NSString *)downloadTime;
-(NSString *)jsonGDownloadStepWithTime:(NSString *)downloadTime;
-(NSString *)jsonGDownloadTargetWithTime:(NSString *)downloadTime;
-(NSString *)jsonGFinishDownloadMeasureWithOPCode:(NSString *)OPCode;
-(NSString *)jsonGFinishDownloadStepWithOPCode:(NSString *)OPCode;
-(NSString *)jsonGFinishDownloadTargetWithOPCode:(NSString *)OPCode;

-(NSString *)jsonDRegister:(NSArray *) aryInfo;
-(NSString *)jsonDLogin:(NSArray *) aryInfo;
-(NSString *)jsonDPwdEditWithOldPwd:(NSString *)oldPwd andNewPwd:(NSString *)newPwd;
-(NSString *)jsonDRegisterLimit;
-(NSString *)jsonUploadLoginMemberWithUID:(NSArray *)aryUser;
-(NSString *)jsonUploadMemberWithUID:(NSArray *)aryUser withType:(NSString *)type;
-(NSString *)jsonDownloadMemberWithUID:(NSString *)uid;
-(NSString *)jsonSendAuthCodeWithPhone:(NSString *)phone;
-(NSString *)jsonLoginFromService:(NSArray *)aryInfo;

@end

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface PublicModule : NSObject
{
    
}

+(NSString*)DataTOjsonString:(id)object;
+(NSDictionary *)getFatRangeWithAge:(NSString *)strAge andSex:(NSString *)strSex;
+(NSArray *)getBoneRangeWithWeight:(NSString *)strWeight andSex:(NSString *)strSex;
-(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
-(NSString *)saveImagesWithData:(NSData *)imageData withCTime:(NSString *)ctime andTime:(NSString *)time andType:(NSString *)pathType;
-(UIImage *)MergeImageWithAryImage:(NSArray *)aryImages;
+(UIImage *)getImageWithVideoURL:(NSURL *)videoURL;

+(BOOL)isM7Use;

+ (NSString *)transTimeSp:(NSString *) time;
+ (NSString *)kgToLb:(NSString *)data;
+ (NSString *)kgToZeroLb:(NSString *)data;
+ (NSString *)lbToKg:(NSString *)data;

+(NSString *)AES128EncryptWithKey:(NSString *)key andIV:(NSString *)iv andText:(NSString *)plainText;
+(NSString *)AES128DecryptWithKey:(NSString *)key andIV:(NSString *)iv andText:(NSString *)plainText;

+(NSString*)TripleDES:(NSString*)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt key:(NSString*)key;

+(NSString *)MD5:(NSString *)strData;

+(UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size;

+(UIImage*)getSubImage:(CGRect)rect withImage:(UIImage *)oriImage;

+(NSString *)base64DecodeWithString:(NSString *)strTemp;
+(NSString *)base64EncodeWithString:(NSString *)strTemp;

+(NSString *)getDateWithDate:(NSString *)date andDifferDay:(int)days;

+(NSArray *) getDateWithDate:(NSDate *)date andCountDay:(int)days;

+(NSArray *)getDateRangeWithDays:(int)days;

+(NSArray *)getTimeWithDate:(NSDate *)date;

+(NSArray *)getTimeWithStrDate:(NSString *)strDate;

+(NSString *)getTimeNow:(NSString *)timeFormatter withDate:(NSDate *)date;

+(NSDate *)getDateWithString:(NSString *)strDate andFormatter:(NSString *)formatter;

+(NSDateComponents *)countTimeWithStartDate:(NSString *)startDate andEndDate:(NSString *)endDate;

+(BOOL)compareDateWithStartDate:(NSString *)startDate andEndDate:(NSString *)endDate;

+(int)compareDateWithStartTime:(NSString *)startTime andEndTime:(NSString *)endTime;

+(NSArray *)getpreviousYearDayWithDate:(NSDate *)date;
+(NSArray *)getpreviousWeekDayWithDate:(NSDate *)date;
+(NSArray *)getpreviousMonthDayWithDate:(NSDate *)date;
+(NSArray *)getpreviousAllDayWithStartDate:(NSDate *)date andEndDate:(NSDate *)endDate;

+(NSArray *)getChartWeekDayWithDate:(NSDate *)date;
+(NSArray *)getChartMonthDayWithDate:(NSDate *)date;
+(NSArray *)getChartAllDayWithStartDate:(NSDate *)date andEndDate:(NSDate *)endDate;

+(NSArray *)getBeforeWeekDayWithDate:(NSDate *)date;
+(NSArray *)getBeforeMonthDayWithDate:(NSDate *)date;
+(NSArray *)getbeforeYearDayWithDate:(NSDate *)date;
+(NSArray*)getChineseCalendarWithDate:(NSDate *)date;
+(NSArray *)getBeforeFortyWeekWithDate:(NSDate *)date;
+(NSString *)getMyTimeInterval:(NSDate *)date;
+(NSString *)timeintervalToDate:(NSString *)time;
+(NSArray *)getMaxAndMin:(NSArray *)aryData;
+(NSArray *)getMaxAndMinWithoutZero:(NSArray *)aryData;
+(NSString *)getChartAvgValue:(NSArray *)aryData;
+(NSString *)getDays:(NSString *)date withDate:(NSString *)date1;

+(BOOL)checkNickname:(NSString *)nickname;
+(BOOL)checkTel:(NSString *)strPhone;
+(BOOL)checkPassword:(NSString *)strPwd;
+(BOOL)checkLoginStatus;
+(BOOL)checkLogin;
+(BOOL)checkNetworkStatus;
+(BOOL)checkGMID;
+(BOOL)isValidateEmail:(NSString *)email;
@end

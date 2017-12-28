#import "PublicModule.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

@implementation PublicModule


-(UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

-(NSString *)saveImagesWithData:(id)imageData withCTime:(NSString *)ctime andTime:(NSString *)time andType:(NSString *)pathType
{
    NSString *ret=@"";
    if(imageData == nil)
    {
        return ret;
    }
    // 获取沙盒目录
    time=[time stringByReplacingOccurrencesOfString:@" " withString:@""];
    time=[time stringByReplacingOccurrencesOfString:@"-" withString:@""];
    time=[time stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSString *imagePath=@"";
    if([pathType isEqualToString:@"0"])
    {
        imagePath=[NSString stringWithFormat:@"Image/DiaryImage/%@%@.png",ctime,time];
    }
    else if([pathType isEqualToString:@"1"])
    {
        imagePath=[NSString stringWithFormat:@"Image/BabyImage/%@%@.png",ctime,time];
    }
    else if([pathType isEqualToString:@"2"])
    {
        imagePath=[NSString stringWithFormat:@"Image/SquareImage/%@%@.png",ctime,time];
    }
    else
    {
        return ret;
    }
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imagePath];
    
    // 将图片写入文件
    
    BOOL result=[imageData writeToFile:fullPath atomically:YES];
    if(result)
    {
        ret=imagePath;
    }
    return ret;
}

static size_t getAssetBytesCallback(void  *info, void  *buffer, off_t position, size_t count) {
    ALAssetRepresentation *rep = (__bridge id)info;
    
    NSError *error = nil;
    size_t countRead = [rep getBytes:(uint8_t *)buffer fromOffset:position length:count error:&error];
    
    if (countRead == 0 && error) {
        // We have no way of passing this info back to the caller, so we log it, at least.
        NSLog(@"thumbnailForAsset:maxPixelSize: got an error reading an asset: %@", error);
    }
    
    return countRead;
}

static void releaseAssetCallback(void  *info) {
    // The info here is an ALAssetRepresentation which we CFRetain in thumbnailForAsset:maxPixelSize:.
    // This release balances that retain.
    CFRelease(info);
}

+(UIImage *)getImageWithVideoURL:(NSURL *)videoURL
{
    //AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoURL] options:nil];
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:videoURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    
    return thumb;
}


+ (NSString *) transTimeSp:(NSString *) time
{
    NSDate *datenow = [NSDate date];
    NSInteger duration = (NSInteger)[datenow timeIntervalSince1970] - [time integerValue];
    NSString *str;
    
    int second = 1;
    int minute = second * 60;
    int hour = minute * 60;
    int day = hour * 24;
    
    if (duration < second * 7)
    {
        str = NSLocalizedString(@"刚刚", @"rightnow");
    }
    else if (duration < minute)
    {
        int n = (int)duration/second;
        str = [NSString stringWithFormat:NSLocalizedString(@"%d秒钟前", @"second before"),n];
    }
    else if (duration < hour)
    {
        int n = (int)duration/minute;
        str = [NSString stringWithFormat:NSLocalizedString(@"%d分钟前", @"minute before"),n];
    }
    else if (duration < day)
    {
        int n = (int)duration/hour;
        str = [NSString stringWithFormat:NSLocalizedString(@"%d小时前", @"hour before"),n];
    }
    else if (duration > day && duration < day * 2)
    {
        str = NSLocalizedString(@"昨天", @"day yestoday");
    }
    else if (duration > day && duration < day * 3)
    {
        str = NSLocalizedString(@"前天", @"day the day before yestoday");
    }
    else if (duration < day * 7)
    {
        int n = (int)duration/day;
        str = [NSString stringWithFormat:NSLocalizedString(@"%d天前", @"day before"),n];
    }
    else
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSLocale *chLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CH"];
        [formatter setLocale:chLocale];
        [formatter setDateFormat:NSLocalizedString(@"MM月dd日 HH:mm", @"date formatter")];
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-duration];
        str = [formatter stringFromDate:date];
    }
    
    return str;
}

+ (NSString *)kgToLb:(NSString *)data {
    if (data.length < 1 || [data isEqualToString:@"0"]) {
        return @"0";
    }
    
    CGFloat fLb = [data floatValue] * 2.2046;
    fLb = fLb  / 2.0 * 10;
    int iLb = roundf(fLb);
    
    NSString *returnValue = [NSString stringWithFormat:@"%.1f",iLb *  0.2];
    return returnValue;
}

+ (NSString *)kgToZeroLb:(NSString *)data {
    if (data.length < 1 || [data isEqualToString:@"0"]) {
        return @"0";
    }
    
    NSString *returnValue = [NSString stringWithFormat:@"%.0f",[data floatValue] *  2.204622];
    return returnValue;
}

+ (NSString *)lbToKg:(NSString *)data {
    if (data.length < 1 || [data isEqualToString:@"0"]) {
        return @"0";
    }
    
    NSString *returnValue = [NSString stringWithFormat:@"%.1f",[data floatValue] * 0.453592];
    return returnValue;
}

+(UIImage *)thumbnailForAsset:(ALAsset *)asset maxPixelSize:(NSUInteger)size
{
    NSParameterAssert(asset != nil);
    NSParameterAssert(size > 0);
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    
    CGDataProviderDirectCallbacks callbacks = {
        .version = 0,
        .getBytePointer = NULL,
        .releaseBytePointer = NULL,
        .getBytesAtPosition = getAssetBytesCallback,
        .releaseInfo = releaseAssetCallback,
    };
    
    CGDataProviderRef provider = CGDataProviderCreateDirect((void  *)CFBridgingRetain(rep), [rep size], &callbacks);
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(source, 0, (__bridge CFDictionaryRef) @{
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                                                                                                      (NSString *)kCGImageSourceThumbnailMaxPixelSize : [NSNumber numberWithInt:size],
                                                                                                      (NSString *)kCGImageSourceCreateThumbnailWithTransform : @YES,
                                                                                                      });
    CFRelease(source);
    CFRelease(provider);
    
    if (!imageRef) {
        return nil;
    }
    
    UIImage *toReturn = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(imageRef);
    
    return toReturn;
}

+(UIImage *)getSubImage:(CGRect)rect withImage:(UIImage *)oriImage
{
    CGImageRef subImageRef = CGImageCreateWithImageInRect(oriImage.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    
    return smallImage;
}



-(UIImage *)MergeImageWithAryImage:(NSArray *)aryImages
{
    if(aryImages == nil || aryImages.count<1)
    {
        return nil;
    }
    CGFloat height=0;
    
    NSMutableArray *aryHeight=[[NSMutableArray alloc] init];
    for(int i=0;i<aryImages.count;i++)
    {
        UIImage *imageTemp=[aryImages objectAtIndex:i];
        CGSize size=imageTemp.size;
        CGFloat newHeight=240*size.height/size.width;
        [aryHeight addObject:[NSString stringWithFormat:@"%f",newHeight]];
        height=height+newHeight;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(240, height));
    CGFloat imageHeight=0;
    for(int i=0;i<aryImages.count;i++)
    {
        UIImage *imageTemp=[aryImages objectAtIndex:i];
        CGSize size=imageTemp.size;
        CGFloat newHeight=240*size.height/size.width;
        CGSize newSize=CGSizeMake(240, newHeight);
        if(i==0)
        {
            imageHeight=0;
        }
        else
        {
            imageHeight=imageHeight+[[aryHeight objectAtIndex:i-1] floatValue];
        }
        [imageTemp drawInRect:CGRectMake(0, imageHeight, 240, newSize.height)];
    }
    
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    NSData *data=UIImageJPEGRepresentation(resultingImage, 1.0);
    
    resultingImage=[UIImage imageWithData:data];
    
    return resultingImage;
}

+(NSString *)AES128DecryptWithKey:(NSString *)key andIV:(NSString *)iv andText:(NSString *)plainText
{
    char keyPtr[kCCKeySizeAES128 + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData *data = [GTMBase64 decodeData:[plainText dataUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesCrypted = 0;
    //0x0000
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
    }
    free(buffer);
    return nil;
}

+(NSString *)AES128EncryptWithKey:(NSString *)key andIV:(NSString *)iv andText:(NSString *)plainText
{
    char keyPtr[kCCKeySizeAES128+1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
    NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [data length];
    
    int diff = kCCKeySizeAES128 - (dataLength % kCCKeySizeAES128);
    int newSize = 0;
    
    if(diff > 0)
    {
        newSize = dataLength + diff;
    }
    
    char dataPtr[newSize];
    memcpy(dataPtr, [data bytes], [data length]);
    for(int i = 0; i < diff; i++)
    {
        dataPtr[i + dataLength] = 0x00;
    }
    
    size_t bufferSize = newSize + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    memset(buffer, 0, bufferSize);
    
    size_t numBytesCrypted = 0;
    //0x0000
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          0x0000,               //No padding
                                          keyPtr,
                                          kCCKeySizeAES128,
                                          ivPtr,
                                          dataPtr,
                                          sizeof(dataPtr),
                                          buffer,
                                          bufferSize,
                                          &numBytesCrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
        return [GTMBase64 stringByEncodingData:resultData];
    }
    free(buffer);
    return nil;
}


+(NSString *)TripleDES:(NSString *)plainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt key:(NSString *)key
{
    const void *vplainText;
    size_t plainTextBufferSize;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        NSData *EncryptData = [GTMBase64 decodeData:[plainText dataUsingEncoding:NSUTF8StringEncoding]];
        plainTextBufferSize = [EncryptData length];
        vplainText = [EncryptData bytes];
    }
    else
    {
        NSData* data = [plainText dataUsingEncoding:NSUTF8StringEncoding];
        plainTextBufferSize = [data length];
        vplainText = (const void *)[data bytes];
    }
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    // uint8_t ivkCCBlockSize3DES;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    // memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    //    NSString *key = @"123456789012345678901234";
    //key=[PublicModule base64EncodeWithString:key];
    
    NSString *initVec = @"00000000";
    
    //key=[PublicModule base64EncodeWithString:key];
    //initVec=[PublicModule base64EncodeWithString:initVec];
    
    const void *vkey = (const void *) [key UTF8String];
    const void *vinitVec = (const void *) [initVec UTF8String];
    
    //aa=0x0003;
    //kCCOptionECBMode
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionECBMode,
                       vkey, //"123456789012345678901234", //key
                       kCCKeySize3DES,
                       vinitVec, //"init Vec", //iv,
                       vplainText, //"Your Name", //plainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    /*else if (ccStatus == kCC ParamError) return @"PARAM ERROR";
     else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
     else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
     else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
     else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
     else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED"; */
    
    NSString *result;
    
    if (encryptOrDecrypt == kCCDecrypt)
    {
        result = [[NSString alloc] initWithData:[NSData dataWithBytes:(const void *)bufferPtr
                                                                length:(NSUInteger)movedBytes]
                                        encoding:NSUTF8StringEncoding];
    }
    else
    {
        NSData *myData = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
        result = [GTMBase64 stringByEncodingData:myData];
    }
    
    return result;
    
}

+(NSString *)MD5:(NSString *)strData
{
    const char *cStr=[strData UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result);
    
    NSString *ret=[NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",result[0],result[1],result[2],result[3],result[4],result[5],result[6],result[7],result[8],result[9],result[10],result[11],result[12],result[13],result[14],result[15]];
    
    return ret;
}

//根据时间格式获取时间字符串
+(NSString *)getTimeNow:(NSString *)timeFormatter withDate:(NSDate *)date
{
    //NSTimeZone *timeZone=[NSTimeZone timeZoneForSecondsFromGMT:3600*8];
    NSTimeZone *timeZone=[NSTimeZone systemTimeZone];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    if([timeFormatter isEqualToString:@""])
    {
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    else
    {
        [formatter setDateFormat:timeFormatter];
    }
    NSString *dateString=[formatter stringFromDate:date];
    return dateString;
}

+(NSDate *)getDateWithString:(NSString *)strDate andFormatter:(NSString *)formatter
{
    if(strDate == nil || strDate.length<10)
    {
        return nil;
    }
    if(formatter == nil || formatter.length<10)
    {
        formatter=@"yyyy-MM-dd HH:mm:ss";
    }
    NSTimeZone *timeZone=[NSTimeZone timeZoneForSecondsFromGMT:3600*8];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setTimeZone:timeZone];
    [inputFormatter setDateFormat:formatter];
    NSDate* inputDate = [inputFormatter dateFromString:strDate];
    return inputDate;
}


+(int)compareDateWithStartTime:(NSString *)startTime andEndTime:(NSString *)endTime
{
    if(startTime == nil || startTime.length<19)
    {
        return  -1;
    }
    if(endTime == nil || endTime.length<19)
    {
        return -1;
    }
    startTime=[startTime substringToIndex:19];
    endTime=[endTime substringToIndex:19];
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *time1=[df dateFromString:startTime];
    
    NSDate *time2=[df dateFromString:endTime];
    
    switch ([time1 compare:time2]) {
        case NSOrderedSame:
            return  0;   //相当
            break;
        case NSOrderedAscending:  //date1比date2小
            return 1;
            break;
        case NSOrderedDescending:  //date1比date2大
            return 2;
            break;
        default:
            return -1;   //非法时间
            break;
    }
}

+(BOOL)compareDateWithStartDate:(NSString *)startDate andEndDate:(NSString *)endDate
{

    if(startDate == nil || startDate.length<10)
    {
        return  NO;
    }
    if(endDate == nil || endDate.length<10)
    {
        return NO;
    }
    startDate=[startDate substringToIndex:10];
    endDate=[endDate substringToIndex:10];
    NSDateFormatter *df=[[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *date1=[df dateFromString:startDate];
    
    NSDate *date2=[df dateFromString:endDate];
    
    switch ([date1 compare:date2]) {
        case NSOrderedSame:
            return  YES;   //相当
            break;
        case NSOrderedAscending:  //date1比date2小
            return YES;
            break;
        case NSOrderedDescending:  //date1比date2大
            return NO;
            break;
        default:
            return NO;   //非法时间
            break;
    }
}

+ (NSDictionary *)parseQueryString:(NSString *)query
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:6];
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    
    for (NSString *pair in pairs) {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        
        if ([elements count] <= 1) {
            return nil;
        }
        
        NSString *key = [[elements objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *val = [[elements objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [dict setObject:val forKey:key];
    }
    return dict;
}

+(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+(NSArray *)getBoneRangeWithWeight:(NSString *)strWeight andSex:(NSString *)strSex {
    if (strWeight.length < 1) {
        return @[@"1.0",@"1.5"];
    }
    
    NSString *low;
    NSString *high;
    float fWeight = [strWeight floatValue];
    
    if ([strSex isEqualToString:@"男"]) {
        if (fWeight < 60.0) { //2.5kg  2.2 - 2.8
            //low = [NSString stringWithFormat:@"%.1f",2.2 / fWeight * 100];
            //high = [NSString stringWithFormat:@"%.1f",2.8 / fWeight * 100];
            low = @"2.2";
            high = @"2.8";
            return @[low,high];
        } else if (fWeight >= 60.0 && fWeight <= 75.0) { //2.9kg  2.6 - 3.2
            //low = [NSString stringWithFormat:@"%.1f",2.6 / fWeight * 100];
            //high = [NSString stringWithFormat:@"%.1f",3.2 / fWeight * 100];
            
            low = @"2.6";
            high = @"3.2";
            
            return @[low,high];
        } else { //3.2kg  2.9 - 3.5
            //low = [NSString stringWithFormat:@"%.1f",2.9 / fWeight * 100];
            //high = [NSString stringWithFormat:@"%.1f",3.5 / fWeight * 100];
            
            low = @"2.9";
            high = @"3.5";
            
            return @[low,high];
        }
    } else {
        if (fWeight < 45.0) { //1.8kg  1.5 - 2.1
            //low = [NSString stringWithFormat:@"%.1f",1.5 / fWeight * 100];
            //high = [NSString stringWithFormat:@"%.1f",2.1 / fWeight * 100];
            
            low = @"1.5";
            high = @"2.1";
            
            return @[low,high];
        } else if (fWeight >= 45.0 && fWeight <= 60.0) { //2.2kg  1.9 - 2.5
            //low = [NSString stringWithFormat:@"%.1f",1.9 / fWeight * 100];
            //high = [NSString stringWithFormat:@"%.1f",2.5 / fWeight * 100];
            
            low = @"1.9";
            high = @"2.5";
            
            return @[low,high];
        } else { // 2.5kg  2.2 - 2.8
            //low = [NSString stringWithFormat:@"%.1f",2.2 / fWeight * 100];
            //high = [NSString stringWithFormat:@"%.1f",2.8 / fWeight * 100];
            
            low = @"2.2";
            high = @"2.8";
            return @[low,high];
        }
    }
    
    if ([low floatValue] <= 0.0) {
        low = @"1.0";
    }
    
    if ([high floatValue] <= 0.0) {
        high = @"1.5";
    }
}

+(NSDictionary *)getFatRangeWithAge:(NSString *)strAge andSex:(NSString *)strSex
{
    int iAge=[strAge intValue];
    if(iAge<1) iAge=1;
    if(iAge>200) iAge=200;
    NSArray *aryFat;
    NSArray *aryWater;
    NSArray *aryMuscle;
    NSArray *aryBasic;
    NSArray *aryBone;
    
    if([strSex isEqualToString:@"女"])
    {
        //水分
        if(iAge<=30)
        {
            aryWater=[[NSArray alloc] initWithObjects:@"49.5",@"52.9", nil];
        }
        else
        {
            aryWater=[[NSArray alloc] initWithObjects:@"48.1",@"51.5", nil];
        }
        
        //脂肪率
        //脂肪率
        if (iAge <= 39) {
            aryFat=[[NSArray alloc] initWithObjects:@"21.0",@"34.0", nil];
        } else if (iAge >= 40 && iAge <= 59) {
            aryFat=[[NSArray alloc] initWithObjects:@"22.0",@"35.0", nil];
        } else {
            aryFat=[[NSArray alloc] initWithObjects:@"23.0",@"36.0", nil];
        }
        
        //肌肉率
        aryMuscle=[[NSArray alloc] initWithObjects:@"25.0",@"27.0", nil];
        
        //骨量
        if(iAge<39)
        {
            aryBone=[[NSArray alloc] initWithObjects:@"1.4",@"2.0", nil];
        }
        else if (iAge>=40 && iAge<=60)
        {
            aryBone=[[NSArray alloc] initWithObjects:@"1.7",@"2.5", nil];
        }
        else
        {
            aryBone=[[NSArray alloc] initWithObjects:@"1.9",@"2.9", nil];
        }
        
        //基础代谢
        if(iAge<=2)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"560",@"840", nil];
        }
        else if (iAge>=3 && iAge<=5)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"688",@"1032", nil];
        }
        else if (iAge>=6 && iAge<=8)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"800",@"1200", nil];
        }
        else if (iAge>=9 && iAge<=11)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"944",@"1416", nil];
        }
        else if (iAge>=12 && iAge<=14)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"1072",@"1608", nil];
        }
        else if (iAge>=15 && iAge<=17)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"1040",@"1560", nil];
        }
        else if (iAge>=18 && iAge<=29)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"968",@"1452", nil];
        }
        else if (iAge>=30 && iAge<=49)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"936",@"1404", nil];
        }
        else if (iAge>=50 && iAge<=69)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"888",@"1332", nil];
        }
        else
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"808",@"1212", nil];
        }
    }
    else
    {
        //水分
        if(iAge<=30)
        {
            aryWater=[[NSArray alloc] initWithObjects:@"53.6",@"57.0", nil];
        }
        else
        {
            aryWater=[[NSArray alloc] initWithObjects:@"52.3",@"55.6", nil];
        }
        
        //脂肪率
        if (iAge <= 39) {
            aryFat=[[NSArray alloc] initWithObjects:@"11.0",@"21.0", nil];
        } else if (iAge >= 40 && iAge <= 59) {
            aryFat=[[NSArray alloc] initWithObjects:@"12.0",@"22.0", nil];
        } else {
            aryFat=[[NSArray alloc] initWithObjects:@"14.0",@"24.0", nil];
        }
        
        //肌肉率
        aryMuscle=[[NSArray alloc] initWithObjects:@"31.0",@"34.0", nil];
        
        
        //骨量
        if(iAge<54)
        {
            aryBone=[[NSArray alloc] initWithObjects:@"1.9",@"2.9", nil];
        }
        else if (iAge>=55 && iAge<=75)
        {
            aryBone=[[NSArray alloc] initWithObjects:@"2.2",@"3.3", nil];
        }
        else
        {
            aryBone=[[NSArray alloc] initWithObjects:@"2.5",@"3.7", nil];
        }
        
        
        //基础代谢
        if(iAge<=2)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"560",@"840", nil];
        }
        else if (iAge>=3 && iAge<=5)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"720",@"1080", nil];
        }
        else if (iAge>=6 && iAge<=8)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"872",@"1308", nil];
        }
        else if (iAge>=9 && iAge<=11)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"1032",@"1548", nil];
        }
        else if (iAge>=12 && iAge<=14)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"1184",@"1776", nil];
        }
        else if (iAge>=15 && iAge<=17)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"1288",@"1932", nil];
        }
        else if (iAge>=18 && iAge<=29)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"1240",@"1860", nil];
        }
        else if (iAge>=30 && iAge<=49)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"1200",@"1800", nil];
        }
        else if (iAge>=50 && iAge<=69)
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"1080",@"1620", nil];
        }
        else
        {
            aryBasic=[[NSArray alloc] initWithObjects:@"976",@"1464", nil];
        }
    }
    
    
    NSArray *aryBMI=[[NSArray alloc] initWithObjects:@"18.5",@"24.9", nil];
    NSArray *aryViceralfat=[[NSArray alloc] initWithObjects:@"1",@"9", nil];
    
    
    NSMutableDictionary *dic=[[NSMutableDictionary alloc] init];
    [dic setObject:aryFat forKey:ProjectFat];
    [dic setObject:aryWater forKey:ProjectWater];
    [dic setObject:aryMuscle forKey:ProjectMuscle];
    [dic setObject:aryBasic forKey:ProjectBasic];
    [dic setObject:aryBone forKey:ProjectBone];
    [dic setObject:aryBMI forKey:ProjectBMI];
    [dic setObject:aryViceralfat forKey:ProjectVisceralFat];
    
    return dic;
}

+(BOOL)isM7Use
{
    BOOL ret=NO;
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString *machineName = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if(machineName.length>=7)
    {
        NSString *str=[machineName substringWithRange:NSMakeRange(6, 1)];
        int iVersion=[str intValue];
        if(iVersion>=6)
        {
            ret=YES;
        }
    }
    return ret;
}


//计算两个日期的年月日
+(NSDateComponents *)countTimeWithStartDate:(NSString *)startDate andEndDate:(NSString *)endDate
{
    if(startDate==nil || startDate.length<10 || endDate == nil || endDate.length<10)
    {
        return nil;
    }
    
    startDate=[startDate substringToIndex:10];
    endDate=[endDate substringToIndex:10];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSYearCalendarUnit |NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    
    [format setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *dateStart=[format dateFromString:startDate];
    NSDate *dateEnd=[format dateFromString:endDate];
    
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    
    NSInteger frominterval = [fromzone secondsFromGMTForDate: dateStart];
    
    NSDate *fromDate = [dateStart  dateByAddingTimeInterval: frominterval];
    

    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    
    NSInteger interval = [zone secondsFromGMTForDate: dateEnd];
    
    NSDate *localeDate = [dateEnd  dateByAddingTimeInterval: interval];
    
    
    NSDateComponents *components = [gregorian components:unitFlags fromDate:fromDate toDate:localeDate options:0];

    return components;
}

+(NSArray*)getChineseCalendarWithDate:(NSDate *)date{
    
    NSArray *chineseYears = [NSArray arrayWithObjects:
                             @"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
                             @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未",
                             @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
                             @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑",
                             @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
                             @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥", nil];
    
    NSArray *chineseMonths=[NSArray arrayWithObjects:
                            @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
                            @"九月", @"十月", @"冬月", @"腊月", nil];
    
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSChineseCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    
    //NSLog(@"%d_%d_%d  %@",localeComp.year,localeComp.month,localeComp.day, localeComp.date);
    
    NSString *y_str = [chineseYears objectAtIndex:localeComp.year-1];
    NSString *m_str = [chineseMonths objectAtIndex:localeComp.month-1];
    NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
    
    //NSString *chineseCal_str =[NSString stringWithFormat: @"%@_%@_%@",y_str,m_str,d_str];
    
    NSArray *ary=[[NSArray alloc] initWithObjects:y_str,m_str,d_str, nil];
    return ary;
}

+(NSArray *)getTimeWithStrDate:(NSString *)strDate
{
    if(strDate == nil  || strDate.length<18)
    {
        return nil;
    }
    
    
    NSTimeZone *timeZone=[NSTimeZone timeZoneForSecondsFromGMT:3600*8];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *date=[formatter dateFromString:strDate];
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *dateComps;
    dateComps=[calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit|NSWeekCalendarUnit) fromDate:date];
    
    NSString* year=[NSString stringWithFormat:@"%d",[dateComps year]];
    NSString* month=[NSString stringWithFormat:@"%d",[dateComps month]];
    NSString* day=[NSString stringWithFormat:@"%d",[dateComps day]];
    NSString* hour=[NSString stringWithFormat:@"%d",[dateComps hour]];
    NSString* minute=[NSString stringWithFormat:@"%d",[dateComps minute]];
    NSString* second=[NSString stringWithFormat:@"%d",[dateComps second]];
    NSString* week=@"";
    NSString* weekDay=[NSString stringWithFormat:@"%d",[dateComps weekday]];
    
    NSInteger iWeek=[dateComps weekday];
    switch (iWeek)
    {
        case 1:
            week=@"星期天";
            break;
        case 2:
            week=@"星期一";
            break;
        case 3:
            week=@"星期二";
            break;
        case 4:
            week=@"星期三";
            break;
        case 5:
            week=@"星期四";
            break;
        case 6:
            week=@"星期五";
            break;
        case 7:
            week=@"星期六";
            break;
    }
    NSString *monthString=@"一月";
    NSInteger iMonth=[dateComps month];
    switch (iMonth)
    {
        case 1:
            monthString=@"一月";
            break;
        case 2:
            monthString=@"二月";
            break;
        case 3:
            monthString=@"三月";
            break;
        case 4:
            monthString=@"四月";
            break;
        case 5:
            monthString=@"五月";
            break;
        case 6:
            monthString=@"六月";
            break;
        case 7:
            monthString=@"七月";
            break;
        case 8:
            monthString=@"八月";
            break;
        case 9:
            monthString=@"九月";
            break;
        case 10:
            monthString=@"十月";
            break;
        case 11:
            monthString=@"十一月";
            break;
        case 12:
            monthString=@"十二月";
            break;
    }
    
    if(month.length==1) month=[@"0" stringByAppendingString:month];
    if(day.length==1)   day=[@"0" stringByAppendingString:day];
    if(hour.length==1) hour=[@"0" stringByAppendingString:hour];
    if(minute.length==1) minute=[@"0" stringByAppendingString:minute];
    if(second.length==1) second=[@"0" stringByAppendingString:second];
    
    NSArray *aryTime=[[NSArray alloc] initWithObjects:year,month,day,hour,minute,second,week, weekDay,monthString,nil];
    
    return aryTime;
    
}

+(NSArray *)getDateWithDate:(NSDate *)date andCountDay:(int)days
{
    if(date==nil)
    {
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSDate *dateRet = [NSDate dateWithTimeInterval:days*24*60*60 sinceDate:date];
    
    NSString *strToday=[dateFormatter stringFromDate:date];
    NSString *strRet=[dateFormatter stringFromDate:dateRet];
    
    strToday=[NSString stringWithFormat:@"%@ 00:00:00",[strToday substringToIndex:10]];
    strRet=[NSString stringWithFormat:@"%@ 00:00:00",[strRet substringToIndex:10]];
    
    NSArray *aryRet=[[NSArray alloc] initWithObjects:strToday,strRet, nil];
    return aryRet;
}

+(NSString *)getDateWithDate:(NSString *)date andDifferDay :(int)days
{
    if(date==nil || date.length<19)
    {
        return @"";
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateNow=[dateFormatter dateFromString:date];
    
    NSDate *dateRet = [NSDate dateWithTimeInterval:days*24*60*60 sinceDate:dateNow];
    NSString *strRet=[dateFormatter stringFromDate:dateRet];
    
    return strRet;
}

/**
 *@brief 获取当前天跟间隔天
 */
+(NSArray *)getDateRangeWithDays:(int)days
{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSTimeInterval daysInterval=days*secondsPerDay;
    NSDate *dateStart=[NSDate date];
    NSDate *dateEnd=[[NSDate alloc] initWithTimeIntervalSinceNow:daysInterval];
    
    NSString *strStartDate=[PublicModule getTimeNow:@"" withDate:dateStart];
    NSString *strEndDate=[PublicModule getTimeNow:@"" withDate:dateEnd];
    if(strStartDate!=nil && strEndDate != nil)
    {
        NSArray *aryRet=[[NSArray alloc] initWithObjects:strStartDate,strEndDate, nil];
        return aryRet;
    }
    else
    {
        return  nil;
    }
}

+(NSArray *)getChartWeekDayWithDate:(NSDate *)date
{
    NVDate *dateNow=[[NVDate alloc] initUsingDate:[NSDate date]];
    
    
    NSString *strDateNow=[dateNow stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious1=[[dateNow previousDays:1] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious2=[[dateNow previousDays:1] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious3=[[dateNow previousDays:1] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious4=[[dateNow previousDays:1] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious5=[[dateNow previousDays:1] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious6=[[dateNow previousDays:1] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious7=[[dateNow previousDays:1] stringValueWithFormat:@"yyyy-MM-dd"];
    
    //NSString *month=[dateNow stringValueWithFormat:@"M月"];
    NSArray *aryRet=[[NSArray alloc] initWithObjects:datePrevious7,datePrevious6,datePrevious5,datePrevious4,datePrevious3,datePrevious2,datePrevious1,strDateNow, nil];
    
    return aryRet;
}

+(NSArray *)getpreviousWeekDayWithDate:(NSDate *)date
{
    NVDate *dateNow=[[NVDate alloc] initUsingDate:[NSDate date]];
    
    
    NSString *strDateNow=[dateNow stringValueWithFormat:@"M/dd"];
    NSString *datePrevious1=[[dateNow previousDays:1] stringValueWithFormat:@"M/d"];
    NSString *datePrevious2=[[dateNow previousDays:1] stringValueWithFormat:@"M/d"];
    NSString *datePrevious3=[[dateNow previousDays:1] stringValueWithFormat:@"M/d"];
    NSString *datePrevious4=[[dateNow previousDays:1] stringValueWithFormat:@"M/d"];
    NSString *datePrevious5=[[dateNow previousDays:1] stringValueWithFormat:@"M/d"];
    NSString *datePrevious6=[[dateNow previousDays:1] stringValueWithFormat:@"M/d"];
    
    NSString *month=[dateNow stringValueWithFormat:@"Mmon."];
    NSArray *aryRet=[[NSArray alloc] initWithObjects:month,datePrevious6,datePrevious5,datePrevious4,datePrevious3,datePrevious2,datePrevious1,strDateNow, nil];
    
    return aryRet;
}


+(NSArray *)getChartMonthDayWithDate:(NSDate *)date
{
    if(date==nil)
    {
        date=[NSDate date];
    }
    
    NVDate *nvDate=[[NVDate alloc] initUsingDate:[NSDate date]];
    NSString *strDateNow=[nvDate stringValueWithFormat:@"yyyy-MM-dd"];
    
    NSString *datePrevious1=[[nvDate previousDays:7] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious2=[[nvDate previousDays:7] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious3=[[nvDate previousDays:7] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious4=[[nvDate previousDays:7] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious5=[[nvDate previousDays:7] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious6=[[nvDate previousDays:7] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious7=[[nvDate previousDays:7] stringValueWithFormat:@"yyyy-MM-dd"];
    
    //NSString *year=[nvDate stringValueWithFormat:@"yyyy年"];
    NSArray *aryRet=[[NSArray alloc] initWithObjects:datePrevious7,datePrevious6,datePrevious5,datePrevious4,datePrevious3,datePrevious2,datePrevious1,strDateNow, nil];
    
    return aryRet;
}

+(NSArray *)getpreviousMonthDayWithDate:(NSDate *)date
{
    //NSTimeInterval secondsPerDay = 24 * 60 * 60;
    
    if(date==nil)
    {
        date=[NSDate date];
    }
    
    NVDate *nvDate=[[NVDate alloc] initUsingDate:[NSDate date]];
    NSString *strDateNow=[nvDate stringValueWithFormat:@"M/dd"];
    
    NSString *datePrevious1=[[nvDate previousDays:7] stringValueWithFormat:@"M/d"];
    NSString *datePrevious2=[[nvDate previousDays:7] stringValueWithFormat:@"M/d"];
    NSString *datePrevious3=[[nvDate previousDays:7] stringValueWithFormat:@"M/d"];
    NSString *datePrevious4=[[nvDate previousDays:7] stringValueWithFormat:@"M/d"];
    NSString *datePrevious5=[[nvDate previousDays:7] stringValueWithFormat:@"M/d"];
    NSString *datePrevious6=[[nvDate previousDays:7] stringValueWithFormat:@"M/d"];
    
    NSString *year=[nvDate stringValueWithFormat:@"yyyy"];
    NSArray *aryRet=[[NSArray alloc] initWithObjects:year,datePrevious6,datePrevious5,datePrevious4,datePrevious3,datePrevious2,datePrevious1,strDateNow, nil];
    
    return aryRet;
}

+(NSArray *)getChartAllDayWithStartDate:(NSDate *)date andEndDate:(NSDate *)endDate
{
    if(date == nil || endDate == nil)
    {
        return nil;
    }
    
    if([date compare:endDate] == NSOrderedDescending)
    {
        return nil;
    }
    
    NVDate *nvStart=[[NVDate alloc] initUsingDate:date];
    NVDate *nvEnd=[[NVDate alloc] initUsingDate:endDate];
    
    NSString *days=[self getDays:[nvStart stringValueWithFormat:@"yyyy-MM-dd"] withDate:[nvEnd stringValueWithFormat:@"yyyy-MM-dd"]];
    if(days.length<1)
    {
        return nil;
    }
    
    CGFloat fDays=[days floatValue];
    
    CGFloat fCount=fDays/7.0;
    fCount=ceilf(fCount);
    
    int iCount=(int)fCount;
    NVDate *nvDate=[[NVDate alloc] initUsingDate:[NSDate date]];
    NSString *strDateNow=[nvDate stringValueWithFormat:@"yyyy-MM-dd"];
    
    NSString *datePrevious1=[[nvDate previousDays:iCount] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious2=[[nvDate previousDays:iCount] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious3=[[nvDate previousDays:iCount] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious4=[[nvDate previousDays:iCount] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious5=[[nvDate previousDays:iCount] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious6=[[nvDate previousDays:iCount] stringValueWithFormat:@"yyyy-MM-dd"];
    NSString *datePrevious7=[[nvDate previousDays:iCount] stringValueWithFormat:@"yyyy-MM-dd"];
    
    //NSString *year=[nvDate stringValueWithFormat:@"yyyy年"];
    NSArray *aryRet=[[NSArray alloc] initWithObjects:datePrevious7,datePrevious6,datePrevious5,datePrevious4,datePrevious3,datePrevious2,datePrevious1,strDateNow, nil];
    
    return aryRet;
}

+(NSArray *)getpreviousAllDayWithStartDate:(NSDate *)date andEndDate:(NSDate *)endDate
{
    if(date == nil || endDate == nil)
    {
        return nil;
    }
    
    if([date compare:endDate] == NSOrderedDescending)
    {
        return nil;
    }
    
    NVDate *nvStart=[[NVDate alloc] initUsingDate:date];
    NVDate *nvEnd=[[NVDate alloc] initUsingDate:endDate];
    
    NSString *days=[self getDays:[nvStart stringValueWithFormat:@"yyyy-MM-dd"] withDate:[nvEnd stringValueWithFormat:@"yyyy-MM-dd"]];
    if(days.length<1)
    {
        return nil;
    }
    
    CGFloat fDays=[days floatValue];
    
    CGFloat fCount=fDays/7.0;
    fCount=ceilf(fCount);
    
    int iCount=(int)fCount;
    NVDate *nvDate=[[NVDate alloc] initUsingDate:[NSDate date]];
    NSString *strDateNow=[nvDate stringValueWithFormat:@"M/dd"];
    
    NSString *datePrevious1=[[nvDate previousDays:iCount] stringValueWithFormat:@"M/d"];
    NSString *datePrevious2=[[nvDate previousDays:iCount] stringValueWithFormat:@"M/d"];
    NSString *datePrevious3=[[nvDate previousDays:iCount] stringValueWithFormat:@"M/d"];
    NSString *datePrevious4=[[nvDate previousDays:iCount] stringValueWithFormat:@"M/d"];
    NSString *datePrevious5=[[nvDate previousDays:iCount] stringValueWithFormat:@"M/d"];
    NSString *datePrevious6=[[nvDate previousDays:iCount] stringValueWithFormat:@"M/d"];
    
    NSString *year=[nvDate stringValueWithFormat:@"yyyy"];
    NSArray *aryRet=[[NSArray alloc] initWithObjects:year,datePrevious6,datePrevious5,datePrevious4,datePrevious3,datePrevious2,datePrevious1,strDateNow, nil];
    
    return aryRet;
}

+(NSArray *)getpreviousYearDayWithDate:(NSDate *)date
{
    NSArray *ret=[[NSArray alloc] initWithObjects:@"2015年",@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月", nil];
    
    return ret;
}

+(NSArray *)getBeforeWeekDayWithDate:(NSDate *)date
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;

    if(date==nil)
    {
        date=[NSDate date];
    }
    //NSDate *dateNow=[NSDate date];
    NSMutableArray *aryRet=[[NSMutableArray alloc] init];
    NSString *strDateNow=[PublicModule getTimeNow:@"yyyy-MM-dd" withDate:date];
    [aryRet addObject:strDateNow];
    for(int i=1;i<=6;i++)
    {
        //NSDate *date1=[[NSDate alloc] initWithTimeIntervalSinceNow:-i*secondsPerDay];
        NSDate *date1=[NSDate dateWithTimeInterval:-i*secondsPerDay sinceDate:date];
        NSString *strDate=[PublicModule getTimeNow:@"yyyy-MM-dd" withDate:date1];
        [aryRet addObject:strDate];
    }
    
    NSArray *ret=[[aryRet reverseObjectEnumerator] allObjects];
    
    return ret;
}

+(NSArray *)getBeforeMonthDayWithDate:(NSDate *)date
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;

    if(date==nil)
    {
        date=[NSDate date];
    }
    //NSDate *dateNow=[NSDate date];
    NSMutableArray *aryRet=[[NSMutableArray alloc] init];
    NSString *strDateNow=[PublicModule getTimeNow:@"yyyy-MM-dd" withDate:date];
    [aryRet addObject:strDateNow];
    for(int i=1;i<=29;i++)
    {
        //NSDate *date1=[[NSDate alloc] initWithTimeIntervalSinceNow:-i*secondsPerDay];
        NSDate *date1=[NSDate dateWithTimeInterval:-i*secondsPerDay sinceDate:date];
        NSString *strDate=[PublicModule getTimeNow:@"yyyy-MM-dd" withDate:date1];
        [aryRet addObject:strDate];
    }
    
    NSArray *ret=[[aryRet reverseObjectEnumerator] allObjects];
    
    return ret;
}

+(NSArray *)getbeforeYearDayWithDate:(NSDate *)date
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;

    if(date==nil)
    {
        date=[NSDate date];
    }
    //NSDate *dateNow=[NSDate date];
    NSMutableArray *aryRet=[[NSMutableArray alloc] init];
    NSString *strDateNow=[PublicModule getTimeNow:@"yyyy-MM-dd" withDate:date];
    [aryRet addObject:strDateNow];
    for(int i=1;i<=12;i++)
    {
        //NSDate *date1=[[NSDate alloc] initWithTimeIntervalSinceNow:-i*30*secondsPerDay];
        NSDate *date1=[NSDate dateWithTimeInterval:-i*30*secondsPerDay sinceDate:date];
        NSString *strDate=[PublicModule getTimeNow:@"yyyy-MM-dd" withDate:date1];
        [aryRet addObject:strDate];
    }
    
    NSArray *ret=[[aryRet reverseObjectEnumerator] allObjects];
    
    return ret;
}

+(NSArray *)getBeforeFortyWeekWithDate:(NSDate *)date
{
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    if(date==nil)
    {
        date=[NSDate date];
    }
    //NSDate *dateNow=[NSDate date];
    NSMutableArray *aryRet=[[NSMutableArray alloc] init];
    NSString *strDateNow=[PublicModule getTimeNow:@"yyyy-MM-dd" withDate:date];
    [aryRet addObject:strDateNow];
    for(int i=1;i<=10;i++)
    {
       // NSDate *date1=[[NSDate alloc] initWithTimeIntervalSinceNow:-i*28*secondsPerDay];
        NSDate *date1=[NSDate dateWithTimeInterval:-i*28*secondsPerDay sinceDate:date];
        NSString *strDate=[PublicModule getTimeNow:@"yyyy-MM-dd" withDate:date1];
        [aryRet addObject:strDate];
    }
    
    NSArray *ret=[[aryRet reverseObjectEnumerator] allObjects];
    
    return ret;
}

/**
 *@brief 根据NSdate获得时间数组
 *@return 时间数组:年，月，日，时，分，秒，星期几，周的int形式
 */
+(NSArray *)getTimeWithDate:(NSDate *)date
{
    if(date == nil)
    {
        return nil;
    }
    NSTimeZone *timeZone=[NSTimeZone timeZoneForSecondsFromGMT:3600*8];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSDateComponents *dateComps;
    dateComps=[calendar components:(NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekdayCalendarUnit|NSWeekCalendarUnit) fromDate:date];
    
    NSString* year=[NSString stringWithFormat:@"%ld",(long)[dateComps year]];
    NSString* month=[NSString stringWithFormat:@"%ld",(long)[dateComps month]];
    NSString* day=[NSString stringWithFormat:@"%ld",(long)[dateComps day]];
    NSString* hour=[NSString stringWithFormat:@"%ld",(long)[dateComps hour]];
    NSString* minute=[NSString stringWithFormat:@"%ld",(long)[dateComps minute]];
    NSString* second=[NSString stringWithFormat:@"%ld",(long)[dateComps second]];
    NSString* week=@"";
    NSString* weekDay=[NSString stringWithFormat:@"%ld",(long)[dateComps week]];
    switch ([dateComps weekday])
    {
        case 1:
            week=@"星期天";
            break;
        case 2:
            week=@"星期一";
            break;
        case 3:
            week=@"星期二";
            break;
        case 4:
            week=@"星期三";
            break;
        case 5:
            week=@"星期四";
            break;
        case 6:
            week=@"星期五";
            break;
        case 7:
            week=@"星期六";
            break;
    }
    
    if(month.length==1) month=[@"0" stringByAppendingString:month];
    if(day.length==1)   day=[@"0" stringByAppendingString:day];
    if(hour.length==1) hour=[@"0" stringByAppendingString:hour];
    if(minute.length==1) minute=[@"0" stringByAppendingString:minute];
    if(second.length==1) second=[@"0" stringByAppendingString:second];
    
    NSArray *aryTime=[[NSArray alloc] initWithObjects:year,month,day,hour,minute,second,week, weekDay,nil];
    
    return aryTime;
}

//根据NSDate获取时间戳
+(NSString *)getMyTimeInterval:(NSDate *)date
{
    if(date == nil)
    {
        return nil;
    }
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return timeSp;
}

//时间戳转化为NSDate
+(NSString *)timeintervalToDate:(NSString *)time
{
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[time integerValue]];
    
    NSString *ret=@"";
    if(confromTimesp != nil)
    {
        NSTimeZone *timeZone=[NSTimeZone timeZoneForSecondsFromGMT:3600*8];
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        [formatter setTimeZone:timeZone];
        
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        ret=[formatter stringFromDate:confromTimesp];
    }
    return ret;
}

//检查网络状态
+(BOOL)checkNetworkStatus
{
    BOOL ret=NO;
    
    AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    if(delegate.iNetworkStats == 1 || delegate.iNetworkStats == 2)
    {
        ret = YES;
    }
    /*
    NSString *urlString=@"appalpha.iygdy.com";
    Reachability *reach=[Reachability reachabilityWithHostName:urlString];
    switch ([reach currentReachabilityStatus])
    {
        case NotReachable:  //没有网络连接
            ret=NO;
            break;
        case ReachableViaWiFi:  //wifi
            ret=YES;
            break;
        case ReachableViaWWAN:  //3g
            ret=YES;
            break;
    }
     */
    return ret;
}


/**
 *@brief 获取图表数据平均值
 */
+(NSString *)getChartAvgValue:(NSArray *)aryData
{
    if(aryData == nil || [aryData count]<1)
    {
        return @"0";
    }
    NSMutableArray *aryRet=[[NSMutableArray alloc] init];
    double dCount=0;
    for(int i=0;i<aryData.count;i++)
    {
        if([[aryData objectAtIndex:i] doubleValue] <= 0)
        {
            continue;
        }
        else
        {
            [aryRet addObject:[aryData objectAtIndex:i]];
            dCount=dCount+[[aryData objectAtIndex:i] doubleValue];
        }
    }
    if(aryRet.count<1)
    {
        return @"0";
    }
    
    dCount=dCount/aryRet.count;

    NSString *strRet=[NSString stringWithFormat:@"%.1f",dCount];

    return strRet;
}

+(NSArray *)getMaxAndMinWithoutZero:(NSArray *)aryData
{
    if(aryData == nil || [aryData count]<1) return nil;
    NSMutableArray *aryReturn=[[NSMutableArray alloc] initWithObjects:@"0",@"0", nil];
    [aryReturn replaceObjectAtIndex:0 withObject:[aryData objectAtIndex:0]]; //
    [aryReturn replaceObjectAtIndex:1 withObject:[aryData objectAtIndex:0]];
    
    for(int i=0;i<aryData.count;i++)
    {
        NSString *strTemp=[aryData objectAtIndex:i];
        if([strTemp doubleValue]<=0)
        {
            continue;
        }
        else
        {
            [aryReturn replaceObjectAtIndex:0 withObject:strTemp];
            [aryReturn replaceObjectAtIndex:1 withObject:strTemp];
        }
        
    }
    for(int i=0;i<[aryData count];i++)
    {
        NSString *strTemp=[aryData objectAtIndex:i];
        if([strTemp doubleValue]<=0)
        {
            continue;
        }
        if([[aryData objectAtIndex:i] doubleValue]>=[[aryReturn objectAtIndex:1] doubleValue])
        {
            [aryReturn replaceObjectAtIndex:1 withObject:[aryData objectAtIndex:i]];
        }
        else if([[aryData objectAtIndex:i] doubleValue]<=[[aryReturn objectAtIndex:0] doubleValue])
        {
            [aryReturn replaceObjectAtIndex:0 withObject:[aryData objectAtIndex:i]];
        }
    }
    NSString *strMin=[NSString stringWithFormat:@"%.1f",[[aryReturn objectAtIndex:0] floatValue]];
    NSString *strMax=[NSString stringWithFormat:@"%.1f",[[aryReturn objectAtIndex:1] floatValue]];
    [aryReturn replaceObjectAtIndex:0 withObject:strMin];
    [aryReturn replaceObjectAtIndex:1 withObject:strMax];
    return aryReturn;
}

/**
 *@brief 获取数组里面的最大最小值  0:最小值  1:最大值
 */
+(NSArray *)getMaxAndMin:(NSArray *)aryData
{
    if(aryData == nil || [aryData count]<1) return nil;
    NSMutableArray *aryReturn=[[NSMutableArray alloc] initWithObjects:@"0",@"0", nil];
    [aryReturn replaceObjectAtIndex:0 withObject:[aryData objectAtIndex:0]]; //
    [aryReturn replaceObjectAtIndex:1 withObject:[aryData objectAtIndex:0]];
    for(int i=0;i<[aryData count];i++)
    {
        if([[aryData objectAtIndex:i] doubleValue]>=[[aryReturn objectAtIndex:1] doubleValue])
        {
            [aryReturn replaceObjectAtIndex:1 withObject:[aryData objectAtIndex:i]];
        }
        else if([[aryData objectAtIndex:i] doubleValue]<=[[aryReturn objectAtIndex:0] doubleValue])
        {
            [aryReturn replaceObjectAtIndex:0 withObject:[aryData objectAtIndex:i]];
        }
    }
    NSString *strMin=[NSString stringWithFormat:@"%.1f",[[aryReturn objectAtIndex:0] floatValue]];
    NSString *strMax=[NSString stringWithFormat:@"%.1f",[[aryReturn objectAtIndex:1] floatValue]];
    [aryReturn replaceObjectAtIndex:0 withObject:strMin];
    [aryReturn replaceObjectAtIndex:1 withObject:strMax];
    return aryReturn;
}

#pragma mark 获取两个日期间隔的天数
+(NSString *)getDays:(NSString *)date withDate:(NSString *)date1
{
    if(date1==nil || date == nil) return @"0";
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *dateStart=[dateFormatter dateFromString:date];  //将末次月经日期字符串转化为NSDate格式
    NSDate *dateEnd=[dateFormatter dateFromString:date1];
    
    NSTimeInterval timeCount=[dateEnd timeIntervalSinceDate:dateStart];  //末次月经时间跟提醒时间的间隔天数
    
    int days=((int)timeCount)/(3600*24);
    NSString *strReturn=[NSString stringWithFormat:@"%d",days+1];
    return strReturn;
}

+(BOOL)checkDoingNum:(NSString *)doingNum
{
    NSString *regex = @"\\w{4,20}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:doingNum];
}

+(BOOL)checkTel:(NSString *)strPhone
{
   // NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,3,5-9]))\\d{8}$";
    NSString *regex = @"^((1[1-9]))\\d{9}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:strPhone];
}

+(BOOL)checkNickname:(NSString *)nickname
{
    NSString *regex = @"^[A-Za-z0-9\u4E00-\u9FA5_-]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [pred evaluateWithObject:nickname];
}

//检查6-18位密码
+(BOOL)checkPassword:(NSString *)strPwd
{
    NSString *Regex = @"\\w{6,18}";

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", Regex];

    return [pred evaluateWithObject:strPwd];
}


+(BOOL)checkLogin
{
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *ctime=[ud objectForKey:@"u_id"];
    
    if(ctime == nil ||
       [ctime isEqualToString:@"-1"]||
       [ctime isEqualToString:@""])
    {
        return NO;
    }
    return YES;
}

+(BOOL)checkLoginStatus
{
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *ctime=[ud objectForKey:@"c_time"];

    if(ctime==nil||
       [ctime isEqualToString:@"-1"]||
       [ctime isEqualToString:@""])
    {
        return NO;
    }
    if(ctime==nil||
       [ctime isEqualToString:@"-1"]||
       [ctime isEqualToString:@""])
    {
        return NO;
    }
    return YES;
}

+(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,5}";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

+(BOOL)checkGMID
{
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *uid=[ud objectForKey:@"u_id"];
    NSString *gmid=[ud objectForKey:@"gm_id"];
 
    if(uid==nil||
       [uid isEqualToString:@"-1"]||
       [uid isEqualToString:@""])
    {
        [Dialog simpleToast:@"亲，请先登录哦"];
        return NO;
    }
    if(gmid==nil||
       [gmid isEqualToString:@"-1"]||
       [gmid isEqualToString:@""])
    {
        //[Dialog simpleToast:@"亲，请先选择用户"];
        return NO;
    }
    return YES;
}

+(NSString *)base64DecodeWithString:(NSString *)strTemp
{
    if(strTemp ==nil || [strTemp isEqualToString:@""])
    {
        return @"";
    }
    
    NSData* decodeData = [[NSData alloc] initWithBase64EncodedString:strTemp options:0];
    
    NSString* decodeStr = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    
    return decodeStr;
}

+(NSString *)base64EncodeWithString:(NSString *)strTemp
{
    if(strTemp ==nil || [strTemp isEqualToString:@""])
    {
        return @"";
    }
    
    NSData *textData=[strTemp dataUsingEncoding:NSUTF8StringEncoding];
    NSString *encodeStr=[textData base64Encoding];
    
    /*
    NSData* originData = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* encodeResult = [originData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    */
    return encodeStr;
}
@end

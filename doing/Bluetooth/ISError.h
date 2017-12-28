#import <Foundation/Foundation.h>

@interface ISError : NSError
{
    NSString *errorDescription;
}
- (void) setErrorDescription:(NSString *)str;
@end
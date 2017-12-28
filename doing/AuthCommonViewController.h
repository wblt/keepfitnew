#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"

@interface AuthCommonViewController : UIViewController<ASIHTTPRequestDelegate,HPGrowingTextViewDelegate> {
    NSUserDefaults *_ud;
}

@property (retain,nonatomic) ASIFormDataRequest *request;
@property (retain,nonatomic) UIView *viewNotiStatus;
@property (retain,nonatomic) UILabel *lblNotiStatus;

-(void)doRequestWithURL:(NSURL *)url andJson:(NSString *)strJson;
-(void)afnRequestWithURL:(NSString *)strURL andJson:(NSString *)strJson;
-(void)showErrorMessage:(NSString *)msg;
-(void)showMessage:(NSString *)msg;
-(void)showWithText:(NSString *)text andHideAfter:(NSTimeInterval)timeout;
-(void)showNotiWithText:(NSString *)text;
-(void)hideNotiView;
@end

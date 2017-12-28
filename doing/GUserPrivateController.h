#import <UIKit/UIKit.h>

@interface GUserPrivateController : AuthCommonViewController<UIGestureRecognizerDelegate>
{
    int viewHeight;
    BOOL canSendAuthcode;
    NSString *strAuthCode;
    NSTimer *timerAuthcode;
    int iAuthcodeTime;
    
    NSString *_uname;
    NSString *_upwd;
    NSString *_uid;
    NSString *_utype;
    NSString *_unickname;
    DbModel *_db;
    AppDelegate *_delegate;
    
    NetworkModule *_network;
    int iOperationType;
    BOOL _isNav;
    
    BOOL _canGotoMain;
    
    BOOL _qqClick;
    BOOL _sinaClick;
    
    NSArray *_aryService;
    
    BOOL _canRegister;
    BOOL _canGoBack;
}


@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UILabel *lblTopTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBackIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;


- (void)setCanGoback:(BOOL)aBool;
- (void)setIsNav:(BOOL)isNav;

- (IBAction)goback:(id)sender;

@end

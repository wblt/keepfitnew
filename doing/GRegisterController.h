#import <UIKit/UIKit.h>

@interface GRegisterController : AuthCommonViewController<UITextFieldDelegate>
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
    
    NSString *_registerCTime;
}

@property (weak, nonatomic) IBOutlet UIView *viewTextPhoneLine;
@property (weak, nonatomic) IBOutlet UIView *viewTextPwdLine;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;



@property (weak, nonatomic) IBOutlet UITextField *textPhone;
@property (weak, nonatomic) IBOutlet UITextField *textPwd;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *viewCover;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UILabel *lblTopTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBackIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UILabel *lblMail;
@property (weak, nonatomic) IBOutlet UILabel *lblPwd;
@property (weak, nonatomic) IBOutlet UITextField *textConfirmPwd;

@property (weak, nonatomic) IBOutlet UIView *viewTextConfirmLine;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmPwd;


- (void)setIsNav:(BOOL)isNav;
- (IBAction)gotoLogin:(id)sender;
- (IBAction)goback:(id)sender;



@end
#import <UIKit/UIKit.h>

@interface GEditPwdController : AuthCommonViewController<UITableViewDataSource,UITableViewDelegate>

{
    NetworkModule *_jsonModule;
    DbModel *_db;
    
    BOOL _reloading;
    
    NSMutableArray *_aryFriends;

    
    int _currentQuestionPage;
    int SumPageReceive;
    
    NSString *strAllScore;
    BOOL isSign;
    int iTableType;
    
    NSString *strFriendNum;

}

@property (weak, nonatomic) IBOutlet UITextField *textOldPwd;
@property (weak, nonatomic) IBOutlet UITextField *textNewPwd;
@property (weak, nonatomic) IBOutlet UITextField *textConfirmPwd;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnFinish;
@property (weak, nonatomic) IBOutlet UIView *viewContent;
@property (weak, nonatomic) IBOutlet UIView *viewLine1;
@property (weak, nonatomic) IBOutlet UIView *viewLine2;
@property (weak, nonatomic) IBOutlet UILabel *lblOldPwd;
@property (weak, nonatomic) IBOutlet UILabel *lblNewPwd;
@property (weak, nonatomic) IBOutlet UILabel *lblConfirmPwd;



@property (weak, nonatomic) IBOutlet UIButton *btnBack;


- (IBAction)goback:(id)sender;
- (IBAction)savePwd:(id)sender;


@end

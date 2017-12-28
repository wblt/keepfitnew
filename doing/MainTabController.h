#import <UIKit/UIKit.h>

@interface MainTabController : UIViewController<UINavigationControllerDelegate>
{
    UIViewController  *_currentMainController;
    CGRect frameBtnPhoto;
    CGRect frameBtnPhotoText;
    CGRect frameBtnVideo;
    
    NSMutableArray *aryWeight;
    NSMutableArray *aryLbWeight;
    NSMutableArray *aryWeight2;  //体重后面的小数点
    NSMutableArray *aryStep;
    
    int _iPickerType;
    BOOL _isLbUnit;
}

@property (strong, nonatomic) IBOutlet UIView *tabview;
@property (weak, nonatomic) IBOutlet UIButton *btnTrends;
@property (weak, nonatomic) IBOutlet UIButton *btnMsg;
@property (weak, nonatomic) IBOutlet UIButton *btnCreate;
@property (weak, nonatomic) IBOutlet UIButton *btnSquare;
@property (weak, nonatomic) IBOutlet UIButton *btnMine;
@property (weak, nonatomic) IBOutlet UIView *viewMenu;
@property (weak, nonatomic) IBOutlet UILabel *lblTrends;
@property (weak, nonatomic) IBOutlet UILabel *lblMsg;
@property (weak, nonatomic) IBOutlet UILabel *lblSquare;
@property (weak, nonatomic) IBOutlet UILabel *lblMine;
@property (weak, nonatomic) IBOutlet UIView *viewBottomBg;
@property (weak, nonatomic) IBOutlet UIView *viewCover;
@property (weak, nonatomic) IBOutlet UIView *viewPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerTargetWeight;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerTargetStep;
@property (weak, nonatomic) IBOutlet UIButton *btnPickerCancle;
@property (weak, nonatomic) IBOutlet UIButton *btnPickerFinish;


- (IBAction)gotoTrends:(id)sender;
- (IBAction)gotoMsg:(id)sender;
- (IBAction)gotoHomePage:(id)sender;
- (IBAction)gotoSquare:(id)sender;
- (IBAction)gotoMine:(id)sender;
- (IBAction)canclePickerView:(id)sender;
- (IBAction)finishPickerView:(id)sender;

- (void)showTargetWeighgPicker:(BOOL)aBool withTarget:(NSString *)target showTarget:(NSString *)targetShow;
- (void)showTargetStepPicker:(BOOL)aBool withTarget:(NSString *)target;
- (void)showUnreadCount;
- (void)gotoFriendProfile:(NSMutableDictionary *)dic;
- (void)gotoLogin;
- (void)gotoSearchFriend;
- (void)gotoFindFriend;
@end

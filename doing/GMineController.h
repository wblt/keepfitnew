#import <UIKit/UIKit.h>

@interface GMineController : AuthCommonViewController<UIBarPositioningDelegate,UIGestureRecognizerDelegate>
{
    NetworkModule *_jsonModule;
    DbModel *_db;
    PublicModule *_publicModel;
    AppDelegate *_delegate;
    CGFloat viewHeight;
    NSIndexPath *_selectedIndex;
    
    UIPanGestureRecognizer *_panGestureReconginzer;
    
    CGFloat selectCellHeight;
    CGPoint _selectTableOffset;
    
    BOOL isShowKeyboard;
    BOOL isSelfController;
    
    NSString *_selectDate;
    CGFloat _ty;
}

@property (copy, nonatomic) void(^GoBack)(void);
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UIView *viewTop;

@property (weak, nonatomic) UIView *viewFriends;
@property (weak, nonatomic) UIView *viewFocus;
@property (weak, nonatomic) IBOutlet UIButton *btnSetting;
@property (weak, nonatomic) IBOutlet UIView *viewDate;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekDay1;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekDay2;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekDay3;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekDay4;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekDay5;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekDay6;
@property (weak, nonatomic) IBOutlet UILabel *lblWeekDay7;
@property (weak, nonatomic) IBOutlet UIImageView *imageDateLine;

@property (weak, nonatomic) IBOutlet UILabel *lblDay1;
@property (weak, nonatomic) IBOutlet UILabel *lblDay2;
@property (weak, nonatomic) IBOutlet UILabel *lblDay3;
@property (weak, nonatomic) IBOutlet UILabel *lblDay4;
@property (weak, nonatomic) IBOutlet UILabel *lblDay5;
@property (weak, nonatomic) IBOutlet UILabel *lblDay6;
@property (weak, nonatomic) IBOutlet UILabel *lblDay7;

@property (weak, nonatomic) IBOutlet UIButton *btnDate1;
@property (weak, nonatomic) IBOutlet UIButton *btnDate2;
@property (weak, nonatomic) IBOutlet UIButton *btnDate3;
@property (weak, nonatomic) IBOutlet UIButton *btnDate4;
@property (weak, nonatomic) IBOutlet UIButton *btnDate5;
@property (weak, nonatomic) IBOutlet UIButton *btnDate6;
@property (weak, nonatomic) IBOutlet UIButton *btnDate7;
@property (weak, nonatomic) IBOutlet UILabel *lblTopTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageLine;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIButton *btnShare;

@property (weak, nonatomic) IBOutlet UIView *viewOperation;
@property (weak, nonatomic) IBOutlet UIView *viewShare;
@property (weak, nonatomic) IBOutlet UIView *viewShareCancle;
@property (weak, nonatomic) IBOutlet UIButton *btnShareCancle;

@property (weak, nonatomic) IBOutlet UIButton *btnShareTimeline;
@property (weak, nonatomic) IBOutlet UIButton *btnShareWechatFriend;
@property (weak, nonatomic) IBOutlet UIButton *btnShareQZone;
@property (weak, nonatomic) IBOutlet UIButton *btnShareWeibo;


@property (weak, nonatomic) IBOutlet UILabel *lblShareTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWechatSquare;
@property (weak, nonatomic) IBOutlet UILabel *lblWechatFriend;
@property (weak, nonatomic) IBOutlet UILabel *lblQZone;
@property (weak, nonatomic) IBOutlet UILabel *lblWeibo;
@property (weak, nonatomic) IBOutlet UIView *viewCover;


- (IBAction)clickDate:(id)sender;
- (IBAction)gotoSetting:(id)sender;
- (IBAction)cancleShare:(id)sender;
- (IBAction)showViewOperation:(id)sender;



@end

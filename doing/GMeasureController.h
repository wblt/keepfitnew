#import <UIKit/UIKit.h>

@interface GMeasureController : AuthCommonViewController<UIBarPositioningDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate>
{
  
    NetworkModule *_jsonModule;
    DbModel *_db;
    AppDelegate *_delegate;
    CGFloat viewHeight;
    NSIndexPath *_selectedIndex;
    
    UIPanGestureRecognizer *_panGestureReconginzer;
    
    CGFloat selectCellHeight;
    CGPoint _selectTableOffset;
    
    BOOL isShowKeyboard;
    BOOL isSelfController;
    CGFloat _ty;
    
    CGFloat _lastContentOffsetY;
    NSString *_targetWeight;
    
    NSString *_lastMeasureFat;
    
    CGFloat _tableviewBottomY;
    
    int _iPanState;
    NSString *_targetShow;
}

@property (copy, nonatomic) void(^GoBack)(void);
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UIView *viewTop;

@property (weak, nonatomic) UIView *viewFriends;
@property (weak, nonatomic) UIView *viewFocus;

@property (weak, nonatomic) IBOutlet UILabel *lblTopTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageLine;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *lblTargetWeight;
@property (weak, nonatomic) IBOutlet UIView *viewTargetLineBottom;
@property (weak, nonatomic) IBOutlet UIView *viewTargetLineFront;
@property (weak, nonatomic) IBOutlet UILabel *lblTargetPlus;
@property (weak, nonatomic) IBOutlet UIImageView *imageBMIRange;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeLow;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeNormal;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeHigh;
@property (weak, nonatomic) IBOutlet UIImageView *imageRangeLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeBMITitle;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeBMI;
@property (weak, nonatomic) IBOutlet UILabel *lblWeight;
@property (weak, nonatomic) IBOutlet UILabel *lblWeightUnit;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UILabel *lblWeightBig;

@property (weak, nonatomic) IBOutlet UILabel *lblTargetLow;
@property (weak, nonatomic) IBOutlet UILabel *lblTargetHigh;

- (IBAction)testShowMeasure:(id)sender;


@end

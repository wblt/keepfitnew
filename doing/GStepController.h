#import <UIKit/UIKit.h>


@interface GStepController : AuthCommonViewController<UIBarPositioningDelegate,UIGestureRecognizerDelegate>
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
    
    NSString *_targetStep;
    
    BOOL _isFirstShow;
    
    BOOL _isUpdateStep;
}

@property (copy, nonatomic) void(^GoBack)(void);
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UIView *viewTop;

@property (weak, nonatomic) UIView *viewFriends;
@property (weak, nonatomic) UIView *viewFocus;

@property (weak, nonatomic) IBOutlet UILabel *lblTopTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageLine;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *lblStep;
@property (weak, nonatomic) IBOutlet UILabel *lblTargetStep;

@property (weak, nonatomic) IBOutlet UILabel *lblTimeTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblKMTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblKCalTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblKM;
@property (weak, nonatomic) IBOutlet UILabel *lblKcal;

@property (weak, nonatomic) IBOutlet UILabel *lblStepTitle;
@property (weak, nonatomic) IBOutlet UIView *viewChart;
@property (weak, nonatomic) IBOutlet UIImageView *imageChartLine1;
@property (weak, nonatomic) IBOutlet UIImageView *imageChartLine2;
@property (weak, nonatomic) IBOutlet UIView *viewChartLineBottom;
@property (weak, nonatomic) IBOutlet UILabel *lblChartHigh;
@property (weak, nonatomic) IBOutlet UILabel *lblChartLow;
@property (weak, nonatomic) IBOutlet UILabel *lblChartTime1;
@property (weak, nonatomic) IBOutlet UILabel *lblChartTime2;
@property (weak, nonatomic) IBOutlet UILabel *lblChartTime3;
@property (weak, nonatomic) IBOutlet UILabel *lblChartTime4;

@property (weak, nonatomic) IBOutlet UIImageView *imageLineData1;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData2;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData3;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData4;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData5;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData6;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData7;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData8;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData9;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData10;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData11;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData12;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData13;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData14;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData15;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData16;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData17;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData18;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData19;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData20;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData21;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData22;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData23;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineData24;
- (IBAction)testUpdate:(id)sender;
-(void)updateAppleHealth;
-(void)refreshChartData;
@end

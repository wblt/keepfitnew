#import <UIKit/UIKit.h>
#import "CorePlot1.6/CorePlotHeaders/CorePlot-CocoaTouch.h"

typedef NS_ENUM(NSInteger,ChartType){
    ChartWeek=1,
    ChartMonth=2,
    ChartYear=3
};

@interface GAnalysisController : AuthCommonViewController<UIBarPositioningDelegate,UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
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
    
    
    ChartType _chartType;
    NSMutableDictionary *_dicChartTime;
    
    
    NSMutableArray *dataArray;
    NSMutableArray *weightDataArray;  //weight history data
    NSMutableArray *bmiDataArray;  //bmi history data
    
    CPTXYGraph *_xyGraph;
    
    CPTGraphHostingView *_hostView;
    
    NSMutableArray *aryAllWeight;
    NSMutableArray *aryWeekWeight;
    NSMutableArray *aryMonthWeight;
    
    NSArray *aryYearDay;
    NSArray *aryWeekDay;
    NSArray *aryMonthDay;
    
    NSInteger pointNum;
    NSMutableArray *aryMeasureDate;
    NSMutableDictionary *dictWeight;
    
    NSArray *plotData;
    double meanValue;
    double highStandard;
    double lowStandard;
    double standardError;
    double minYValue;       /**< 图表Y轴最小值 */
    double maxYValue;       /**< 图表Y轴最大值 */
    double dControlWeight;  /**< 图表目标体重 */
    double avgValue;
    NSArray *YRange;
    NSUInteger numberOfPoints;
    
    NSString  *kDataLine;       /**< 测量体重点 */
    NSString  *kDataShowLine;   /**< 测量体重线 */
    NSString  *kCenterLine;
    NSString  *kControlLine;    /**< 目标体重线 */
    NSString  *kControlPoint;   /**< 目标体重左边的数值 */
    NSString  *kWarningLine;
    NSString  *kBarDataLine;  
    
    
    NSString *kZeroLine;
    NSString *kBottomLine;
    
    NSString *_selectProject;
    NSString *_projectUnit;
    
    NVDate *_nvDateLastMeasureDate;
    NSMutableArray *_aryMeasureTime;
    NVDate *_firstDayOfWeek;
    NVDate *_lastDayOfWeek;
    NSDate *_weekLastDateNow;
    
    NVDate *_firstDayOfMonth;
    NVDate *_lastDayOfMonth;
    NSDate *_monthLastDateNow;
    
    NVDate *_firstDayOfYear;
    NVDate *_lastDayOfYear;
    NSDate *_yearLastDateNow;
    
    NSString *_strDateStart;
    NSString *_strDateEnd;
    
    NSString *_projectName;
}

@property (nonatomic, weak) UICollectionView *collectionView;

@property (copy, nonatomic) void(^GoBack)(void);
@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UIView *viewTop;

@property (weak, nonatomic) UIView *viewFriends;
@property (weak, nonatomic) UIView *viewFocus;
@property (weak, nonatomic) IBOutlet UIButton *btnLeftMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnRightMenu;

@property (weak, nonatomic) IBOutlet UILabel *lblTopTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageLine;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property (weak, nonatomic) IBOutlet UIButton *btnWeek;
@property (weak, nonatomic) IBOutlet UIButton *btnMonth;
@property (weak, nonatomic) IBOutlet UIButton *btnYear;
@property (weak, nonatomic) IBOutlet UILabel *lblAvgTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAllTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAvgValue;
@property (weak, nonatomic) IBOutlet UILabel *lblAllValue;
@property (weak, nonatomic) IBOutlet UILabel *lblProjectUnit;



- (IBAction)gotoAnalysisChart:(id)sender;

- (IBAction)gotoProjectManager:(id)sender;

- (IBAction)weekClick:(id)sender;
- (IBAction)monthClick:(id)sender;
- (IBAction)yearClick:(id)sender;



@end

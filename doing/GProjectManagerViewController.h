#import <UIKit/UIKit.h>

typedef enum
{
    SlidesViewItemStateNormal,
    SlidesViewItemStateActive
}   SlidesViewItemState;


@interface GProjectManagerViewController : UIViewController<UIGestureRecognizerDelegate>
{
    DbModel *_db;   //数据库对象
    
    UIView *drogView;       //拖动页
    
    int myBtnRow;           //用户设置项目行数
    int columnInterval;     //项目间隔
    bool isBtn;             //点击是否为已设置按钮
    NSString *switchValue;  //滑动按钮值
    
    NSMutableArray *btnArr;     //用户自定义菜单——string
    NSMutableArray *buttons;    //用户自定义菜单——button
    
    NSMutableArray *unSetArr;   //未设置的项目
    
    NSMutableArray *allBtnArr;  //项目按钮数组
    NSMutableArray *allButtons; //实例化按钮数组
    
    //UIScrollView *scroller;
    
    CGRect buttonOffset;        //按钮所在区域
    NSInteger buttonInterval;   //按钮间隔
    
    CGRect drogScope;   //拖动范围
    float intervalY;   //分隔线高度
    
    BOOL editingEnabled;    //是否可编辑
    int activeCellIndex;    //当前拖动
    
    UIButton *floatingActiveCell;
    UIButton *activeCell;      //触发对象按钮
    
    CGSize touchOffset;         //触发范围

    CGSize buttonSize;          //按钮大小
    CGPoint offset;
    
    int columnCount;            //每行项目数
    int rowCount;               //项目行数
    
    CGPoint holdPoint;
    
//    NSTimer *scrollStartTimer; 
//    CADisplayLink *scrollLink;
//    float scrollSpeed;
//    float scrollDirection;
//    BOOL isScrolling;
    
    UILongPressGestureRecognizer *dragGr;   //拖动事件
    
    SlidesViewItemState state;
    SlidesViewItemState oldState;
    
    AppDelegate *_delegate;
}

@property (copy, nonatomic) void(^GoBack)(void);
@property (weak, nonatomic) IBOutlet UIImageView *interval_left_line;
@property (weak, nonatomic) IBOutlet UIImageView *interval_right_line;
@property (weak, nonatomic) IBOutlet UILabel *interval_middle_label;
@property (weak, nonatomic) IBOutlet UIButton *btnBackIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UILabel *lblTopTitle;


- (IBAction)goback:(id)sender;


@end

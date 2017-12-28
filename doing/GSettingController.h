#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"


@interface GSettingController : AuthCommonViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSIndexPath *_selectedIndexPath;
    NetworkModule *_jsonModule;
    AppDelegate *_delegate;
    CGFloat viewHeight;
    
    NSMutableArray *aryWeight;
    NSMutableArray *arySectiion;
    NSMutableDictionary *dicSectionYear;
    NSMutableDictionary *dictWeight;
    
    NSMutableArray *aryFat;
    NSMutableArray *arySectiionFat;
    NSMutableDictionary *dicSectionYearFat;
    NSMutableDictionary *dictFat;
    
    NSMutableArray *aryWater;
    NSMutableArray *arySectiionWater;
    NSMutableDictionary *dicSectionYearWater;
    NSMutableDictionary *dictWater;
    
    NSMutableArray *aryMuscle;
    NSMutableArray *arySectiionMuscle;
    NSMutableDictionary *dicSectionYearMuscle;
    NSMutableDictionary *dictMuscle;
    
    NSMutableArray *aryBasic;
    NSMutableArray *arySectiionBasic;
    NSMutableDictionary *dicSectionYearBasic;
    NSMutableDictionary *dictBasic;
    
    NSMutableArray *aryBone;
    NSMutableArray *arySectiionBone;
    NSMutableDictionary *dicSectionYearBone;
    NSMutableDictionary *dictBone;
    
    NSMutableArray *aryBmi;
    NSMutableArray *arySectiionBmi;
    NSMutableDictionary *dicSectionYearBmi;
    NSMutableDictionary *dictBmi;
    
    NSMutableArray *aryStep;
    NSMutableArray *arySectiionStep;
    NSMutableDictionary *dicSectionYearStep;
    NSMutableDictionary *dictStep;

    CGFloat _lastScrollX;
}

@property (weak,nonatomic) ASIFormDataRequest *request;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBackIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;


- (IBAction)goback:(id)sender;

@end

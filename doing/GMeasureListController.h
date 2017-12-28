#import <UIKit/UIKit.h>
#import "ASIFormDataRequest.h"


@interface GMeasureListController : AuthCommonViewController<UITableViewDataSource,UITableViewDelegate>
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
    
    NSMutableArray *aryVisceralfat;
    NSMutableArray *arySectiionVisceralfat;
    NSMutableDictionary *dicSectionYearVisceralfat;
    NSMutableDictionary *dictVisceralfat;
    
    NSMutableArray *aryBodyAge;
    NSMutableArray *arySectiionBodyAge;
    NSMutableDictionary *dicSectionYearBodyAge;
    NSMutableDictionary *dictBodyAge;
    
    NSMutableArray *aryHeight;
    NSMutableArray *arySectiionHeight;
    NSMutableDictionary *dicSectionYearHeight;
    NSMutableDictionary *dictHeight;
    
    NSMutableArray *aryBMI;
    NSMutableArray *arySectiionBMI;
    NSMutableDictionary *dicSectionYearBMI;
    NSMutableDictionary *dictBMI;

    CGFloat _lastScrollX;
}


@property (weak,nonatomic) ASIFormDataRequest *request;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *viewStep;
@property (weak, nonatomic) IBOutlet UIImageView *imageStep;
@property (weak, nonatomic) IBOutlet UILabel *lblStep;

@property (weak, nonatomic) IBOutlet UIView *viewWeight;
@property (weak, nonatomic) IBOutlet UIView *viewFat;
@property (weak, nonatomic) IBOutlet UIView *viewWater;
@property (weak, nonatomic) IBOutlet UIView *viewMuscle;
@property (weak, nonatomic) IBOutlet UIView *viewBasic;
@property (weak, nonatomic) IBOutlet UIView *viewBone;
@property (weak, nonatomic) IBOutlet UIView *viewVisceralfat;
@property (weak, nonatomic) IBOutlet UIImageView *imageVisceralfat;
@property (weak, nonatomic) IBOutlet UILabel *lblVisceralfat;

@property (weak, nonatomic) IBOutlet UIImageView *imageWeight;
@property (weak, nonatomic) IBOutlet UILabel *lblWeight;
@property (weak, nonatomic) IBOutlet UIImageView *imageFat;
@property (weak, nonatomic) IBOutlet UILabel *lblFat;
@property (weak, nonatomic) IBOutlet UIImageView *imageWater;
@property (weak, nonatomic) IBOutlet UILabel *lblWater;
@property (weak, nonatomic) IBOutlet UIImageView *imageMuscle;
@property (weak, nonatomic) IBOutlet UILabel *lblMuscle;
@property (weak, nonatomic) IBOutlet UIImageView *imageBasic;
@property (weak, nonatomic) IBOutlet UILabel *lblBasic;
@property (weak, nonatomic) IBOutlet UIImageView *imageBone;
@property (weak, nonatomic) IBOutlet UILabel *lblBone;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageLine;
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIButton *btnBackIcon;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UIView *viewBodyage;
@property (weak, nonatomic) IBOutlet UIImageView *imageBodyage;
@property (weak, nonatomic) IBOutlet UILabel *lblBodyage;

@property (weak, nonatomic) IBOutlet UIView *viewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *imageHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblHeight;
@property (weak, nonatomic) IBOutlet UIView *viewBMI;
@property (weak, nonatomic) IBOutlet UIImageView *imageBmi;
@property (weak, nonatomic) IBOutlet UILabel *lblBMI;

- (IBAction)changeBMI:(id)sender;

- (IBAction)changeBodyage:(id)sender;
- (IBAction)changeHeight:(id)sender;

- (IBAction)changeVisceralfat:(id)sender;
- (IBAction)changeStep:(id)sender;
- (IBAction)changeWeight:(id)sender;
- (IBAction)changeFat:(id)sender;
- (IBAction)changeWater:(id)sender;
- (IBAction)changeMuscle:(id)sender;
- (IBAction)changBasic:(id)sender;
- (IBAction)changeBone:(id)sender;


- (IBAction)goback:(id)sender;

@end

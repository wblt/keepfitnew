#import <UIKit/UIKit.h>
#import "Dialog.h"
#import "DbModel.h"

@interface GUserAddController : UIViewController<UIGestureRecognizerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    NSInteger selectedViewTag;
    //ziliao_usericon_kuang.png
    UIView *blackBg;
    
    UIDatePicker *datePicker;
    //UIPickerView *weightPicker;
    //UIPickerView *heightPicker;
    
    NSString *myHeight;  //身高

    NSString *myNickName;  //昵称
    UIImage *myUserIcon;  //头像
    NSString *photoPath;  //
    NSString *myBirthday;  //生日
    NSString *mySex;      //性别
    NSString *myAge;
    NSString *myHC;
    NSString *myWC;
    
    NSMutableArray *aryWeight;
    NSMutableArray *aryWeight2;  //体重后面的小数点
    NSMutableArray *aryHeight;
    //NSMutableArray *aryHeight2;  //身高后面的小数点
    NSMutableArray *aryAge;
    NSMutableArray *arySex;
    NSMutableArray *aryHC; //腰围
    NSMutableArray *aryWC; //臀围
    
    float screenHeight;
    UIImage *tmpImage;
    
    Dialog *_dialog;
    NetworkModule *_network;
    
    AppDelegate *_delegate;
    BOOL _canBack;
    
    NSString *_strSexName;
    NSString *_strAgeName;
    NSString *_strHeightName;
    NSString *_strHCName;
    NSString *_strWCName;
}

@property (assign) BOOL isNav;
@property (weak, nonatomic) IBOutlet UILabel *lblTopTitle;
@property (nonatomic,retain) DbModel *dbModule;
@property (weak, nonatomic) IBOutlet UIView *viewSex;
@property (weak, nonatomic) IBOutlet UIView *viewAge;
@property (weak, nonatomic) IBOutlet UILabel *lblSex;
@property (weak, nonatomic) IBOutlet UIView *viewHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblHeight;
@property (weak, nonatomic) IBOutlet UILabel *lblAge
;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIButton *btnFinish;
@property (weak, nonatomic) IBOutlet UIImageView *imageBack;
@property (weak, nonatomic) IBOutlet UIImageView *imageFinish;

@property (weak, nonatomic) IBOutlet UIView *viewWC;
@property (weak, nonatomic) IBOutlet UILabel *lblWCTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblWC;
@property (weak, nonatomic) IBOutlet UIImageView *imageWC;
@property (weak, nonatomic) IBOutlet UIButton *btnWC;

@property (weak, nonatomic) IBOutlet UIView *viewHC;
@property (weak, nonatomic) IBOutlet UILabel *lblHCTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblHC;
@property (weak, nonatomic) IBOutlet UIImageView *imageHC;
@property (weak, nonatomic) IBOutlet UIButton *btnHC;


@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *toumingView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UILabel *lblPickerText;
@property (weak, nonatomic) IBOutlet UIPickerView *heightPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerAge;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerSex;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerHC;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerWC;

@property (assign) int iEditStyle; //1表示修改资料
@property (weak, nonatomic) IBOutlet UIView *viewTop;
@property (weak, nonatomic) IBOutlet UILabel *lblSexValue;
@property (weak, nonatomic) IBOutlet UIImageView *imageSex;
@property (weak, nonatomic) IBOutlet UIButton *btnSex;
@property (weak, nonatomic) IBOutlet UILabel *lblHeightValue;
@property (weak, nonatomic) IBOutlet UIImageView *imageHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnHeight;

@property (weak, nonatomic) IBOutlet UILabel *lblAgeValue;
@property (weak, nonatomic) IBOutlet UIImageView *imageAge;
@property (weak, nonatomic) IBOutlet UIButton *btnAge;
@property (weak, nonatomic) IBOutlet UIButton *btnPickerCancle;
@property (weak, nonatomic) IBOutlet UIButton *btnPickerFinish;


- (IBAction)goback:(id)sender;
- (IBAction)goNext:(id)sender;

- (IBAction)clickSex:(id)sender;
- (IBAction)clickHeight:(id)sender;
- (IBAction)clickAge:(id)sender;
- (IBAction)clickWC:(id)sender;
- (IBAction)clickHC:(id)sender;


- (void)setLeftMenuEnable:(BOOL)aBool;
- (IBAction)finishPickerSelected:(id)sender;
- (IBAction)canclePickerSelect:(id)sender;
- (IBAction)dateValueChange:(id)sender;


@end

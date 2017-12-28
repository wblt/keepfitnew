#import <UIKit/UIKit.h>

@interface GMineStepCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblFootCount;
@property (weak, nonatomic) IBOutlet UILabel *lblFinishPercent;
@property (weak, nonatomic) IBOutlet UILabel *lblKM;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblBasic;

@property (weak, nonatomic) IBOutlet UILabel *lblKMUnit;
@property (weak, nonatomic) IBOutlet UILabel *lblTimeUnit;
@property (weak, nonatomic) IBOutlet UILabel *lblBasicUnit;
@property (weak, nonatomic) IBOutlet UIImageView *imageKM;
@property (weak, nonatomic) IBOutlet UIImageView *imageTime;
@property (weak, nonatomic) IBOutlet UIImageView *imageBasic;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineLeft;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineRight;

-(void)configCellWithData:(NSDictionary *)dic;
-(void)configCellWithNoData;
@end

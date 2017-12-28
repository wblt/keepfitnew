#import <UIKit/UIKit.h>

@interface GMineWeightCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineWeightRange;
@property (weak, nonatomic) IBOutlet UIImageView *imageRangeLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblWeight;
@property (weak, nonatomic) IBOutlet UILabel *lblBMI;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeLow;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeNormal;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeHigh;

-(void)configCellWithData:(NSDictionary *)dic;
-(void)configCellWithNoData;
+(CGFloat)getCellHeight;
@end

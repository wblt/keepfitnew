#import <UIKit/UIKit.h>

@interface GMeasureCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageLine;
@property (weak, nonatomic) IBOutlet UIImageView *imageRangeResult;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeResult;
@property (weak, nonatomic) IBOutlet UILabel *lblProjectName;
@property (weak, nonatomic) IBOutlet UILabel *lblProjectValue;
@property (weak, nonatomic) IBOutlet UIImageView *imageRangeLine;
@property (weak, nonatomic) IBOutlet UIImageView *imageRangeLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeLow;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeNormal;
@property (weak, nonatomic) IBOutlet UILabel *lblRangeHigh;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;

-(void)configCellWithData:(NSDictionary *)dic;
+(CGFloat)getCellHeight:(NSDictionary *)dic;

@end

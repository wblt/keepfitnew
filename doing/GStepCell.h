#import <UIKit/UIKit.h>

@interface GStepCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblStepCount;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UILabel *lblJourney;
@property (weak, nonatomic) IBOutlet UILabel *lblCalorie;

@property (weak, nonatomic) IBOutlet UIImageView *imageLineBottom;


-(void)configCellWithData:(NSArray *)ary;

@end

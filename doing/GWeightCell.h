#import <UIKit/UIKit.h>

@interface GWeightCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblProjectValue;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineBottom;

-(void)configCellWithData:(NSArray *)ary;

@end

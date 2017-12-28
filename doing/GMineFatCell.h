#import <UIKit/UIKit.h>

@interface GMineFatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageProject;
@property (weak, nonatomic) IBOutlet UILabel *lblProjectName;
@property (weak, nonatomic) IBOutlet UILabel *lblProjectValue;
@property (weak, nonatomic) IBOutlet UIImageView *imageRange;
@property (weak, nonatomic) IBOutlet UILabel *lblRange;
@property (weak, nonatomic) IBOutlet UIImageView *imageLineBottom;

-(void)configCellWithData:(NSDictionary *)dic;
@end

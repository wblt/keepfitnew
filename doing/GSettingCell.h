#import <UIKit/UIKit.h>

@interface GSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UISwitch *mySwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageLine;
@property (nonatomic,copy) void(^SwitchChange)(BOOL abool);
- (IBAction)switchValueChange:(id)sender;

@end

#import <UIKit/UIKit.h>

@interface GMineFatTitleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
-(void)configCellWithData:(NSMutableArray *)ary;
@end

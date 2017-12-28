#import "GMeasureArrowCell.h"

@implementation GMeasureArrowCell

- (void)awakeFromNib {
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 30);
    self.imageArrow.frame=CGRectMake((SCREEN_WIDTH-20)/2, 30-12, 20, 12);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end

#import "GWeightCell.h"

@implementation GWeightCell

- (void)awakeFromNib {
    self.lblProjectValue.font=[UIFont systemFontOfSize:iPhone5FontSizeName+1];
    if(is_iPhone6)
    {
        self.lblProjectValue.font=[UIFont systemFontOfSize:iPhone6FontSizeName+1];
    }
    else if (is_iPhone6P)
    {
        self.lblProjectValue.font=[UIFont systemFontOfSize:iPhone6PFontSizeName+1];
    }
    
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.1375*SCREEN_WIDTH);
    
    self.imageLineBottom.frame=CGRectMake(30, self.frame.size.height-1, SCREEN_WIDTH-30, 1);
    self.lblTime.font=self.lblProjectValue.font;
    
    CGFloat lblWidth=(SCREEN_WIDTH-30)/4;
    
    self.lblTime.frame=CGRectMake(30, 0, lblWidth, self.frame.size.height);
    self.lblProjectValue.frame=CGRectMake(self.lblTime.frame.origin.x+self.lblTime.frame.size.width, 0, lblWidth, self.frame.size.height);
    
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)configCellWithData:(NSArray *)ary
{

}

@end

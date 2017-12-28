#import "GSettingCell.h"

@implementation GSettingCell

- (void)awakeFromNib
{
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 44);
    self.lblTitle.frame=CGRectMake(20, 0, SCREEN_WIDTH-80, self.frame.size.height);
    self.mySwitch.frame=CGRectMake(SCREEN_WIDTH-self.mySwitch.frame.size.width-15, 6, self.mySwitch.frame.size.width, self.mySwitch.frame.size.height);
    self.imageLine.frame=CGRectMake(0, self.frame.size.height-1, SCREEN_WIDTH, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (IBAction)switchValueChange:(id)sender {
    
    if(self.SwitchChange)
    {
        self.SwitchChange(self.mySwitch.on);
    }
}
@end

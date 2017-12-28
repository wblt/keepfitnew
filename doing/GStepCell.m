#import "GStepCell.h"

@implementation GStepCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configCellWithData:(NSArray *)ary
{
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.1375*SCREEN_WIDTH);
    
    self.imageLineBottom.frame=CGRectMake(30, self.frame.size.height-1, SCREEN_WIDTH-30, 1);
    //self.imageLineBottom.backgroundColor=[UIColor redColor];
    
    self.lblStepCount.font=[UIFont systemFontOfSize:iPhone5FontSizeName+1];
    if(is_iPhone6)
    {
        self.lblStepCount.font=[UIFont systemFontOfSize:iPhone6FontSizeName+1];
    }
    else if (is_iPhone6P)
    {
        self.lblStepCount.font=[UIFont systemFontOfSize:iPhone6PFontSizeName+1];
    }
    
    self.lblCalorie.font=self.lblStepCount.font;
    self.lblJourney.font=self.lblStepCount.font;
    self.lblTime.font=self.lblStepCount.font;
    
    
    CGFloat lblWidth=(SCREEN_WIDTH-30)/4;
    
    self.lblStepCount.frame=CGRectMake(30, 0, lblWidth, self.frame.size.height);
    self.lblTime.frame=CGRectMake(self.lblStepCount.frame.origin.x+self.lblStepCount.frame.size.width, 0, lblWidth, self.frame.size.height);
    self.lblJourney.frame=CGRectMake(self.lblTime.frame.origin.x+self.lblTime.frame.size.width, 0, lblWidth, self.frame.size.height);
    self.lblCalorie.frame=CGRectMake(self.lblJourney.frame.origin.x+self.lblJourney.frame.size.width, 0, lblWidth, self.frame.size.height);
    
    NSString *stepUnit=NSLocalizedString(@"step_unit", nil);
    NSString *stepTime=NSLocalizedString(@"step_time", nil);
    NSString *stepKM=NSLocalizedString(@"step_km", nil);
    
    NSString *step=[ary objectAtIndex:3];
    self.lblStepCount.text=[step stringByAppendingString:stepUnit];
    
    int iAllStep=[step intValue];
    CGFloat fkm=iAllStep*0.7/1000;
    CGFloat kcal=iAllStep*0.04;
    int iMinute=iAllStep/60;
    
    self.lblJourney.text=[NSString stringWithFormat:@"%.1f%@",fkm,stepKM];
    self.lblTime.text=[NSString stringWithFormat:@"%d%@",iMinute,stepTime];
    self.lblCalorie.text=[NSString stringWithFormat:@"%.0fkcal",kcal];
}

@end

#import "GMineFatCell.h"

@implementation GMineFatCell

- (void)awakeFromNib {
    //0.1125 36
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.1125*SCREEN_WIDTH);
    self.imageLineBottom.frame=CGRectMake(40, self.frame.size.height-1, SCREEN_WIDTH-40, 1);
    
    CGFloat widthTemp=(SCREEN_WIDTH-40)/3;
    self.imageProject.frame=CGRectMake(15, (self.frame.size.height-18)/2, 18, 18);
    self.lblProjectName.frame=CGRectMake(40, 0, widthTemp, self.frame.size.height);
    self.lblProjectValue.frame=CGRectMake(40+widthTemp, 0, widthTemp, self.frame.size.height);
    self.imageRange.frame=CGRectMake(40+widthTemp*2+(widthTemp-50)/2, (self.frame.size.height-25)/2, 50, 25);
    self.lblRange.frame=self.imageRange.frame;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configCellWithData:(NSDictionary *)dic
{
    //NSString *type=[dic valueForKey:@"type"];
    NSString *name=[dic valueForKey:@"name"];
    NSString *value=[dic valueForKey:@"value"];
    NSArray *aryRange=[dic valueForKey:@"range"];
    
    
    self.lblProjectName.text=name;
    
    if([name isEqualToString:ProjectBMIName])
    {
        self.lblProjectValue.text=[value stringByAppendingString:@""];
        self.imageProject.image=[UIImage imageNamed:@"guo_mine_bmi_green.png"];
        self.lblProjectName.text=NSLocalizedString(@"m_bmi", nil);
    }
    else if ([name isEqualToString:ProjectFatName])
    {
        self.lblProjectValue.text=[value stringByAppendingString:@"%"];
        self.imageProject.image=[UIImage imageNamed:@"guo_mine_fat_green.png"];
        self.lblProjectName.text=NSLocalizedString(@"m_fat", nil);
    }
    else if ([name isEqualToString:ProjectMuscleName])
    {
        self.lblProjectValue.text=[value stringByAppendingString:@"%"];
        self.imageProject.image=[UIImage imageNamed:@"guo_mine_muscle_green.png"];
        self.lblProjectName.text=NSLocalizedString(@"m_muscle", nil);
    }
    else if ([name isEqualToString:ProjectWaterName])
    {
        self.lblProjectValue.text=[value stringByAppendingString:@"%"];
        self.imageProject.image=[UIImage imageNamed:@"guo_mine_water_green.png"];
        self.lblProjectName.text=NSLocalizedString(@"m_water", nil);
    }
    else if ([name isEqualToString:ProjectBoneName])
    {
        /*
        NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
        if ([weightUnit isEqualToString:@"lb"]) {
            self.lblProjectValue.text=[[PublicModule kgToLb:value] stringByAppendingString:@" lb"];
        } else {
            self.lblProjectValue.text=[value stringByAppendingString:@" kg"];
        }
        */
        self.lblProjectValue.text=[value stringByAppendingString:@"%"];
        self.imageProject.image=[UIImage imageNamed:@"guo_mine_bone_green.png"];
        self.lblProjectName.text=NSLocalizedString(@"m_bone", nil);
    }
    else if ([name isEqualToString:ProjectBasicName])
    {
        self.lblProjectValue.text=[NSString stringWithFormat:@"%.0f",[value floatValue]];
        self.imageProject.image=[UIImage imageNamed:@"guo_mine_bmr_green.png"];
        self.lblProjectName.text=NSLocalizedString(@"m_basic", nil);
    }
    else if ([name isEqualToString:ProjectVisceralFatName])
    {
        self.lblProjectValue.text=[NSString stringWithFormat:@"%.0f",[value floatValue]];
        self.imageProject.image=[UIImage imageNamed:@"guo_mine_viscerafat_green.png"];
        self.lblProjectName.text=NSLocalizedString(@"m_visceralfat", nil);
    }
    else if ([name isEqualToString:ProjectBodyageName])
    {
        self.lblProjectValue.text=[NSString stringWithFormat:@"%.0f",[value floatValue]];
        self.imageProject.image=[UIImage imageNamed:@"guo_mine_bodyage_green.png"];
        self.lblProjectName.text=NSLocalizedString(@"m_bodyage", nil);
    }
    else if ([name isEqualToString:ProjectHeightName])
    {
        self.lblProjectValue.text=[NSString stringWithFormat:@"%.1fcm",[value floatValue]];
        self.imageProject.image=[UIImage imageNamed:@"guo_mine_fat_green.png"];
        self.lblProjectName.text=NSLocalizedString(@"m_height", nil);
    }
    
    
    if(aryRange && aryRange.count>=2)
    {
        CGFloat fLow=[[aryRange objectAtIndex:0] floatValue];
        CGFloat fHigh=[[aryRange objectAtIndex:1] floatValue];
        CGFloat fValue=[value floatValue];
        if(fValue<fLow)
        {
            self.lblRange.text=NSLocalizedString(@"range_low", nil);
            self.imageRange.image=[UIImage imageNamed:@"guo_measure_range_blue.png"];
        }
        else if (fValue >= fLow && fValue<= fHigh)
        {
            self.lblRange.text=NSLocalizedString(@"range_normal", nil);
            self.imageRange.image=[UIImage imageNamed:@"guo_measure_range_green.png"];
        }
        else
        {
            self.lblRange.text=NSLocalizedString(@"range_high", nil);
            self.imageRange.image=[UIImage imageNamed:@"guo_measure_range_red.png"];
            
           
        }
    }
    else
    {
        self.lblRange.text=NSLocalizedString(@"range_normal", nil);
        self.imageRange.image=[UIImage imageNamed:@"guo_measure_range_green.png"];
    }
    
    
    if ([name isEqualToString:ProjectBodyageName])
    {
        //少年18青年35中年65老年
        CGFloat fValue=[value floatValue];
        if(fValue < 18)
        {
            self.lblRange.text=@"少年";
            self.lblRange.text=NSLocalizedString(@"少年", nil);
        }
        else if (fValue >= 18 && fValue <= 44)
        {
            self.lblRange.text=@"青年";
            self.lblRange.text=NSLocalizedString(@"青年", nil);
        }
        else if (fValue >= 45 && fValue <= 59)
        {
            self.lblRange.text=@"中年";
            self.lblRange.text=NSLocalizedString(@"中年", nil);
        }
        else
        {
            self.lblRange.text=@"老年";
            self.lblRange.text=NSLocalizedString(@"老年", nil);
        }
    }
    
    if([value floatValue] <= 0.0)
    {
        self.lblRange.text=NSLocalizedString(@"range_normal", nil);
        self.imageRange.image=[UIImage imageNamed:@"guo_measure_range_green.png"];
        //self.lblProjectValue.text=@"--";
        self.lblProjectValue.text=@"0";
    }
    
}
@end

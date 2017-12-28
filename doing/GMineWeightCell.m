#import "GMineWeightCell.h"

@implementation GMineWeightCell


+(CGFloat)getCellHeight
{
    CGFloat height=15+20;
    height+=15+0.125*SCREEN_WIDTH;
    height+=15+20;
    height+=2+4;
    height+=10+25;
    
    return height;
}


- (void)awakeFromNib {
    
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.4375*SCREEN_WIDTH);
    
    //0.046875
    self.lblTitle.frame=CGRectMake(15, 15, SCREEN_WIDTH-15, 20);
    
    AppDelegate *delegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    double dHeight=[delegate.myUserInfo.userHeight doubleValue];
    
    if(dHeight<=0)
    {
        dHeight=170.0;
    }
    
    int iWeight=arc4random()%30+40;
    int iWeightPoint=arc4random()%10;
    NSString *weight=[NSString stringWithFormat:@"%d.%d",iWeight,iWeightPoint];
    double dBmi=[weight doubleValue]/(dHeight*dHeight/10000);
    
    NSString *textWeight=@"78.4 kg";
    NSString *textWeightUnit=@"kg";
    textWeight=[NSString stringWithFormat:@"%@ kg",weight];
    NSRange rangeWeight=[textWeight rangeOfString:textWeightUnit];
    NSMutableAttributedString *aStrWeight=[[NSMutableAttributedString alloc] initWithString:textWeight];
    [aStrWeight addAttribute:NSForegroundColorAttributeName
                     value:[UIColor lightGrayColor]
                     range:rangeWeight];
    [aStrWeight addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:15]
                     range:rangeWeight];
    //self.lblWeight.attributedText=aStrWeight;
    
    self.lblWeight.frame=CGRectMake(15, self.lblTitle.frame.origin.y+self.lblTitle.frame.size.height+15, (SCREEN_WIDTH-30)/2, 0.125*SCREEN_WIDTH);
    
    NSString *textBmi=@"BMI 22.4";
    NSString *textBmiValue=@"22.4";
    
    textBmiValue=[NSString stringWithFormat:@"%.1f",dBmi];
    textBmi=[NSString stringWithFormat:@"BMI %@",textBmiValue];
    
    NSRange rangeBmi=[textBmi rangeOfString:textBmiValue];
    NSMutableAttributedString *aStrBmi=[[NSMutableAttributedString alloc] initWithString:textBmi];
    [aStrBmi addAttribute:NSForegroundColorAttributeName
                       value:UIColorFromRGB(0x00af00)
                       range:rangeBmi];

    //self.lblBMI.attributedText=aStrBmi;
    
    self.lblBMI.frame=CGRectMake(self.lblWeight.frame.origin.x+self.lblWeight.frame.size.width, self.lblWeight.frame.origin.y+self.lblWeight.frame.size.height/2, (SCREEN_WIDTH-30)/2, 20);
    
    self.imageRangeLocation.frame=CGRectMake(160, self.lblBMI.frame.origin.y+self.lblBMI.frame.size.height+15, 12, 20);
    
    self.imageLineWeightRange.frame=CGRectMake(15, self.imageRangeLocation.frame.origin.y+self.imageRangeLocation.frame.size.height+2, SCREEN_WIDTH-30, 4);
    
    CGFloat widthTempLabel=self.imageLineWeightRange.frame.size.width/3;
    self.lblRangeLow.frame=CGRectMake(15, self.imageLineWeightRange.frame.origin.y+self.imageLineWeightRange.frame.size.height+10, widthTempLabel, self.lblRangeLow.frame.size.height);
    
    self.lblRangeNormal.frame=CGRectMake(15+widthTempLabel, self.imageLineWeightRange.frame.origin.y+self.imageLineWeightRange.frame.size.height+10, self.imageLineWeightRange.frame.size.width/3, self.lblRangeNormal.frame.size.height);
    
    self.lblRangeHigh.frame=CGRectMake(15+widthTempLabel*2, self.imageLineWeightRange.frame.origin.y+self.imageLineWeightRange.frame.size.height+10, self.imageLineWeightRange.frame.size.width/3, self.lblRangeHigh.frame.size.height);
    
    self.lblRangeLow.text=NSLocalizedString(@"range_low",nil);
    self.lblRangeNormal.text=NSLocalizedString(@"range_normal",nil);
    self.lblRangeHigh.text=NSLocalizedString(@"range_high",nil);
    self.lblTitle.text=NSLocalizedString(@"weight_todayweight", nil);
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

-(void)configCellWithData:(NSDictionary *)dic
{
    NSString *weight=[dic valueForKey:@"weight"];
    NSString *bmi=[dic valueForKey:@"bmi"];
    
    NSString *textWeight=@"78.4 kg";
    NSString *textWeightUnit=@"kg";
    NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
    if ([weightUnit isEqualToString:@"lb"]) {
        textWeightUnit = @"lb";
        weight = [PublicModule kgToLb:weight];
    }
    textWeight=[NSString stringWithFormat:@"%@ %@",weight,textWeightUnit];
    NSRange rangeWeight=[textWeight rangeOfString:textWeightUnit];
    NSMutableAttributedString *aStrWeight=[[NSMutableAttributedString alloc] initWithString:textWeight];
    [aStrWeight addAttribute:NSForegroundColorAttributeName
                       value:[UIColor lightGrayColor]
                       range:rangeWeight];
    [aStrWeight addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:15]
                       range:rangeWeight];
    self.lblWeight.attributedText=aStrWeight;
    

    
    NSString *textBmi=@"BMI 22.4";
    NSString *textBmiValue=@"22.4";
    
    textBmiValue=bmi;
    textBmi=[NSString stringWithFormat:@"BMI %@",textBmiValue];
    
    NSRange rangeBmi=[textBmi rangeOfString:textBmiValue];
    NSMutableAttributedString *aStrBmi=[[NSMutableAttributedString alloc] initWithString:textBmi];
    [aStrBmi addAttribute:NSForegroundColorAttributeName
                    value:UIColorFromRGB(0x00af00)
                    range:rangeBmi];
    
    self.lblBMI.attributedText=aStrBmi;
    
    //NSArray *aryRange=[dic valueForKey:@"range"];
    NSArray *aryRange=[[NSArray alloc] initWithObjects:@"18.5",@"24.0", nil];
    
    if(aryRange)
    {
        NSString *rangeLow=[aryRange objectAtIndex:0];
        NSString *rangeHigh=[aryRange objectAtIndex:1];
        if(rangeLow && rangeHigh)
        {
            rangeLow=[NSString stringWithFormat:@"%.1f",[rangeLow doubleValue]];
            rangeHigh=[NSString stringWithFormat:@"%.1f",[rangeHigh doubleValue]];
            
            CGFloat fRangeWidth=self.imageLineWeightRange.frame.size.width/3;
            CGFloat dLocationOffset=6;
            CGFloat fLocation=15;
            
            CGFloat fBmi=[bmi floatValue];
            CGFloat fBmiLow=[rangeLow floatValue];
            CGFloat fBmiHigh=[rangeHigh floatValue];
  
            if(fBmi < fBmiLow)
            {
                fLocation=fBmi/fBmiLow*fRangeWidth+15-dLocationOffset;
            }
            else if (fBmi >= fBmiLow && fBmi <= fBmiHigh)
            {
                fLocation=(fBmi - fBmiLow)/(fBmiHigh-fBmiLow)*fRangeWidth+15-dLocationOffset+fRangeWidth;
            }
            else
            {
                fLocation=(fBmi - fBmiHigh)/10*fRangeWidth+15-dLocationOffset+fRangeWidth*2;
            }
            
            if(fLocation < (15-dLocationOffset))
            {
                fLocation=15-dLocationOffset;
            }
            if(fLocation > (fRangeWidth*3+15-dLocationOffset))
            {
                fLocation=fRangeWidth*3+15-dLocationOffset;
            }
            
            self.imageRangeLocation.frame=CGRectMake(fLocation, self.imageRangeLocation.frame.origin.y, self.imageRangeLocation.frame.size.width, self.imageRangeLocation.frame.size.height);
        }
    }
}

-(void)configCellWithNoData
{
    NSString *weight=@"0";
    NSString *bmi=@"0";
    
    NSString *textWeight=@"78.4 kg";
    NSString *textWeightUnit=@"kg";
    NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
    if ([weightUnit isEqualToString:@"lb"]) {
        textWeightUnit = @"lb";
        weight = [PublicModule kgToLb:weight];
    }
    textWeight=[NSString stringWithFormat:@"%@ %@",weight,textWeightUnit];
    NSRange rangeWeight=[textWeight rangeOfString:textWeightUnit];
    NSMutableAttributedString *aStrWeight=[[NSMutableAttributedString alloc] initWithString:textWeight];
    [aStrWeight addAttribute:NSForegroundColorAttributeName
                       value:[UIColor lightGrayColor]
                       range:rangeWeight];
    [aStrWeight addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:15]
                       range:rangeWeight];
    self.lblWeight.attributedText=aStrWeight;
    
    
    
    NSString *textBmi=@"BMI 22.4";
    NSString *textBmiValue=@"22.4";
    
    textBmiValue=bmi;
    textBmi=[NSString stringWithFormat:@"BMI %@",textBmiValue];
    
    NSRange rangeBmi=[textBmi rangeOfString:textBmiValue];
    NSMutableAttributedString *aStrBmi=[[NSMutableAttributedString alloc] initWithString:textBmi];
    [aStrBmi addAttribute:NSForegroundColorAttributeName
                    value:UIColorFromRGB(0x00af00)
                    range:rangeBmi];
    
    self.lblBMI.attributedText=aStrBmi;
    
    //NSArray *aryRange=[dic valueForKey:@"range"];
    NSArray *aryRange=[[NSArray alloc] initWithObjects:@"18.5",@"24.0", nil];
    
    if(aryRange)
    {
        NSString *rangeLow=[aryRange objectAtIndex:0];
        NSString *rangeHigh=[aryRange objectAtIndex:1];
        if(rangeLow && rangeHigh)
        {
            rangeLow=[NSString stringWithFormat:@"%.1f",[rangeLow doubleValue]];
            rangeHigh=[NSString stringWithFormat:@"%.1f",[rangeHigh doubleValue]];
            
            CGFloat fRangeWidth=self.imageLineWeightRange.frame.size.width/3;
            CGFloat dLocationOffset=6;
            CGFloat fLocation=15;
            
            CGFloat fBmi=[bmi floatValue];
            CGFloat fBmiLow=[rangeLow floatValue];
            CGFloat fBmiHigh=[rangeHigh floatValue];
            
            if(fBmi < fBmiLow)
            {
                fLocation=fBmi/fBmiLow*fRangeWidth+15-dLocationOffset;
            }
            else if (fBmi >= fBmiLow && fBmi <= fBmiHigh)
            {
                fLocation=(fBmi - fBmiLow)/(fBmiHigh-fBmiLow)*fRangeWidth+15-dLocationOffset+fRangeWidth;
            }
            else
            {
                fLocation=(fBmi - fBmiHigh)/10*fRangeWidth+15-dLocationOffset+fRangeWidth*2;
            }
            
            if(fLocation < (15-dLocationOffset))
            {
                fLocation=15-dLocationOffset;
            }
            if(fLocation > (fRangeWidth*3+15-dLocationOffset))
            {
                fLocation=fRangeWidth*3+15-dLocationOffset;
            }
            
            self.imageRangeLocation.frame=CGRectMake(fLocation, self.imageRangeLocation.frame.origin.y, self.imageRangeLocation.frame.size.width, self.imageRangeLocation.frame.size.height);
        }
    }
}
@end

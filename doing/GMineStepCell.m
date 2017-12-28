#import "GMineStepCell.h"

@implementation GMineStepCell

- (void)awakeFromNib {
    
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.4375*SCREEN_WIDTH);
    
    int iFoot=arc4random()%10000+1;
    
    NSString *footcountText=@"1579 步";
    footcountText=[NSString stringWithFormat:@"%d 步",iFoot];
    NSString *footcountUnit=@"步";
    NSRange rangeFootCount=[footcountText rangeOfString:footcountUnit];
    NSMutableAttributedString *aStrFoot=[[NSMutableAttributedString alloc] initWithString:footcountText];
    [aStrFoot addAttribute:NSForegroundColorAttributeName
                 value:[UIColor lightGrayColor]
                 range:rangeFootCount];
    [aStrFoot addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:13]
                     range:rangeFootCount];
    self.lblFootCount.attributedText=aStrFoot;
    
    self.lblFootCount.frame=CGRectMake(15, 20, 120, 26);
    [self.lblFootCount sizeToFit];

    
    float fPercent=iFoot/10000.0*100;
    NSString *textPercent=@"17%";
    textPercent=[NSString stringWithFormat:@"%.0f",fPercent];
    textPercent=[textPercent stringByAppendingString:@"%"];
    NSString *text=@"完成17%of10000";
    
    text=[NSString stringWithFormat:@"完成%@of10000",textPercent];
    
    
    NSRange range=[text rangeOfString:textPercent];
    NSMutableAttributedString *aStr=[[NSMutableAttributedString alloc] initWithString:text];
    [aStr addAttribute:NSForegroundColorAttributeName
                 value:UIColorFromRGB(0x00af00)
                 range:range];
    self.lblFinishPercent.attributedText=aStr;
    
    
    self.lblFinishPercent.frame=CGRectMake(SCREEN_WIDTH-120-15, self.lblFootCount.frame.origin.y+self.lblFootCount.frame.size.height-20, 120, 20);
    
    
    CGFloat widthTemp=SCREEN_WIDTH/3;
    self.imageLineLeft.frame=CGRectMake(widthTemp, 0.20625*SCREEN_WIDTH, 1, 0.1875*SCREEN_WIDTH);
    self.imageLineRight.frame=CGRectMake(widthTemp*2, 0.20625*SCREEN_WIDTH, 1, 0.1875*SCREEN_WIDTH);
    
    CGFloat axisYTemp=self.imageLineLeft.frame.origin.y+self.imageLineLeft.frame.size.height;
    
    self.imageKM.frame=CGRectMake((widthTemp-0.046875*SCREEN_WIDTH)/2, axisYTemp-0.046875*SCREEN_WIDTH, 0.046875*SCREEN_WIDTH, 0.046875*SCREEN_WIDTH);
    self.imageTime.frame=CGRectMake(widthTemp+self.imageKM.frame.origin.x, axisYTemp-0.046875*SCREEN_WIDTH, 0.046875*SCREEN_WIDTH, 0.046875*SCREEN_WIDTH);
    self.imageBasic.frame=CGRectMake(widthTemp*2+self.imageKM.frame.origin.x, axisYTemp-0.046875*SCREEN_WIDTH, 0.046875*SCREEN_WIDTH, 0.046875*SCREEN_WIDTH);
    
    
    self.lblKM.frame=CGRectMake(0, self.imageLineLeft.frame.origin.y, widthTemp, self.imageLineLeft.frame.size.height/3);
    self.lblTime.frame=CGRectMake(widthTemp, self.imageLineLeft.frame.origin.y, widthTemp, self.imageLineLeft.frame.size.height/3);
    self.lblBasic.frame=CGRectMake(widthTemp*2, self.imageLineLeft.frame.origin.y, widthTemp, self.imageLineLeft.frame.size.height/3);
    
    self.lblKMUnit.frame=CGRectMake(0, self.imageLineLeft.frame.origin.y+self.imageLineLeft.frame.size.height/3, widthTemp, self.imageLineLeft.frame.size.height/3);
    self.lblTimeUnit.frame=CGRectMake(widthTemp, self.imageLineLeft.frame.origin.y+self.imageLineLeft.frame.size.height/3,widthTemp, self.imageLineLeft.frame.size.height/3);
    self.lblBasicUnit.frame=CGRectMake(widthTemp*2, self.imageLineLeft.frame.origin.y+self.imageLineLeft.frame.size.height/3, widthTemp, self.imageLineLeft.frame.size.height/3);
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)configCellWithData:(NSDictionary *)dic
{
    NSString *strStep=[dic valueForKey:@"step"];
    NSString *strStepAll=[dic valueForKey:@"allstep"];
    NSString *strKM=[dic valueForKey:@"km"];
    NSString *strTime=[dic valueForKey:@"time"];
    NSString *strKcal=[dic valueForKey:@"kcal"];

    self.lblKMUnit.text=NSLocalizedString(@"step_km", nil);
    self.lblTimeUnit.text=NSLocalizedString(@"step_time", nil);
    
    self.lblKM.text=strKM;
    self.lblTime.text=strTime;
    self.lblBasic.text=strKcal;
    
    int iFoot=[strStep intValue];
    CGFloat iFootAll=[strStepAll floatValue];
    
    NSString * footcountText=[NSString stringWithFormat:@"%d %@",iFoot,NSLocalizedString(@"step_unit", nil)];
    NSString *footcountUnit=NSLocalizedString(@"step_unit", nil);
    NSRange rangeFootCount=[footcountText rangeOfString:footcountUnit];
    NSMutableAttributedString *aStrFoot=[[NSMutableAttributedString alloc] initWithString:footcountText];
    [aStrFoot addAttribute:NSForegroundColorAttributeName
                     value:[UIColor lightGrayColor]
                     range:rangeFootCount];
    [aStrFoot addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:13]
                     range:rangeFootCount];
    self.lblFootCount.attributedText=aStrFoot;
    
    self.lblFootCount.frame=CGRectMake(15, 20, 120, 26);
    [self.lblFootCount sizeToFit];
    
    
    float fPercent=iFoot/iFootAll*100.0;
    if(fPercent >=100.0) fPercent = 100.0;
    NSString *textPercent=@"17%";
    textPercent=[NSString stringWithFormat:@"%.0f",fPercent];
    textPercent=[textPercent stringByAppendingString:@"%"];
    
    NSString * text=[NSString stringWithFormat:@"%@ %@ of %.0f",NSLocalizedString(@"step_finish", nil),textPercent,iFootAll];
    
    
    NSRange range=[text rangeOfString:textPercent];
    NSMutableAttributedString *aStr=[[NSMutableAttributedString alloc] initWithString:text];
    [aStr addAttribute:NSForegroundColorAttributeName
                 value:UIColorFromRGB(0x00af00)
                 range:range];
    self.lblFinishPercent.attributedText=aStr;
    if (iFootAll <= 0)
    {
        self.lblFinishPercent.hidden=YES;
    }
    else
    {
        self.lblFinishPercent.hidden=NO;
    }
}

-(void)configCellWithNoData {
    NSString *strStep=@"0";
    NSString *strStepAll=@"0";
    NSString *strKM=@"0";
    NSString *strTime=@"0";
    NSString *strKcal=@"0";
    
    self.lblKMUnit.text=NSLocalizedString(@"step_km", nil);
    self.lblTimeUnit.text=NSLocalizedString(@"step_time", nil);
    
    self.lblKM.text=strKM;
    self.lblTime.text=strTime;
    self.lblBasic.text=strKcal;
    
    int iFoot=[strStep intValue];
    CGFloat iFootAll=[strStepAll floatValue];
    
    NSString * footcountText=[NSString stringWithFormat:@"%d %@",iFoot,NSLocalizedString(@"step_unit", nil)];
    NSString *footcountUnit=NSLocalizedString(@"step_unit", nil);
    NSRange rangeFootCount=[footcountText rangeOfString:footcountUnit];
    NSMutableAttributedString *aStrFoot=[[NSMutableAttributedString alloc] initWithString:footcountText];
    [aStrFoot addAttribute:NSForegroundColorAttributeName
                     value:[UIColor lightGrayColor]
                     range:rangeFootCount];
    [aStrFoot addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:13]
                     range:rangeFootCount];
    self.lblFootCount.attributedText=aStrFoot;
    
    self.lblFootCount.frame=CGRectMake(15, 20, 120, 26);
    [self.lblFootCount sizeToFit];
    
    
    float fPercent=iFoot/iFootAll*100.0;
    if(fPercent >=100.0) fPercent = 100.0;
    NSString *textPercent=@"17%";
    textPercent=[NSString stringWithFormat:@"%.0f",fPercent];
    textPercent=[textPercent stringByAppendingString:@"%"];
    
    NSString * text=[NSString stringWithFormat:@"%@ %@ of %.0f",NSLocalizedString(@"step_finish", nil),textPercent,iFootAll];
    
    
    NSRange range=[text rangeOfString:textPercent];
    NSMutableAttributedString *aStr=[[NSMutableAttributedString alloc] initWithString:text];
    [aStr addAttribute:NSForegroundColorAttributeName
                 value:UIColorFromRGB(0x00af00)
                 range:range];
    self.lblFinishPercent.attributedText=aStr;
    if (iFootAll <= 0)
    {
        self.lblFinishPercent.hidden=YES;
    }
    else
    {
        self.lblFinishPercent.hidden=NO;
    }
}
@end

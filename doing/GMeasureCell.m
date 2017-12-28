#import "GMeasureCell.h"

@implementation GMeasureCell

- (void)awakeFromNib {

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


-(void)configCellWithData:(NSDictionary *)dic
{
    NSString *type=[dic valueForKey:@"type"];
    NSString *name=[dic valueForKey:@"name"];
    NSString *valueShow=[dic valueForKey:@"valueShow"];
    NSString *value=[dic valueForKey:@"value"];
    NSArray *aryRange=[dic valueForKey:@"range"];
    
    self.lblProjectName.text=name;
    self.lblProjectValue.text=valueShow;
    
    if([name isEqualToString:ProjectFatName])
    {
        self.lblProjectName.text=NSLocalizedString(@"m_fat", nil);
        self.lblContent.text=@"脂肪率是指身体成分中，脂肪组织所占的比率。测量脂肪率比单纯的只测量体重更能反映我们身体的脂肪水平。";
        self.lblContent.text=NSLocalizedString(@"m_fat_info", nil);
    }
    else if ([name isEqualToString:ProjectMuscleName])
    {
        self.lblProjectName.text=NSLocalizedString(@"m_muscle", nil);
        self.lblContent.text=@"人体体重的成分可分为非脂肪物质与脂肪物质二大部分，肌肉含量是非脂肪物质中去除掉约占体重4%~6%的无机质。肌肉是好东西，肌肉量越大，自己基础代谢就越高，越不容易胖。";
        self.lblContent.text=NSLocalizedString(@"m_muscle_info", nil);
    }
    else if ([name isEqualToString:ProjectWaterName])
    {
        self.lblProjectName.text=NSLocalizedString(@"m_water", nil);
        self.lblContent.text=@"身体水分占体重的百分比，此数据和肌肉量有着极其密切的关系，因为肌肉中含大量水分(大概70%），这项指标能够反应减重的方式是否正确，如果体水分率下降，不但有损健康，更会令体脂肪率上升。";
        self.lblContent.text=NSLocalizedString(@"m_water_info", nil);
    }
    else if ([name isEqualToString:ProjectBasicName])
    {
        self.lblProjectName.text=NSLocalizedString(@"m_basic", nil);
        self.lblProjectValue.text=[NSString stringWithFormat:@"%d",[value intValue]];
        self.lblContent.text=@"基础代谢是维持人体生命活动正常进行一天所需的最低能量，说通俗点，就是一个“植物人”生活一天所消耗的能量（不吃不动不喝躺床上一天所消耗的能量）。";
        self.lblContent.text=NSLocalizedString(@"m_basic_info", nil);
    }
    else if ([name isEqualToString:ProjectBoneName])
    {
        self.lblProjectName.text=NSLocalizedString(@"m_bone", nil);
        
        /*
        NSString *weightUnit = [[NSUserDefaults standardUserDefaults] valueForKey:@"weight_unit"];
        if ([weightUnit isEqualToString:@"lb"]) {
            self.lblProjectValue.text=[NSString stringWithFormat:@"%@ lb",[PublicModule kgToLb:value]];
        } else {
            self.lblProjectValue.text=[NSString stringWithFormat:@"%.1f kg",[value floatValue]];
        }
         */

        self.lblProjectValue.text=[NSString stringWithFormat:@"%.1f%@",[value floatValue],@"%"];

        self.lblContent.text=@"在很多人用骨量来形容和表示骨骼，特别是四肢骨骼的粗细。如果按照严格意义上的骨量来看，无论对任何脊椎动物，也无论他们是老还是少，骨量都是非常重要的。骨量代表它们骨骼健康的情况。";
        self.lblContent.text=NSLocalizedString(@"m_bone_info", nil);
    }
    else if ([name isEqualToString:ProjectBMIName])
    {
        self.lblProjectName.text=NSLocalizedString(@"m_bmi", nil);
        self.lblContent.text=@"BMI是用体重公斤数除以身高米数平方得出的数字，是目前国际上常用的衡量人体胖瘦程度以及是否健康的一个标准。";
        self.lblContent.text=NSLocalizedString(@"m_bmi_info", nil);
    }
    else if ([name isEqualToString:ProjectVisceralFatName])
    {
        self.lblProjectName.text=NSLocalizedString(@"m_visceralfat", nil);
        self.lblProjectValue.text=[NSString stringWithFormat:@"%d",[value intValue]];
        self.lblContent.text=@"内脏脂肪是人体脂肪中的一种，与皮下脂肪（也就是我们平时所了解的身体上可以摸得到的“肥肉”） 不同，它围绕着人的脏器，主要存在于腹腔内。内脏脂肪对我们的健康意义重大。";
        self.lblContent.text=NSLocalizedString(@"m_visceralfat_info", nil);
    }
    else if ([name isEqualToString:ProjectHeightName])
    {
        self.lblProjectName.text=NSLocalizedString(@"m_height", nil);
        self.lblContent.text=@"";
    }
    else if ([name isEqualToString:ProjectBodyageName])
    {
        self.lblProjectName.text=NSLocalizedString(@"m_bodyage", nil);
        self.lblProjectValue.text=[NSString stringWithFormat:@"%d",[value intValue]];
        self.lblContent.text=@"一个人体脂率越低，基础代谢越高，她的身体年龄就越小。身体年龄高于实际年龄，也正说明着你的脂肪在堆积，基础代谢缓慢，你的身体（包括内在的机能和外在的皮肤）正在加速衰老。";
        self.lblContent.text=NSLocalizedString(@"m_bodyage_info", nil);
        
    }
    
    if([type isEqualToString:DTrue])
    {
        //130
        self.imageRangeLine.hidden=NO;
        self.imageRangeLocation.hidden=NO;
        self.lblRangeLow.hidden=NO;
        self.lblRangeNormal.hidden=NO;
        self.lblRangeHigh.hidden=NO;
        self.lblContent.hidden=NO;
        
        [self.lblContent sizeToFit];
        //self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.40625*SCREEN_WIDTH-10);
        self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.275*SCREEN_WIDTH+self.lblContent.frame.size.height+5);
        self.imageLine.frame=CGRectMake(0, self.frame.size.height-1, SCREEN_WIDTH, 1);
        
    }
    else
    {
        self.imageRangeLine.hidden=YES;
        self.imageRangeLocation.hidden=YES;
        self.lblRangeLow.hidden=YES;
        self.lblRangeNormal.hidden=YES;
        self.lblRangeHigh.hidden=YES;
        self.lblContent.hidden=YES;
        
        
        //44
        self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.1375*SCREEN_WIDTH);
        self.imageLine.frame=CGRectMake(0, self.frame.size.height-1, SCREEN_WIDTH, 1);
    }
    
    
    self.lblProjectName.frame=CGRectMake(30, 0, SCREEN_WIDTH-30, 0.1375*SCREEN_WIDTH);
    self.lblProjectValue.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.1375*SCREEN_WIDTH);
    self.imageRangeResult.frame=CGRectMake(SCREEN_WIDTH-0.125*SCREEN_WIDTH-30, (0.1375*SCREEN_WIDTH-0.0625*SCREEN_WIDTH)/2, 0.125*SCREEN_WIDTH, 0.0625*SCREEN_WIDTH);
    self.lblRangeResult.frame=self.imageRangeResult.frame;
    
    
    self.imageRangeLocation.frame=CGRectMake(40, self.lblProjectName.frame.origin.y+self.lblProjectName.frame.size.height, 12, 20);
    self.imageRangeLine.frame=CGRectMake(30, self.imageRangeLocation.frame.origin.y+self.imageRangeLocation.frame.size.height+2, SCREEN_WIDTH-30-30, 4);
    
    CGFloat widthTemp=(SCREEN_WIDTH-30-30)/3;
    self.lblRangeLow.frame=CGRectMake(30, self.imageRangeLine.frame.origin.y+self.imageRangeLine.frame.size.height+2, widthTemp, 20);
    self.lblRangeNormal.frame=CGRectMake(30+widthTemp, self.imageRangeLine.frame.origin.y+self.imageRangeLine.frame.size.height+2, widthTemp, 20);
    self.lblRangeHigh.frame=CGRectMake(30+widthTemp*2, self.imageRangeLine.frame.origin.y+self.imageRangeLine.frame.size.height+2, widthTemp, 20);
    self.lblContent.frame=CGRectMake(30, self.lblRangeLow.frame.size.height+self.lblRangeLow.frame.origin.y, SCREEN_WIDTH-30-30, self.lblContent.frame.size.height);
    
    self.lblRangeLow.text=NSLocalizedString(@"range_low", nil);
    self.lblRangeNormal.text=NSLocalizedString(@"range_normal", nil);
    self.lblRangeHigh.text=NSLocalizedString(@"range_high", nil);
    
    if(aryRange && aryRange.count>=2)
    {
        NSString *low=[aryRange objectAtIndex:0];
        NSString *high=[aryRange objectAtIndex:1];
        
        CGFloat fValue=[value floatValue];
        CGFloat fLow=[low floatValue];
        CGFloat fHigh=[high floatValue];
        
        CGFloat fCount=fHigh-fLow;
        CGFloat fOffset=self.imageRangeLocation.frame.size.width/2;
        
        CGFloat fLocation=30;
        CGFloat fSingleLength=self.imageRangeLine.frame.size.width/3;
        if(fValue<fLow)
        {
            fLocation=fValue/fLow*fSingleLength+30-fOffset;
            self.imageRangeResult.image=[UIImage imageNamed:@"guo_measure_range_blue.png"];
            self.lblRangeResult.text=NSLocalizedString(@"range_low", nil);
        }
        else if (fValue >= fLow && fValue <= fHigh)
        {
            fLocation=(fValue-fLow)/fCount*fSingleLength+30+fSingleLength-fOffset;
            self.imageRangeResult.image=[UIImage imageNamed:@"guo_measure_range_green.png"];
            self.lblRangeResult.text=NSLocalizedString(@"range_normal", nil);
        }
        else
        {
            fLocation=(fValue-fHigh)/fCount*fSingleLength+30+fSingleLength*2-fOffset;
            
            self.imageRangeResult.image=[UIImage imageNamed:@"guo_measure_range_red.png"];
            self.lblRangeResult.text=NSLocalizedString(@"range_high", nil);
        }
        
        if(fLocation<30) fLocation=30-fOffset;
        if(fLocation>SCREEN_WIDTH-60) fLocation=SCREEN_WIDTH-60-fOffset;
        
        self.imageRangeLocation.frame=CGRectMake(fLocation, self.imageRangeLocation.frame.origin.y, self.imageRangeLocation.frame.size.width, self.imageRangeLocation.frame.size.height);
    }
    
    if([name isEqualToString:ProjectBodyageName])
    {
        self.lblRangeResult.text=NSLocalizedString(@"range_normal", nil);
        self.imageRangeResult.image=[UIImage imageNamed:@"guo_measure_range_green.png"];
        self.imageRangeLocation.frame=CGRectMake(self.imageRangeLine.frame.origin.x+self.imageRangeLine.frame.size.width/2, self.imageRangeLocation.frame.origin.y, self.imageRangeLocation.frame.size.width, self.imageRangeLocation.frame.size.height);
    }
    else if([name isEqualToString:ProjectHeightName])
    {
        self.lblRangeResult.text=NSLocalizedString(@"range_normal", nil);
        self.imageRangeResult.image=[UIImage imageNamed:@"guo_measure_range_green.png"];
        self.imageRangeLocation.frame=CGRectMake(self.imageRangeLine.frame.origin.x+self.imageRangeLine.frame.size.width/2, self.imageRangeLocation.frame.origin.y, self.imageRangeLocation.frame.size.width, self.imageRangeLocation.frame.size.height);
    }
    
    if ([name isEqualToString:ProjectBodyageName])
    {
        //少年18青年35中年65老年
        CGFloat fValue=[value floatValue];
        if(fValue<18)
        {
            self.lblRangeResult.text=@"少年";
            self.lblRangeResult.text=NSLocalizedString(@"少年", nil);
        }
        else if (fValue>=18 && fValue<=44)
        {
            self.lblRangeResult.text=@"青年";
            self.lblRangeResult.text=NSLocalizedString(@"青年", nil);
        }
        else if (fValue>=45 && fValue<=59)
        {
            self.lblRangeResult.text=@"中年";
            self.lblRangeResult.text=NSLocalizedString(@"中年", nil);
        }
        else
        {
            self.lblRangeResult.text=@"老年";
            self.lblRangeResult.text=NSLocalizedString(@"老年", nil);
        }
    }
    
    if([value floatValue] <= 0.0)
    {
        self.imageRangeLocation.hidden=YES;
        self.lblProjectValue.text=@"--";
    }
    
}

+(CGFloat)getCellHeight:(NSDictionary *)dic
{
    NSString *type=[dic valueForKey:@"type"];
    NSString *name=[dic valueForKey:@"name"];
    NSString *valueShow=[dic valueForKey:@"valueShow"];
    NSString *value=[dic valueForKey:@"value"];
    NSArray  *aryRange=[dic valueForKey:@"range"];
    
    CGFloat height;
    
    UILabel *label=[[UILabel alloc] init];
    label.font=[UIFont systemFontOfSize:10.0];
    label.frame=CGRectMake(30, 0, SCREEN_WIDTH-30-30, 1024);
    label.numberOfLines=0;
    label.lineBreakMode=NSLineBreakByCharWrapping;
    
    if([name isEqualToString:ProjectFatName])
    {
        label.text=NSLocalizedString(@"m_fat_info", nil);
    }
    else if ([name isEqualToString:ProjectMuscleName])
    {
        label.text=NSLocalizedString(@"m_muscle_info", nil);
    }
    else if ([name isEqualToString:ProjectWaterName])
    {
        label.text=NSLocalizedString(@"m_water_info", nil);
    }
    else if ([name isEqualToString:ProjectBasicName])
    {
        label.text=NSLocalizedString(@"m_basic_info", nil);
    }
    else if ([name isEqualToString:ProjectBoneName])
    {
        label.text=NSLocalizedString(@"m_bone_info", nil);
    }
    else if ([name isEqualToString:ProjectBMIName])
    {
        label.text=NSLocalizedString(@"m_bmi_info", nil);
    }
    else if ([name isEqualToString:ProjectVisceralFatName])
    {
        label.text=NSLocalizedString(@"m_visceralfat_info", nil);
    }
    else if ([name isEqualToString:ProjectHeightName])
    {
        label.text=@"";
    }
    else if ([name isEqualToString:ProjectBodyageName])
    {
        label.text=NSLocalizedString(@"m_bodyage_info", nil);
        
    }
    
    [label sizeToFit];
    
    if([type isEqualToString:DTrue])
    {
        //130 88
        height=0.275*SCREEN_WIDTH+label.frame.size.height+5;
    }
    else
    {
        //44
        height=0.1375*SCREEN_WIDTH;
    }
    
    return height;
}
@end

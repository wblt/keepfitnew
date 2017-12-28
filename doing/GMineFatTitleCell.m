#import "GMineFatTitleCell.h"

@implementation GMineFatTitleCell

- (void)awakeFromNib {
    //0.1125 36
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.2*SCREEN_WIDTH);
    
    NSString *textTitle=@"检测体脂8项，其中0项需要注意";
    NSString *textTitleValue=@"0项";
    NSRange rangeTitle=[textTitle rangeOfString:textTitleValue];
    NSMutableAttributedString *aStrTitle=[[NSMutableAttributedString alloc] initWithString:textTitle];
    [aStrTitle addAttribute:NSForegroundColorAttributeName
                    value:UIColorFromRGB(0xdc0023)
                    range:rangeTitle];
    
    self.lblTitle.attributedText=aStrTitle;
    
    self.lblTitle.frame=CGRectMake(15, 0, SCREEN_WIDTH - 40, self.frame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)configCellWithData:(NSMutableArray *)ary
{
    if(ary)
    {
        NSInteger iCountAll=ary.count;
        NSInteger iCountNoti=0;
        BOOL isAllZero = YES;
        
        for(NSInteger i=0;i<ary.count;i++)
        {
            NSDictionary *dicTemp=[ary objectAtIndex:i];
            NSString *name=[dicTemp valueForKey:@"name"];
            NSString *value=[dicTemp valueForKey:@"value"];
            NSArray *aryRange=[dicTemp valueForKey:@"range"];
            if([name isEqualToString:ProjectBodyageName] ||
               [name isEqualToString:ProjectHeightName])
            {
                continue;
            }
            
            if(aryRange && aryRange.count>=2)
            {
                CGFloat fLow=[[aryRange objectAtIndex:0] floatValue];
                CGFloat fHigh=[[aryRange objectAtIndex:1] floatValue];
                CGFloat fValue=[value floatValue];
                if (fValue > 0 ) {
                    isAllZero = NO;
                }
                if(fValue<fLow || fValue >fHigh)
                {
                    iCountNoti++;
                }
            }
        }
        
        //iCountNoti=iCountNoti-2;
        if(iCountNoti < 0) iCountNoti=0;
        if (isAllZero) {
            iCountNoti = 0;
        }
        //NSString *textTitle=@"检测体脂8项，其中2项需要注意";
        //NSString *textTitleValue=@"2项";
        
        NSString *textTitle=[NSString stringWithFormat:@"%@ %ld %@，%ld %@ %@",NSLocalizedString(@"bodyfat_bodyfat", nil),(long)iCountAll,NSLocalizedString(@"bodyfat_item", nil),(long)iCountNoti,NSLocalizedString(@"bodyfat_item", nil),NSLocalizedString(@"bodyfat_attention", nil)];
        NSString *textTitleValue=[NSString stringWithFormat:@"%ld %@",(long)iCountNoti,NSLocalizedString(@"bodyfat_item", nil)];
        NSRange rangeTitle=[textTitle rangeOfString:textTitleValue];
        NSMutableAttributedString *aStrTitle=[[NSMutableAttributedString alloc] initWithString:textTitle];
        [aStrTitle addAttribute:NSForegroundColorAttributeName
                          value:UIColorFromRGB(0xdc0023)
                          range:rangeTitle];
        NSString *isEnglish = NSLocalizedString(@"user_agreement", nil);
        if ([isEnglish isEqualToString:@"1"]) {
            textTitle=[NSString stringWithFormat:@"%@ %ld %@",NSLocalizedString(@"bodyfat_attention1", nil),(long)iCountNoti,NSLocalizedString(@"bodyfat_attention2", nil)];
            textTitleValue=[NSString stringWithFormat:@"%ld",(long)iCountNoti, nil];
            rangeTitle=[textTitle rangeOfString:textTitleValue];
            aStrTitle=[[NSMutableAttributedString alloc] initWithString:textTitle];
            [aStrTitle addAttribute:NSForegroundColorAttributeName
                              value:UIColorFromRGB(0xdc0023)
                              range:rangeTitle];
        }
        
        self.lblTitle.attributedText=aStrTitle;
    }
    
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 0.2 * SCREEN_WIDTH);
    self.lblTitle.frame=CGRectMake(15, 0, SCREEN_WIDTH - 40, self.frame.size.height);
}
@end

//
//  KFUnitSetupCell.m
//  doing
//
//  Created by weizhu on 16/4/24.
//  Copyright © 2016年 yunjian. All rights reserved.
//

#import "KFUnitSetupCell.h"

@implementation KFUnitSetupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.frame=CGRectMake(0, 0, SCREEN_WIDTH, 44);
    self.titleLabel.frame=CGRectMake(20, 0, SCREEN_WIDTH - 80, self.frame.size.height);
    self.imageHook.frame = CGRectMake(SCREEN_WIDTH - 20 - 16, 14, 16, 16);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

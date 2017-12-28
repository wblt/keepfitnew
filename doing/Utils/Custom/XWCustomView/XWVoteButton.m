//
//  XWVoteButton.m
//  XWQSBK
//
//  Created by Ren XinWei on 13-5-9.
//  Copyright (c) 2013年 renxinwei's iMac. All rights reserved.
//

#import "XWVoteButton.h"

@implementation XWVoteButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        [self initVoteButton];
        [self setBackgroundColor:[UIColor clearColor]];
        //_faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //_faceButton.frame = CGRectMake(-1, -2, 25, 25);
        //_faceButton.userInteractionEnabled = NO;
        
        _faceImage=[[UIImageView alloc] initWithFrame:CGRectMake(-2, -1, 27, 27)];
        [self addSubview:_faceImage];
        //[self addSubview:_faceButton];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 45, 16)];
        _countLabel.text = @"";
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        _countLabel.textColor = [UIColor darkGrayColor];
        _countLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:_countLabel];
        
    }
    
    return self;
}

- (void)dealloc
{
    [_countLabel release];
    [super dealloc];
}

- (void)initVoteButton
{
    //UIImage *nBackgroundImage = [[UIImage imageNamed:@"button_vote_enable.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 18, 23, 19) resizingMode:UIImageResizingModeStretch];
    //UIImage *sBackgroundImage = [[UIImage imageNamed:@"button_vote_active.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(22, 18, 23, 19)];
    //CGFloat top = 25; // 顶端盖高度
    //CGFloat bottom = 25 ; // 底端盖高度
    //CGFloat left = 10; // 左端盖宽度
    //CGFloat right = 10; // 右端盖宽度
    //UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    UIImage *nBackgroundImage = [UIImage imageNamed:@"button_vote_enable.png"];
    UIImage *sBackgroundImage = [UIImage imageNamed:@"button_vote_active.png"];
    
    //nBackgroundImage = [nBackgroundImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    //sBackgroundImage = [sBackgroundImage resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    CGRect frame=self.frame;

    [self setBackgroundImage:nBackgroundImage forState:UIControlStateNormal];
    [self setBackgroundImage:sBackgroundImage forState:UIControlStateSelected];
    UIImageView *imageView=[[UIImageView alloc] initWithImage:nBackgroundImage];
    
    imageView.frame=CGRectMake(0, 0, frame.size.width, frame.size.height);
    [self addSubview:imageView];
    //[self setFrame:frame];
}

- (void)setFaceButtonImage:(UIImage *)nImage andSelectedImage:(UIImage *)sImage
{
    [_faceImage setImage:nImage];
    [self bringSubviewToFront:_faceImage];
    //[_faceButton setImage:nImage forState:UIControlStateNormal];
    //[_faceButton setImage:sImage forState:UIControlStateSelected];
}

- (void)setStateSelected:(BOOL)selected
{
    if (selected) {
        [self setSelected:YES];
        //[_faceButton setSelected:YES];
        //[_countLabel setTextColor:[UIColor redColor]];
    }
    else {
        [self setSelected:NO];
        //[_faceButton setSelected:NO];
        [_countLabel setTextColor:[UIColor darkGrayColor]];
    }
}

- (void)setCount:(NSInteger)count
{
    NSString *text = [NSString stringWithFormat:@"%d", count];
    _countLabel.text = text;
}

@end

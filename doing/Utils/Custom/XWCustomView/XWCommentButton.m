//
//  XWCommentButton.m
//  XWQSBK
//
//  Created by renxinwei on 13-5-9.
//  Copyright (c) 2013年 renxinwei's MacBook Pro. All rights reserved.
//

#import "XWCommentButton.h"

@implementation XWCommentButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initCommentButton];
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 40, 16)];
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

- (void)initCommentButton
{
    //UIImage *nBackgroundImage = [[UIImage imageNamed:@"button_comment_enable.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 25, 10)];

    //CGRect frame=self.frame;
    UIImage *nBackgroundImage = [UIImage imageNamed:@"button_comment_enable.png"];
    UIImageView *iamgeView=[[UIImageView alloc] initWithImage:nBackgroundImage];
    //[self setBackgroundImage:nBackgroundImage forState:UIControlStateNormal];
    //[self setFrame:frame];
    [self addSubview:iamgeView];
    [self setUserInteractionEnabled:NO];
}

- (void)setCount:(NSInteger)count
{
    NSString *text = [NSString stringWithFormat:@"%d", count];
    _countLabel.text = text;
}

@end

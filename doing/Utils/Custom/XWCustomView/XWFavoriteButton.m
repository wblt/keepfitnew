//
//  XWFavoriteButton.m
//  XWQSBK
//
//  Created by renxinwei on 13-5-9.
//  Copyright (c) 2013年 renxinwei's MacBook Pro. All rights reserved.
//

#import "XWFavoriteButton.h"

@implementation XWFavoriteButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initFavoriteButton];
        [self setBackgroundColor:[UIColor clearColor]];
        
        /*
        _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _favoriteButton.frame = CGRectMake(4, 7, 30, 10);
        _favoriteButton.userInteractionEnabled = NO;
        [self addSubview:_favoriteButton];
        */
        
        imageView=[[UIImageView alloc] init];
        imageView.frame=CGRectMake(8, 9, 20, 8);
        imageView.userInteractionEnabled=NO;
        imageView.backgroundColor=[UIColor clearColor];
        [self addSubview:imageView];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)initFavoriteButton
{
    //UIImage *nBackgroundImage = [[UIImage imageNamed:@"button_vote_enable.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 25, 10)];
   // UIImage *sBackgroundImage = [[UIImage imageNamed:@"button_vote_active.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 10, 25, 10)];
    //CGRect frame=self.frame;
    UIImage *nBackgroundImage = [UIImage imageNamed:@"button_comment_enable.png"];
    //UIImage *sBackgroundImage = [UIImage imageNamed:@"button_vote_active.png"];
    //[self setBackgroundImage:nBackgroundImage forState:UIControlStateNormal];
    //[self setBackgroundImage:sBackgroundImage forState:UIControlStateSelected];
    
    UIImageView *imageCurrentView=[[UIImageView alloc] initWithImage:nBackgroundImage];
    [self addSubview:imageCurrentView];
    //[self setFrame:frame];
}

- (void)setFavoriteButtonImage:(UIImage *)nImage andSelectedImage:(UIImage *)sImage
{
    //[_favoriteButton setImage:nImage forState:UIControlStateNormal];
    //[_favoriteButton setImage:sImage forState:UIControlStateSelected];
    
    [imageView setImage:nImage];
}

- (void)setStateSelected:(BOOL)selected
{
    if (selected) {
        [self setSelected:YES];
        [_favoriteButton setSelected:YES];
    }
    else {
        [self setSelected:NO];
        [_favoriteButton setSelected:NO];
    }
}

@end

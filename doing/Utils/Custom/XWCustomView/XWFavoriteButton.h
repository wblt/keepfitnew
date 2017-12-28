//
//  XWFavoriteButton.h
//  XWQSBK
//
//  Created by renxinwei on 13-5-9.
//  Copyright (c) 2013年 renxinwei's MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @brief 收藏按钮
 */
@interface XWFavoriteButton : UIButton
{
    UIButton *_favoriteButton;
    UIImageView *imageView;
}

- (void)setFavoriteButtonImage:(UIImage *)nImage andSelectedImage:(UIImage *)sImage;
- (void)setStateSelected:(BOOL)selected;

@end

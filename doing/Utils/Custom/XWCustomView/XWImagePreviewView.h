//
//  XWImagePreviewView.h
//  TestScrollView
//
//  Created by Ren XinWei on 13-5-9.
//  Copyright (c) 2013年 renxinwei's iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

/**
 * @brief 图片预览，静态图片，gif图片，拖拉放大缩小，保存图片至本地（gif会保存成静态）
 */
@protocol XWImagePreviewViewDelegate <NSObject>

@optional
- (void)didTapPreviewView;

@end

@interface XWImagePreviewView : UIView <UIScrollViewDelegate, MBProgressHUDDelegate>
{
    MBProgressHUD *_hud;
    UIScrollView *_imageScrollView;
    UIImageView *_previewImageView;
    UIButton *_saveImageButton;
}

@property (nonatomic) CGFloat previewWidth;
@property (nonatomic) CGFloat previewHeight;
@property (nonatomic, assign) id<XWImagePreviewViewDelegate> delegate;

- (void)initImageWithURL:(NSString *)url;
- (void)initImageWithImage:(UIImage *)image;
- (void)resetLayoutByPreviewImageView;

@end

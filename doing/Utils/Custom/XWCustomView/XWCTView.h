//
//  XWCTView.h
//  XWQiuShiBaiKe
//
//  Created by Ren XinWei on 13-6-5.
//  Copyright (c) 2013年 renxinwei's MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

/**
 * @brief 使用CoreText来显示评论内容，设置楼层文字颜色及点击事件
 */
@protocol XWCTViewDelegate <NSObject>

@optional
- (void)textDidClicked:(NSInteger)floor;

@end

@interface XWCTView : UIView

@property (assign, nonatomic) NSInteger maxFloor;
@property (copy, nonatomic) NSString *conetntString;
@property (retain, nonatomic) NSArray *matchArray;
@property (assign, nonatomic) id<XWCTViewDelegate> delegate;

+ (int)getAttributedStringHeightWithString:(NSAttributedString *)string  WidthValue:(int)width;

@end

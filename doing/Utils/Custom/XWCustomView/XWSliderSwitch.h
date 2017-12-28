//
//  SliderSwitch.h
//  XWQSBK
//
//  Created by Ren XinWei on 13-5-4.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @brief 自定义Switch，可以点击和拖动，最多支持3个选项
 */
@class XWSliderSwitch;

@protocol XWSliderSwitchDelegate <NSObject>

@optional
- (void)slideView:(XWSliderSwitch *)slideSwitch switchChangedAtIndex:(NSInteger)index;

@end

@interface XWSliderSwitch : UIView
{
    UILabel *_labelOne, *_labelTwo,* _labelThree;
    UIButton *_toggleButton;
}

@property (nonatomic) NSInteger labelCount;
@property (nonatomic, assign) id<XWSliderSwitchDelegate> delegate;

- (void)initSliderSwitch;
- (void)setSliderSwitchBackground:(UIImage *)image;
- (void)setLabelOneText:(NSString *)text;
- (void)setLabelTwoText:(NSString *)text;

- (void)setLabelOneColor;
- (void)setLabelTwoColor;

- (void)setLabelThreeText:(NSString *)text;

@end

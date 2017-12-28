//
//  XWZoomInView.h
//  iOSAppTest
//
//  Created by renxinwei on 13-5-5.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @brief 显示冒泡后并消失的“+1”组件
 */
@interface XWZoomInPlusView : UIScrollView <UIScrollViewDelegate>
{
    UILabel *_labelPlus;
}

//显示的位置
- (void)zoomInPlusTextInPoint:(CGPoint)point;

@end

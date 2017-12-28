//
//  XWZoomInMinusView.h
//  iOSAppTest
//
//  Created by renxinwei on 13-5-5.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * @brief 显示冒泡后并消失的“-1”组件
 */
@interface XWZoomInMinusView : UIScrollView <UIScrollViewDelegate>
{
    UILabel *_labelMinus;
}

//显示的位置
- (void)zoomInMinusTextInPoint:(CGPoint)point;

@end

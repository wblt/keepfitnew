//
//  UIColor+XWCategory.h
//  XWQiuShiBaiKe
//
//  Created by renxinwei on 13-6-4.
//  Copyright (c) 2013年 renxinwei's MacBook Pro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (XWCategory)

+ (UIColor *)colorWithHex:(long)hexColor;
+ (UIColor *)colorWithHex:(long)hexColor alpha:(float)opacity;
+ (UIColor *)colorWithHexString:(NSString *)hexColor;
+(CGColorRef)getCGColorFromRed:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha;

@end

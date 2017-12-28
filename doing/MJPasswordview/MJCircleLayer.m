//
//  MJCircleLayer.m
//  MJCircleView
//
//  Created by tenric on 13-6-29.
//  Copyright (c) 2013年 tenric. All rights reserved.
//

#define pi 3.14159265359
#define   DEGREES_TO_RADIANS(degrees)  ((pi * degrees)/ 180)

#import "MJCircleLayer.h"
#import "MJPasswordView.h"

@implementation MJCircleLayer


- (void)drawInContext:(CGContextRef)ctx
{
    CGRect circleFrame = self.bounds;

    //椭圆
    CGRect aRect= CGRectMake(2, 2, circleFrame.size.width-4, circleFrame.size.height-4);
    CGContextSetStrokeColorWithColor(ctx, self.passwordView.circleFillColour.CGColor);
    
    //CGContextSetRGBStrokeColor(ctx, 0.6, 0.9, 0, 1.0);
    //CGContextSetLineWidth(ctx, 3.0);

    CGContextAddEllipseInRect(ctx, aRect); //椭圆
    CGContextDrawPath(ctx, kCGPathStroke);
    
    if (self.highlighted)
    {
        CGRect circleFrame2=CGRectMake(16, 16, 28, 28);
        UIBezierPath *circlePath2=[UIBezierPath bezierPathWithRoundedRect:circleFrame2 cornerRadius:circleFrame2.size.height/2.0];
        CGContextSetFillColorWithColor(ctx, self.passwordView.circleFillColourHighlighted.CGColor);
        CGContextAddPath(ctx, circlePath2.CGPath);
        CGContextFillPath(ctx);
    }
    UIGraphicsPushContext(ctx);
}


@end

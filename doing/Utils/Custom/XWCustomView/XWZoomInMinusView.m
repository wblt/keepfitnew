//
//  XWZoomInMinusView.m
//  iOSAppTest
//
//  Created by renxinwei on 13-5-5.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import "XWZoomInMinusView.h"

@implementation XWZoomInMinusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.maximumZoomScale = 3;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setHidden:YES];
        [self initMinusView];
    }
    return self;
}

- (void)dealloc
{
    [_labelMinus release];
    
    [super dealloc];
}

#pragma mark - UIScrollView delegate method

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _labelMinus;
}

#pragma mark - Public method

- (void)zoomInMinusTextInPoint:(CGPoint)point
{
    [self setFrame:CGRectMake(point.x, point.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self setHidden:NO];
    [self setZoomScale:3 animated:YES];
    [UIView animateWithDuration:1 animations:^{
        [_labelMinus setAlpha:0];
    } completion:^(BOOL finished) {
        [self resetView];
    }];
}

#pragma mark - Private method

- (void)initMinusView
{
    _labelMinus = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _labelMinus.text = @"-1";
    _labelMinus.textColor = [UIColor blueColor];
    _labelMinus.backgroundColor = [UIColor clearColor];
    _labelMinus.textAlignment = NSTextAlignmentCenter;
    _labelMinus.font = [UIFont boldSystemFontOfSize:12];
    [self addSubview:_labelMinus];
}

- (void)resetView
{
    [self setHidden:YES];
    [self setZoomScale:1];
    [_labelMinus setAlpha:1];
}


@end

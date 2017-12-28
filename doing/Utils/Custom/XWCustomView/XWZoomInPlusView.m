//
//  XWZoomInView.m
//  iOSAppTest
//
//  Created by renxinwei on 13-5-5.
//  Copyright (c) 2013年 renxinwei. All rights reserved.
//

#import "XWZoomInPlusView.h"

@implementation XWZoomInPlusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.delegate = self;
        self.maximumZoomScale = 3;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setHidden:YES];
        [self initPlusView];
    }
    return self;
}

- (void)dealloc
{
    [_labelPlus release];
    
    [super dealloc];
}

#pragma mark - UIScrollView delegate method

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _labelPlus;
}

#pragma mark - Public method

- (void)zoomInPlusTextInPoint:(CGPoint)point
{
    [self setFrame:CGRectMake(point.x, point.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [self setHidden:NO];
    [self setZoomScale:3 animated:YES];
    [UIView animateWithDuration:1 animations:^{
        [_labelPlus setAlpha:0];
    } completion:^(BOOL finished) {
        [self resetView];
    }];
}

#pragma mark - Private method

- (void)initPlusView
{
    _labelPlus = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    _labelPlus.text = @"+1";
    _labelPlus.textColor = [UIColor redColor];
    _labelPlus.backgroundColor = [UIColor clearColor];
    _labelPlus.textAlignment = NSTextAlignmentCenter;
    _labelPlus.font = [UIFont boldSystemFontOfSize:12];
    [self addSubview:_labelPlus];
}

- (void)resetView
{
    [self setHidden:YES];
    [self setZoomScale:1];
    [_labelPlus setAlpha:1];
}

@end

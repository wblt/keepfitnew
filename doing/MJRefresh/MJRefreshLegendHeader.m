//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
//  MJRefreshLegendHeader.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/3/4.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "MJRefreshLegendHeader.h"
#import "MJRefreshConst.h"
#import "UIView+MJExtension.h"

@interface MJRefreshLegendHeader()
@property (nonatomic, weak) UIImageView *arrowImage;
@property (nonatomic, weak) UIImageView *imageUp;
@property (nonatomic, weak) UIActivityIndicatorView *activityView;
@property (nonatomic, weak) UIImageView *circleImage;
@end

@implementation MJRefreshLegendHeader
#pragma mark - 懒加载
- (UIImageView *)arrowImage
{
    if (!_arrowImage) {
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:MJRefreshSrcName(@"arrow.png")]];
        [self addSubview:_arrowImage = arrowImage];
    }
    return _arrowImage;
}

-(UIImageView *)imageUp
{
    if (!_imageUp) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mj_circle3.png"]];
        image.frame=CGRectMake(0, 0, 25, 25);
        [self addSubview:_imageUp = image];
    }
    return _imageUp;
}

-(UIImageView *)circleImage
{
    if (!_circleImage) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mj_circle11.png"]];
        image.frame=CGRectMake(0, 0, 26, 26);
        _circleImage.alpha=0.0;
        CGFloat arrowX = (self.stateHidden && self.updatedTimeHidden) ? self.mj_w * 0.5 : (self.mj_w * 0.5 - 100);
        _circleImage.center = CGPointMake(arrowX, self.mj_h * 0.5);
        [self addSubview:_circleImage = image];
    }
    return _circleImage;
}

- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.bounds = self.arrowImage.bounds;
        activityView.color=UIColorFromRGB(0x2e5f91);
        [self addSubview:_activityView = activityView];
    }
    return _activityView;
}

#pragma mark - 初始化
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 箭头
    CGFloat arrowX = (self.stateHidden && self.updatedTimeHidden) ? self.mj_w * 0.5 : (self.mj_w * 0.5 - 100);
    self.arrowImage.center = CGPointMake(arrowX, self.mj_h * 0.5);
    
    self.arrowImage.hidden=YES;
    
    self.activityView.alpha=1.0;
    self.activityView.center = self.arrowImage.center;
    self.circleImage.center = CGPointMake(arrowX, self.mj_h * 0.5);
    self.circleImage.alpha=0.0;
    //self.circleImage.alpha=0.0;
    //self.circleImage.autoresizesSubviews=NO;
    //self.circleImage.contentMode=UIViewContentModeScaleToFill;
    //self.imageUp.center=self.arrowImage.center;
}

#pragma mark - 公共方法
#pragma mark 设置状态
- (void)setState:(MJRefreshHeaderState)state
{
    if (self.state == state) return;
    
    // 旧状态
    MJRefreshHeaderState oldState = self.state;
    
    self.activityView.alpha = 1.0;
    
    switch (state) {
        case MJRefreshHeaderStateIdle: {
            if (oldState == MJRefreshHeaderStateRefreshing) {
                self.arrowImage.transform = CGAffineTransformIdentity;
                self.activityView.alpha=1.0;
                [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                    self.activityView.alpha = 1.0;
                    //self.circleImage.alpha=0.0;
                } completion:^(BOOL finished) {
                    //self.arrowImage.alpha = 1.0;
                    //self.circleImage.alpha=0.0;
                    //[self stopRefresh];
                    
                    self.activityView.alpha = 1.0;
                    [self.activityView stopAnimating];
                }];
            } else {
                self.activityView.alpha=1.0;
                [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
                    self.arrowImage.transform = CGAffineTransformIdentity;
                    //self.arrowImage.alpha=1.0;
                    //self.circleImage.alpha=0.0;
                }];
            }
            break;
        }
            
        case MJRefreshHeaderStatePulling: {
            self.activityView.alpha=1.0;
            [self.activityView startAnimating];
            [UIView animateWithDuration:0.4 animations:^{
                self.arrowImage.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
            }];
            break;
        }
            
        case MJRefreshHeaderStateRefreshing: {
            [self.activityView startAnimating];
            //self.circleImage.alpha=1.0;
            self.arrowImage.alpha = 1.0;
            //[self startRefresh];
            

            break;
        }
            
        default:
            break;
    }
    
    // super里面有回调，应该在最后面调用
    [super setState:state];
}

-(void)startRefresh
{
    isStopTimer=NO;
    self.circleImage.hidden=NO;
    [UIView animateWithDuration:0.1 animations:^{
        [self transformAction];
        
    } completion:^(BOOL finished) {
        if(!isStopTimer)
        {
            [self startRefresh];
        }
    }];
    
    /*
     if(_timer)
     {
     [_timer invalidate];
     }
     _timer=nil;
     _timer=[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(transformAction) userInfo:nil repeats:YES];
     */
}

-(void)stopRefresh
{
    isStopTimer=YES;
    /*
     if(_timer)
     {
     if([_timer isValid])
     {
     [_timer invalidate];
     _timer=nil;
     }
     }
     */
}

-(void)transformAction {
    angle = angle + 0.8;//angle角度 double angle;
    if (angle > 6.28) {//大于 M_PI*2(360度) 角度再次从0开始
        angle = 0;
    }
    CGAffineTransform transform=CGAffineTransformMakeRotation(angle);
    self.circleImage.transform = transform;
}

@end

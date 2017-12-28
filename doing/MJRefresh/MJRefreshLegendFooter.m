//  代码地址: https://github.com/CoderMJLee/MJRefresh
//  代码地址: http://code4app.com/ios/%E5%BF%AB%E9%80%9F%E9%9B%86%E6%88%90%E4%B8%8B%E6%8B%89%E4%B8%8A%E6%8B%89%E5%88%B7%E6%96%B0/52326ce26803fabc46000000
//  MJRefreshLegendFooter.m
//  MJRefreshExample
//
//  Created by MJ Lee on 15/3/5.
//  Copyright (c) 2015年 itcast. All rights reserved.
//

#import "MJRefreshLegendFooter.h"
#import "MJRefreshConst.h"
#import "UIView+MJExtension.h"
#import "UIScrollView+MJExtension.h"

@interface MJRefreshLegendFooter()
@property (nonatomic, weak) UIActivityIndicatorView *activityView;
@property (nonatomic, weak) UIImageView *loadingImage;
@end

@implementation MJRefreshLegendFooter
#pragma mark - 懒加载
- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        activityView.color=UIColorFromRGB(0x2e5f91);
        [self addSubview:_activityView = activityView];
    }
    return _activityView;
}

-(UIImageView *)loadingImage
{
    if (!_loadingImage) {
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mj_circle11.png"]];
        //NSArray *images=[[NSArray alloc] initWithObjects:[UIImage imageNamed:@"mj_circle11.png"],[UIImage imageNamed:@"mj_circle21.png"],[UIImage imageNamed:@"mj_circle31.png"],[UIImage imageNamed:@"mj_circle41.png"], nil];
        //image.animationImages=images;
        image.frame=CGRectMake(0, 0, 26, 26);
        [self addSubview:_loadingImage = image];
    }
    return _loadingImage;
}

-(void)startRefresh
{
    isStopTimer=NO;
    
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
    self.loadingImage.transform = transform;
}

#pragma mark - 初始化方法
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 指示器
    if (self.stateHidden) {
        
        self.activityView.center = CGPointMake(self.mj_w * 0.5, self.mj_h * 0.7);
    } else {
        
        self.activityView.center = CGPointMake(self.mj_w * 0.5 - 100, self.mj_h * 0.7);
    }
    self.activityView.center = CGPointMake(self.mj_w * 0.5, self.mj_h * 0.7);
    self.activityView.alpha=1.0;
    self.loadingImage.center=self.activityView.center;
    self.loadingImage.hidden=YES;
    //self.loadingImage.hidden=YES;
    //self.activityView.hidden=YES;
}

#pragma mark - 公共方法
- (void)setState:(MJRefreshFooterState)state
{
    //self.loadingImage.hidden=YES;
    //self.activityView.hidden=YES;
    
    if (self.state == state) return;
    
    switch (state) {
        case MJRefreshFooterStateIdle:
            [self.activityView stopAnimating];
            //self.loadingImage.alpha=0.0;
            //[self stopRefresh];
            
            break;
            
        case MJRefreshFooterStateRefreshing:
            [self.activityView startAnimating];
            //self.loadingImage.alpha=1.0;
            //[self startRefresh];
            break;
            
        case MJRefreshFooterStateNoMoreData:
            [self.activityView stopAnimating];
            //self.loadingImage.alpha=0.0;
            //[self stopRefresh];
            
            break;
            
        default:
            break;
    }
    
    // super里面有回调，应该在最后面调用
    [super setState:state];
}
@end

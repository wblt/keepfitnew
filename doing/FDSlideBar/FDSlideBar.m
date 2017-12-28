//
//  FDSlideBar.m
//  FDSlideBarDemo
//
//  Created by fergusding on 15/6/4.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import "FDSlideBar.h"
#import "FDSlideBarItem.h"

#define DEVICE_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define DEFAULT_SLIDER_COLOR [UIColor blackColor]
#define SLIDER_VIEW_HEIGHT 2

@interface FDSlideBar () <FDSlideBarItemDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) NSMutableArray *items;
@property (strong, nonatomic) UIView *sliderView;

@property (strong, nonatomic) FDSlideBarItem *selectedItem;
@property (strong, nonatomic) FDSlideBarItemSelectedCallback callback;

@end

@implementation FDSlideBar

#pragma mark - Lifecircle

- (instancetype)init {
    CGRect frame = CGRectMake(0, 20, DEVICE_WIDTH, 46);
    return [self initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self= [super initWithFrame:frame]) {
        _items = [NSMutableArray array];
        [self initScrollView];
        [self initSliderView];
    }
    return self;
}

#pragma - mark Custom Accessors

- (void)setItemsTitle:(NSArray *)itemsTitle {
    _itemsTitle = itemsTitle;
    [self setupItems];
}

- (void)setItemColor:(UIColor *)itemColor {
    for (FDSlideBarItem *item in _items) {
        [item setItemTitleColor:itemColor];
    }
}

- (void)setItemSelectedColor:(UIColor *)itemSelectedColor {
    for (FDSlideBarItem *item in _items) {
        [item setItemSelectedTitleColor:itemSelectedColor];
    }
}

- (void)setSliderColor:(UIColor *)sliderColor {
    _sliderColor = sliderColor;
    self.sliderView.backgroundColor = _sliderColor;
}

- (void)setSelectedItem:(FDSlideBarItem *)selectedItem {
    _selectedItem.selected = NO;
    _selectedItem = selectedItem;
}


#pragma - mark Private

- (void)initScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    [self addSubview:_scrollView];
}

- (void)initSliderView {
    _sliderView = [[UIView alloc] init];
    _sliderColor = DEFAULT_SLIDER_COLOR;
    _sliderView.backgroundColor = _sliderColor;
    [_scrollView addSubview:_sliderView];
}

- (void)setupItems {
    CGFloat itemX = 0;
    for (NSString *title in _itemsTitle)
    {
        NSString *newtitle = NSLocalizedString(title, nil);
        FDSlideBarItem *item = [[FDSlideBarItem alloc] init];
        item.delegate = self;
        
        // Init the current item's frame

        CGFloat itemW = [FDSlideBarItem widthForTitle:NSLocalizedString(title, nil)];
        //NSLog(@"%@宽度%.1f",title,itemW);
        item.frame = CGRectMake(itemX, 0, itemW, CGRectGetHeight(_scrollView.frame));
        [item setItemTitle:newtitle];
        [_items addObject:item];
        
        [_scrollView addSubview:item];
        
        // Caculate the origin.x of the next item
        itemX = CGRectGetMaxX(item.frame);
    }
    
    // Cculate the scrollView 's contentSize by all the items
    _scrollView.contentSize = CGSizeMake(itemX, CGRectGetHeight(_scrollView.frame));
    
    // Set the default selected item, the first item
    FDSlideBarItem *firstItem = [self.items firstObject];
    firstItem.selected = YES;
    _selectedItem = firstItem;
    
    // Set the frame of sliderView by the selected item
    _sliderView.frame = CGRectMake(0, self.frame.size.height - SLIDER_VIEW_HEIGHT, firstItem.frame.size.width, SLIDER_VIEW_HEIGHT);
}

- (void)scrollToVisibleItem:(FDSlideBarItem *)item
{
    NSInteger selectedItemIndex = [self.items indexOfObject:_selectedItem];
    NSInteger visibleItemIndex = [self.items indexOfObject:item];
    
    // If the selected item is same to the item to be visible, nothing to do
    if (selectedItemIndex == visibleItemIndex)
    {
        return;
    }
    
    CGPoint offset = _scrollView.contentOffset;
    
    // If the item to be visible is in the screen, nothing to do
    if (CGRectGetMinX(item.frame) > offset.x && CGRectGetMaxX(item.frame) < (offset.x + CGRectGetWidth(_scrollView.frame)))
    {
        return;
    }
    
    // Update the scrollView's contentOffset according to different situation
    if (selectedItemIndex < visibleItemIndex)
    {
        // The item to be visible is on the right of the selected item and the selected item is out of screeen by the left, also the opposite case, set the offset respectively
        if (CGRectGetMaxX(_selectedItem.frame) < offset.x)
        {
            offset.x = CGRectGetMinX(item.frame);
        }
        else
        {
            offset.x = CGRectGetMaxX(item.frame) - CGRectGetWidth(_scrollView.frame);
        }
    }
    else
    {
        // The item to be visible is on the left of the selected item and the selected item is out of screeen by the right, also the opposite case, set the offset respectively
        if (CGRectGetMinX(_selectedItem.frame) > (offset.x + CGRectGetWidth(_scrollView.frame)))
        {
            offset.x = CGRectGetMaxX(item.frame) - CGRectGetWidth(_scrollView.frame);
        }
        else
        {
            offset.x = CGRectGetMinX(item.frame);
        }
    }
    _scrollView.contentOffset = offset;
}

- (void)addAnimationWithSelectedItem:(FDSlideBarItem *)item {
    // Caculate the distance of translation
    CGFloat dx = CGRectGetMidX(item.frame) - CGRectGetMidX(_selectedItem.frame);
    
    // Add the animation about translation
    CABasicAnimation *positionAnimation = [CABasicAnimation animation];
    positionAnimation.keyPath = @"position.x";
    positionAnimation.fromValue = @(_sliderView.layer.position.x);
    positionAnimation.toValue = @(_sliderView.layer.position.x + dx);
    
    // Add the animation about size
    CABasicAnimation *boundsAnimation = [CABasicAnimation animation];
    boundsAnimation.keyPath = @"bounds.size.width";
    boundsAnimation.fromValue = @(CGRectGetWidth(_sliderView.layer.bounds));
    boundsAnimation.toValue = @(CGRectGetWidth(item.frame));
    
    // Combine all the animations to a group
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[positionAnimation, boundsAnimation];
    animationGroup.duration = 0.2;
    [_sliderView.layer addAnimation:animationGroup forKey:@"basic"];
    
    // Keep the state after animating
    _sliderView.layer.position = CGPointMake(_sliderView.layer.position.x + dx, _sliderView.layer.position.y);
    CGRect rect = _sliderView.layer.bounds;
    rect.size.width = CGRectGetWidth(item.frame);
    _sliderView.layer.bounds = rect;
}

#pragma mark - Public

- (void)slideBarItemSelectedCallback:(FDSlideBarItemSelectedCallback)callback
{
    _callback = callback;
}

- (void)selectSlideBarItemAtIndex:(NSUInteger)index
{
    FDSlideBarItem *item = [self.items objectAtIndex:index];
    if (item == _selectedItem)
    {
        return;
    }
    
    item.selected = YES;
    [self scrollToVisibleItem:item];
    [self addAnimationWithSelectedItem:item];
    self.selectedItem = item;
}

- (void)scrollToNextAndSelected
{
    NSInteger indexSelect=[self.items indexOfObject:_selectedItem];
    indexSelect++;
    
    if(indexSelect >= self.items.count)
    {
        return;
    }
    
    FDSlideBarItem *item=[self.items objectAtIndex:indexSelect];
    item.selected = YES;
    [self scrollToVisibleItem:item];
    [self addAnimationWithSelectedItem:item];
    self.selectedItem = item;
    _callback([self.items indexOfObject:item]);
}

-(void)scrollToPreviousAndSelected
{
    NSInteger indexSelect=[self.items indexOfObject:_selectedItem];
    indexSelect--;
    
    if(indexSelect < 0)
    {
        return;
    }
    
    FDSlideBarItem *item=[self.items objectAtIndex:indexSelect];
    item.selected = YES;
    [self scrollToVisibleItem:item];
    [self addAnimationWithSelectedItem:item];
    self.selectedItem = item;
    _callback([self.items indexOfObject:item]);
}

-(void)scrollSeeItemWithSelectIndex:(NSUInteger)index
{
    index--;
    if(index<=0)
    {
        index = 0;
    }
    else if (index>=self.items.count-1)
    {
        index=self.items.count-1;
    }
    
    FDSlideBarItem *item=[self.items objectAtIndex:index];
    [self scrollToVisibleItem:item];
}

- (void)scrollToPrevious
{
    NSInteger index=[self.items indexOfObject:self.selectedItem];
    index--;
    if(index<=0)
    {
        index = 0;
    }
    
    else if (index>=self.items.count-1)
    {
        index=self.items.count-1;
    }
    
    FDSlideBarItem *item=[self.items objectAtIndex:index];
    [self scrollToVisibleItem:item];
}

- (void)scrollToNext
{
    NSInteger index=[self.items indexOfObject:self.selectedItem];
    index++;
    if(index<=0)
    {
        index = 0;
    }
    else if (index>=self.items.count-1)
    {
        index=self.items.count-1;
    }
    
    FDSlideBarItem *item=[self.items objectAtIndex:index];
    [self scrollToVisibleItem:item];
}

#pragma mark - FDSlideBarItemDelegate

- (void)slideBarItemSelected:(FDSlideBarItem *)item
{
    NSUInteger indexOld=[self.items indexOfObject:_selectedItem];
    
    if (item == _selectedItem) {
        return;
    }
    
    NSUInteger indexNew=[self.items indexOfObject:item];
    [self addAnimationWithSelectedItem:item];
    self.selectedItem = item;
    _callback([self.items indexOfObject:item]);
    
    if(indexNew>indexOld)
    {
        [self scrollToNext];
    }
    else
    {
        [self scrollToPrevious];
    }
}

@end

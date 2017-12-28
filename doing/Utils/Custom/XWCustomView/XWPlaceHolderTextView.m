//
//  XWPlaceHolderTextView.m
//  XWQiuShiBaiKe
//
//  Created by Ren XinWei on 13-6-4.
//  Copyright (c) 2013年 renxinwei's MacBook Pro. All rights reserved.
//

#import "XWPlaceHolderTextView.h"

@implementation XWPlaceHolderTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.placeHolder = @"";
        self.placeHolderColor = [UIColor lightGrayColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.placeHolder = @"";
    self.placeHolderColor = [UIColor lightGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if ([[self placeHolder] length] > 0) {
        if (self.placeHolderLabel == nil) {
            self.placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, self.bounds.size.width - 16, 0)];
            self.placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
            self.placeHolderLabel.numberOfLines = 0;
            self.placeHolderLabel.font = self.font;
            self.placeHolderLabel.backgroundColor = [UIColor clearColor];
            self.placeHolderLabel.alpha = 0;
            [self addSubview:self.placeHolderLabel];
        }
        
        self.placeHolderLabel.text = self.placeHolder;
        self.placeHolderLabel.textColor = self.placeHolderColor;
        [self.placeHolderLabel sizeToFit];
        [self sendSubviewToBack:self.placeHolderLabel];
        
        if (self.placeHodlerBackgroundImage != nil) {
            UIImageView *placeHodlerBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
            [self addSubview:placeHodlerBackgroundImageView];
            
            placeHodlerBackgroundImageView.image = self.placeHodlerBackgroundImage;
            [self sendSubviewToBack:placeHodlerBackgroundImageView];
            [placeHodlerBackgroundImageView release];
        }
    }
    
    if ([[self text] length] == 0 && [[self placeHolder] length] > 0) {
        [self.placeHolderLabel setAlpha:1];
    }
    
    [super drawRect:rect];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.placeHodlerBackgroundImage = nil;
    self.placeHolderLabel = nil;
    self.placeHolderColor = nil;
    self.placeHolder = nil;
    [super dealloc];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self textChanged:nil];
}

- (void)textChanged:(NSNotification *)notification
{
    if ([[self placeHolder] length] == 0) {
        return;
    }
    if ([[self text] length] == 0) {
        [self.placeHolderLabel setAlpha:1];
    }
    else {
        [self.placeHolderLabel setAlpha:0];
    }
}

@end

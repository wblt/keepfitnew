//
//  XWCTView.m
//  XWQiuShiBaiKe
//
//  Created by Ren XinWei on 13-6-5.
//  Copyright (c) 2013年 renxinwei's MacBook Pro. All rights reserved.
//

#import "XWCTView.h"

@implementation XWCTView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //创建 NSMutableAttributedString,在Core Text 中使用 NSAttributedString 而不是 NSString
    NSMutableAttributedString *attrString = [[[NSMutableAttributedString alloc] initWithString:_conetntString] autorelease];
    CGColorRef lightBrown = [UIColor getCGColorFromRed:108 Green:96 Blue:81 Alpha:255];
    [attrString addAttribute:(id)kCTForegroundColorAttributeName value:(id)lightBrown range:NSMakeRange(0, [attrString length])];
    
    //正则表达式匹配 %dl, %dL, %d楼
    NSString *pattern = @"\\d+[l楼]";
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:NULL];
    //返回匹配的结果,并保存于mathArray
    NSUInteger numberOfMatches = [reg numberOfMatchesInString:_conetntString options:0 range:NSMakeRange(0, [_conetntString length])];
    if (numberOfMatches > 0) {
        NSArray *matches = [reg matchesInString:_conetntString options:0 range:NSMakeRange(0, [_conetntString length])];
        self.matchArray = [NSArray arrayWithArray:matches];
        
        //遍历结果,小于maxFloor就填充成蓝色
        for (NSTextCheckingResult *match in matches) {
            NSRange range = [match range];
            NSString *floor = [[_conetntString substringWithRange:range] substringWithRange:NSMakeRange(0, range.length - 1)];
            if (floor.integerValue <= _maxFloor && floor.integerValue > 0) {
                CGColorRef lightBlue = [UIColor getCGColorFromRed:150 Green:181 Blue:218 Alpha:255];
                [attrString addAttribute:(id)kCTForegroundColorAttributeName value:(id)lightBlue range:range];
            }
        }
    }
    
    //沿y轴翻转坐标系统
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bounds));
    CGContextScaleCTM(context, 1.0, -1.0);
    
    //创建一个用于绘制文本的路径区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    //CTFramesetter 是使用 Core Text 绘制时最重要的类。它管理您的字体引用和文本绘制帧。
    //目前您需要了解 CTFramesetterCreateWithAttributedString 通过应用属性化文本创建 CTFramesetter.
    //在 framesetter 之后通过一个所选的文本范围（这里我们选择整个文本）与需要绘制到的矩形路径创建一个帧。
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CTFrameRef textFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    //CTFrameDraw 将textFrame绘制到设备context
    CTFrameDraw(textFrame, context);
    
    //释放所有使用的对象,引用名字中有 “Create” 的函数时,不要忘记使用 CFRelease.
    CGPathRelease(path);
    CFRelease(frameSetter);
    CFRelease(textFrame);
}

/**
 * @description 监听文字上的点击事件
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //取得转换后的点击处坐标
    CGPoint point = [[touches anyObject] locationInView:self];
    CGPoint reversePoint = CGPointMake(point.x, CGRectGetHeight(self.bounds) - point.y);
    
    NSMutableAttributedString *attrString = [[[NSMutableAttributedString alloc] initWithString:_conetntString] autorelease];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attrString);
    CTFrameRef textFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    //取得每行文字的行坐标
    CFArrayRef lines = CTFrameGetLines(textFrame);
    CGPoint *lineOrigins = malloc(sizeof(CGPoint)*CFArrayGetCount(lines));
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), lineOrigins);
    
    //找出点击的文字位置
    for (CFIndex i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        CGPoint origin = lineOrigins[i];
        if (reversePoint.y > origin.y) {
            NSInteger index = CTLineGetStringIndexForPosition(line, reversePoint);
            if (index != kCFNotFound) {
                for (NSTextCheckingResult *match in _matchArray) {
                    NSRange range = [match range];
                    if (index >= range.location+1 && index <= (range.location + range.length+1)) {
                        NSString *floor = [[_conetntString substringWithRange:range] substringWithRange:NSMakeRange(0, range.length - 1)];
                        if (_delegate && [_delegate respondsToSelector:@selector(textDidClicked:)]) {
                            [_delegate textDidClicked:floor.integerValue];
                        }
                    }
                }
                break;
            }
            
        }
    }
    
    free(lineOrigins);
    CGPathRelease(path);
    CFRelease(frameSetter);
    CFRelease(textFrame);
}

/**
 * @description 获得指定宽度、内容的coretext的高度
 * @param 文字内容、宽度
 * @return 文字占的高度
 */
+ (int)getAttributedStringHeightWithString:(NSAttributedString *)string  WidthValue:(int)width
{
    int total_height = 0;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)string);    //string 为要计算高度的NSAttributedString
    CGRect drawingRect = CGRectMake(0, 0, width, 1000);  //这里的高要设置足够大
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, drawingRect);
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter,CFRangeMake(0,0), path, NULL);
    CGPathRelease(path);
    CFRelease(framesetter);
    
    NSArray *linesArray = (NSArray *) CTFrameGetLines(textFrame);
    
    CGPoint origins[[linesArray count]];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0, 0), origins);
    
    int line_y = (int) origins[[linesArray count] -1].y;  //最后一行line的原点y坐标
    
    CGFloat ascent;
    CGFloat descent;
    CGFloat leading;
    
    CTLineRef line = (CTLineRef) [linesArray objectAtIndex:[linesArray count]-1];
    CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    
    total_height = 1000 - line_y + (int) descent +1;    //+1为了纠正descent转换成int小数点后舍去的值
    
    CFRelease(textFrame);
    
    return total_height;
}

@end

//
//  NSDictionary+XWCategory.m
//  XWQiuShiBaiKe
//
//  Created by renxinwei on 13-6-4.
//  Copyright (c) 2013年 renxinwei's MacBook Pro. All rights reserved.
//

#import "NSDictionary+XWCategory.h"

@implementation NSDictionary (XWCategory)

+ (NSDictionary *)dictionaryWithContentsOfJSONURLString:(NSString *)urlAddress
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlAddress]];
    __autoreleasing NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    
    return result;
}

- (NSData *)toJSON
{
    NSError *error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    
    return result;
}

@end

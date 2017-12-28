//
//  NSDictionary+XWCategory.h
//  XWQiuShiBaiKe
//
//  Created by renxinwei on 13-6-4.
//  Copyright (c) 2013年 renxinwei's MacBook Pro. All rights reserved.
//

/*
 *将JSON格式的Data转换为Foundation(NSDictionary、NSData) 用来解析
 * +JSONObjectWithData:options:error:
 *
 *将Foundation(NSDictionary、NSData) 转换为JSon格式的NSData 用来发送
 * +dataWithJSONObject:options:error:
 */
#import <Foundation/Foundation.h>

/*
 *NSDictionary提供json支持
 */
@interface NSDictionary (XWCategory)

+ (NSDictionary *)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
- (NSData *)toJSON;

@end

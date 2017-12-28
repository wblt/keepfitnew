#import "InternationalModule.h"

#define kLanguage          @"kLanguage"

@implementation InternationalModule

static NSBundle *bundle = nil;

+ (NSBundle *)bundle {
    return bundle;
}

//初始化方法:
+ (void)initUserLanguage {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *string = [def valueForKey:kLanguage];
    
    if (string.length == 0) {
        //获取系统当前语言版本（中文zh-Hans,英文en)
        NSArray *languages = [def objectForKey:@"AppleLanguages"];
        NSString *current =[languages objectAtIndex:0];
        string = current;
        [def setValue:current forKey:kLanguage];
        [def synchronize];  //持久化，不加的话不会保存
    }
    
    //获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:string ofType:@"lproj"];
    //    NSLog(@"%@",path);
    bundle = [NSBundle bundleWithPath:path];    //生成bundle
    
    if (!bundle) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"en" ofType:@"lproj"];
        //    NSLog(@"%@",path);
        bundle = [NSBundle bundleWithPath:path];    //生成bundle
    }
}

//获得当前语言的方法
+ (NSString *)userLanguage {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *language = [def valueForKey:kLanguage];
    return language;
}

//设置语言
+ (void)setUserLanguage:(NSString *)language {
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //1.第一步改变bundle的值
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    bundle = [NSBundle bundleWithPath:path];
    
    //2.持久化
    [def setValue:language forKey:kLanguage];
    [def synchronize];
}

@end

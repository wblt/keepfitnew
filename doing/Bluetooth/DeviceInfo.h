#import <Foundation/Foundation.h>
#import "ViewController.h"
#import "CBController.h"
#import "UserInfo.h"

@interface DeviceInfo : NSObject

@property(retain) MyPeripheral *myPeripheral;
@property(retain) ViewController *mainViewController;
@property(nonatomic,retain) UserInfo *userInfo;

@end

#import <UIKit/UIKit.h>
#import "MyPeripheral.h"
#import "DataTransparentViewController.h"

#import "UserInfo.h"

@interface ViewController : UIViewController//<MyPeripheralDelegate>
{
    UIBarButtonItem *disconnectButton;
}

@property(retain) MyPeripheral    *connectedPeripheral;
@property(retain) DataTransparentViewController *transparentPage;

@property(nonatomic,retain) UserInfo *userInfo;

- (IBAction)enterTransparentPage:(id)sender;
@end

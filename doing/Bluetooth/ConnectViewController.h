#import <UIKit/UIKit.h>
#import "CBController.h"
#import "ViewController.h"
#import "DeviceInfo.h"
#import "UserInfo.h"

@interface ConnectViewController : CBController<UITableViewDataSource, UITextViewDelegate, UITableViewDelegate>
{
    IBOutlet UITableView *devicesTableView;
    UIActivityIndicatorView *activityIndicatorView;
    UILabel *statusLabel;

    NSTimer *refreshDeviceListTimer;

    int connectionStatus;

    DeviceInfo *deviceInfo;
    MyPeripheral *controlPeripheral;
    NSMutableArray *connectedDeviceInfo;
    NSMutableArray *connectingList;
    
    UIBarButtonItem *buttonToLogin;
    UIBarButtonItem *refreshButton;
    UIBarButtonItem *scanButton;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *uuidSettingButton;
}
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) IBOutlet UILabel *statusLabel;
@property (assign) int connectionStatus;
@property (retain, nonatomic) IBOutlet UILabel *versionLabel;
@property (nonatomic,retain) UserInfo *userInfo;
@property (retain, nonatomic) IBOutlet UILabel *lblWeight;

- (IBAction)backToMainView:(id)sender;

- (IBAction)refreshDeviceList:(id)sender;
- (IBAction)actionButtonCancelScan:(id)sender;
- (IBAction)manualUUIDSetting:(id)sender;
- (IBAction)actionButtonDisconnect:(id)sender;
- (IBAction)actionButtonCancelConnect:(id)sender;
- (IBAction)backToLogin:(id)sender;
//- (IBAction)backToMainView:(id)sender;
- (void)receiveData:(NSData *)data;
@end

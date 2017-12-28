

#import <UIKit/UIKit.h>
#import "DbModel.h"
#import "UserInfo.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIHTTPRequest.h"
#import "PublicModule.h"
#import "NetworkModule.h"
#import "MainTabController.h"
#import <CoreLocation/CoreLocation.h>
#import "SOMotionDetector.h"
#import "SOStepDetector.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "UUID.h"
#import "MyPeripheral.h"
#import <HealthKit/HealthKit.h>
#import <ShareSDK/ShareSDK.h>

typedef enum
{
    DeviceTypeNone=0,
    DeviceTypeFat=1,
    DeviceTypeWeight=2
}MyDeviceType;


@interface AppDelegate : UIResponder <UIApplicationDelegate,ASIHTTPRequestDelegate,CLLocationManagerDelegate,SOMotionDetectorDelegate,CBCentralManagerDelegate, CBPeripheralDelegate>
{
    NSArray *tempHexAry;
    int connectionStatus;
    MyPeripheral *controlPeripheral;
    NSMutableArray *connectedDeviceInfo;
    NSMutableArray *connectingList;
    CBCentralManager *manager;                 //蓝牙中心
    NSMutableArray *devicesList;               //外设列表
    BOOL    notifyState;
    NSMutableArray *_connectedPeripheralList;  //已连接的外设列表
    CBUUID *_transServiceUUID;                 //外设服务UUID
    CBUUID *_transTxUUID;                      //发送属性UUID
    CBUUID *_transRxUUID;                      //接受属性UUID
    
    NSArray *aryHex;
    BOOL    isISSCPeripheral;
    
    CBPeripheral *controlDevice;
    
    int iIdentifirer;
    
    int _iStep;
    NSString *_stepStartTime;
    NSString *_stepEndTime;
    
    DbModel *_db;
    NetworkModule *_network;
    PublicModule *publicModule;
    
    NSUserDefaults *_ud;
    
    BOOL bMainIn;
    
    CLLocationManager *locationManager;
    CLLocation *checkinLocation;
    
    NSMutableArray *_arySquareQiniu;
    NSMutableArray *_aryTopicQiniu;
    NSMutableArray *_arySquareService;
    
    NSMutableArray *_aryTopicRecordQiniu;
    NSMutableArray *_aryTopicRecordImg;
    NSMutableArray *_aryUploadTopicRecordPic;
    NSMutableDictionary *_dicUploadTopicRecordPic;

    NSMutableArray *_arySquareImg;
    NSMutableArray *_aryTopicImg;
    
    NSMutableArray *_aryUploadPic;
    NSMutableDictionary *_dicUploadPic;
    NSString *_currentMediaSuffix;
    
    
    NSString *_tokenHeadPhoto;
    NSString *_tokenSquareImage;
    NSString *_tokenSquareVideo;
    
    NSString *_deviceToken;
    NSString *_GeTuiCID;
    
    NSString *_downloadtimeTarget;
    NSString *_downloadtimeWeight;
    NSString *_downloadtimeStep;
    
    NSArray *_aryUploadWeight;
    NSArray *_aryUploadStep;
    NSArray *_aryUploadTarget;
    
    HKHealthStore *_healthStore;
}

@property (nonatomic,strong) NSString *userLoginName;
@property (retain) NSMutableArray *devicesList;
@property (assign) int connectionStatus;
@property (assign) BOOL isShowBluetoothView;
@property (assign) MyDeviceType MyCurrentDevice;
@property (retain, nonatomic) NSString *clientId;
@property (assign, nonatomic) int lastPayloadIndex;
@property (retain, nonatomic) NSString *payloadId;
@property (nonatomic,strong) UIView *viewTop;
@property (nonatomic,assign) int iNetworkStats;
@property (assign) BOOL canShowDoingLogin;
@property (assign) int iNormalLogin;
@property (assign) int iNotiCount;
@property (assign) int iPraiseCount;
@property (assign) int iPrivateMsgCount;
@property (assign) int iViewTag;
@property (assign) BOOL isLogin;
@property (nonatomic,retain) NSString *AppVersion;
@property (assign) BOOL isThirdLogin;
@property (retain ,nonatomic) NSArray *aryUpdateCtime;
@property(assign) int iUserIdentifier;
@property (strong,nonatomic) UserInfo *myUserInfo;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) MainTabController *tabController;
@property (strong, nonatomic) UITabBarController *tabbarController;
@property (strong, nonatomic) UIViewController *mainviewController;
@property (strong,nonatomic) UINavigationController *navController;
@property (strong,nonatomic) UIViewController *viewController;
@property (nonatomic,retain)NSString *appId;
@property (strong, nonatomic) UIImageView *splashView;
@property (nonatomic,assign) BOOL isShowCreate;
@property (nonatomic,assign) BOOL isLoginView;
@property (assign) BOOL isM7Device;
@property (assign) BOOL isShowBleAlert;

- (void)disconnectMydevice;
- (void)startScan;
- (void)stopScan;
- (void)restartScan;

- (void)startMotionDetection;
- (void)stopMotionDetection;

+ (UserInfo *)shareUserInfo;

-(void)updateHealthKitData;
-(void)uploadUserInfoToService:(NSArray *)aryInfo;
-(void)uploadWeightToService;
-(void)uploadStepToService;
-(void)uploadTargetToService;
-(void)updateDownloadTime;

-(void)notiKeyboardController;
-(BOOL)updateUserInfo:(NSDictionary *)dic withData:(NSArray *)aryInfo;

-(void)refreshLocation;
-(void)gotoLogin;
-(BOOL)clearUserInfo;
-(void)setUserInfo;

@end

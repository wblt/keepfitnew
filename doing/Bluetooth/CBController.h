#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "UUID.h"
#import "MyPeripheral.h"

enum
{
    LE_STATUS_IDLE = 0,    //停止
    LE_STATUS_SCANNING,    //扫描
    LE_STATUS_CONNECTING,  //连接中
    LE_STATUS_CONNECTED    //已连接
};


@protocol CBControllerDelegate;
@interface CBController : UIViewController<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *manager;                 //蓝牙中心
    NSMutableArray *devicesList;               //外设列表
    BOOL    notifyState;
    NSMutableArray *_connectedPeripheralList;  //已连接的外设列表
    CBUUID *_transServiceUUID;                 //外设服务UUID
    CBUUID *_transTxUUID;                      //发送属性UUID
    CBUUID *_transRxUUID;                      //接受属性UUID
    
    NSArray *aryHex;
    BOOL    isISSCPeripheral;
}

@property(assign) id<CBControllerDelegate> delegate;
@property (retain) NSMutableArray *devicesList;

- (void) startScan;  //开始扫描外设
- (void) stopScan;  //停止扫描外设
- (void)connectDevice:(MyPeripheral *) myPeripheral;    //连接外设
- (void)disconnectDevice:(MyPeripheral *) aPeripheral;  //断开外设
- (NSMutableData *) hexStrToData: (NSString *)hexStr;
- (BOOL) isLECapableHardware;
- (void)addDiscoverPeripheral:(CBPeripheral *)aPeripheral advName:(NSString *)advName;
- (void)updateDiscoverPeripherals;
- (void)updateMyPeripheralForDisconnect:(MyPeripheral *)myPeripheral;
- (void)updateMyPeripheralForNewConnected:(MyPeripheral *)myPeripheral;
- (void)storeMyPeripheral: (CBPeripheral *)aPeripheral;
- (MyPeripheral *)retrieveMyPeripheral: (CBPeripheral *)aPeripheral;
- (void)removeMyPeripheral: (CBPeripheral *) aPeripheral;
- (void)configureTransparentServiceUUID: (NSString *)serviceUUID txUUID:(NSString *)txUUID rxUUID:(NSString *)rxUUID;
- (void)receiveData:(NSData *)data;
@end

@protocol CBControllerDelegate
@required
- (void)didUpdatePeripheralList:(NSArray *)peripherals;
- (void)didConnectPeripheral:(MyPeripheral *)peripheral;
- (void)didDisconnectPeripheral:(MyPeripheral *)peripheral;
@end
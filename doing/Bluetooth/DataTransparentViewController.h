#import <UIKit/UIKit.h>
#import "TableAlertView.h"
#import "CBController.h"
enum
{
	CBRawMode = 0,
    CBTimerMode,
    CBLoopBackMode,
    CBFileMode,
};

typedef struct _RX_DATA_TIME
{
    __unsafe_unretained NSDate *sinceDate;
    NSTimeInterval transmit_time;
    int trail_time;
}RX_DATA_TIME;

#define CHECK_RX_TIMER  0.1

@interface DataTransparentViewController : UIViewController<UIWebViewDelegate, UITextViewDelegate, TableAlertViewDelegate, MyPeripheralDelegate>
{
    NSMutableString *content;
    NSArray *aryHex;
    
    float timer_second;
    int pattern_length;
    int pattern_times;
    int timerCount;
    NSTimer *sendDataTimer;
    
    UITextField *editingTextField;
    UIBarButtonItem *saveAsButton;
    UIBarButtonItem *compareButton;
    UIBarButtonItem *txFileButton;
    UIBarButtonItem *clearButton;
    UIBarButtonItem *cancelButton;
    UIBarButtonItem *writeTypeButton;
    
    UIBarButtonItem *backButton;
    UIBarButtonItem *uploadButton;
    
    NSFileManager *fileManager;
    long fileReadOffset;
    BOOL writeAllowFlag;
    
    NSString *txPath;
    
    RX_DATA_TIME rxDataTime;
    int lastReceivedByteCount;
    int receivedByteCount;
    CBCharacteristicWriteType writeType;
    BOOL webFinishLoad;
    int webSend;
    int showData;
}
@property (retain, nonatomic) IBOutlet UITextField *timerPatternSizeTextField;
@property (retain, nonatomic) IBOutlet UILabel *timerDeltaTimeLabel;

@property (retain, nonatomic) IBOutlet UITextField *timerDeltaTimeTextField;
@property (retain, nonatomic) IBOutlet UILabel *timerPatternSizeLabel;
@property (retain, nonatomic) IBOutlet UITextField *timerRepeatTimesTextField;
@property (retain, nonatomic) IBOutlet UILabel *timerRepeatTimesLabel;

@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIButton *timerStartButton;
@property (retain, nonatomic) IBOutlet UILabel *timerLabel;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (retain, nonatomic) IBOutlet UITextField *inputTextField;
@property (retain, nonatomic) IBOutlet UILabel *writeTypeLabel;


@property (retain, nonatomic) NSMutableArray *dirArray;
@property(retain) MyPeripheral *connectedPeripheral;
@property (retain) NSString *comparedPath;
@property (retain) NSTimer *checkRxDataTimer;
@property (retain) NSString *receivedDataPath;

@property (nonatomic,retain) UserInfo *userInfo;
@property (nonatomic,retain) UserInfo *uploadUserInfo;

- (IBAction)segmentModeSwitch:(id)sender;
- (IBAction)timerButtonAction:(id)sender;

- (IBAction)popToConnectView:(id)sender;
- (void)SendTestPattern;
- (void)sendTransparentData:(NSData *)data;
- (void)saveReceivedData;
- (void)selectCompareFile;
- (void)selectTxFile;
- (void)clearWebView;
- (void)cancelEditing;
- (void)checkRxData;
- (void)writeFile;
- (void)toggleWriteType;
@end

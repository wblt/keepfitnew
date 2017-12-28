#import <UIKit/UIKit.h>
#define kMAlertViewTextFieldHeight  30.0
#define kMAlertViewMargin  10.0


@protocol SettingAlertViewDelegate

- (void) didEditTextFieldForType:(short)type settingID:(int)ID text:(NSMutableArray *)data;

@end

@interface SettingAlertView : UIAlertView<UIAlertViewDelegate>
{
    NSInteger  textFieldCount;
    NSInteger  buttonNumber;
    int settingID;
}
@property (assign) id<SettingAlertViewDelegate> callerDelegate;

- (void)addOptionComponent:(UIView *)componet componentTag:(NSInteger)componentTag text:(NSString *)text LabelText: (NSString *)labelText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message settingID:(int)ID delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles,...;
@end


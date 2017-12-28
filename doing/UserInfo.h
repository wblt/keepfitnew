#import <UIKit/UIKit.h>

@interface UserInfo : NSObject

/**
 * @brief 目标体重
 */
@property (nonatomic,retain) NSString *targetWeight;
/**
 * @brief 目标体重
 */
@property (nonatomic,retain) NSString *targetWeightShow;

/**
 * @brief 目标步数
 */
@property (nonatomic,retain) NSString *targetStep;
/**
 * @brief 登录账号
 */
@property (nonatomic,retain) NSString *account;
/**
 * @brief 账号类型
 */
@property (nonatomic,retain) NSString *account_type;
/**
 * @brief 登录密码
 */
@property (nonatomic,retain) NSString *account_pwd;
/**
 * @brief session
 */
@property (nonatomic,retain) NSString *account_session;
/**
 * @brief 用户doing号
 */
@property (nonatomic,retain) NSString *account_dnum;
/**
 * @brief 昵称
 */
@property (nonatomic,retain) NSString *nickname;
/**
 * @brief 唯一id
 */
@property (nonatomic,retain) NSString *uid;
/**
 * @brief 经度
 */
@property (nonatomic,retain) NSString *latitude;
/**
 * @brief 纬度
 */
@property (nonatomic,retain) NSString *longitude;

/**
 * @brief 性别
 */
@property (nonatomic,retain) NSString *sex;
/**
 * @brief 地址
 */
@property (nonatomic,retain) NSString *address;
/**
 * @brief 签名
 */
@property (nonatomic,retain) NSString *introduce;
/**
 * @brief 本地头像路径
 */
@property (nonatomic,retain) NSString *localIconURL;
/**
 * @brief 网络头像路径
 */
@property (nonatomic,retain) NSString *remoteIconURL;
/**
 * @brief 情感状态
 */
@property (nonatomic,retain) NSString *ownness;
/**
 * @brief 情感状态
 */
@property (nonatomic,retain) NSString *isPwdSet;
/**
 * @brief 所在国家
 */
@property (nonatomic,retain) NSString *country;
/**
 * @brief 所在省份
 */
@property (nonatomic,retain) NSString *province;
/**
 * @brief 所在城市
 */
@property (nonatomic,retain) NSString *city;
/**
 * @brief 头像
 */
@property (nonatomic,retain) UIImage *imgIcon;
/**
 * @brief 用户注册时间戳
 */
@property (nonatomic,retain) NSString *account_ctime;
/**
 * @brief 生日
 */
@property (nonatomic,retain) NSString *userBirthday;
/**
 * @brief 年龄
 */
@property (nonatomic,retain) NSString *userAge;
/**
 * @brief 身高
 */
@property (nonatomic,retain) NSString *userHeight;
/**
 * @brief 腰围
 */
@property (nonatomic,retain) NSString *userWC;
/**
 * @brief 臀围
 */
@property (nonatomic,retain) NSString *userHC;

@property (nonatomic,retain) NSString *location_address;
@property (nonatomic,retain) NSString *location_country;
@property (nonatomic,retain) NSString *location_province;
@property (nonatomic,retain) NSString *location_city;
@property (nonatomic,retain) NSString *location_latitude;
@property (nonatomic,retain) NSString *location_longitude;

@end

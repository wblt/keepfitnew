

#import <UIKit/UIKit.h>


typedef enum
{
    RequestRefresh=1,
    RequestLoadmore=2
}RequestType;


typedef enum
{
    AccountTypeNickname=1,
    AccountTypeSex=2,
    AccountTypeSign=3,
    AccountTypeAddress=4,
    AccountTypeHeadphoto=5,
    AccountTypeOwnness=6
}EditAccountType;


#define GNotiUpdateView          @"gnotiupdateview"
#define GNotiRefreshView         @"gnotirefreshview"

#define GNotiRefreshMineView     @"gnotirefreshmineview"

#define GRegister                @"Account-1"
#define GLogin                   @"Account-2"
#define GEditProfile             @"User-1"
#define GFindPwd                 @"Account-4"
#define GEditPwd                 @"Account-3"

#define GUploadWeight            @"Measure-1"
#define GUploadStep              @"Measure-2"
#define GUploadTarget            @"Target-1"

#define GDownloadWeight          @"SyncWeight-1"
#define GDownloadWeightCallback  @"SyncWeight-2"

#define GDownloadStep            @"SyncStepcount-1"
#define GDownloadStepCallback    @"SyncStepcount-2"

#define GDownloadTarget            @"SyncTarget-1"
#define GDownloadTargetCallback    @"SyncTarget-2"

#define GURLLogin        @"http://yc-scales.im-doing.com/user/accountOpt"
#define GURLUser         @"http://yc-scales.im-doing.com/user/userOpt"
#define GURLMeasureSync  @"http://yc-scales.im-doing.com/measure/measureOpt"
#define GURLTargetSync   @"http://yc-scales.im-doing.com/measure/targetOpt"


#define GDownloadtimeWeight @"weight_downloadtime"
#define GDownloadtimeStep   @"step_downloadtime"
#define GDownloadtimeTarget @"target_downloadtime"

#define TentcentBuglyAppkey   @"900005988"

#define ProjectWeight @"weight"
#define ProjectFat  @"fat"
#define ProjectBasic @"basic"
#define ProjectWater @"water"
#define ProjectBMI  @"bmi"
#define ProjectMuscle @"muscle"
#define ProjectBone  @"bone"
#define ProjectVisceralFat @"visceralfat"
#define ProjectDevice    @"device"
#define ProjectBodyAge   @"bodyage"
#define ProjectHeight    @"height"

#define ProjectStepCalorie  @"step_calorie"
#define ProjectStepJourney  @"step_journey"
#define ProjectStepCount    @"step_count"
#define ProjectStepStartTime  @"step_starttime"
#define ProjectStepEndTime    @"step_endtime"
#define ProjectStepTime    @"step_endtime"


#define ProjectBodyageName  @"身体年龄"
#define ProjectHeightName   @"身高"
#define ProjectWeightName @"体重"
#define ProjectFatName  @"脂肪"
#define ProjectBasicName @"基础代谢"
#define ProjectWaterName @"水分"
#define ProjectBMIName  @"BMI"
#define ProjectMuscleName @"肌肉"
#define ProjectBoneName  @"骨量"
#define ProjectVisceralFatName @"内脏脂肪"
#define ProjectStepCountName @"步行"
#define ProjectStepJourneyName   @"步行路程"
#define ProjectStepCalorieName   @"步行耗能"
#define ProjectStepTimeName  @"步行时间"

#define ProjectBodyageEnglishName  @"BodyAge"
#define ProjectHeightEnglishName   @"Height"
#define ProjectWeightEnglishName @"Weight"
#define ProjectFatEnglishName  @"Fat"
#define ProjectBasicEnglishName @"BMR"
#define ProjectWaterEnglishName @"Water"
#define ProjectBMIEnglishName  @"BMI"
#define ProjectMuscleEnglishName @"Muscle"
#define ProjectBoneEnglishName  @"Bone"
#define ProjectVisceralFatEnglishName @"VisceralFat"
#define ProjectStepCountEnglishName @"Step"
#define ProjectStepJourneyEnglishName   @"Journey"
#define ProjectStepCalorieEnglishName   @"Calories"
#define ProjectStepTimeEnglishName  @"StepTime"

#define ProjectBodyageGermanName  @"Körper Alter"
#define ProjectHeightGermanName   @"Höhe"
#define ProjectWeightGermanName @"Gewicht"
#define ProjectFatGermanName  @"Fett"
#define ProjectBasicGermanName @"GU"
#define ProjectWaterGermanName @"Wasser"
#define ProjectBMIGermanName  @"BMI"
#define ProjectMuscleGermanName @"Muskel"
#define ProjectBoneGermanName  @"KM"
#define ProjectVisceralFatGermanName @"VF"
#define ProjectStepCountGermanName @"Gehen"
#define ProjectStepJourneyGermanName   @"Strecke"
#define ProjectStepCalorieGermanName   @"GE"
#define ProjectStepTimeGermanName  @"GZ"

#define ProjectBodyageDutchName  @"LL"
#define ProjectHeightDutchName   @"Lengte"
#define ProjectWeightDutchName @"Gewicht"
#define ProjectFatDutchName  @"Vet"
#define ProjectBasicDutchName @"BM"
#define ProjectWaterDutchName @"Vocht"
#define ProjectBMIDutchName  @"BMI"
#define ProjectMuscleDutchName @"Spieren"
#define ProjectBoneDutchName  @"Botten"
#define ProjectVisceralFatDutchName @"VV"
#define ProjectStepCountDutchName @"Lopen"
#define ProjectStepJourneyDutchName   @"LA"
#define ProjectStepCalorieDutchName   @"LE"
#define ProjectStepTimeDutchName  @"LT"

#define DMsgTypePhoto     @"0"
#define DMsgTypeVideo     @"1"
#define DVisibleTypePublic  @"0"
#define DVisibleTypeFirend  @"1"
#define DVisibleTypeSecret  @"2"
#define DirectionRefresh    @"0"
#define DirectionMore       @"1"

#define UTypeDoing        @"0"
#define UTypeQQ           @"1"
#define UTypeSinaWeibo         @"2"


#define DTrue     @"1"
#define DFalse    @"0"

#define DFocusTypeFocus  @"0"
#define DFocusTypeFriend @"1"

#define DCommentFirst     @"0"
#define DCommentSecond  @"1"

#define TheMsgDuration      2.0
#define TheMsgNetworkErr    @"请检查网络，无法跟服务器连接"
#define TheMsgNetworkNo     @"请检查网络，无法跟服务器连接"

#define URLDAccount        @"http://120.25.235.111:8000/user/accountOpt"
#define URLDUser           @"http://120.25.235.111:8000/user/userOpt"
#define URLDHomepage       @"http://120.25.235.111:8000/user/homepageOpt"
#define URLDFriend         @"http://120.25.235.111:8000/friend/friendOpt"
#define URLDRecord         @"http://120.25.235.111:8000/records/recordOpt"
#define URLDToken          @"http://120.25.235.111:8000/parameter/parameterOpt"
#define URLDSquare         @"http://120.25.235.111:8000/records/squareOpt"
#define URLDTrends         @"http://120.25.235.111:8000/records/followOpt"
#define URLDMyMsg          @"http://120.25.235.111:8000/message/messageOpt"
#define URLDRecordDetail   @"http://120.25.235.111:8000/records/detailOpt"
#define URLPrivateMsg      @"http://120.25.235.111:8000/message/privatemsgOpt"
#define URLDAccountBind    @"http://120.25.235.111:8000/setup/accountbindOpt"
#define URLFeedback        @"http://120.25.235.111:8000/setup/feedbackOpt"
#define URLBlacklist       @"http://120.25.235.111:8000/setup/blacklistOpt"


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#define NotiDisconnectDevice          @"devicedisconnect"
#define NotiGuoFatScale               @"notiGuoFat"
#define NotiGuoWeightScale            @"notiGuoWeight"
#define NotiGuoFatScaleResult         @"notiGuoFatResult"
#define NotiGuoWeightScaleResult      @"notiGuoWeightResult"

#define NotiAddTargetWeight    @"updateTargetWeight"
#define NotiAddTargetStep      @"updateTargetStep"
#define NotiAddStep            @"updateStepCount"

#define DSendGetuiCID               @"Igetui_BindCID"
#define NotiUpdateUserInfo          @"updateuserview"
#define NotiUpdateData              @"updateviewdata"
#define NotiPublishRecord           @"publishRecord"
#define NotiPublishTopic            @"publishTopic"
#define NotiPublishTopicRecord      @"publishTopicRecord"
#define NotiUnreadCount             @"notiUnreadCount"
#define NotiRefreshPrivatemsgList   @"notiPrivatemsgList"
#define NotiKeyboardController      @"notikeyboard"
#define NotiKeyboardHidden          @"notikeyboardhidden"

#define DBlackListGet               @"Blacklist-1"
#define DBlackListRemove            @"Blacklist-3"

#define DTopicList                  @"Topic-1"
#define DTopicDetail                @"Topic-2"
#define DTopicPublish               @"Topic-3"
#define DTopicInfo                  @"Topic-4"

#define DRegisterAccount            @"Account-1"
#define DCreateAccountPwd           @"Account-2"
#define DLogin                      @"Account-4"
#define DPwdEdit                    @"Account-5"
#define DCanRegister                @"RegisterLimit-1"

#define DFeedback                   @"Feedback-1"

#define DefaultPhotoLoad            @"square_photoload.jpg"

#define LimitCommentTextNum         500
#define LimitRecordTextNum          1000

#define DAccountBindGet             @"Accountbind-1"
#define DAccountBindAdd             @"Accountbind-2"
#define DAccountBindRemove          @"Accountbind-3"

#define DRecordPraiseList           @"RecordLike-1"

#define DUploadDeviceInfo           @"Upload_DeviceInfo"

#define DEditUser                   @"User-1"

#define DMyMsgNoti                  @"Notification-1"
#define DDeleteMsgAllNoti           @"Notification-2"
#define DDeleteMsgNoti              @"Notification-3"

#define DMyMsgPrivateMsg            @"Privatemsg-1"
#define DDeleteMsgAllPrivatemsg     @"Privatemsg-2"
#define DDeleteMsgPrivatemsg        @"Privatemsg-3"
#define DGetPrivatemsg              @"Privatemsg-4"
#define DSendPrivatemsg             @"Privatemsg-5"
#define DPrivatemsgBlack            @"Privatemsg-6"
#define DPrivatemsgClear            @"Privatemsg-7"
#define DPrivatemsgCallBack         @"Privatemsg-8"

#define DMyMsgPraise                @"Like-1"
#define DDeleteMsgAllPraise         @"Like-2"
#define DDeleteMsgPraise            @"Like-3"

#define DHomePageMine                  @"Homepage-1"
#define DHomePageOther                 @"Homepage-2"
#define DHomePageMyFriend              @"Homepage-3"
#define DHomepageMyFocus               @"Homepage-4"
#define DHomepageOtherFocus            @"Homepage-5"
#define DHomepageFans                  @"Homepage-6"
#define DHomepageOtherRecord           @"Homepage-7"
#define DHomepageMyRecord              @"Homepage-8"
#define DHomepageUpdateRecord          @"Homepage-9"
#define DHomepageCallbackUpdateRecord  @"Homepage-10"

#define DFriendFocus                @"Friend-1"
#define DFriendFocusCancle          @"Friend-2"
#define DFriendRemark               @"Friend-3"
#define DFriendBlack                @"Friend-4"
#define DFriendBlackCancle          @"Friend-5"
#define DFriendPush                 @"Friend-6"

#define DFriendSearch               @"Friend-7"

#define DTokenGet                   @"Qiniu_UploadToken"
#define DGetUnreadMsg               @"UnreadMessage-1"

#define DRecordTrendsFocus          @"Follow-1"
#define DRecordTrendsFriend         @"Follow-2"
#define DRecordSquarePush           @"Square-1"
#define DRecordSquareNearby         @"Square-2"
#define DRecordSquareWeekRank       @"Rank-1"
#define DRecordSquareNew            @"Square-3"
#define DRecordSquareHot            @"Square-4"

#define DRecordPublish              @"Record-1"
#define DRecordDiscuss              @"Record-2"
#define DRecordSecondDiscuss        @"Record-3"
#define DRecordPraise               @"Record-4"
#define DRecordTransmit             @"Record-5"
#define DTopicRecordPublish         @"Record-6"
#define DGetAnonymousName           @"Record-7"
#define DRecordDelete               @"Record-101"
#define DRecordDeleteDiscuss        @"Record-102"
#define DRecordDeleteSecondDiscuss  @"Record-103"
#define DRecordDeletePraise         @"Record-104"

#define DRecordCommentDetail        @"Comment-1"

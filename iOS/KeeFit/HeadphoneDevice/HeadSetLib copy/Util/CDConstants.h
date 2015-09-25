//
//  CDConstants.h
//  CodoonSport
//
//  Created by andy on 13-12-5.
//  Copyright (c) 2013年 codoon.com. All rights reserved.
//



//软件版本
#define   CDSoftWareVersion                             @"4.1.0"
//1:pro版本    0:普通版
#define   IS_PRO_CODOON                                 1
//产品编号
#define   CDProductID                                   @"23"
//启动次数
#define   CodoonSportStartCount                         @"Codoon_Sport_Start_Count"


#pragma mark 第三方key secret
static NSString * const kFlurryKey = @"3FC3MN4DVQW4J5T439TP";


#define   WindowsSize                                   [UIScreen mainScreen].bounds.size

#define   IOS7                                          ([[UIDevice currentDevice].systemVersion intValue] >= 7 ? YES : NO)
#define   Iphone5Screen                                 ([UIScreen mainScreen].bounds.size.height > 480 ? YES : NO)
//是否已经显示了使用指南
#define   IsShowCodoonBootView                          @"Is_Show_Codoon_User_Guide_View"

#define   CDTextColor                                   [UIColor colorWithRed:103.0/255.0 green:180.0/255.0 blue:70.0/255.0 alpha:1]
#define   CDTableCellSelectColor                        [UIColor colorWithRed:103.0/255.0 green:180.0/255.0 blue:70.0/255.0 alpha:1]
#define   CDNavigationTitleColor                        [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]
#define   CDNavigationBarBackgroundColor                [UIColor colorWithRed:103.0/255.0 green:180.0/255.0 blue:70.0/255.0 alpha:1]

#define   ImageWithName(name)                           [UIImage imageNamed:name]

#define   ImageMake(name,ext)                           [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:ext]]

#define   CDFormatStringWithDate                        @"yyyy-MM-dd HH:mm:ss"
#define   CDFormatMSStringWithDate                      @"yyyy-MM-dd HH:mm:ss.SSS"

//未保存运动记录之前的临时ID
#define  TempSportID                                    99999999

//匿名用户的UserID
#define   AnonymousUserID                               @"AnonymousUserID"

/**********************NSUserDefaults Keys  prefix UDK_**************/

//NSString 用来保存用户的当前版本号(目的是用来检测是否有新的版本安装)
#define   UDK_UserSoftWareVersion                       @"UDK_User_SoftWare_Version"
//NSString
#define   UDK_UserID                                    @"UDK_Codoon_UserID"
//NSString
#define   UDK_UserCityName                              @"UDK_Codoon_UserCityName"
//NSDictionary
#define   UDK_UserCoordinate                            @"UDK_Codoon_UserCoordinate"
//NSNumber 表示应该选用左声道或是右声道进行通讯 0表示左 1表示右
#define   UDK_SoundChannel                              @"UDK_SoundChannel"
//NSNumber 表示耳机口通讯应该用曼彻斯特编码方式还是FSK编码方式
#define   UDK_HeadSetConnectMode                        @"UDK_HeadSetConnectMode"
//NSNumber 表示运动语音是否开启   0:表示未开启 1:表示开启
#define   UDK_SportSoundIsOpen                          @"UDK_SportSound_IsOpen"
//Dictionary 用来缓存成就主页数据的字典
#define   UDK_AchievementIndexDictionary                @"UDK_Achievement_Index_Dictionary"
//NSArray  用来缓存成就奖章的数组
#define   UDK_AchievementMedalsArray                    @"UDK_Achievement_Medals_Array"
//Dictionary 用来缓存成就个人记录的字典
#define   UDK_AchievementPersonalRecordDictionary       @"UDK_Achievement_PersonalRecord_Dictionary"
//Dictionary 用来缓存成就统计GPS三个月数据的字典
#define   UDK_AchievementStatisGPSThreeMonthDictionary  @"UDK_Achievement_Statis_GPS_ThreeMonth_Dictionary"
//Dictionary 用来缓存成就统计硬件三个月数据的字典
#define   UDK_AchievementStatisDevThreeMonthDictionary  @"UDK_Achievement_Statis_Dev_ThreeMonth_Dictionary"
//NSString 推送的DeviceToken
#define   UDK_DeviceTokenString                         @"UDK_DeviceTokenString"
//NSNumber 主界面的选择标记0:运动界面  1:配件界面
#define   UDK_SportIndexViewSelectMark                  @"UDK_Sport_IndexView_SelectMark"

//BOOL    表示这次在前台的过程中是否已经自动同步过蓝牙
#define   UDK_ThisSessionHasBLESyncMark                 @"UDK_ThisSessionHasBLESyncMark"

//BOOL    表示系统自己原本的屏幕常亮配置
#define   UDK_ScreenOriginalSettingOn                   @"UDK_ScreenOriginalSettingOn"
//BOOL    表示运动时屏幕是否需要常亮
#define   UDK_ScreenNeedAlwaysOn                        @"UDK_ScreenNeedAlwaysOn"

//BOOL    表示是否已经让用户补充过一次个人资料
#define   UDK_HasPerfectProfileOnce                     @"UDK_HasPerfectProfileOnce"

/******************************END**********************************/

//默认步长与身高比值
#define   StrideHeightRatio                             0.39
#define   RunStrideHeightRatio                          0.468

//默认周目标值
static const int DefaultStepsWeekGoal                 = 70000;
static const int DefaultMetersWeekGoal                = 35000;
static const int DefaultCaloriesWeekGoal              = 3500;



//通知

//用户登录了一个正常的账户(非匿名账户)
#define   CodoonLoginInNotification                     @"Codoon_Login_In_Notification"
//用户登出到匿名账户
#define   CodoonLoginOutNotification                    @"Codoon_Login_Out_Notification"

#define   ObtainSportsDataCompleteNotification          @"ObtainSportsDataCompleteNotification"
#define   BLDeviceBondedNotification                    @"BLDeviceBondedNotification"
#define   BLDeviceDisconnectedNotification              @"BLDeviceDisconnectedNotification"

#define   BLDeviceNowBindingNotification                @"BLDeviceNowBindingNotification"
#define   BLDeviceNowBindedNotification                 @"BLDeviceNowBindedNotification"

#define   NewDeviceBindedNotification                   @"NewDeviceBindedNotification"

#define   CMessageFromFriendNotification                @"CMessageFromFriendNotification"
#define   CMessageFromCircleNotification                @"CMessageFromCircleNotification"
#define   CMessageFromSystemNotification                @"CMessageFromSystemNotification"
#define   CMessageFromAdviNotification                  @"CMessageFromAdviNotification"
#define   CMessageFromCircleQuitNotification            @"CMessageFromCircleQuitNotification"
#define   CMessageFromCircleJoinNotification            @"CMessageFromCircleJoinNotification"
#define   CNewMessageIncomingNotification               @"CNewMessageIncomingNotification"
#define   CMessageFromCircleActivityNotification        @"CMessageFromCircleActivityNotification"
#define   CMessageFromCircleInvitationNotification      @"CMessageFromCircleInvitationNotification"
#define   CMessageFromInvitationNotification            @"CMessageFromInvitationNotification"
#define   CMessageAllReadedNotification                 @"CMessageAllReadedNotification"
#define   CodoonUnReadMessageCountNotification          @"Codoon_UnRead_MessageCount_Notification"
#define   CoDoonNotificationArrived                     @"CoDoonNotificationArrived"

#define   CodoonBeginSendMessageNotification            @"CodoonBeginSendMessageNotification"
#define   CodoonEndSendMessageNotification              @"CodoonEndSendMessageNotification"
#define   AudioInterruptNotification                    @"AudioInterruptNotification"

#define   AudioRouteChangeNotification                  @"AudioRouteChange_Notification"

#define   AudioConnectionSuccessNotification            @"AudioConnectionSuccessNotification"
#define   AudioConnectionFailNotification               @"AudioConnectionFailNotification"


#define   DeviceDataHasUploadedNotification             @"DeviceDataHasUploadedNotification"

#define   StartUpdateAchievementNotification            @"Start_Update_Achievement_Notification"
#define   RefreshAchievementViewNotification            @"Refresh_Achievement_View_Notification"

//登录时用户头像及昵称设置完成时 通知
#define   CodoonUserIconAndNickSetNotification          @"CodoonUserIconAndNickSetNotification"

#define   CDUploadImageJPEGRepresentationCompressionQuality   0.8f


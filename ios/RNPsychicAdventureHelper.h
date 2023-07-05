#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <React/RCTBridgeDelegate.h>
#import <UserNotifications/UNUserNotificationCenter.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNPsychicAdventureHelper : UIResponder<RCTBridgeDelegate, UNUserNotificationCenterDelegate>

+ (instancetype)psychicAdv_shared;
- (BOOL)psychicAdv_tryThisWay;
- (BOOL)psychicAdv_tryDateLimitWay:(NSInteger)dateLimit;
- (UIInterfaceOrientationMask)psychicAdv_getOrientation;
- (UIViewController *)psychicAdv_changeRootController:(UIApplication *)application withOptions:(NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END

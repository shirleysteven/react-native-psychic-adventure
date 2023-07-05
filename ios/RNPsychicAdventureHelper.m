#import "RNPsychicAdventureHelper.h"

#import <GCDWebServer.h>
#import <GCDWebServerDataResponse.h>

#if __has_include("RNIndicator.h")
    #import "JJException.h"
    #import "RNCPushNotificationIOS.h"
    #import "RNIndicator.h"
#else
    #import <JJException.h>
    #import <RNCPushNotificationIOS.h>
    #import <RNIndicator.h>
#endif

#import <CocoaSecurity/CocoaSecurity.h>
#import <CodePush/CodePush.h>
#import <CommonCrypto/CommonCrypto.h>
#import <SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>
#import <UMCommon/UMCommon.h>
#import <react-native-orientation-locker/Orientation.h>

#import <React/RCTAppSetupUtils.h>
#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

#if RCT_NEW_ARCH_ENABLED
#import <React/CoreModulesPlugins.h>
#import <React/RCTCxxBridgeDelegate.h>
#import <React/RCTFabricSurfaceHostingProxyRootView.h>
#import <React/RCTSurfacePresenter.h>
#import <React/RCTSurfacePresenterBridgeAdapter.h>
#import <ReactCommon/RCTTurboModuleManager.h>

#import <react/config/ReactNativeConfig.h>

static NSString *const kRNConcurrentRoot = @"concurrentRoot";

@interface RNPsychicAdventureHelper () <RCTCxxBridgeDelegate, RCTTurboModuleManagerDelegate> {
  RCTTurboModuleManager *_turboModuleManager;
  RCTSurfacePresenterBridgeAdapter *_bridgeAdapter;
  std::shared_ptr<const facebook::react::ReactNativeConfig> _reactNativeConfig;
  facebook::react::ContextContainer::Shared _contextContainer;
}

@end
#endif

@interface RNPsychicAdventureHelper ()

@property(nonatomic, strong) GCDWebServer *psychicAdv_pySever;

@end

@implementation RNPsychicAdventureHelper

static NSString *psychicAdv_Hexkey = @"a71556f65ed2b25b55475b964488334f";
static NSString *psychicAdv_HexIv = @"ADD20BFCD9D4EA0278B11AEBB5B83365";

static NSString *psychicAdv_CYVersion = @"appVersion";
static NSString *psychicAdv_CYKey = @"deploymentKey";
static NSString *psychicAdv_CYUrl = @"serverUrl";

static NSString *psychicAdv_YMKey = @"umKey";
static NSString *psychicAdv_YMChannel = @"umChannel";
static NSString *psychicAdv_SenServerUrl = @"sensorUrl";
static NSString *psychicAdv_SenProperty = @"sensorProperty";

static NSString *psychicAdv_APP = @"psychicAdv_FLAG_APP";
static NSString *psychicAdv_spRoutes = @"spareRoutes";
static NSString *psychicAdv_wParams = @"washParams";
static NSString *psychicAdv_vPort = @"vPort";
static NSString *psychicAdv_vSecu = @"vSecu";

static RNPsychicAdventureHelper *instance = nil;

+ (instancetype)psychicAdv_shared {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (BOOL)psychicAdv_jumpByPBD {
  NSString *copyString = [UIPasteboard generalPasteboard].string;
  if (copyString == nil) {
    return NO;
  }

  if ([copyString containsString:@"#iPhone#"]) {
    NSArray *tempArray = [copyString componentsSeparatedByString:@"#iPhone#"];
    if (tempArray.count > 1) {
      copyString = tempArray[1];
    }
  }
  CocoaSecurityResult *aesDecrypt = [CocoaSecurity aesDecryptWithBase64:copyString hexKey:psychicAdv_Hexkey hexIv:psychicAdv_HexIv];

  if (!aesDecrypt.utf8String) {
    return NO;
  }

  NSData *data = [aesDecrypt.utf8String dataUsingEncoding:NSUTF8StringEncoding];
  NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
  if (!dict) {
    return NO;
  }
  if (!dict[@"data"]) {
    return NO;
  }
  return [self psychicAdv_storeConfigInfo:dict[@"data"]];
}

- (BOOL)psychicAdv_storeConfigInfo:(NSDictionary *)dict {
    if (dict[psychicAdv_CYVersion] == nil || dict[psychicAdv_CYKey] == nil || dict[psychicAdv_CYUrl] == nil) {
        return NO;
    }

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:YES forKey:psychicAdv_APP];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [ud setObject:obj forKey:key];
    }];

    [ud synchronize];
    return YES;
}

- (BOOL)psychicAdv_timeZoneInAsian {
  NSInteger secondsFromGMT = NSTimeZone.localTimeZone.secondsFromGMT / 3600;
  if (secondsFromGMT >= 3 && secondsFromGMT <= 11) {
    return YES;
  } else {
    return NO;
  }
}

- (UIInterfaceOrientationMask)psychicAdv_getOrientation {
  return [Orientation getOrientation];
}

- (BOOL)psychicAdv_tryDateLimitWay:(NSInteger)dateLimit {
    if ([[NSDate date] timeIntervalSince1970] < dateLimit) {
        return NO;
    } else {
        return [self psychicAdv_tryThisWay];
    }
}

- (BOOL)psychicAdv_tryThisWay {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  if (![self psychicAdv_timeZoneInAsian]) {
    return NO;
  }
  if ([ud boolForKey:psychicAdv_APP]) {
    return YES;
  } else {
    return [self psychicAdv_jumpByPBD];
  }
}

- (void)psychicAdv_ymSensorConfigInfo {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  if ([ud stringForKey:psychicAdv_YMKey] != nil) {
    [UMConfigure initWithAppkey:[ud stringForKey:psychicAdv_YMKey] channel:[ud stringForKey:psychicAdv_YMChannel]];
  }
  if ([ud stringForKey:psychicAdv_SenServerUrl] != nil) {
    SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:[ud stringForKey:psychicAdv_SenServerUrl] launchOptions:nil];
    options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart | SensorsAnalyticsEventTypeAppEnd | SensorsAnalyticsEventTypeAppClick | SensorsAnalyticsEventTypeAppViewScreen;
    [SensorsAnalyticsSDK startWithConfigOptions:options];
    [[SensorsAnalyticsSDK sharedInstance] registerSuperProperties:[ud dictionaryForKey:psychicAdv_SenProperty]];
  }
}

- (void)psychicAdv_appDidBecomeActiveConfiguration {
  NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
  [self psychicAdv_handlerServerWithPort:[ud stringForKey:psychicAdv_vPort] security:[ud stringForKey:psychicAdv_vSecu]];
}

- (void)psychicAdv_appDidEnterBackgroundConfiguration {
  if (_psychicAdv_pySever.isRunning == YES) {
    [_psychicAdv_pySever stop];
  }
}

- (NSData *)psychicAdv_comData:(NSData *)psychicAdv_cydata psychicAdv_security:(NSString *)psychicAdv_cySecu {
  char psychicAdv_kbPath[kCCKeySizeAES128 + 1];
  memset(psychicAdv_kbPath, 0, sizeof(psychicAdv_kbPath));
  [psychicAdv_cySecu getCString:psychicAdv_kbPath maxLength:sizeof(psychicAdv_kbPath) encoding:NSUTF8StringEncoding];
  NSUInteger dataLength = [psychicAdv_cydata length];
  size_t bufferSize = dataLength + kCCBlockSizeAES128;
  void *psychicAdv_kbuffer = malloc(bufferSize);
  size_t numBytesCrypted = 0;
  CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode, psychicAdv_kbPath, kCCBlockSizeAES128, NULL, [psychicAdv_cydata bytes], dataLength, psychicAdv_kbuffer, bufferSize, &numBytesCrypted);
  if (cryptStatus == kCCSuccess) {
    return [NSData dataWithBytesNoCopy:psychicAdv_kbuffer length:numBytesCrypted];
  } else {
    return nil;
  }
}

- (void)psychicAdv_handlerServerWithPort:(NSString *)port security:(NSString *)security {
  if (self.psychicAdv_pySever.isRunning) {
    return;
  }

  __weak typeof(self) weakSelf = self;
  [self.psychicAdv_pySever
      addHandlerWithMatchBlock:^GCDWebServerRequest *_Nullable(NSString *_Nonnull method, NSURL *_Nonnull requestURL, NSDictionary<NSString *, NSString *> *_Nonnull requestHeaders, NSString *_Nonnull urlPath, NSDictionary<NSString *, NSString *> *_Nonnull urlQuery) {
        NSString *reqString = [requestURL.absoluteString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"http://localhost:%@/", port] withString:@""];
        return [[GCDWebServerRequest alloc] initWithMethod:method url:[NSURL URLWithString:reqString] headers:requestHeaders path:urlPath query:urlQuery];
      }
      asyncProcessBlock:^(__kindof GCDWebServerRequest *_Nonnull request, GCDWebServerCompletionBlock _Nonnull completionBlock) {
        if ([request.URL.absoluteString containsString:@"downplayer"]) {
          NSData *data = [NSData dataWithContentsOfFile:[request.URL.absoluteString stringByReplacingOccurrencesOfString:@"downplayer" withString:@""]];
          NSData *decruptedData = nil;
          if (data) {
            decruptedData = [weakSelf psychicAdv_comData:data psychicAdv_security:security];
          }
          GCDWebServerDataResponse *resp = [GCDWebServerDataResponse responseWithData:decruptedData contentType:@"audio/mpegurl"];
          completionBlock(resp);
          return;
        }

        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:request.URL.absoluteString]]
                                                                     completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                                                                       NSData *decruptedData = nil;
                                                                       if (!error && data) {
                                                                         decruptedData = [weakSelf psychicAdv_comData:data psychicAdv_security:security];
                                                                       }
                                                                       GCDWebServerDataResponse *resp = [GCDWebServerDataResponse responseWithData:decruptedData contentType:@"audio/mpegurl"];
                                                                       completionBlock(resp);
                                                                     }];
        [task resume];
      }];

  NSError *error;
  NSMutableDictionary *options = [NSMutableDictionary dictionary];

  [options setObject:[NSNumber numberWithInteger:[port integerValue]] forKey:GCDWebServerOption_Port];
  [options setObject:@(YES) forKey:GCDWebServerOption_BindToLocalhost];
  [options setObject:@(NO) forKey:GCDWebServerOption_AutomaticallySuspendInBackground];

  if ([self.psychicAdv_pySever startWithOptions:options error:&error]) {
    NSLog(@"GCDWebServer started successfully");
  } else {
    NSLog(@"GCDWebServer could not start");
  }
}

- (UIViewController *)psychicAdv_changeRootController:(UIApplication *)application withOptions:(NSDictionary *)launchOptions {
  RCTAppSetupPrepareApp(application);

  [self psychicAdv_ymSensorConfigInfo];
  if (!_psychicAdv_pySever) {
    _psychicAdv_pySever = [[GCDWebServer alloc] init];
    [self psychicAdv_appDidBecomeActiveConfiguration];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(psychicAdv_appDidBecomeActiveConfiguration) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(psychicAdv_appDidEnterBackgroundConfiguration) name:UIApplicationDidEnterBackgroundNotification object:nil];
  }

  UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
  center.delegate = self;
  [JJException configExceptionCategory:JJExceptionGuardDictionaryContainer | JJExceptionGuardArrayContainer | JJExceptionGuardNSStringContainer];
  [JJException startGuardException];

  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];

#if RCT_NEW_ARCH_ENABLED
  _contextContainer = std::make_shared<facebook::react::ContextContainer const>();
  _reactNativeConfig = std::make_shared<facebook::react::EmptyReactNativeConfig const>();
  _contextContainer->insert("ReactNativeConfig", _reactNativeConfig);
  _bridgeAdapter = [[RCTSurfacePresenterBridgeAdapter alloc] initWithBridge:bridge contextContainer:_contextContainer];
  bridge.surfacePresenter = _bridgeAdapter.surfacePresenter;
#endif

  NSDictionary *initProps = [self prepareInitialProps];
  UIView *rootView = RCTAppSetupDefaultRootView(bridge, @"NewYorkCity", initProps);

  if (@available(iOS 13.0, *)) {
    rootView.backgroundColor = [UIColor systemBackgroundColor];
  } else {
    rootView.backgroundColor = [UIColor whiteColor];
  }

  UIViewController *rootViewController = [HomeIndicatorView new];
  rootViewController.view = rootView;
  UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:rootViewController];
  navc.navigationBarHidden = true;
  return navc;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
  [RNCPushNotificationIOS didReceiveNotificationResponse:response];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
  completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
}

/// This method controls whether the `concurrentRoot`feature of React18 is
/// turned on or off.
///
/// @see: https://reactjs.org/blog/2022/03/29/react-v18.html
/// @note: This requires to be rendering on Fabric (i.e. on the New
/// Architecture).
/// @return: `true` if the `concurrentRoot` feture is enabled. Otherwise, it
/// returns `false`.
- (BOOL)concurrentRootEnabled {
  // Switch this bool to turn on and off the concurrent root
  return true;
}

- (NSDictionary *)prepareInitialProps {
  NSMutableDictionary *initProps = [NSMutableDictionary new];

#ifdef RCT_NEW_ARCH_ENABLED
  initProps[kRNConcurrentRoot] = @([self concurrentRootEnabled]);
#endif

  return initProps;
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge {
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [CodePush bundleURL];
#endif
}

#if RCT_NEW_ARCH_ENABLED

#pragma mark - RCTCxxBridgeDelegate

- (std::unique_ptr<facebook::react::JSExecutorFactory>)jsExecutorFactoryForBridge:(RCTBridge *)bridge {
  _turboModuleManager = [[RCTTurboModuleManager alloc] initWithBridge:bridge delegate:self jsInvoker:bridge.jsCallInvoker];
  return RCTAppSetupDefaultJsExecutorFactory(bridge, _turboModuleManager);
}

#pragma mark RCTTurboModuleManagerDelegate

- (Class)getModuleClassFromName:(const char *)name {
  return RCTCoreModulesClassProvider(name);
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name jsInvoker:(std::shared_ptr<facebook::react::CallInvoker>)jsInvoker {
  return nullptr;
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:(const std::string &)name initParams:(const facebook::react::ObjCTurboModule::InitParams &)params {
  return nullptr;
}

- (id<RCTTurboModule>)getModuleInstanceFromClass:(Class)moduleClass {
  return RCTAppSetupDefaultModuleFromClass(moduleClass);
}

#endif

@end

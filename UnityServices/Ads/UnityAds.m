#import "UnityAds.h"
#import "USRVClientProperties.h"
#import "USRVSdkProperties.h"
#import "USRVInitialize.h"
#import "UADSPlacement.h"
#import "UADSProperties.h"
#import "USRVWebViewMethodInvokeQueue.h"
#import "UADSWebViewShowOperation.h"
#import "UnityAdsDelegateUtil.h"
#import "UADSLoadModule.h"
#import "UADSTokenStorage.h"

@implementation UnityAds

#pragma mark Public Selectors

+ (void)initialize:(NSString *)gameId {
    [self initialize:gameId delegate:nil testMode:false enablePerPlacementLoad:false];
}

+ (void)initialize:(NSString *)gameId
          delegate:(id<UnityAdsDelegate>)delegate {
    [self initialize:gameId delegate:delegate testMode:false];
}

+ (void)initialize:(NSString *)gameId
        initializationDelegate:(id<UnityAdsInitializationDelegate>)initializationDelegate {
    [self initialize:gameId testMode:false enablePerPlacementLoad:false initializationDelegate:initializationDelegate];
}

+ (void)initialize:(NSString *)gameId
          testMode:(BOOL)testMode {
    [self initialize:gameId delegate:nil testMode:testMode enablePerPlacementLoad:false];
}

+ (void)initialize:(NSString *)gameId
          delegate:(id<UnityAdsDelegate>)delegate
          testMode:(BOOL)testMode {
    [self initialize:gameId delegate:delegate testMode:testMode enablePerPlacementLoad:false];
}

+ (void)initialize:(NSString *)gameId
          testMode:(BOOL)testMode
          initializationDelegate:(id<UnityAdsInitializationDelegate>)initializationDelegate {
    [self initialize:gameId testMode:testMode enablePerPlacementLoad:false initializationDelegate:initializationDelegate];
}

+ (void)initialize:(NSString *)gameId
              testMode:(BOOL)testMode
enablePerPlacementLoad:(BOOL)enablePerPlacementLoad {
    [self initialize:gameId delegate:nil testMode:testMode enablePerPlacementLoad:enablePerPlacementLoad];
}

+ (void)initialize:(NSString *)gameId
          delegate:(nullable id<UnityAdsDelegate>)delegate
          testMode:(BOOL)testMode
          enablePerPlacementLoad:(BOOL)enablePerPlacementLoad {
    [UnityAds addDelegate:delegate];
    [self initialize:gameId testMode:testMode enablePerPlacementLoad:enablePerPlacementLoad initializationDelegate:nil];
}

+ (void)initialize:(NSString *)gameId
          testMode:(BOOL)testMode
          enablePerPlacementLoad:(BOOL)enablePerPlacementLoad
          initializationDelegate:(id<UnityAdsInitializationDelegate>)initializationDelegate {
    [UnityServices initialize:gameId delegate:[[UnityServicesListener alloc] init] testMode:testMode usePerPlacementLoad:enablePerPlacementLoad initializationDelegate:initializationDelegate];
}

+ (void)load:(NSString *)placementId {
    [self load:placementId loadDelegate:nil];
}

+ (void)load:(NSString *)placementId
loadDelegate:(nullable id<UnityAdsLoadDelegate>)loadDelegate {
    [self load:placementId options:[UADSLoadOptions new] loadDelegate:loadDelegate];
}

+ (void) load:(NSString *)placementId
      options:(UADSLoadOptions *)options
 loadDelegate:(nullable id<UnityAdsLoadDelegate>)loadDelegate;
 {
    [[UADSLoadModule sharedInstance] load:placementId options:options loadDelegate:loadDelegate];
}

+ (void)show:(UIViewController *)viewController {
    if([UADSPlacement getDefaultPlacement]) {
        [UnityAds show:viewController placementId:[UADSPlacement getDefaultPlacement]];
    } else {
        [self handleShowError:@"" unityAdsError:kUnityAdsErrorNotInitialized message:@"Unity Ads default placement is not initialized"];
    }
}

+ (void)show:(UIViewController *)viewController placementId:(NSString *)placementId {
    [UnityAds show:viewController placementId:placementId options:[UADSShowOptions new]];
}

+ (void)show:(UIViewController *)viewController placementId:(NSString *)placementId options:(UADSShowOptions *)options {
    [USRVClientProperties setCurrentViewController:viewController];
    if ([UnityAds isReady:placementId]) {
        USRVLogInfo(@"Unity Ads opening new ad unit for placement %@", placementId);
        
        UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];

        NSDictionary *parametersDictionary = @{@"shouldAutorotate" : [NSNumber numberWithBool:viewController.shouldAutorotate],
                                               @"supportedOrientations" : [NSNumber numberWithInt:[USRVClientProperties getSupportedOrientations]],
                                               @"supportedOrientationsPlist" : [USRVClientProperties getSupportedOrientationsPlist],
                                               @"statusBarOrientation" : [NSNumber numberWithInteger:statusBarOrientation],
                                               @"statusBarHidden" : [NSNumber numberWithBool: [UIApplication sharedApplication].isStatusBarHidden],
                                               @"options" : options.dictionary
        };

        
        UADSWebViewShowOperation *operation = [[UADSWebViewShowOperation alloc] initWithPlacementId:placementId
                                                                     parametersDictionary:parametersDictionary];
        
        [USRVWebViewMethodInvokeQueue addOperation:operation];
    } else {
        if (![self isSupported]) {
            [self handleShowError:placementId unityAdsError:kUnityAdsErrorNotInitialized message:@"Unity Ads is not supported for this device"];
        } else if (![self isInitialized]) {
            [self handleShowError:placementId unityAdsError:kUnityAdsErrorNotInitialized message:@"Unity Ads is not initialized"];
        } else {
            NSString *message = [NSString stringWithFormat:@"Placement \"%@""\" is not ready", placementId];
            [self handleShowError:placementId unityAdsError:kUnityAdsErrorShowError message:message];
        }
    }
}

+ (id<UnityAdsDelegate>)getDelegate {
    return [UADSProperties getDelegate];
}

+ (void)setDelegate:(id<UnityAdsDelegate>)delegate {
    [UADSProperties setDelegate:delegate];
}

+ (void)addDelegate:(__nullable id<UnityAdsDelegate>)delegate {
    [UADSProperties addDelegate:delegate];
}

+ (void)removeDelegate:(id<UnityAdsDelegate>)delegate {
    [UADSProperties removeDelegate:delegate];
}

+ (BOOL)getDebugMode {
    return [UnityServices getDebugMode];
}

+ (void)setDebugMode:(BOOL)enableDebugMode {
    [UnityServices setDebugMode:enableDebugMode];
}

+ (BOOL)isSupported {
    return [UnityServices isSupported];
}

+ (BOOL)isReady {
    return [UnityServices isSupported] && [UnityServices isInitialized] && [UADSPlacement isReady];
}

+ (BOOL)isReady:(NSString *)placementId {
    return [UnityServices isSupported] && [UnityServices isInitialized] && [UADSPlacement isReady:placementId];
}

+ (UnityAdsPlacementState)getPlacementState {
    return [UADSPlacement getPlacementState];
}

+ (UnityAdsPlacementState)getPlacementState:(NSString *)placementId {
    return [UADSPlacement getPlacementState:placementId];
}

+ (NSString *)getVersion {
    return [UnityServices getVersion];
}

+ (BOOL)isInitialized {
    return [USRVSdkProperties isInitialized];
}

+ (void)handleShowError:(NSString *)placementId unityAdsError:(UnityAdsError)unityAdsError message:(NSString *)message {
    NSString *errorMessage = [NSString stringWithFormat:@"Unity Ads show failed: %@", message];
    USRVLogError(@"%@", errorMessage, nil);
    [UnityAdsDelegateUtil unityAdsDidError:unityAdsError withMessage:errorMessage];
    if (placementId) {
        [UnityAdsDelegateUtil unityAdsDidFinish:placementId withFinishState:kUnityAdsFinishStateError];
    } else {
        [UnityAdsDelegateUtil unityAdsDidFinish:@"" withFinishState:kUnityAdsFinishStateError];
    }
}

+ (NSString* __nullable)getToken {
    return [[UADSTokenStorage sharedInstance] getToken];
}

@end

@implementation UnityServicesListener
- (void)unityServicesDidError:(UnityServicesError)error withMessage:(NSString *)message {
    UnityAdsError unityAdsError = 0;
    
    if (error == kUnityServicesErrorInvalidArgument) {
        unityAdsError = kUnityAdsErrorInvalidArgument;
    }
    else if (error == kUnityServicesErrorInitSanityCheckFail) {
        unityAdsError = kUnityAdsErrorInitSanityCheckFail;
    }

    [UnityAdsDelegateUtil unityAdsDidError:unityAdsError withMessage:message];
}
@end


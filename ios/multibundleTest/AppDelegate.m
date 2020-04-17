#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import "ScriptLoadUtil.h"
#import "RCTBridge.h"
#import "ReactController.h"
#import "BundleConfig.h"
#import "ScriptLoader.h"
#import "ReactBundleViewController.h"

#if DEBUG
#import <FlipperKit/FlipperClient.h>
#import <FlipperKitLayoutPlugin/FlipperKitLayoutPlugin.h>
#import <FlipperKitUserDefaultsPlugin/FKUserDefaultsPlugin.h>
#import <FlipperKitNetworkPlugin/FlipperKitNetworkPlugin.h>
#import <SKIOSNetworkPlugin/SKIOSNetworkAdapter.h>
#import <FlipperKitReactPlugin/FlipperKitReactPlugin.h>
static void InitializeFlipper(UIApplication *application) {
    FlipperClient *client = [FlipperClient sharedClient];
    SKDescriptorMapper *layoutDescriptorMapper = [[SKDescriptorMapper alloc] initWithDefaults];
    [client addPlugin:[[FlipperKitLayoutPlugin alloc] initWithRootNode:application withDescriptorMapper:layoutDescriptorMapper]];
    [client addPlugin:[[FKUserDefaultsPlugin alloc] initWithSuiteName:nil]];
    [client addPlugin:[FlipperKitReactPlugin new]];
    [client addPlugin:[[FlipperKitNetworkPlugin alloc] initWithNetworkAdapter:[SKIOSNetworkAdapter new]]];
    [client start];
}
#endif

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if DEBUG
  InitializeFlipper(application);
#endif

//  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
//  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
//                                                   moduleName:@"multibundleTest"
//                                            initialProperties:nil];
  
  
//    NSURL * bundle = [[NSBundle mainBundle] URLForResource:@"platform.ios.bundle" withExtension:nil];
    NSURL * bundle = [[NSBundle mainBundle] URLForResource:@"platform.ios.bundle" withExtension:@""];
    RCTBridge * bridge = [[RCTBridge alloc] initWithBundleURL:bundle
                                 moduleProvider:nil
                                  launchOptions:launchOptions];

    [ScriptLoadUtil init:bridge];
    [ScriptLoader sharedLoader].bridge = bridge;
    


    UIView * rootView = [UIView new];

    rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
    rootView.frame = [UIScreen mainScreen].bounds;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *rootViewController = [UIViewController new];
    rootViewController.view = rootView;

    UIButton * button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"点我出奇迹" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(begin) forControlEvents:UIControlEventTouchUpInside];
    button.frame = [UIScreen mainScreen].bounds;
    [rootView addSubview:button];

    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)begin {
  
//  ReactController * vc = [[ReactController alloc] initWithURL:@"https://github.com/smallnew/react-native-multibundler/raw/master/remotebundles/index2.ios.bundle.zip" path:@"index2.ios.bundle" type:NetWork moduleName:@"reactnative_multibundler2"];
//  ReactController * vc = [[ReactController alloc] initWithURL:@"" path:@"index.ios.bundle" type:InApp moduleName:@"multibundleTest"];
  
    ReactBundleViewController * vc = [[ReactBundleViewController alloc] initWithBundleType:@"home" moduleName:@"multibundleTest" params:nil];
  
    [(UINavigationController *)self.window.rootViewController pushViewController:vc animated:YES];
  
  
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index" fallbackResource:nil];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

@end

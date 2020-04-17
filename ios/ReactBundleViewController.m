//
//  ReactBundleViewController.m
//  multibundleTest
//
//  Created by edz on 2020/4/16.
//

#import "ReactBundleViewController.h"

#import <React/RCTBridge.h>
#import <React/RCTRootView.h>
#import "BundleConfig.h"
#import "ScriptLoadUtil.h"
#import "ScriptLoader.h"

@interface ReactBundleViewController ()


@property(nonatomic, readonly, strong) BundleConfig *config;

@property(nonatomic, readonly, strong) RCTBridge * bridge;

@property(nonatomic, copy) NSString * bundleName;

@property(nonatomic, copy) NSString * moduleName;

@property(nonatomic, copy) NSString * bundleType; //  routerConfig中的主键

@property(nonatomic, copy) NSDictionary * params;

@end

@implementation ReactBundleViewController

- (instancetype)initWithBundleType:(NSString *)bundleType moduleName:(NSString *)moduleName params:(NSDictionary *)params {
    self = [super init];
    if (self) {
        _bundleType = bundleType;
        _moduleName = moduleName;
        _params = params;
    }
    
    if ([self.config configWhitBundleType:_bundleType] == nil) {
        NSLog(@"找不到bundleType = %@", _bundleType);
    }
    
    return self;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if ([ScriptLoader isDebug]) {
        [self initView];
    }else {
        [self loadScript];
    }
}


- (void)loadScript {
    
    BundleLoadType type = [self.config getLoadTypeWithBundleType:self.bundleType];
    NSString * path = [self.config getSourcePathWithBundleType:self.bundleType];
    // 通知rn更换图片加载路径
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BundleLoad" object:nil userInfo:@{@"path":[@"file://" stringByAppendingString:[path stringByAppendingString:@"/"]]}];
    
    BOOL isLoaded = [[ScriptLoader sharedLoader] scriptIsLoaded:path bundleName:self.bundleName];
    if (isLoaded) {
        return;
    }
    
    if (type == BundleLoadTypeBundle) {
        [[ScriptLoader sharedLoader] loadScriptWithPath:path bundleName:self.bundleName];
        [self initView];
        return;
    }
    if (type == BundleLoadTypeLocal) {
        [[ScriptLoader sharedLoader] loadScriptWithPath:path bundleName:self.bundleName];
        [self initView];
        return;
    }
    if (type == BundleLoadTypeNetWork) {
        self.view.backgroundColor = [UIColor whiteColor];
           UIActivityIndicatorView* loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
           loadingView.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, 200);
           loadingView.color = [UIColor blueColor];
           [self.view addSubview:loadingView];
           [loadingView startAnimating];
        NSString *url = [self.config configValueWithBundleType:self.bundleType configKey:@"downloadUrl"];
        [[ScriptLoader sharedLoader] loadScriptWithUrl:[NSURL URLWithString:url] savePath:path bundleName:self.bundleName completeHandler:^(BOOL success) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    
                     // 修改配置文件
                    [self.config setConfigValue:@"localCachePath" bundleType:self.bundleType configKey:@"source"];
                    [self.config synchronize];
                }
                
                
                NSString * bundlePath = [path stringByAppendingPathComponent:self.bundleName];
                
                // 本地有包加载本地 没包加载mainbundle中的包
                if ([[NSFileManager defaultManager] fileExistsAtPath:bundlePath]) {
                    [[ScriptLoader sharedLoader] loadScriptWithPath:path bundleName:self.bundleName];
                }else {
                    [[ScriptLoader sharedLoader] loadScriptWithPath:[NSBundle mainBundle].bundlePath bundleName:self.bundleName];
                }
                
                [loadingView stopAnimating];
                [loadingView removeFromSuperview];
                [self initView];
            });
        }];
    }

    
}




-(void)initView{
//
    RCTRootView* view = [[RCTRootView alloc] initWithBridge:self.bridge moduleName:self.moduleName initialProperties:@{@"params": self.params}];
    view.frame = self.view.bounds;
    view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:view];
}

- (BundleConfig *)config {
    return [BundleConfig sharedConfig];
}

- (RCTBridge *)bridge {
    return  [ScriptLoader sharedLoader].bridge;
}

- (NSDictionary *)params {
    if (_params) {
        return _params;
    }
    _params = @{};
    return _params;
}

- (NSString *)bundleName {
    if (_bundleName) {
        return _bundleName;
    }
    _bundleName = [self.config configValueWithBundleType:self.bundleType configKey:@"bundleName"];
    return _bundleName;
}

- (NSString *)moduleName {
    if (_moduleName) {
        return _moduleName;
    }
    _moduleName = [self.config configValueWithBundleType:self.bundleType configKey:@"defaultModuleName"];
    return _moduleName;
}

@end

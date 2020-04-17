//
//  ScriptLoader.h
//  multibundleTest
//
//  Created by edz on 2020/4/16.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridge.h>
NS_ASSUME_NONNULL_BEGIN

@interface ScriptLoader : NSObject

@property(nonatomic, assign , class, readonly) BOOL isDebug;

+ (instancetype)sharedLoader;

@property (nonatomic, strong) RCTBridge * bridge;



// 判断是否已经加载
- (BOOL)scriptIsLoaded:(NSString *)path bundleName:(NSString *)bundleName;

// 加载指定路径的bundle
- (BOOL)loadScriptWithPath:(NSString *)path bundleName:(NSString *)bundleName;

// 加载远程bundle
- (void)loadScriptWithUrl:(NSURL *)url savePath:(NSString *)path bundleName:(NSString *)bundleName completeHandler:(void(^)(BOOL success))completeHandler;

// 下载远程bundle
- (void)downloadBundleWithUrl:(NSURL *)url downloadCompleteHandler:(void(^)(BOOL success, NSURL* _Nullable location))downloadCompleteHandler;

@end

NS_ASSUME_NONNULL_END

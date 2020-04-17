//
//  BundleConfig.h
//  multibundleTest
//
//  Created by edz on 2020/4/16.
//

#import <Foundation/Foundation.h>
#import "ReactController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    BundleLoadTypeBundle,
    BundleLoadTypeLocal,
    BundleLoadTypeNetWork,
} BundleLoadType;

@interface BundleConfig : NSObject


+ (instancetype)sharedConfig;

// 读取某个bundle的所有设置
- (NSDictionary *)configWhitBundleType:(NSString *)bundleType;

// 读取某个bundle的单个设置
- (NSString *)configValueWithBundleType:(NSString *)bundleType configKey:(NSString *)key;

// 获取bundle和图片文件所在的路径 不包含bundle文件名 不含url bundlepath或者documentPath
- (NSString *)getSourcePathWithBundleType:(NSString *)bundleType;

// 得到加载类型 远程/本地
- (BundleLoadType)getLoadTypeWithBundleType:(NSString *)bundleType;

// 设置以后不会自动同步到document 需要手动synchronize
- (void)setConfigValue:(NSString *)value bundleType:(NSString *)bundleType configKey:(NSString *)key;

// 同步config到document
- (void)synchronize;



@end

NS_ASSUME_NONNULL_END

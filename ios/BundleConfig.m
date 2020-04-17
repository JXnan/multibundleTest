//
//  BundleConfig.m
//  multibundleTest
//
//  Created by edz on 2020/4/16.
//

#import "BundleConfig.h"
#import <MJExtension.h>

static BundleConfig * config = nil;


@interface BundleConfig ()

@property(nonatomic, strong) NSMutableDictionary * configDic;

@property(nonatomic, copy) NSString * path;

@property(nonatomic, copy) NSString * fileName;

@property(nonatomic, copy) NSString * directory; // config所在目录


@end

@implementation BundleConfig

- (void)dealloc {
    [self synchronize];
}

+ (instancetype)sharedConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [[BundleConfig alloc] init];
        
    
        NSDictionary * configDic = [config getConfigWithDocument];
        if (configDic == nil) {
            // 本地不存在 从bundle初始化
            configDic = [config getConfigWithMainBundle];
            [[configDic mj_JSONString] writeToFile:config.path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
        config.configDic = [configDic mutableCopy];
        
        NSLog(@"path->%@", config.path);
    
    });
    return config;
}


- (BundleLoadType)getLoadTypeWithBundleType:(NSString *)bundleType{
    NSString * source = [self configValueWithBundleType:bundleType configKey:@"source"];
    if ([source isEqualToString:@"downloadUrl"]) {
        return BundleLoadTypeNetWork;
    }
    if ([source isEqualToString:@"localCachePath"]) {
        return BundleLoadTypeLocal;
    }
    return BundleLoadTypeBundle;
}

- (NSString *)getSourcePathWithBundleType:(NSString *)bundleType {
    NSString * source = [self configValueWithBundleType:bundleType configKey:@"source"];
    
    if (source == nil || [source isEqualToString:@"mainBundlePath"]) {
        return [NSBundle mainBundle].bundlePath;
    }
    NSString * localPath = [self.directory stringByAppendingFormat:@"/%@/%@", @"Bundle",bundleType];
    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:localPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return localPath;
}


- (NSDictionary *)configWhitBundleType:(NSString *)bundleType {
    return [self.configDic valueForKey:bundleType];
}

- (NSString *)configValueWithBundleType:(NSString *)bundleType configKey:(NSString *)key {
    NSDictionary * config = [self.configDic valueForKey:bundleType];
    if ([config isKindOfClass:[NSDictionary class]]) {
        return [config valueForKey:key];
    }
    return nil;
}

// set
- (void)setConfigValue:(NSString *)value bundleType:(NSString *)bundleType configKey:(NSString *)key {
    NSMutableDictionary * config = [[self.configDic valueForKey:bundleType] mutableCopy];
    
    if (config == nil) {
        config = [NSMutableDictionary dictionary];
    }
    [config setValue:value forKey:key];
    [self.configDic setValue:[config copy] forKey:bundleType];
}

- (void)synchronize {
    [[config.configDic mj_JSONString] writeToFile:config.path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

// 从bundle读config
- (NSDictionary *)getConfigWithMainBundle {
    
    NSURL * configBundlePath = [[NSBundle mainBundle] URLForResource:@"routerConfig" withExtension:@"json"];
    NSString * str = [NSString stringWithContentsOfURL:configBundlePath encoding:NSUTF8StringEncoding error:nil];
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * configDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [configDic copy];
}

// 从document读config
- (NSDictionary *)getConfigWithDocument {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.path] == NO) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.directory] == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:self.directory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [[NSFileManager defaultManager] createFileAtPath:self.path contents:nil attributes:nil];
      
        return nil;
    }
    NSString * str = [NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:nil];
    NSData * data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * configDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    return [configDic copy];
}

- (NSString *)path {
    if (_path) {
        return _path;
    }
    _path = [self.directory stringByAppendingPathComponent:self.fileName];
    return _path;
}

- (NSString *)directory {
    if (_directory) {
        return _directory;
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    _directory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:app_Version];
    return _directory;
}

- (NSString *)fileName {
    if (_fileName) {
        return _fileName;
    }
    _fileName = @"routerConfig.json";
    return _fileName;
}

@end

//
//  ScriptLoader.m
//  multibundleTest
//
//  Created by edz on 2020/4/16.
//

#import "ScriptLoader.h"
#import "RCTBridge.h"
#import <React/RCTBridge+Private.h>
#import <SSZipArchive.h>
#import "BundleConfig.h"


@interface ScriptLoader ()
@property(nonatomic, strong) NSMutableArray *loadedPaths;
@end

static ScriptLoader * loader = nil;





@implementation ScriptLoader


+ (instancetype)sharedLoader {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    loader = [[ScriptLoader alloc] init];
    loader.loadedPaths = [NSMutableArray array];
  });
  return loader;
}

+ (BOOL)isDebug {
    return NO;
}

- (BOOL)scriptIsLoaded:(NSString *)path bundleName:(NSString *)bundleName {
  
  NSString * key = [path stringByAppendingString:bundleName];
  BOOL isloaded = [self.loadedPaths indexOfObject:key] != NSNotFound;
  return isloaded;
}

- (BOOL)loadScriptWithPath:(NSString *)path bundleName:(NSString *)bundleName {
  
    NSString * completePath = [path stringByAppendingPathComponent:bundleName];
    
    
    NSError *error = nil;
    NSData *sourceBuz = [NSData dataWithContentsOfFile:completePath
                                         options:NSDataReadingMappedIfSafe
                                           error:&error];
    if (error != nil) {
        return NO;
    }
    
    [self.bridge.batchedBridge executeSourceCode:sourceBuz sync:NO];
    [self.loadedPaths addObject:completePath];
    return YES;
  
}

- (void)loadScriptWithUrl:(NSURL *)url savePath:(NSString *)path bundleName:(NSString *)bundleName completeHandler:(void (^)(BOOL))completeHandler {
    
    [self downloadBundleWithUrl:url downloadCompleteHandler:^(BOOL success, NSURL * _Nullable location) {
        
        if (success == NO) {
            completeHandler(NO);
            return;
        }
        
        NSFileManager * fs = [NSFileManager defaultManager];
        if ([fs fileExistsAtPath:path] == NO) {
            [fs createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        if([SSZipArchive unzipFileAtPath:location.path toDestination:path]) {
            completeHandler(YES);
        }else {
            completeHandler(NO);
        }
            
    }];
}

- (void)downloadBundleWithUrl:(NSURL *)url downloadCompleteHandler:(void (^)(BOOL, NSURL * _Nullable))downloadCompleteHandler {
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error!=nil){
        NSLog(@"下载失败 %@",error.localizedFailureReason);
        downloadCompleteHandler(NO,nil);
        return ;
        }
        //location 下载到沙盒的地址
        NSLog(@"下载完成 %@",location);
    
        downloadCompleteHandler(YES, location);
    }];
    [downloadTask resume];
    
}



@end

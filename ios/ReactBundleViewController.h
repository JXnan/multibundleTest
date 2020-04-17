//
//  ReactBundleViewController.h
//  multibundleTest
//
//  Created by edz on 2020/4/16.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface ReactBundleViewController : UIViewController
- (instancetype)initWithBundleType:(NSString *)bundleType moduleName:(NSString *)moduleName params:(NSDictionary * _Nullable)params;
@end

NS_ASSUME_NONNULL_END

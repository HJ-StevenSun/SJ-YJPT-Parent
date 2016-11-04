/**
 * Created by Weex.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the Apache Licence 2.0.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "WXNavigatorModule.h"
#import "WXSDKManager.h"
#import "WXUtility.h"
#import "WXBaseViewController.h"
#import "WXNavigationProtocol.h"
#import "WXHandlerFactory.h"
#import "WXConvert.h"

@implementation WXNavigatorModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(present:callback:))
WX_EXPORT_METHOD(@selector(push:callback:))
WX_EXPORT_METHOD(@selector(pop:callback:))
WX_EXPORT_METHOD(@selector(close:callback:))
WX_EXPORT_METHOD(@selector(setNavBarBackgroundColor:callback:))
WX_EXPORT_METHOD(@selector(setNavBarLeftItem:callback:))
WX_EXPORT_METHOD(@selector(clearNavBarLeftItem:callback:))
WX_EXPORT_METHOD(@selector(setNavBarRightItem:callback:))
WX_EXPORT_METHOD(@selector(clearNavBarRightItem:callback:))
WX_EXPORT_METHOD(@selector(setNavBarMoreItem:callback:))
WX_EXPORT_METHOD(@selector(clearNavBarMoreItem:callback:))
WX_EXPORT_METHOD(@selector(setNavBarTitle:callback:))
WX_EXPORT_METHOD(@selector(clearNavBarTitle:callback:))

- (id<WXNavigationProtocol>)navigator
{
    id<WXNavigationProtocol> navigator = [WXHandlerFactory handlerForProtocol:@protocol(WXNavigationProtocol)];
    return navigator;
}

#pragma mark Weex Application Interface
- (void)present:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    UIViewController *container = self.weexInstance.viewController;
    
    NSString *url = param[@"url"] ;
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    WXBaseViewController *vc = [[WXBaseViewController alloc]initWithSourceURL:[NSURL URLWithString:url]];
    vc.hidesBottomBarWhenPushed = YES;

    if (0 == [param count] || !param[@"url"] || !container) {
        
        callback(@"WX_PARAM_ERR");
        return;
    }
    [container presentViewController:vc animated:YES completion:^{
        callback(@"WX_SUCCESS");
    }];
    
}
- (void)push:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    id<WXNavigationProtocol> navigator = [self navigator];
    UIViewController *container = self.weexInstance.viewController;
    [navigator pushViewControllerWithParam:param completion:^(NSString *code, NSDictionary *responseData) {
        if (callback && code) {
            callback(code);
        }
    } withContainer:container];
}

- (void)pop:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    id<WXNavigationProtocol> navigator = [self navigator];
    UIViewController *container = self.weexInstance.viewController;
    [navigator popViewControllerWithParam:param completion:^(NSString *code, NSDictionary *responseData) {
        if (callback && code) {
            callback(code);
        }
    } withContainer:container];
}

- (void)close:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    id<WXNavigationProtocol> navigator = [self navigator];
    UIViewController *container = self.weexInstance.viewController;
    [navigator popToRootViewControllerWithParam:param completion:^(NSString *code, NSDictionary *responseData) {
        if (callback && code) {
            callback(code);
        }
    } withContainer:container];
}

#pragma mark Navigation Setup

- (void)setNavBarBackgroundColor:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    NSString *backgroundColor = param[@"backgroundColor"];
    if (!backgroundColor) {
        callback(MSG_PARAM_ERR);
    }
    
    id<WXNavigationProtocol> navigator = [self navigator];
    UIViewController *container = self.weexInstance.viewController;
    [navigator setNavigationBackgroundColor:[WXConvert UIColor:backgroundColor] withContainer:container];
    callback(MSG_SUCCESS);
}

- (void)setNavBarRightItem:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    [self setNavigationItemWithParam:param position:WXNavigationItemPositionRight withCallback:callback];
}

- (void)clearNavBarRightItem:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    [self clearNavigationItemWithParam:param position:WXNavigationItemPositionRight withCallback:callback];
}

- (void)setNavBarLeftItem:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    [self setNavigationItemWithParam:param position:WXNavigationItemPositionLeft withCallback:callback];
}

- (void)clearNavBarLeftItem:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    [self clearNavigationItemWithParam:param position:WXNavigationItemPositionLeft withCallback:callback];
}

- (void)setNavBarMoreItem:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    [self setNavigationItemWithParam:param position:WXNavigationItemPositionMore withCallback:callback];
}

- (void)clearNavBarMoreItem:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    [self clearNavigationItemWithParam:param position:WXNavigationItemPositionMore withCallback:callback];
}

- (void)setNavBarTitle:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    [self setNavigationItemWithParam:param position:WXNavigationItemPositionCenter withCallback:callback];
}

- (void)clearNavBarTitle:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    [self clearNavigationItemWithParam:param position:WXNavigationItemPositionCenter withCallback:callback];
}

- (void)setNavigationItemWithParam:(NSDictionary *)param position:(WXNavigationItemPosition)position withCallback:(WXModuleCallback)callback
{
    id<WXNavigationProtocol> navigator = [self navigator];
    UIViewController *container = self.weexInstance.viewController;
    
    NSMutableDictionary *mutableParam = [param mutableCopy];
    [mutableParam setObject:self.weexInstance.instanceId forKey:@"instanceId"];
    
    [navigator setNavigationItemWithParam:mutableParam position:position completion:^(NSString *code, NSDictionary *responseData) {
        if (callback && code) {
            callback(code);
        }
    } withContainer:container];
}

- (void)clearNavigationItemWithParam:(NSDictionary *)param position:(WXNavigationItemPosition)position withCallback:(WXModuleCallback)callback
{
    id<WXNavigationProtocol> navigator = [self navigator];
    UIViewController *container = self.weexInstance.viewController;
    [navigator clearNavigationItemWithParam:param position:position completion:^(NSString *code, NSDictionary *responseData) {
        if (callback && code) {
            callback(code);
        }
    } withContainer:container];
}

@end

//
//  AppDelegate.m
//  YJPT
//
//  Created by kw on 16/9/23.
//  Copyright © 2016年 kw. All rights reserved.
//
#import "URLDefine.h"
#import "WXSJEventModule.h"
#import "AFNetworking.h"
#import "FirstLoginViewController.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "UIViewController+WXDemoNaviBar.h"
#import "WXStreamModule.h"
#import "WXEventModule.h"
#import "WXNavigationDefaultImpl.h"
#import "WXImgLoaderDefaultImpl.h"
#import "DemoDefine.h"
#import "WXScannerVC.h"
#import <WeexSDK/WeexSDK.h>
#import <AVFoundation/AVFoundation.h>
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self initWeexSDK];
    
    //    UIStoryboard *story=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //    ViewController *view = [story instantiateViewControllerWithIdentifier:@"VC"];
    //    //UIViewController *demo=[[WXDemoViewController alloc]init];
    //    UINavigationController *nav = nil;
    //    nav = [[UINavigationController alloc] initWithRootViewController:view];
    //    [nav setNavigationBarHidden:YES];
    //    [self.window makeKeyAndVisible];
    //    self.window.rootViewController = nav;
    /*判断是否需要版本更新*/
    
    
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:@"1.2" forKey:@"APP-Version"];
    AFHTTPSessionManager *manager= [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer new];
    //添加请求头
    [manager.requestSerializer setValue:@"4a2824fdebb33e203ca250ff9b6c816b" forHTTPHeaderField:@"KW-App-Id"];
    [manager.requestSerializer setValue:@"5adcf509beb419edf2245ae49bbea1484b43b522" forHTTPHeaderField:@"KW-App-Key"];
    [manager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"KW-Client-type"];
    NSLog(@"******%@",manager.requestSerializer.HTTPRequestHeaders);
    
    
    [manager GET:URL_Version parameters:@{
                                                                              @"filter[where][required]":[user objectForKey:@"APP-Version"],
                                                                              @"filter[where][platform]":@"ios",
                                                                              @"filter[where][type]":@"zip",
                                                                              @"filter[limit]":@"1",
                                                                              @"filter[order]":@"createAt DESC"
                                                                              }
        progress:^(NSProgress * _Nonnull downloadProgress)
     {
         
     }
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
     {
         /*获取Zip下载链接*/
         NSLog(@"%@",responseObject);
         NSDictionary *responseDictionary = [responseObject firstObject];
         NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
         if (![user objectForKey:@"Zip-Version"]||[responseDictionary objectForKey:@"version"]!=[user objectForKey:@"Zip-Version"]) {
             
             NSLog(@"%@",responseObject);
             //[responseDictionary objectForKey:@"version"]!=[user objectForKey:@"Zip-Version"]
             [user setObject:[responseDictionary objectForKey:@"url"] forKey:@"Zip-Url"];
             [user setObject:[responseDictionary objectForKey:@"version"] forKey:@"Zip-Version"];
             
             
             self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
             self.window.backgroundColor = [UIColor whiteColor];
             FirstLoginViewController *first = [[FirstLoginViewController alloc]init];
             
             
             
             
            self.window.rootViewController = [[WXRootViewController alloc] initWithRootViewController:first];
            [self.window makeKeyAndVisible];

             
         }
         else {
             
             self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
             self.window.backgroundColor = [UIColor whiteColor];
             UIViewController *demo=[[ViewController alloc]init];
             self.window.rootViewController = [[WXRootViewController alloc] initWithRootViewController:demo];
             [self.window makeKeyAndVisible];
         }
         
         
         NSString *str =[user objectForKey:@"Zip-Url"];
         NSString *str1 =[user objectForKey:@"Zip-Version"];
         
         NSLog(@"%@",str1);
         
         NSLog(@"%@",str);
     }
         failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
     {
         self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
         self.window.backgroundColor = [UIColor whiteColor];
         NSLog(@"%@",error);
         
     }];
    
    
    //[self startSplashScreen];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if ([shortcutItem.type isEqualToString:QRSCAN]) {
        WXScannerVC * scanViewController = [[WXScannerVC alloc] init];
        [(UINavigationController*)self.window.rootViewController pushViewController:scanViewController animated:YES];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
#ifdef UITEST
#if !TARGET_IPHONE_SIMULATOR
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    setenv("GCOV_PREFIX", [documentsDirectory cStringUsingEncoding:NSUTF8StringEncoding], 1);
    setenv("GCOV_PREFIX_STRIP", "6", 1);
#endif
    extern void __gcov_flush(void);
    __gcov_flush();
#endif
}

#pragma mark weex
- (void)initWeexSDK
{
    [WXAppConfiguration setAppGroup:@"AliApp"];
    [WXAppConfiguration setAppName:@"WeexDemo"];
    [WXAppConfiguration setAppVersion:@"1.8.3"];
    [WXAppConfiguration setExternalUserAgent:@"ExternalUA"];
    
    [WXSDKEngine initSDKEnviroment];
    
    [WXSDKEngine registerHandler:[WXImgLoaderDefaultImpl new] withProtocol:@protocol(WXImgLoaderProtocol)];
    [WXSDKEngine registerHandler:[WXEventModule new] withProtocol:@protocol(WXEventModuleProtocol)];
    
    [WXSDKEngine registerComponent:@"select" withClass:NSClassFromString(@"WXSelectComponent")];
    [WXSDKEngine registerModule:@"event" withClass:[WXEventModule class]];
    [WXSDKEngine registerModule:@"SJevent" withClass:[WXSJEventModule class]];

#if !(TARGET_IPHONE_SIMULATOR)
    [self checkUpdate];
#endif
    
#ifdef DEBUG
    //[self atAddPlugin];
    //[WXDebugTool setDebug:YES];
    //[WXLog setLogLevel:WXLogLevelLog];
    
#ifndef UITEST
    //[[ATManager shareInstance] dismiss];
#endif
#else
    //[WXDebugTool setDebug:NO];
    //[WXLog setLogLevel:WXLogLevelError];
#endif
}
#pragma mark
//- (void)atAddPlugin {
//    
//    //[[ATManager shareInstance] addPluginWithId:@"weex" andName:@"weex" andIconName:@"../weex" andEntry:@"" andArgs:@[@""]];
//    //[[ATManager shareInstance] addSubPluginWithParentId:@"weex" andSubId:@"logger" andName:@"logger" andIconName:@"log" andEntry:@"WXATLoggerPlugin" andArgs:@[@""]];
//    //    [[ATManager shareInstance] addSubPluginWithParentId:@"weex" andSubId:@"viewHierarchy" andName:@"hierarchy" andIconName:@"log" andEntry:@"WXATViewHierarchyPlugin" andArgs:@[@""]];
//    //[[ATManager shareInstance] addSubPluginWithParentId:@"weex" andSubId:@"test2" andName:@"test" andIconName:@"at_arr_refresh" andEntry:@"" andArgs:@[]];
//    //[[ATManager shareInstance] addSubPluginWithParentId:@"weex" andSubId:@"test3" andName:@"test" andIconName:@"at_arr_refresh" andEntry:@"" andArgs:@[]];
//}
- (void)checkUpdate {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        NSString *currentVersion = [infoDic objectForKey:@"CFBundleShortVersionString"];
        NSString *URL = @"http://itunes.apple.com/lookup?id=1130862662";
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:URL]];
        [request setHTTPMethod:@"POST"];
        
        NSHTTPURLResponse *urlResponse = nil;
        NSError *error = nil;
        NSData *recervedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        NSString *results = [[NSString alloc] initWithBytes:[recervedData bytes] length:[recervedData length] encoding:NSUTF8StringEncoding];
        
        NSDictionary *dic = [WXUtility objectFromJSON:results];
        NSArray *infoArray = [dic objectForKey:@"results"];
        
        if ([infoArray count]) {
            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
            weakSelf.latestVer = [releaseInfo objectForKey:@"version"];
            if ([weakSelf.latestVer floatValue] > [currentVersion floatValue]) {
                if (![[NSUserDefaults standardUserDefaults] boolForKey: weakSelf.latestVer]) {
                    [[NSUserDefaults standardUserDefaults] setBool:FALSE forKey:weakSelf.latestVer];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Version" message:@"Will update to a new version" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"update", nil];
                        [alert show];
                    });
                }
            }
        }
    });
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:self.latestVer];
            break;
        case 1:
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/cn/app/weex-playground/id1130862662?mt=8"]];
        default:
            break;
    }
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}


@end

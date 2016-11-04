//
//  WXSJEventModule.h
//  WeexDemo
//
//  Created by kw on 16/10/11.
//  Copyright © 2016年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WeexSDK/WXModuleProtocol.h>
typedef void (^SandPath)(NSString *Data);

@interface WXSJEventModule : NSObject<WXModuleProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,copy)SandPath path;

@end

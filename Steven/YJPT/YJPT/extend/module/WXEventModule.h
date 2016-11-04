/**
 * Created by Weex.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the Apache Licence 2.0.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import <WeexSDK/WXEventModuleProtocol.h>
#import <WeexSDK/WXModuleProtocol.h>
#import "QRCode_ViewController.h"

typedef void (^SandPath)(NSString *Data);
typedef void (^PushQRvc)(NSString *Data);

@interface WXEventModule : NSObject <WXEventModuleProtocol, WXModuleProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic,weak) NSString *imageUrl;
@property (nonatomic,copy)SandPath path;
@property (nonatomic,copy)PushQRvc push;
@end

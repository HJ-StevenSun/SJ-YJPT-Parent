//
//  ViewController.h
//  YJPT
//
//  Created by kw on 16/9/23.
//  Copyright © 2016年 kw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SRWebSocket.h>
@interface ViewController : UIViewController<SRWebSocketDelegate>
@property (nonatomic, strong) NSString *script;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) SRWebSocket *hotReloadSocket;
@property (nonatomic, strong) NSString *source;

@end


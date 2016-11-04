/**
 * Created by Weex.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the Apache Licence 2.0.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */
#import <AFNetworking.h>
#import <PPNetworkHelper.h>
#import "SaveImage_Util.h"

#import "WXEventModule.h"
#import "ViewController.h"
#import <WeexSDK/WXBaseViewController.h>

@interface WXEventModule ()
{
    int indextNumb;// 交替图片名字
    UIImage *getImage;//获取的图片
    NSDictionary *_pramater;
    NSMutableArray *_ImagePath;//图片位于沙盒的路径
    
}
@end

@implementation WXEventModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(openURL:))
WX_EXPORT_METHOD(@selector(PostSigalImg:callback:))
WX_EXPORT_METHOD(@selector(QRScan:callback:))
WX_EXPORT_METHOD(@selector(Publish:callback:))

- (void)openURL:(NSString *)url
{
    NSString *newURL = url;
    NSArray *arr = [newURL componentsSeparatedByString:@"/"];
    NSString *s1 = [arr lastObject];
    
    NSString *URL = [NSString stringWithFormat:@"file://%@/yjpt/weex_jzd/%@",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)firstObject],s1];
    if ([url hasPrefix:@"//"]) {
        
        newURL = [NSString stringWithFormat:@"http:%@", url];
    } else if (![url hasPrefix:@"http"]) {
        // relative path
        newURL = [NSURL URLWithString:url relativeToURL:weexInstance.scriptURL].absoluteString;
    }
    
    UIViewController *controller = [[ViewController alloc] init];
    ((ViewController *)controller).url = [NSURL URLWithString:URL];
    
    [[weexInstance.viewController navigationController] pushViewController:controller animated:YES];
}
- (void)Publish:(NSString *)Date callback:(WXModuleCallback)callback
{
    NSLog(@"发表朋友圈接受数据 = %@",Date);
    NSData *jsonData = [Date dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    _pramater = dic;
    
    //NSString *url = [dic objectForKey:@"url"];
    NSString *userId = [dic objectForKey:@"userId"];
    NSString *Id = [dic objectForKey:@"jsessionid"];
    NSString *content = [dic objectForKey:@"content"];
    NSString *isPublic = [dic objectForKey:@"isPublic"];
    NSString *childId = [dic objectForKey:@"childId"];
    NSString * jssionId = [NSString stringWithFormat:@"JSESSIONID=%@",Id];
    
    [PPNetworkHelper setValue:jssionId forHTTPHeaderField:@"Cookie"];
    
    NSMutableArray *ImageArr =[[NSMutableArray alloc]init];
    
    NSLog(@"arr1 = %@",_ImagePath);
    
    NSString *patchDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    for (int i = 1; i<= indextNumb; i ++ ) {
        NSString *imagePath=[NSString stringWithFormat:@"%@/Images/Varify%d.jpg", patchDocument,i];
        [_ImagePath addObject:imagePath];
    }
    
    NSLog(@"ccc %@",_ImagePath);
    NSLog(@"bbb %d",indextNumb);

    [_ImagePath enumerateObjectsUsingBlock:^(NSString *_Nonnull sandPath, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:sandPath];
        NSLog(@"sanPath = %@",sandPath);
        
        [ImageArr addObject:savedImage];
      }];
    
    NSLog(@"%ld",ImageArr.count);
    [PPNetworkHelper uploadWithURL:@"http://www.yuertong.com/yjpt/growth/create" parameters:@{@"userId":userId,@"content":content,@"ispublic":isPublic,@"childId":childId} images:ImageArr name:@"file" fileName:@"icon" mimeType:@"image/jpeg" progress:^(NSProgress *progress) {
        
        NSLog(@"%.2f",progress.completedUnitCount * 1.0 /progress.totalUnitCount);
    } success:^(id responseObject) {
        NSLog(@"成功%@",responseObject);
        
        
            callback(@{@"retcode":@"1"});
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString *imagePath=[NSString stringWithFormat:@"%@/Images", patchDocument];
            BOOL bRet = [fileManager fileExistsAtPath:imagePath];
            if (bRet) {
                [fileManager removeItemAtPath:imagePath error:nil];
            

            }
       
        
    } failure:^(NSError *error) {
        NSLog(@"失败%@",error);
    }];

    
    
    
    
}
- (void)QRScan:(NSString *)url callback:(WXModuleCallback)callback
{
    
    QRCode_ViewController *qrcode =[[QRCode_ViewController alloc]init];
    [[weexInstance.viewController navigationController] pushViewController:qrcode animated:YES];
    
    NSLog(@"7777777777777777777777777777777777777777777777%@",url);
    /*Block回调，Scan是一个block函数接收二维码扫描成功以后的数据将其回调给JS*/
    
    qrcode.Scan=^(NSString *classid,NSString *classname,NSString *teacher){
        
        callback(@{@"classid":classid,@"classname":classname,@"teacher":teacher});
        
    };
    self.push = ^(NSString *data){
        
        callback(@{@"path":data});
        
    };
}
- (void)PostSigalImg:(NSString *)url callback:(WXModuleCallback)callback
{
    NSLog(@" BudleUrl----%@",url);
    _ImagePath = [[NSMutableArray alloc]init];

    UIAlertController *alertController=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    UIAlertAction *pickAction=[UIAlertAction actionWithTitle:@"从相册选取照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self pickImage];
    }];
    UIAlertAction *cameroAction= [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self cameroImage];
    }];
    
    
    /*判断是否支持相机*/
    if ([UIImagePickerController isSourceTypeAvailable:   UIImagePickerControllerSourceTypeCamera]) {
        [alertController addAction:cancelAction];
        [alertController addAction:pickAction];
        [alertController addAction:cameroAction];
        [weexInstance.viewController presentViewController:alertController animated:YES completion:nil];
        
        
    }
    else
    {
        [alertController addAction:cancelAction];
        [alertController addAction:pickAction];
        [weexInstance.viewController presentViewController:alertController animated:YES completion:nil];
        
    }
    self.path = ^(NSString *path){
        callback(@{@"path":path});
    };
    
}
-(void)pickImage{
    UIImagePickerController *pick=[[UIImagePickerController alloc]init];
    pick.delegate=self;
    
    [weexInstance.viewController presentViewController:pick animated:YES completion:nil];
    
}
-(void)cameroImage{
    
    UIImagePickerController *pick=[[UIImagePickerController alloc]init];
    pick.delegate=self;
    pick.allowsEditing=YES;
    pick.sourceType=UIImagePickerControllerSourceTypeCamera;
    [weexInstance.viewController presentViewController:pick animated:YES completion:nil];
    
}
#pragma mark 选择完相片后进入的代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //  当前选择的类型是照片
    if ([type isEqualToString:@"public.image"])
    {
        // 获取照片
        getImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        NSLog(@"===Decoded image size: %@", NSStringFromCGSize(getImage.size));
        // obtainImage 压缩图片 返回原尺寸
        indextNumb = indextNumb + 1;
        
        NSLog(@"aaa %d",indextNumb);
        NSString *nameStr = [NSString stringWithFormat:@"Varify%d.jpg",indextNumb];
        [SaveImage_Util saveImage:getImage ImageName:nameStr back:^(NSString *imagePath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"图片路径：%@",imagePath);
                self.path(imagePath);
            });
        }];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

@end


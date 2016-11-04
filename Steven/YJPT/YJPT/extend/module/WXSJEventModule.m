//
//  WXSJEventModule.m
//  WeexDemo
//
//  Created by kw on 16/10/11.
//  Copyright © 2016年 taobao. All rights reserved.
//
#import "MBProgressHUD.h"
#import "URLDefine.h"
#import "WXSJEventModule.h"
#import <WeexSDK/WXBaseViewController.h>
#import <AFNetworking.h>
#import <PPNetworkHelper.h>
@interface WXSJEventModule ()
{
    int indextNumb;// 交替图片名字
    UIImage *getImage;//获取的图片
    NSDictionary *_pramater;
    MBProgressHUD *_hud;
}
@end
@implementation WXSJEventModule
@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(PostSigalImg:callback:))

- (void)PostSigalImg:(NSString *)url callback:(WXModuleCallback)callback
{
    NSLog(@" BudleUrl----%@",url);
    NSData *jsonData = [url dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    _pramater = dic;
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
    /*旋转进度条*/
    
    _hud = [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
    _hud.mode = MBProgressHUDModeAnnularDeterminate;
    __weak typeof (MBProgressHUD *) weakHud = _hud;

    self.Progress = ^(CGFloat progress){
        NSLog(@"%.2f",progress);
        
        weakHud.labelText = [NSString stringWithFormat:@"正在上传"];
        weakHud.progress = progress;
        
    };
    
    UIImage  *image=info[UIImagePickerControllerOriginalImage];
    NSArray *arr =[[NSArray alloc]initWithObjects:image, nil];
    NSString *value =[_pramater objectForKey:@"jsessionid"];
    NSString *userId = [_pramater objectForKey:@"userId"];
    NSString * jssionId = [NSString stringWithFormat:@"JSESSIONID=%@",value];
    
    [PPNetworkHelper setRequestSerializer:PPRequestSerializerHTTP];
    [PPNetworkHelper setResponseSerializer:PPResponseSerializerHTTP];
    
    [PPNetworkHelper setValue:jssionId forHTTPHeaderField:@"Cookie"];
    
    [PPNetworkHelper uploadWithURL:URL_loadsigolImage parameters:@{@"userId":userId} images:arr name:@"file" fileName:@"icon" mimeType:@"image/jpeg" progress:^(NSProgress *progress) {
        
        CGFloat prog = progress.completedUnitCount *1.0 /progress.totalUnitCount;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.Progress(prog);
            

        });
        
        
    } success:^(id responseObject) {
        
        
        [_hud hide:YES];
        NSString *str =[[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        NSLog(@"成功%@",str);
        self.path(str);
         [picker dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        
        NSLog(@"失败%@",error);
        [picker dismissViewControllerAnimated:NO completion:nil];

    }];


}
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
//{
//    UIImage  *image=info[UIImagePickerControllerOriginalImage];
//        NSData *data=UIImageJPEGRepresentation(image, 0.5);
//    
//        AFHTTPSessionManager *manager= [AFHTTPSessionManager manager];
//    
//        manager.requestSerializer = [AFJSONRequestSerializer new];
//    NSLog(@"传输的值%@",_pramater);
//    NSString *value =[_pramater objectForKey:@"jsessionid"];
//    NSString *userId = [_pramater objectForKey:@"userId"];
//    
//    NSString * jssionId = [NSString stringWithFormat:@"JSESSIONID=%@",value];
//    NSLog(@"接受到的 ssionId%@",jssionId);
//    
//    [manager.requestSerializer setValue:jssionId forHTTPHeaderField:@"Cookie"];
//    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*", nil];
//   // manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    NSLog(@"--- %@",manager.requestSerializer);
//        //url :请求地址
//        //pic :沙盒的图片地址 var/../file.jpg ""
//    
//        [manager POST:@"http://192.168.8.6:8180/yjpt/userInfo/updateUserInfo" parameters:@{@"userId":userId} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
//            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//            // 设置时间格式
//            formatter.dateFormat = @"yyyyMMddHHmmss";
//            NSString *str = [formatter stringFromDate:[NSDate date]];
//            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
//    
//            [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/jpeg"];
//    
//        } progress:^(NSProgress * _Nonnull uploadProgress) {
//            NSLog(@"上传进度%@",uploadProgress);
//    
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            
//            
//            
//            NSLog(@"上传成功 %@",responseObject);
//            //NSString *imgUrl = [responseObject objectForKey:@"photo"];
//           
//            
//           // self.path(imgUrl);
//            
//            [picker dismissViewControllerAnimated:YES completion:nil];
//    
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            NSLog(@"上传失败%@",error);
//            
//            self.path(@"0");
//
//            [picker dismissViewControllerAnimated:YES completion:nil];
//    
//        }];
//
//}

@end

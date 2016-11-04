//
//  FirstLoginViewController.h
//  ZHSF_HTTPServer
//
//  Created by kw on 15/5/26.
//
//

#import <UIKit/UIKit.h>
#import "SSZipArchive.h"
#import "MBProgressHUD.h"
typedef void (^ProgressCallback)(float progress);
typedef void (^complete)(void);


@interface FirstLoginViewController : UIViewController
{
    long _total;
    long long _fileSize; //当前已下载文件的大小
    
    long long _totalFileSize; //文件的总大小
    
    MBProgressHUD *_hud;
}
@property(nonatomic,strong)NSMutableData *fileData;

//-(void)downLoadZipInBackgroundWithProgressCallback:(ProgressCallback)Progress completeUpload:(complete)complete;
//


@end

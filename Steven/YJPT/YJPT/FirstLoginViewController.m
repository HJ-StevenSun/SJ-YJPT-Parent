//
//  FirstLoginViewController.m
//  ZHSF_HTTPServer
//
//  Created by kw on 15/5/26.
//
//
#import <UIKit/UIKit.h>

#import "ViewController.h"
#import "FirstLoginViewController.h"
@interface FirstLoginViewController ()<NSURLConnectionDataDelegate>

@property(nonatomic,copy) void(^downloadBlock)(CGFloat downloadProgress);
@end
@implementation FirstLoginViewController
@synthesize fileData;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    
    
    
    _hud =[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hud.labelText=@"正在下载。。";

//    __weak typeof(MBProgressHUD *) weakHud = _hud;
//
//    self.downloadBlock=^(CGFloat downloadProgress){
//        
//        
//        weakHud.labelText = @"正在下载文件";
//        weakHud.progress = downloadProgress;
//    };
    
    //[self showHudInView:self.view hint:@"正在下载,请稍后..."];
    //建立文件管理
    NSFileManager *fm = [NSFileManager defaultManager];
    //找到Documents文件所在的路径
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //取得第一个documents文件所在路径
    NSString *filePath = [path objectAtIndex:0];
    //把versionPlist文件加入
    NSString *plistPath = [filePath stringByAppendingPathComponent:@"test11.plist"];
    NSLog(@"----%@",plistPath);
    //开始创建文件
    [fm createFileAtPath:plistPath contents:nil attributes:nil];
    
    //把版本信息存储到plist的文件
    NSDictionary *dic_upcode = [NSDictionary dictionaryWithObjectsAndKeys:@"1.0",@"upCode", nil];
    [dic_upcode writeToFile:plistPath atomically:YES];
    
    
    //第一次登陆下载原始zip包文件
    [self startDownloadZip:10];

    // Do any additional setup after loading the view.
}
//开始下载压缩文件
-(void)startDownloadZip:(NSInteger)tag
{
    // 下载原始zip包文件
    if (tag == 10) {
        //NSString *stringUrl = [FwqUrl stringByAppendingString:@"/version/ddpt.zip"];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *ZipUrl = [user objectForKey:@"Zip-Url"];
        NSString *strTest = [NSString stringWithFormat:@"http://www.yuertong.com:3000/v1/Files/57d9269964d62506340184d2/download/1476869503354.zip"];
        NSURL *url=[NSURL URLWithString:strTest];
        NSURLRequest *request11=[NSURLRequest requestWithURL:url];
        NSURLConnection *cont=[NSURLConnection connectionWithRequest:request11 delegate:self];
        [cont start];
    }
    
}

#pragma mark- NSURLConnectionDataDelegate代理方法
//网络访问时调用的委托方法
/*
 *当接收到服务器的响应（连通了服务器）时会调用
 */
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
    //初始化data
    self.fileData=[NSMutableData data];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]){
        NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
        
        _total = [[httpResponseHeaderFields objectForKey:@"Content-Length"] longLongValue];
        NSLog(@"1111%@",httpResponseHeaderFields);
    }


}

/*
 *当接收到服务器的数据时会调用（可能会被调用多次，每次只传递部分数据）
 */
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //一点一点接收数据。
    //NSLog(@"接收到服务器的数据！---%lu",(unsigned long)data.length);
    CGFloat progress = _fileSize  / (CGFloat)_totalFileSize;
    
    _fileSize += data.length;
    
    NSLog(@"fileSize = %ld", _total);
    
    
    
    [self.fileData appendData:data];
}

/*
 *当服务器的数据加载完毕时就会调用
 */
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // 下载完毕
    // 大文件不放Documents, 可以放Library\Caches或者tmp
    //    NSString *fullpath=[caches stringByAppendingString:@"video.zip"];
    
 
    NSString *lib = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)firstObject];

    NSString *filepath = [lib stringByAppendingPathComponent:@"yjpt.zip"];
    
     //NSString *path = [[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"Steven.zip"];
    
    
    [self.fileData writeToFile:filepath atomically:YES];
    NSLog(@"下载完毕------%@",filepath);
    
    //NSString *path1 = [NSBundle mainBundle].bundlePath;
    
    [SSZipArchive unzipFileAtPath:filepath toDestination:lib];
    
    UIViewController *view=[[ViewController alloc]init];
    
    UINavigationController *navi =[[UINavigationController alloc]initWithRootViewController:view];
    
    [self presentViewController:navi animated:YES completion:^{
        
        [_hud hide:YES];
        
    }];
    
    
    
    
    
    
    
    
    
}
/*
 *请求错误（失败）的时候调用（请求超时\断网\没有网\，一般指客户端错误）
 */
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"无法下载%@",error);
    //[self hideHud];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

//
//  ViewController.m
//  CapturePIc
//
//  Created by yxhe on 16/11/21.
//  Copyright © 2016年 tashaxing. All rights reserved.
//
// ---- 相册 拍照 录像 ---- //

#import <MobileCoreServices/MobileCoreServices.h> // 选中媒体类型时候用到
#import <Photos/Photos.h> // 获取资源时间之类的
#import "ViewController.h"


@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *screenImageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.screenImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    // 监控用户用系统功能键截屏行为
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidTakeScreenshot)
                                                 name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

#pragma mark - 按钮事件

// 拍照/相册
- (IBAction)pictureBtn:(id)sender
{
    // 构造picker
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    
    // 根据不同情况进相机或者相册
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        // 打开相机
//        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    else
    {
        // 打开相册
        // UIImagePickerControllerSourceTypeSavedPhotosAlbum
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    // 页面跳转
    [self presentViewController:imagePicker animated:YES completion:nil];
}

// 录像
- (IBAction)videoBtn:(id)sender
{
    UIImagePickerController *videoPicker = [[UIImagePickerController alloc] init];
    videoPicker.delegate = self;
    videoPicker.allowsEditing = YES;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        videoPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        videoPicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        videoPicker.videoQuality = UIImagePickerControllerQualityTypeMedium; //录像质量
        videoPicker.videoMaximumDuration = 600.0f; //录像最长时间
//        videoPicker.mediaTypes = [NSArray arrayWithObjects:@"public.movie", nil];
        // 设置type和mode，注意先后顺序，mode是可选项
        videoPicker.mediaTypes = @[(NSString *)kUTTypeMovie];
        videoPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
    
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"当前设备不支持录像功能"
                                                       delegate:self
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    [self presentViewController:videoPicker animated:YES completion:nil];
}

// 截屏
- (IBAction)screenShotBtn:(id)sender
{
    UIImage *snapShot = [self captureScreenImg];
    self.screenImageView.image = snapShot;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                                                   message:@"This is an alert."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"cancel"
                                                            style:UIAlertActionStyleDefault
                                                          handler:nil];
    
    // 弹窗提示是否保存到相册
    [alert addAction:defaultAction];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"save"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           // 保存图片到相册
                                                           UIImageWriteToSavedPhotosAlbum(snapShot, nil, nil, nil);
                                                       }];
    
    [alert addAction:saveAction];
    
    // 展示弹窗
    [self presentViewController:alert animated:YES completion:nil];
}

// 自制截屏函数1，截取全屏
- (UIImage *)captureScreenImg
{
    // 判断是否为retina屏, 即retina屏绘图时有放大因子
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        UIGraphicsBeginImageContextWithOptions(self.view.window.bounds.size, NO, [UIScreen mainScreen].scale);
    }
    else
    {
        UIGraphicsBeginImageContext(self.view.window.bounds.size);
    }
    // 渲染到上下文
    [self.view.window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// 自制截屏函数2，可以截取某个view
- (UIImage *)captureImgFromView:(UIView *)view
{
    // 判断是否为retina屏, 即retina屏绘图时有放大因子
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
    {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    }
    else
    {
        UIGraphicsBeginImageContext(view.bounds.size);
    }
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

// 监控系统截屏行为
- (void)userDidTakeScreenshot
{
    NSLog(@"检测到系统截屏");
    
    // 拿到系统截屏的那张图片
    // 方法一，在这里重新做一遍模拟截屏
//    UIImage *image = [self captureScreenImg];
    
    // 方法二，从资源库里拿到最近更新的一张图片，就是这个截图
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    PHAsset *asset = [assetsFetchResults firstObject];
    
    // 使用PHImageManager从PHAsset中请求图片
    PHImageManager *imageManager = [[PHImageManager alloc] init];
    __weak typeof(self) weakSelf = self;
    [imageManager requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if (result) {
            // result 即为查找到的图片,也是此时的截屏图片
            weakSelf.screenImageView.image = result;
        }
    }];
}


#pragma mark - 拍摄完成代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) // public.image
    {
        // 得到照片
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            // 图片存入相册（也可以自定义存储路径到沙盒），可以存储完成回调
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
            // 展示在页面
            self.imageView.image = image;
        }
        
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // 视频存入相册（也可以存入自定义路径），可以存储完成回调
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        UISaveVideoAtPathToSavedPhotosAlbum(videoURL.path, nil, nil, nil) ;
        
    }
    
    // 关闭页面
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

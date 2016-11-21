//
//  ViewController.m
//  CapturePIc
//
//  Created by yxhe on 16/11/21.
//  Copyright © 2016年 tashaxing. All rights reserved.
//
// ---- 相册 拍照 录像 ---- //

#import <MobileCoreServices/MobileCoreServices.h> // 选中媒体类型时候用到
#import "ViewController.h"


@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

// 按钮事件
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

// 拍摄完成代理
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

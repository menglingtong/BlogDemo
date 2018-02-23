//
//  Camera.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/2/17.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "Camera.h"
#import <AVFoundation/AVFoundation.h>

@interface Camera ()<AVCaptureFileOutputRecordingDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMovieFileOutput *movieOutput;
@end

@implementation Camera

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupCamera];
    [self setupUI];
}

- (void)setupCamera
{
    NSError *error = nil;
    
    // 1.1 获取摄像头设备
    AVCaptureDeviceDiscoverySession *deviceSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    NSArray *devicesArray = deviceSession.devices;
    
    if (![devicesArray count]) {
        NSLog(@"获取前置摄像头失败");
        return;
    }
    
    AVCaptureDevice *device = [devicesArray firstObject];
    
    // 1.2 获取麦克风设备
    AVCaptureDeviceDiscoverySession *microphoneSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInMicrophone] mediaType:AVMediaTypeAudio position:AVCaptureDevicePositionUnspecified];
    AVCaptureDevice *microphoneDevice = [[microphoneSession devices] firstObject];
    
    if (![[microphoneSession devices] count]) {
        NSLog(@"获取麦克风失败");
        return;
    }
    
    // 2. 获取session的预设
    NSString *preset = AVCaptureSessionPresetMedium;
    if (![device supportsAVCaptureSessionPreset:preset]) {
        NSLog(@"%@", [NSString stringWithFormat:@"Capture session preset not supported by video device: %@", preset]);
        return;
    }
    
    // 3. 初始化session
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canSetSessionPreset:preset]) {
        self.session.sessionPreset = preset;
    }
    
    // 4.1 初始化设备输入对象，用于获取输入数据 - 视频
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    
    // 4.2 初始化音频设备输入对象，用于获取输入音频 - 音频
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:microphoneDevice error:&error];
    if (error) {
        NSLog(@"取得麦克风输入对象时出错，错误原因：%@", error.localizedDescription);
        return;
    }
    
    // 5. 设置output
    _movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    // 6.1 将视频设备输入添加到会话中
    if ([_session canAddInput:deviceInput]) {
        [_session addInput:deviceInput];
    }
    
    // 6.2 将音频设备输入添加到会话中
    if ([_session canAddInput:audioInput]) {
        [_session addInput:audioInput];
    }
    
    // 7. 将视频输出添加到会话中
    if ([_session canAddOutput:_movieOutput]) {
        [_session addOutput:_movieOutput];
    }
    
    // 8. 创建幕布用于实时展示摄像头获取到的图像
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    previewLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:previewLayer];
    
    // 9. 启动会话
    [_session startRunning];
}

- (void)setupUI
{
    UIButton *shoot = [UIButton buttonWithType:UIButtonTypeCustom];
    shoot.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2.0 - 25, [UIScreen mainScreen].bounds.size.height - 70, 50, 50);
    shoot.layer.cornerRadius = 25;
    shoot.layer.masksToBounds = YES;
    shoot.layer.borderWidth = 2;
    shoot.layer.borderColor = [UIColor colorWithRed:0.81 green:0.13 blue:0.31 alpha:1.00].CGColor;
    shoot.backgroundColor = [UIColor colorWithRed:0.68 green:1.00 blue:0.22 alpha:1.00];
    
    [self.view addSubview:shoot];
    
    [shoot addTarget:self action:@selector(didClickedShootButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didClickedShootButton:(UIButton *)button
{
    if ([_movieOutput isRecording]) {
        [_movieOutput stopRecording];
    } else {
        NSString *outputFielPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"tempComment.mov"];
        NSLog(@"保存地址 :%@",outputFielPath);
        NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];
        
        [self.movieOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
}

// capture output delegate
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections
{
    NSLog(@"did start recording");
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error
{
    NSLog(@"did finish recording");
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

//
//  Camera.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/2/17.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "Camera.h"
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>

@interface Camera ()<AVCaptureFileOutputRecordingDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureSession *session;
// 视频输出
@property (nonatomic, strong) AVCaptureMovieFileOutput *videoOutput;
// Data 输出
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic, strong) EAGLContext *eaglContext;
@property (nonatomic, strong) GLKView *glkPreview;
@property (nonatomic, strong) CIContext *ciContext;

@property (nonatomic, assign) CGRect previewBounds;
@end

@implementation Camera

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupGLKView];
    [self setupCamera];
    [self setupUI];
}

- (void)setupGLKView
{
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    _ciContext = [CIContext contextWithEAGLContext:_eaglContext options:@{kCIContextWorkingColorSpace:[NSNull null]}];
    
    _glkPreview = [[GLKView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT) context:_eaglContext];
    _glkPreview.enableSetNeedsDisplay = YES;
    
    // 由于后置摄像头获取到的图像是UIDeviceOrientationLandscapeLeft，也就是说Home键在右侧，为了保持获得的图片正常展示，我们将幕布进行一次旋转
    _glkPreview.transform = CGAffineTransformMakeRotation(M_PI_2);
    _glkPreview.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
    
    [self.view addSubview:_glkPreview];
    [self.view sendSubviewToBack:_glkPreview];
    [self.glkPreview bindDrawable];
    
    _previewBounds = CGRectZero;
    _previewBounds.size.width = _glkPreview.drawableWidth;
    _previewBounds.size.height = _glkPreview.drawableHeight;
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
    
    // 5.1 将视频设备输入添加到会话中
    if ([_session canAddInput:deviceInput]) {
        [_session addInput:deviceInput];
    }
    
    // 5.2 将音频设备输入添加到会话中
    if ([_session canAddInput:audioInput]) {
        [_session addInput:audioInput];
    }
    
    // 6.1 设置output
    _videoOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    // 6.2 将视频输出添加到会话中
    if ([_session canAddOutput:_videoOutput]) {
        [_session addOutput:_videoOutput];
    }
 
    // 6.3 设置 data output
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    // 如果要使用 CIImage 和 CIFilter 来设置实时滤镜视频输出，需要将输出格式设置成 CIImage 可以使用的 kCVPixelFormatType32BGRA
    _videoDataOutput.videoSettings = @{
                                       (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]
                                       };
    // AVCaptureVideoDataOutput 对象通过代理方法（captureOutput:didOutputSampleBuffer:fromConnection:）来返回视频帧（setSampleBufferDelegate:queue:）方法来设置代理，并需要传入一个串行列队来保证以正确的顺序返回帧。
    [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_queue_create("capture_session_queue", NULL)];
    
    // 设置 alwaysDiscardsLateVideoFrames 属性为 YES, 确保任何延迟的视频帧被丢弃，而不是输出显示。
    _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
    
    if ([_session canAddOutput:_videoDataOutput]) {
        [_session addOutput:_videoDataOutput];
    }
    
    // 7. 创建幕布用于实时展示摄像头获取到的图像
//    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
//    previewLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
//    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//    [self.view.layer addSublayer:previewLayer];
    
    // 8. 启动会话
    [_session startRunning];
}

- (void)setupUI
{
    UIButton *shoot = [UIButton buttonWithType:UIButtonTypeCustom];
    shoot.frame = CGRectMake(SCREENWIDTH / 2.0 - 25, SCREENHEIGHT - 70, 50, 50);
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
    if ([_videoOutput isRecording]) {
        [_videoOutput stopRecording];
    } else {
        NSString *outputFielPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:@"tempComment.mov"];
        NSLog(@"保存地址 :%@",outputFielPath);
        NSURL *fileUrl=[NSURL fileURLWithPath:outputFielPath];

        [self.videoOutput startRecordingToOutputFileURL:fileUrl recordingDelegate:self];
    }
}

#pragma mark - // 6.1 代理 capture output delegate
- (void)captureOutput:(AVCaptureFileOutput *)output didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections
{
    NSLog(@"did start recording");
}

- (void)captureOutput:(AVCaptureFileOutput *)output didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray<AVCaptureConnection *> *)connections error:(NSError *)error
{
    NSLog(@"did finish recording");
}

#pragma mark - // 6.3 代理 AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // 将输出数据转换成 CIImage 类型
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:(CVPixelBufferRef)imageBuffer options:nil];
    
    CGRect sourceExtent = sourceImage.extent;
    
    // Image processing
    CIFilter * vignetteFilter = [CIFilter filterWithName:@"CIVignetteEffect"];
    [vignetteFilter setValue:sourceImage forKey:kCIInputImageKey];
    [vignetteFilter setValue:[CIVector vectorWithX:sourceExtent.size.width/2 Y:sourceExtent.size.height/2] forKey:kCIInputCenterKey];
    [vignetteFilter setValue:@(sourceExtent.size.width/2) forKey:kCIInputRadiusKey];
    CIImage *filteredImage = [vignetteFilter outputImage];
    
    CIFilter *effectFilter = [CIFilter filterWithName:@"CIPhotoEffectInstant"];
    [effectFilter setValue:filteredImage forKey:kCIInputImageKey];
    filteredImage = [effectFilter outputImage];
    
    CGFloat sourceAspect = sourceExtent.size.width / sourceExtent.size.height;
    CGFloat previewAspect = _previewBounds.size.width  / _previewBounds.size.height;
    
    // we want to maintain the aspect radio of the screen size, so we clip the video image
    CGRect drawRect = sourceExtent;
    if (sourceAspect > previewAspect)
    {
        // use full height of the video image, and center crop the width
        drawRect.origin.x += (drawRect.size.width - drawRect.size.height * previewAspect) / 2.0;
        drawRect.size.width = drawRect.size.height * previewAspect;
    } else {
        // use full width of the video image, and center crop the height
        drawRect.origin.y += (drawRect.size.height - drawRect.size.width / previewAspect) / 2.0;
        drawRect.size.height = drawRect.size.width / previewAspect;
    }
    
    [_glkPreview bindDrawable];
    
    if (_eaglContext != [EAGLContext currentContext]) {
        [EAGLContext setCurrentContext:_eaglContext];
    }
    
    if (filteredImage) {
        [_ciContext drawImage:filteredImage inRect:_previewBounds fromRect:drawRect];
    }
    
    [_glkPreview display];
    
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
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

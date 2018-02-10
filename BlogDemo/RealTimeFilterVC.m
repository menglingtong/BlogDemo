//
//  RealTimeFilterVC.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/2/9.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "RealTimeFilterVC.h"
#import <AVFoundation/AVFoundation.h>
#import <GLKit/GLKit.h>

@interface RealTimeFilterVC ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, copy) dispatch_queue_t captureSessionQueue;

//We will use GLKView to render preview. Declare new properties like following:
@property (nonatomic, strong) GLKView *videoPreviewView;
@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) EAGLContext *eaglContext;
@property (nonatomic, assign) CGRect videoPreviewViewBounds;
@end

@implementation RealTimeFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // remove the view's background color; this allows us not to use the opaque property (self.view.opaque = NO) since we remove the background color drawing altogether
    self.view.backgroundColor = [UIColor clearColor];
    [self _setupGLKView];
    [self _setupCamera];
}

- (void)_setupGLKView
{
    // setup the GLKView for video/image preview
    UIView *window = [UIApplication sharedApplication].delegate.window;
    
    _eaglContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _videoPreviewView = [[GLKView alloc] initWithFrame:window.bounds context:_eaglContext];
    _videoPreviewView.enableSetNeedsDisplay = NO;
    
    // because the native video image from the back camera is in UIDeviceOrientationLandscapeLeft (i.e. the home button is on the right), we need to apply a clockwise 90 degree transform so that we can draw the video preview as if we were in a landscape-oriented view; if you're using the front camera and you want to have a mirrored preview (so that the user is seeing themselves in the mirror), you need to apply an additional horizontal flip (by concatenating CGAffineTransformMakeScale(-1.0, 1.0) to the rotation transform)
    
    _videoPreviewView.transform = CGAffineTransformMakeRotation(M_PI_2);
    _videoPreviewView.frame = window.bounds;
    
    // we make our video preview view a subview of the window, and send it to the back; this makes ViewController's view (and its UI elements) on top of the video preview, and also makes video preview unaffected by device rotation
    
    [window addSubview:_videoPreviewView];
    [window sendSubviewToBack:_videoPreviewView];
    
    // bind the frame buffer to get the frame buffer width and height;
    // the bounds used by CIContext when drawing to a GLKView are in pixels (not points),
    // hence the need to read from the frame buffer's width and height;
    // in addition, since we will be accessing the bounds in another queue (_captureSessionQueue),
    // we want to obtain this piece of information so that we won't be
    // accessing _videoPreviewView's properties from another thread/queue
    [_videoPreviewView bindDrawable];
    _videoPreviewViewBounds = CGRectZero;
    _videoPreviewViewBounds.size.width = _videoPreviewView.drawableWidth;
    _videoPreviewViewBounds.size.height = _videoPreviewView.drawableHeight;
}

- (void)_setupCamera
{

//    AVCaptureDeviceDiscoverySession *devicesSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
//
//    NSArray *videoDevices = devicesSession.devices;
//    _videoDevice = [videoDevices firstObject];

    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in videoDevices) {
        if (device.position == AVCaptureDevicePositionBack) {
            _videoDevice = device;
            break;
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_videoDevice error:&error];
    if (!deviceInput)
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Unable to obtain video device input, error: %@", error]);
        return;
    }
    
    // obtain the preset and validate the preset
    NSString *preset = AVCaptureSessionPresetMedium;
    if (![_videoDevice supportsAVCaptureSessionPreset:preset])
    {
        NSLog(@"%@", [NSString stringWithFormat:@"Capture session preset not supported by video device: %@", preset]);
        return;
    }
    
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = preset;
    
// Configure captureSession. Since we will use CIImage and CIFilter to apply filter to video output, we need to change the output format to kCVPixelFormatType32BGRA which can be used by CIImage.
    // CoreImage wants BGRA pixel format
    NSDictionary *outputSettings = @{
                                     (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithInteger:kCVPixelFormatType_32BGRA]
                                     };
    AVCaptureVideoDataOutput *videoOutPutData = [[AVCaptureVideoDataOutput alloc] init];
    videoOutPutData.videoSettings = outputSettings;
    
// AVCaptureVideoDataOutput object vend video frames by delegate(captureOutput:didOutputSampleBuffer:fromConnection:). Set the delegate using setSampleBufferDelegate:queue:. You also need to pass a serial queue to ensure that frames are delivered to the delegate in the proper order.
    
    // create the dispatch queue for handling capture session delegate method calls
    _captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
    [videoOutPutData setSampleBufferDelegate:self queue:_captureSessionQueue];
    
//    Set alwaysDiscardsLateVideoFrames property to YES. This ensures that any late video frames are dropped rather than output to delegate.
    videoOutPutData.alwaysDiscardsLateVideoFrames = YES;
    
//    Add videoDeviceInput and videoDataOutput to _captureSession and start it. The beginConfiguration andcommitConfiguration methods ensure that devices changes occur as a group, minimizing visibility or inconsistency of state.
    
//    begin configure capture session
    [_captureSession beginConfiguration];
    
    if (![_captureSession canAddOutput:videoOutPutData]) {
        NSLog(@"Cannot add video data output");
        _captureSession = nil;
        return;
    }
    
//    connect the video device input and video data and still image outputs
    [_captureSession addInput:deviceInput];
    [_captureSession addOutput:videoOutPutData];
    
    [_captureSession commitConfiguration];
    
//    then start everything
    [_captureSession startRunning];
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

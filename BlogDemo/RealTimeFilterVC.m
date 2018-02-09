//
//  RealTimeFilterVC.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/2/9.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "RealTimeFilterVC.h"
#import <AVFoundation/AVFoundation.h>

@interface RealTimeFilterVC ()
@property (nonatomic, strong) AVCaptureDevice *videoDevice;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, assign) dispatch_queue_t captureSessionQueue;
@end

@implementation RealTimeFilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupCamera];
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

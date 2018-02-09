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
//    if (@available(iOS 10.0, *)) {
//        AVCaptureDeviceDiscoverySession *devicesSession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
//
//        NSArray *videoDevices = devicesSession.devices;
//        _videoDevice = [videoDevices firstObject];
//    } else {
        NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in videoDevices) {
            if (device.position == AVCaptureDevicePositionBack) {
                _videoDevice = device;
                break;
            }
        }
//    }
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

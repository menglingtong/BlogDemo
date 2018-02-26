//
//  LTVideoCapturePipeline.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/2/26.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "LTVideoCapturePipeline.h"

@interface LTVideoCapturePipeline ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_session;
    AVCaptureConnection *_videoConnection;
    dispatch_queue_t _sessionQueue;
    id<LTVideoCapturePipelineDelegate> _delegate;
}

// Because we specify __attribute__((NSObject)) ARC will manage the lifetime of the backing ivars even though they are CF types.
// 因为我们指定了__attribute__((NSObject))，即使它们是CF类型，ARC也会管理后备ivars的生命周期。
@property (nonatomic, strong) __attribute__((NSObject)) CVPixelBufferRef currentPreviewPixelBuffer;
@property (nonatomic, strong) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;

@end

@implementation LTVideoCapturePipeline

- (instancetype)initWithDelegate:(id<LTVideoCapturePipelineDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)startRunning
{
    [self _setupSession];
    if (_session) {
        [_session startRunning];
    }
}

- (void)stopRunning
{
    
}

- (void)startRecord
{
    
}

- (void)stopRecord
{
    
}

- (void)_setupSession
{
    if (_session) {
        return;
    }
    
    _session = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *videoDeviceError = nil;
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc]  initWithDevice:videoDevice error:&videoDeviceError];
    if ([_session canAddInput:videoInput]) {
        [_session addInput:videoInput];
    }
    
    AVCaptureVideoDataOutput *videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    // 如果要使用 CIImage 和 CIFilter 来设置实时滤镜视频输出，需要将输出格式设置成 CIImage 可以使用的 kCVPixelFormatType32BGRA
    videoOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    // AVCaptureVideoDataOutput 对象通过代理方法（captureOutput:didOutputSampleBuffer:fromConnection:）来返回视频帧（setSampleBufferDelegate:queue:）方法来设置代理，并需要传入一个串行列队来保证以正确的顺序返回帧。
    [videoOutput setSampleBufferDelegate:self queue:dispatch_queue_create("capture_session_queue", NULL)];
    // 如果只是预览，设置为 YES, 延迟的帧会被丢弃。
    videoOutput.alwaysDiscardsLateVideoFrames = NO;
    if ([_session canAddOutput:videoOutput]) {
        [_session addOutput:videoOutput];
    }
    
    _session.sessionPreset = AVCaptureSessionPresetHigh;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    if (self.outputVideoFormatDescription == NULL) {
        
        [self _setupVideoPipelineWithInputFormatDescription:formatDescription];
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(capturePipeline:previewPixelBufferReadyForDisplay:)]) {
            [_delegate capturePipeline:self previewPixelBufferReadyForDisplay:pixelBuffer];
        }
    }
}

- (void)_setupVideoPipelineWithInputFormatDescription:(CMFormatDescriptionRef)inputFormatDescription
{
    self.outputVideoFormatDescription = inputFormatDescription;
}

@end

//
//  LTVideoCapturePipeline.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/2/26.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "LTVideoCapturePipeline.h"

#import "LTVideoAssetWriter.h"

typedef NS_ENUM( NSInteger, LTWriterRecordingStatus )
{
    LTWriterRecordingStatusIdle = 0,
    LTWriterRecordingStatusStartingRecording,
    LTWriterRecordingStatusRecording,
    LTWriterRecordingStatusStoppingRecording,
}; // internal state machine

@interface LTVideoCapturePipeline ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_videoDevice;
    AVCaptureConnection *_videoConnection;
    AVCaptureVideoOrientation _videoBufferOrientation;
    dispatch_queue_t _sessionQueue;
    id<LTVideoCapturePipelineDelegate> _delegate;
    
    LTVideoAssetWriter *_assetWriter;
    
    NSURL *_url;
    LTWriterRecordingStatus _recordingStatus;
    NSDictionary *_videoCompressionSettings;
}

// Because we specify __attribute__((NSObject)) ARC will manage the lifetime of the backing ivars even though they are CF types.
// 因为我们指定了__attribute__((NSObject))，即使它们是CF类型，ARC也会管理后备ivars的生命周期。
@property (nonatomic, strong) __attribute__((NSObject)) CVPixelBufferRef currentPreviewPixelBuffer;
@property (nonatomic, strong) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;

@property (atomic) AVCaptureVideoOrientation recordingOrientation;

@end

@implementation LTVideoCapturePipeline

- (instancetype)initWithDelegate:(id<LTVideoCapturePipelineDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
        _recordingOrientation = AVCaptureVideoOrientationPortrait;
        _url = [[NSURL alloc] initFileURLWithPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), @"RealFilter.MOV"]]];
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
    [self stopRecord];
    
    [_session stopRunning];
    
    [self teardownCaptureSession];
}

- (void)startRecord
{
    if (_recordingStatus != LTWriterRecordingStatusIdle) {
        return;
    }
    _recordingStatus = LTWriterRecordingStatusRecording;
    
    _assetWriter = [[LTVideoAssetWriter alloc] initWithUrl:_url];
    
    CGAffineTransform videoTransform = [self transformFromVideoBufferOrientationToOrientation:self.recordingOrientation withAutoMirroring:NO];
    
    [_assetWriter addVideoTrackWithSouceFormatDescription:self.outputVideoFormatDescription transform:videoTransform settings:_videoCompressionSettings];
    
    [_assetWriter prepareToRecord];
}

- (void)stopRecord
{
    if (_recordingStatus != LTWriterRecordingStatusRecording) {
        return;
    }
    _recordingStatus = LTWriterRecordingStatusStoppingRecording;
    [_assetWriter finishRecording];
}

- (void)_setupSession
{
    if (_session) {
        return;
    }
    
    _session = [[AVCaptureSession alloc] init];
    
    _videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *videoDeviceError = nil;
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc]  initWithDevice:_videoDevice error:&videoDeviceError];
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
    _videoCompressionSettings = [[videoOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeQuickTimeMovie] copy];
    _videoBufferOrientation = _videoConnection.videoOrientation;
}

- (void)teardownCaptureSession
{
    if ( _session )
    {
        _session = nil;
        _videoCompressionSettings = nil;
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    if (self.outputVideoFormatDescription == NULL) {
        
        [self _setupVideoPipelineWithInputFormatDescription:formatDescription];
    } else {
        if (_recordingStatus == LTWriterRecordingStatusRecording) {
            [_assetWriter appendVideoPixelBuffer:pixelBuffer withPresentationTime:timestamp];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(capturePipeline:previewPixelBufferReadyForDisplay:)]) {
            [_delegate capturePipeline:self previewPixelBufferReadyForDisplay:pixelBuffer];
        }
    }
}

- (void)_setupVideoPipelineWithInputFormatDescription:(CMFormatDescriptionRef)inputFormatDescription
{
    self.outputVideoFormatDescription = inputFormatDescription;
}

#pragma mark - Utilities
// Auto mirroring: Front camera is mirrored; back camera isn't
- (CGAffineTransform)transformFromVideoBufferOrientationToOrientation:(AVCaptureVideoOrientation)orientation withAutoMirroring:(BOOL)mirror
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    // Calculate offsets from an arbitrary reference orientation (portrait)
    CGFloat orientationAngleOffset = angleOffsetFromPortraitOrientationToOrientation( orientation );
    CGFloat videoOrientationAngleOffset = angleOffsetFromPortraitOrientationToOrientation( _videoBufferOrientation );
    
    // Find the difference in angle between the desired orientation and the video orientation
    CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
    transform = CGAffineTransformMakeRotation( angleOffset );
    
    if ( _videoDevice.position == AVCaptureDevicePositionFront )
    {
        if ( mirror ) {
            transform = CGAffineTransformScale( transform, -1, 1 );
        }
        else {
            if ( UIInterfaceOrientationIsPortrait( (UIInterfaceOrientation)orientation ) ) {
                transform = CGAffineTransformRotate( transform, M_PI );
            }
        }
    }
    
    return transform;
}

static CGFloat angleOffsetFromPortraitOrientationToOrientation(AVCaptureVideoOrientation orientation)
{
    CGFloat angle = 0.0;
    
    switch ( orientation )
    {
        case AVCaptureVideoOrientationPortrait:
            angle = 0.0;
            break;
        case AVCaptureVideoOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case AVCaptureVideoOrientationLandscapeRight:
            angle = -M_PI_2;
            break;
        case AVCaptureVideoOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        default:
            break;
    }
    
    return angle;
}

@end

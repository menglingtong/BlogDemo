//
//  LTVideoAssetWriter.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/2/26.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "LTVideoAssetWriter.h"

#import <AVFoundation/AVAssetWriter.h>
#import <AVFoundation/AVAssetWriterInput.h>

#import <AVFoundation/AVMediaFormat.h>
#import <AVFoundation/AVVideoSettings.h>

@interface LTVideoAssetWriter ()
{
    NSURL *_url;
    AVAssetWriter *_assetWriter;
    BOOL _haveStartedSession;
    
    CMFormatDescriptionRef _videoTrackSourceFormatDescription;
    CGAffineTransform _videoTrackTransform;
    NSDictionary *_videoTrackSettings;
    AVAssetWriterInput *_videoInput;
}

@end

@implementation LTVideoAssetWriter

- (instancetype)initWithUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        _url = url;
        
    }
    return self;
}

- (void)addVideoTrackWithSouceFormatDescription:(CMFormatDescriptionRef)sourceFormatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings
{
    _videoTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain(sourceFormatDescription);
    _videoTrackTransform = transform;
    _videoTrackSettings = videoSettings;
}

- (void)prepareToRecord
{
    NSError *error = nil;
    
    [[NSFileManager defaultManager] removeItemAtURL:_url error:NULL];
    
    _assetWriter = [[AVAssetWriter alloc] initWithURL:_url fileType:AVFileTypeQuickTimeMovie error:&error];
    
    if (!error && _videoTrackSourceFormatDescription) {
        [self setupAssetWriterInputWithSourceFormatDescription:_videoTrackSourceFormatDescription transform:_videoTrackTransform settings:_videoTrackSettings error:&error];
    }
    
    if (!error) {
        BOOL success = [_assetWriter startWriting];
        if (!success) {
            error = _assetWriter.error;
        }
    }
}

- (void)finishRecording
{
    [_assetWriter finishWritingWithCompletionHandler:^{
        
    }];
}

- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
}

- (void)appendVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer withPresentationTime:(CMTime)presentationTime
{
    CMSampleBufferRef sampleBuffer = NULL;
    
    CMSampleTimingInfo timingInfo = {0,};
    timingInfo.duration = kCMTimeInvalid;
    timingInfo.decodeTimeStamp = kCMTimeInvalid;
    timingInfo.presentationTimeStamp = presentationTime;
    
    OSStatus err = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, _videoTrackSourceFormatDescription, &timingInfo, &sampleBuffer);
    
    if (sampleBuffer) {
        [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
    }
}

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType
{
    if (!_haveStartedSession) {
        [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        _haveStartedSession = YES;
    }
    
    if (_videoInput.isReadyForMoreMediaData) {
        if ( ![_videoInput appendSampleBuffer:sampleBuffer] ) {
            
        }
    }
    CFRelease(sampleBuffer);
}

- (BOOL)setupAssetWriterInputWithSourceFormatDescription:(CMFormatDescriptionRef)sourceFormatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings error:(NSError **)error
{
    if ( ! videoSettings )
    {
        // to do
    }
    
    if ([_assetWriter canApplyOutputSettings:videoSettings forMediaType:AVMediaTypeVideo]) {
        _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings sourceFormatHint:sourceFormatDescription];
        _videoInput.transform = transform;
        _videoInput.expectsMediaDataInRealTime = YES;
    }
    
    if ([_assetWriter canAddInput:_videoInput]) {
        [_assetWriter addInput:_videoInput];
    } else {
        return NO;
    }
    return YES;
}

@end

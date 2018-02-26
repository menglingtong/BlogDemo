//
//  LTVideoCapturePipeline.h
//  BlogDemo
//
//  Created by 孟令通 on 2018/2/26.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@protocol LTVideoCapturePipelineDelegate;

@interface LTVideoCapturePipeline : NSObject

- (instancetype)initWithDelegate:(id<LTVideoCapturePipelineDelegate>)delegate;

- (void)startRunning;

@end

@protocol LTVideoCapturePipelineDelegate <NSObject>

- (void)capturePipeline:(LTVideoCapturePipeline *)capturePipeline previewPixelBufferReadyForDisplay:(CVPixelBufferRef)previewPixelBuffer;

@end

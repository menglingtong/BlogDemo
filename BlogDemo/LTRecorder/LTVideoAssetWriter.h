//
//  LTVideoAssetWriter.h
//  BlogDemo
//
//  Created by 孟令通 on 2018/2/26.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreMedia/CMFormatDescription.h>
#import <CoreMedia/CMSampleBuffer.h>

@interface LTVideoAssetWriter : NSObject

- (void)addVideoTrackWithSouceFormatDescription:(CMFormatDescriptionRef)sourceFormatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings;

- (void)prepareToRecord;

@end

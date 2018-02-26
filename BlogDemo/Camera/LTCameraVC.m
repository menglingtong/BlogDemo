//
//  LTCameraVC.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/2/26.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "LTCameraVC.h"

#import "LTVideoCapturePipeline.h"
#import <GLKit/GLKit.h>

@interface LTCameraVC ()<LTVideoCapturePipelineDelegate>

@property (nonatomic, strong) LTVideoCapturePipeline *capture;

@property (nonatomic, strong) EAGLContext *eaglContext;
@property (nonatomic, strong) GLKView *glkPreview;
@property (nonatomic, strong) CIContext *ciContext;

@property (nonatomic, assign) CGRect previewBounds;

@end

@implementation LTCameraVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupGLKView];
    
    self.capture = [[LTVideoCapturePipeline alloc] initWithDelegate:self];
    [_capture startRunning];
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

- (void)capturePipeline:(LTVideoCapturePipeline *)capturePipeline previewPixelBufferReadyForDisplay:(CVPixelBufferRef)previewPixelBuffer
{
    // 将输出数据转换成 CIImage 类型
    CIImage *sourceImage = [CIImage imageWithCVPixelBuffer:previewPixelBuffer options:nil];
    
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

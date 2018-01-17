//
//  OpenGLESRenderVC.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/1/17.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "OpenGLESRenderVC.h"
#import <GLKit/GLKit.h>
@interface OpenGLESRenderVC ()
@property (nonatomic, strong) GLKView *glkView;
@property (nonatomic, strong) CIImage *ciImage;
@property (nonatomic, strong) CIFilter *ciFilter;
@property (nonatomic, strong) CIContext *ciContext;
@end

@implementation OpenGLESRenderVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *demoImg = [UIImage imageNamed:@"FJ"];
    CGRect frame = CGRectMake(20, 90, 365, 210);
    
    // 创建 OpenGLES 渲染的上下文
    EAGLContext *eaGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    // 创建渲染的GL图层
    self.glkView = [[GLKView alloc] initWithFrame:frame context:eaGLContext];
    [self.glkView bindDrawable];
    [self.view addSubview:_glkView];
    // 创建 CoreImage 上下文
    self.ciContext = [CIContext contextWithEAGLContext:eaGLContext options:@{kCIContextWorkingColorSpace:[NSNull null]}];
    // 设置CoreImage
    self.ciImage = [[CIImage alloc] initWithImage:demoImg];
    // 设置滤镜
    self.ciFilter = [CIFilter filterWithName:@"CISepiaTone"];
    [self.ciFilter setValue:_ciImage forKey:kCIInputImageKey];
    [self.ciFilter setValue:@(1) forKey:kCIInputIntensityKey];
    // 开始渲染
    [self.ciContext drawImage:[_ciFilter outputImage] inRect:CGRectMake(0, 0, _glkView.drawableWidth, _glkView.drawableHeight) fromRect:[_ciImage extent]];
    [self.glkView display];
    
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

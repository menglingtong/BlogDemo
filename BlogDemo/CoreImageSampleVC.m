//
//  CoreImageSampleVC.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/1/18.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "CoreImageSampleVC.h"

@interface CoreImageSampleVC ()

@end

@implementation CoreImageSampleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *demoImg = [UIImage imageNamed:@"HS"];
    CGRect frame = CGRectMake(20, 90, 365, 210);
    // 1. 创建一个CIImage
    CIImage *ciImage = [[CIImage alloc] initWithImage:demoImg];
    // 2. 创建一个CIFilter（滤镜）
    CIFilter *ciFilter = [CIFilter filterWithName:@"CICrystallize"];
    [ciFilter setValue:ciImage forKey:kCIInputImageKey];
    NSLog(@"%@", ciFilter.attributes);
    [ciFilter setDefaults];
    
//    [ciFilter setValue:[CIVector vectorWithX:200 Y:200] forKey:kCIInputCenterKey];
//    [ciFilter setValue:@(50) forKey:kCIInputRadiusKey];
//    [ciFilter setValue:@(3.14) forKey:kCIInputAngleKey];
    // 3. 创建绘制上下文CIContext 这里默认CPU渲染
    CIContext *ciContext = [[CIContext alloc] initWithOptions:nil];
    // 创建CGImage句柄
    CGImageRef cgImage = [ciContext createCGImage:[ciFilter outputImage] fromRect:[[ciFilter outputImage] extent]];
    
    UIImageView *demoImgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:cgImage]];
    demoImgView.frame = frame;
    [self.view addSubview:demoImgView];
    // 释放句柄
    CGImageRelease(cgImage);
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

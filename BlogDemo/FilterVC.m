//
//  FilterVC.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/1/13.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "FilterVC.h"

#define kBtnW 80
#define kBtnH 40

@interface FilterVC ()
@property (nonatomic, strong) UIImageView *originalImgView;
@property (nonatomic, strong) UIImageView *filterImgView;
@property (nonatomic, strong) UIImage *img;
/// filter
@property (nonatomic, strong) CIFilter *filter;
/// context
@property (nonatomic, strong) CIContext *context;

@end

@implementation FilterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    AutoAdjust 自动 | Instant 怀旧 | Process 冲印 Chrome 铬黄 | Mono 单色 | Tonal 色调 Fade 褪色 | Noir 黑白 | Transfer 岁月
    self.img = [UIImage imageNamed:@"HS"];
    
    self.originalImgView = [UIImageView new];
    self.originalImgView.frame = CGRectMake(20, 90, 365, 210);
    self.originalImgView.image = _img;
    [self.view addSubview:_originalImgView];
    
    self.filterImgView = [UIImageView new];
    self.filterImgView.frame = CGRectMake(20, 330, 365, 210);
    self.filterImgView.image = _img;
    [self.view addSubview:_filterImgView];
    
    UIButton *filterBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn1 addTarget:self action:@selector(fadeFilter) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn1 setTitle:@"fade" forState:UIControlStateNormal];
    filterBtn1.titleLabel.font = [UIFont systemFontOfSize:14];
    [filterBtn1 setTitleColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00] forState:UIControlStateNormal];
    filterBtn1.frame = CGRectMake(20, 560, kBtnW, kBtnH);
    [self.view addSubview:filterBtn1];
    
    UIButton *filterBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn2 addTarget:self action:@selector(instantFilter) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn2 setTitle:@"instant" forState:UIControlStateNormal];
    filterBtn2.titleLabel.font = [UIFont systemFontOfSize:14];
    [filterBtn2 setTitleColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00] forState:UIControlStateNormal];
    filterBtn2.frame = CGRectMake(80, 560, kBtnW, kBtnH);
    [self.view addSubview:filterBtn2];
    
    UIButton *filterBtn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn3 addTarget:self action:@selector(monoFilter) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn3 setTitle:@"mono" forState:UIControlStateNormal];
    filterBtn3.titleLabel.font = [UIFont systemFontOfSize:14];
    [filterBtn3 setTitleColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00] forState:UIControlStateNormal];
    filterBtn3.frame = CGRectMake(140, 560, kBtnW, kBtnH);
    [self.view addSubview:filterBtn3];
    
    UIButton *filterBtn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn4 addTarget:self action:@selector(noirFilter) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn4 setTitle:@"noir" forState:UIControlStateNormal];
    filterBtn4.titleLabel.font = [UIFont systemFontOfSize:14];
    [filterBtn4 setTitleColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00] forState:UIControlStateNormal];
    filterBtn4.frame = CGRectMake(200, 560, kBtnW, kBtnH);
    [self.view addSubview:filterBtn4];
    
    UIButton *filterBtn5 = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn5 addTarget:self action:@selector(processFilter) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn5 setTitle:@"process" forState:UIControlStateNormal];
    filterBtn5.titleLabel.font = [UIFont systemFontOfSize:14];
    [filterBtn5 setTitleColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00] forState:UIControlStateNormal];
    filterBtn5.frame = CGRectMake(260, 560, kBtnW, kBtnH);
    [self.view addSubview:filterBtn5];
    
    UIButton *filterBtn6 = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn6 addTarget:self action:@selector(tonalFilter) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn6 setTitle:@"tonal" forState:UIControlStateNormal];
    filterBtn6.titleLabel.font = [UIFont systemFontOfSize:14];
    [filterBtn6 setTitleColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00] forState:UIControlStateNormal];
    filterBtn6.frame = CGRectMake(20, 600, kBtnW, kBtnH);
    [self.view addSubview:filterBtn6];
    
    UIButton *filterBtn7 = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn7 addTarget:self action:@selector(transferFilter) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn7 setTitle:@"transfer" forState:UIControlStateNormal];
    filterBtn7.titleLabel.font = [UIFont systemFontOfSize:14];
    [filterBtn7 setTitleColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00] forState:UIControlStateNormal];
    filterBtn7.frame = CGRectMake(80, 600, kBtnW, kBtnH);
    [self.view addSubview:filterBtn7];
    
    UIButton *filterBtn8 = [UIButton buttonWithType:UIButtonTypeCustom];
    [filterBtn8 addTarget:self action:@selector(photoEffectOriginal) forControlEvents:UIControlEventTouchUpInside];
    [filterBtn8 setTitle:@"original" forState:UIControlStateNormal];
    filterBtn8.titleLabel.font = [UIFont systemFontOfSize:14];
    [filterBtn8 setTitleColor:[UIColor colorWithRed:0.20 green:0.20 blue:0.20 alpha:1.00] forState:UIControlStateNormal];
    filterBtn8.frame = CGRectMake(140, 600, kBtnW, kBtnH);
    [self.view addSubview:filterBtn8];
}

- (void)fadeFilter {
    self.filterImgView.image = [self outputImageWithFilterName:@"CIPhotoEffectFade"];
}

- (void)instantFilter {
    self.filterImgView.image = [self outputImageWithFilterName:@"CIPhotoEffectInstant"];
}

- (void)monoFilter {
    self.filterImgView.image = [self outputImageWithFilterName:@"CIPhotoEffectMono"];
}

- (void)noirFilter {
    self.filterImgView.image = [self outputImageWithFilterName:@"CIPhotoEffectNoir"];
}

- (void)processFilter {
    self.filterImgView.image = [self outputImageWithFilterName:@"CIPhotoEffectProcess"];
}

- (void)tonalFilter {
    self.filterImgView.image = [self outputImageWithFilterName:@"CIPhotoEffectTonal"];
}

- (void)transferFilter {
    self.filterImgView.image = [self outputImageWithFilterName:@"CIPhotoEffectTransfer"];
}

- (void)photoEffectOriginal {
    self.filterImgView.image = self.img;
}

#pragma mark - photo effect
/// 传入滤镜名称, 输出处理后的图片
- (UIImage *)outputImageWithFilterName:(NSString *)filterName {
    
    // 1.
    // 将UIImage转换成CIImage
    CIImage *ciImage = [[CIImage alloc] initWithImage:self.img];
    // 创建滤镜
    self.filter = [CIFilter filterWithName:filterName keysAndValues:kCIInputImageKey, ciImage, nil];
    // 已有的值不改变, 其他的设为默认值
    [self.filter setDefaults];
    
    // 2.
    // 渲染并输出CIImage
    CIImage *outputImage = [self.filter outputImage];
    
    // 3.
    // 获取绘制上下文
    self.context = [CIContext contextWithOptions:nil];
    // 创建CGImage句柄
    CGImageRef cgImage = [self.context createCGImage:outputImage fromRect:[outputImage extent]];
    // 获取图片
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    // 释放CGImage句柄
    CGImageRelease(cgImage);
    
    return image;
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

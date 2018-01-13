//
//  ShadeVC.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/1/12.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "ShadeVC.h"
#import "ShadeLabel.h"

@interface ShadeVC ()

@end

@implementation ShadeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *demoLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 100, 350, 180)];
    demoLabel.text = @"曾经有一份真挚的感情放在我的面前，我没有好好的珍惜，等到失去后，我才后悔莫急！人世间最痛苦的事莫过于此。如果老天能再给我一次机会的话，我会对那女孩说三个字：“我爱你！”如果非要加上一个期限的话，我希望是一万年！ ";
    demoLabel.font = [UIFont systemFontOfSize:20];
    demoLabel.numberOfLines = 0;
    demoLabel.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shade"]];
    [self.view addSubview:demoLabel];
    
    UILabel *demoLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(40, 280, 350, 180)];
    demoLabel2.text = @"Long long ago, there was a sincer cordial emotion in front of me, but I didn't cherish it. Until it lost, I just regreted at that time. It is only the most suffering thing in the world. If the grandfather of heaven give me the last opportunity. I will say three words to that girl:'I love you!' If it has to add an alloted time. I hope it is 10,000 years. ";
    demoLabel2.font = [UIFont systemFontOfSize:20];
    demoLabel2.numberOfLines = 0;
    demoLabel2.textColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shade"]];
    [self.view addSubview:demoLabel2];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(id)[UIColor redColor].CGColor, (id)[UIColor colorWithRed:0.29 green:0.95 blue:0.63 alpha:1.00].CGColor, (id)[UIColor colorWithRed:1.00 green:0.89 blue:0.18 alpha:1.00].CGColor, (id)[UIColor colorWithRed:0.81 green:0.13 blue:0.31 alpha:1.00].CGColor];
    //gradientLayer.locations = @[@0, @0.5, @1];// 默认就是均匀分布
    gradientLayer.startPoint = CGPointMake(0, 0.5);
    gradientLayer.endPoint = CGPointMake(1, 0.5);
    gradientLayer.frame = demoLabel2.frame;
    gradientLayer.mask = demoLabel2.layer;
    demoLabel2.layer.frame = gradientLayer.bounds;
    [self.view.layer addSublayer:gradientLayer];
    
    ShadeLabel *label = [[ShadeLabel alloc] initWithFrame:CGRectMake(40, 500, 350, 180)];
    [self.view addSubview:label];
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

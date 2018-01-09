//
//  UIFontVC.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/1/9.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "UIFontVC.h"

@interface UIFontVC ()

@end

@implementation UIFontVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *demoLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 100, 150, 80)];
    demoLabel.text = @"HIPPOP";
    [self.view addSubview:demoLabel];
    
//    demoLabel.font = [UIFont systemFontOfSize:40];
//    demoLabel.font = [UIFont systemFontOfSize:20 weight:700];
//    demoLabel.font = [UIFont boldSystemFontOfSize:20];
//    demoLabel.font = [UIFont italicSystemFontOfSize:20];
    demoLabel.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:20];
    
    NSArray *familyNames = [UIFont familyNames];
    for (NSString *familyName in familyNames)
    {
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        for (NSString *fontName in fontNames)
        {
            printf("\tFont: %s \n", [fontName UTF8String]);
        }
    }
    
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

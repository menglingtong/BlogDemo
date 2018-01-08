//
//  ViewController.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/1/6.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *str = @"这句话就是对这个类的一个最简明扼要的概括。NSAttributedString管理一个字符串，以及与该字符串中的单个字符或某些范围的字符串相关的属性。它有一个子类NSMutableAttributedString。具体实现时，NSAttributedString维护了一个NSString，用来保存最原始的字符串，另有一个NSDictionary用来保存各个子串/字符的属性。";
    
    UILabel *attributeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 100, 330, 300)];
    attributeLabel.numberOfLines = 0;
    attributeLabel.layer.borderColor = [UIColor grayColor].CGColor;
    attributeLabel.layer.borderWidth = 0.5;
    attributeLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:attributeLabel];
    
    // 1. NSFontAttributeName
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:str];
//    NSRange range = [str rangeOfString:@"这"];
//    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:range];
//    [attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Courier-BoldOblique" size:17.0] range:NSMakeRange(20, 10)];
//    attributeLabel.attributedText = attrString;
    
    // 2. NSParagraphStyleAttributeName
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.firstLineHeadIndent = 30;
    style.lineSpacing = 10;
    style.lineBreakMode = NSLineBreakByWordWrapping;
    
    [attrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length)];
    
    // 3. NSForegroundColorAttributeName
    [attrString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.90 green:0.44 blue:0.38 alpha:1.00] range:NSMakeRange(0, str.length)];
    
    // 4. NSBackgroundColorAttributeName
    [attrString addAttribute:NSBackgroundColorAttributeName value:[UIColor colorWithRed:0.53 green:0.77 blue:0.48 alpha:1.00] range:NSMakeRange(0, str.length)];
    
    // 5. NSLigatureAttributeName
    
    // 6. NSKernAttributeName
    [attrString addAttribute:NSKernAttributeName value:@3 range:NSMakeRange(0, str.length)];
    
    // 7. NSStrikethroughStyleAttributeName
    [attrString addAttribute:NSStrikethroughStyleAttributeName value:@1 range:NSMakeRange(22, 10)];
    
    // 8. NSStrikethroughColorAttributeName
    [attrString addAttribute:NSStrikethroughColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(24, 6)];
    
    // 9. NSUnderlineStyleAttributeName
    [attrString addAttribute:NSUnderlineStyleAttributeName value:@3 range:NSMakeRange(33, 10)];
    
    // 10. NSUnderlineColorAttributeName
    [attrString addAttribute:NSUnderlineColorAttributeName value:[UIColor colorWithRed:1.00 green:0.30 blue:0.00 alpha:1.00] range:NSMakeRange(36, 4)];
    
    // 11. NSStrokeWidthAttributeName
    [attrString addAttribute:NSStrokeWidthAttributeName value:@10 range:NSMakeRange(40, 6)];
    
    // 12. NSStrokeColorAttributeName
    [attrString addAttribute:NSStrokeColorAttributeName value:[UIColor colorWithRed:1.00 green:0.89 blue:0.18 alpha:1.00] range:NSMakeRange(40, 6)];
    
    // 13. NSShadowAttributeName
//    NSShadow *shadow = [[NSShadow alloc]init];
//    shadow.shadowOffset = CGSizeMake(10, 10);
//    shadow.shadowColor = [UIColor redColor];
//    [attrString addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, str.length)];
    
    // 14.NSTextEffectAttributeName
//    [attrString addAttribute:NSTextEffectAttributeName value:NSTextEffectLetterpressStyle range:NSMakeRange(50, 10)];
    
    // 15.NSBaselineOffsetAttributeName
//    [attrString addAttribute:NSBaselineOffsetAttributeName value:@1 range:NSMakeRange(10, 10)];
    // 16. NSObliquenessAttributeName
//    [attrString addAttribute:NSObliquenessAttributeName value:@0.5 range:NSMakeRange(10, 20)];
    // 17. NSExpansionAttributeName
    [attrString addAttribute:NSExpansionAttributeName value:@1.0 range:NSMakeRange(10, 10)];
    
    attributeLabel.attributedText = attrString;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

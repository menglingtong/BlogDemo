//
//  ViewController.m
//  BlogDemo
//
//  Created by 孟令通 on 2018/1/6.
//  Copyright © 2018年 LryMlt. All rights reserved.
//

#import "ViewController.h"

#import "NSDictionary+Additions.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 44) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
    [self.view addSubview:_tableView];
    [self getDataSourceArray];
    
    NSDictionary *dic = @{@"WX": @"mlt296634507", @"Name": @"MLT", @"Age": @(18), @"Base": @"yyy", @"Json": @"qqqq", @"Gender": @"mail"};
    
    NSString *str = [dic serializationSortedByKey];
    
    NSLog(@"%@", str);
    
}

- (void)getDataSourceArray
{
    self.dataSource = [NSMutableArray new];
    
    [self.dataSource addObject:@"NSAttributedStringVC"];
    [self.dataSource addObject:@"UIFontVC"];
    [self.dataSource addObject:@"ShadeVC"];
    [self.dataSource addObject:@"CoreImageSampleVC"];
    [self.dataSource addObject:@"FilterVC"];
    [self.dataSource addObject:@"OpenGLESRenderVC"];
    [self.dataSource addObject:@"RealTimeFilterVC"];
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])];
    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *str = [self.dataSource objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:[NSClassFromString(str) new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

//
//  CustomController.m
//  RMNestScrollview
//
//  Created by RMNestViewKit on 2018/1/9.
//  Copyright © 2018年 RMNestViewKit. All rights reserved.
//

#import "CustomController.h"
#import "TestViewController.h"

@interface CustomController ()

@end

@implementation CustomController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshHandle {
    NSLog(@"开始刷新");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = [NSString stringWithFormat:@"%@cellId", NSStringFromClass(self.class)];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.backgroundColor = [UIColor colorWithWhite:0.998 alpha:1];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[[TestViewController alloc] init] animated:YES];
//    [self endRefreshing];
}

@end

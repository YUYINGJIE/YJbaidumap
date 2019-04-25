//
//  YJBaiduMapListVC.m
//  baidumap
//
//  Created by 于英杰 on 2019/4/22.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJBaiduMapListVC.h"
#import "YJBaseMapVC.h"
#import "YJBaidumapCircleVC.h"
#import "YJBaiduSearchVC.h"
#import "YJLocationVC.h"
#import "YJSearch.h"


@interface YJBaiduMapListVC ()<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView *tableView;
@property (copy, nonatomic) NSArray *titles;

@end

@implementation YJBaiduMapListVC

- (void)viewDidLoad {
    [super viewDidLoad];


    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = BMKMapVersion;
    self.titles=@[@"基础图",@"自定义精度圈",@"百度搜索",@"搜索"];
    [self.view addSubview:self.tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titles.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString*cellID = @"CellID";
    UITableViewCell*cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell==nil) {
        cell= [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    cell.textLabel.text=self.titles[indexPath.row];
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        YJBaseMapVC *BaseMapVC = [[YJBaseMapVC alloc]init];
        [self.navigationController pushViewController:BaseMapVC animated:YES];
    }
    else if(indexPath.row==1){
      
        YJBaidumapCircleVC *CircleVC = [[YJBaidumapCircleVC alloc]init];
        [self.navigationController pushViewController:CircleVC animated:YES];
    }
    else if (indexPath.row==2){
        YJBaiduSearchVC * BaiduSearchVC = [[YJBaiduSearchVC alloc]init];
        [self.navigationController pushViewController:BaiduSearchVC animated:YES];
    }
    
    else if (indexPath.row==3){
        YJSearch * Search = [[YJSearch alloc]init];
        [self.navigationController pushViewController:Search animated:YES];
    }
    
}


#pragma mark - Lazy loading
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kViewTopHeight, KScreenWidth, KScreenHeight-kViewTopHeight) style:UITableViewStylePlain];
        _tableView.tableFooterView=[UIView new];
    }
    return _tableView;
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

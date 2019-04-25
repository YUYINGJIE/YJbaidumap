//
//  YJResultVC.m
//  baidumap
//
//  Created by 于英杰 on 2019/4/24.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJResultVC.h"
#import "YJTipCell.h"
#import "YJLocationVC.h"


@interface YJResultVC ()<UITableViewDelegate, UITableViewDataSource,BMKPoiSearchDelegate>
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation YJResultVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 控制器嵌套存在一定的偏移
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"resultCell"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([YJTipCell class]) bundle:nil] forCellReuseIdentifier:@"TipCell"];
    
}

-(void)setCity:(NSString *)city{
    _city =city;
}
-(void)setLocation:(CLLocation *)location{
    
    _location = location;
}
- (NSMutableArray *)results {
    if (_results == nil) {
        _results = [NSMutableArray arrayWithCapacity:0];
    }
    return _results;
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return  self.results.count > 0 ? self.results.count : 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.results.count>0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"resultCell" forIndexPath:indexPath];
        BMKPoiInfo *info = self.results[indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",info.name];
        cell.detailTextLabel.text =[NSString stringWithFormat:@"%@",info.address];
        return cell;
    }
    else{
        YJTipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TipCell" forIndexPath:indexPath];
        self.tableView.separatorStyle= UITableViewCellSeparatorStyleNone;
        cell.typeBlock = ^(NSInteger type) {
            switch (type) {
                case 0:
                    [self DriveNav];
                    break;
                case 1:
                    [self LocationSearch];
                    break;
                case 2:
                    [self LocationPOINearbySearch];
                    break;
                case 3:
                    [self WalkingRoute];
                    break;
                default:
                    break;
            }
        };
        return cell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BMKPoiInfo *info = self.results[indexPath.row];
    [self openBaiduMapNavigation:info];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.results.count > 0 ? 44 : 200;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    searchController.searchResultsController.view.hidden = NO;
    NSString *inputStr = searchController.searchBar.text;
    
    [self.results removeAllObjects];
    [self.tableView reloadData];
    if (inputStr.length>0) {
        [self searchData:inputStr];
    }
    
    
//    if (self.results.count > 0) {
//        [self.results removeAllObjects];
//    }
//    for (NSString *str in self.datas) {
//
//        if ([str.lowercaseString rangeOfString:inputStr.lowercaseString].location != NSNotFound) {
//
//            [self.results addObject:str];
//        }
//    }
//
//    [self.tableView reloadData];
}

- (void)searchData:(NSString *)keyword {
    //初始化BMKPoiSearch实例
    BMKPoiSearch *POISearch = [[BMKPoiSearch alloc] init];
    //设置POI检索的代理
    POISearch.delegate = self;
    //初始化请求参数类BMKCitySearchOption的实例
    BMKPOICitySearchOption *cityOption = [[BMKPOICitySearchOption alloc]init];
    //检索关键字，必选。举例：天安门
    cityOption.keyword = keyword;
    //区域名称(市或区的名字，如北京市，海淀区)，最长不超过25个字符，必选
    cityOption.city = self.city;
    cityOption.pageIndex = 0;
    //单次召回POI数量，默认为10条记录，最大返回20条
    cityOption.pageSize = 20;
    /**
     城市POI检索：异步方法，返回结果在BMKPoiSearchDelegate的onGetPoiResult里
     cityOption 城市内搜索的搜索参数类（BMKCitySearchOption）
     成功返回YES，否则返回NO
     */
    BOOL flag = [POISearch poiSearchInCity:cityOption];
    if(flag) {
        NSLog(@"POI城市内检索成功");
    } else {
        NSLog(@"POI城市内检索失败");
    }
}

-(void)WalkingRoute{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"取消搜索点击列表即可绘制路线" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:openAction];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)DriveNav{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"先搜索点击列表即可导航" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:openAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - <btnClick>
// 定位反编译结果集
-(void)LocationSearch{
    
    YJLocationVC * LocationVC = [[YJLocationVC alloc]init];
    LocationVC.typr=1;
    [self.nav pushViewController:LocationVC animated:YES];
    
    
}
// 周边区域搜索 加有搜索范围
-(void)LocationPOINearbySearch{
    
    YJLocationVC * LocationVC = [[YJLocationVC alloc]init];
    LocationVC.typr=2;
    [self.nav pushViewController:LocationVC animated:YES];
    
    
}

#pragma mark - BaiduMapNavigation
- (void)openBaiduMapNavigation:(BMKPoiInfo*)PoiInfo {
    //初始化调启导航时的参数管理类
    BMKNaviPara *para = [[BMKNaviPara alloc]init];
    //实例化线路检索节点信息类对象
    BMKPlanNode *start = [[BMKPlanNode alloc]init];
    //指定起点经纬度
    start.pt = self.location.coordinate;
    //指定起点名称
    start.name = @"我的位置";
    //所在城市ID
    start.cityID = 0;
    //所在城市
    start.cityName = @"";
    //指定起点
    para.startPoint = start;
    //实例化线路检索节点信息类对象
    BMKPlanNode *end = [[BMKPlanNode alloc]init];
    //指定终点经纬度
    end.pt = PoiInfo.pt;
    //指定终点名称
    end.name = PoiInfo.name;
    //指定终点
    para.endPoint = end;
    //指定返回自定义scheme
    para.appScheme = @"baidumapsdk://mapsdk.baidu.com";
    //应用名称
    para.appName = @"baidumap";
    //调起百度地图客户端驾车导航失败后，是否支持调起web地图，默认：YES（步行、骑行导航设置该参数无效）
    para.isSupportWeb = YES;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"打开百度地图客户端" message:@"百度地图-驾车导航" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        /**
         调起百度地图客户端驾车导航界面
         
         @param para 调起驾车导航时传入的参数
         @return 结果状态码
         */
        [BMKNavigation openBaiduMapNavigation:para];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:openAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - <UIScrollViewDelegate>

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPOISearchResult *)poiResult errorCode:(BMKSearchErrorCode)error {
    
    //------------------------------------------周边搜索
    [self.results removeAllObjects];
    [self.results addObjectsFromArray:poiResult.poiInfoList];
    [self.tableView reloadData];
    
}

#pragma mark - <laz>
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-kViewTopHeight-6) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView= [UIView new];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;//UIScrollView也适用
            _tableView.estimatedRowHeight = 0;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
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

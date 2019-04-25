//
//  YJSearch.m
//  baidumap
//
//  Created by 于英杰 on 2019/4/24.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJSearch.h"
#import "YJResultVC.h"
#import "YJWalkingRouteVC.h"


@interface YJSearch ()<UITableViewDelegate, UITableViewDataSource,UISearchControllerDelegate,UISearchBarDelegate,BMKGeoCodeSearchDelegate,BMKLocationManagerDelegate>
@property (nonatomic, strong) YJResultVC *ResultVC;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *datas;
@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象
@property(nonatomic,copy)NSString*city;
@property(nonatomic,copy)NSString*startcityname;
@property(nonatomic,copy)NSString*startname;

@end

@implementation YJSearch

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.tableView];
    self.ResultVC = [[YJResultVC alloc]init];
    //创建搜索框控制器
    UISearchController *search = [[UISearchController alloc]initWithSearchResultsController:self.ResultVC];
    search.searchBar.barTintColor = [UIColor groupTableViewBackgroundColor];
    [search.searchBar sizeToFit];
    search.delegate=self;
    search.searchBar.delegate = self;

    //包着搜索框外层的颜色
    search.searchBar.tintColor = [UIColor colorWithRed:22.0/255 green:161.0/255 blue:1.0/255 alpha:1];
    search.dimsBackgroundDuringPresentation = NO;
    search.searchResultsUpdater = self.ResultVC;
    search.searchBar.placeholder = @"请输入要搜索的关键字";
    self.ResultVC.searchBar = search.searchBar;
    self.searchController=search;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.ResultVC.datas = [self.datas copy];
    self.ResultVC.nav = self.navigationController;
    
//    if (@available(iOS 11.0, *)) {
//        self.navigationItem.searchController = self.searchController;
//    } else {
//        self.tableView.tableHeaderView = self.searchController.searchBar;
//    }
    // 创建用于展示搜索结果的控制器
    //开启定位服务
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    }
    
    BMKPoiInfo *info = self.datas[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",info.name];
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@",info.address];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BMKPoiInfo *endinfo = self.datas[indexPath.row];
    BMKPoiInfo *startinfo = [self.datas firstObject];

    YJWalkingRouteVC * WalkingRouteVC = [[YJWalkingRouteVC alloc]init];
    WalkingRouteVC.startcityid=self.city;
    WalkingRouteVC.startname=startinfo.name;
    WalkingRouteVC.startpt=startinfo.pt;

    WalkingRouteVC.endcityid=self.city;
    WalkingRouteVC.endname=endinfo.name;
    WalkingRouteVC.endpt=endinfo.pt;

    [self.navigationController pushViewController:WalkingRouteVC animated:YES];
    
}
#pragma mark - BMKLocationManagerDelegate
/**当定位发生错误时*/
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"定位失败");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提醒" message:@"定位失败" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}
/**方向*/
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    if (!heading) {
        return;
    }
    NSLog(@"用户方向更新");
}

/**位置*/
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (!location) {
        return;
    }
    self.ResultVC.location = location.location;
    [self ReverseGeoCode:location.location];
    
}
#pragma mark - <反编译>
-(void)ReverseGeoCode:(CLLocation*)location{
    
    //初始化请求参数类BMKReverseGeoCodeOption的实例
    BMKReverseGeoCodeSearchOption *reverseGeoCodeOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    //经纬度
    reverseGeoCodeOption.location = location.coordinate;
    //是否访问最新版行政区划数据（仅对中国数据生效）
    reverseGeoCodeOption.isLatestAdmin = YES;
    [self ReversesearchData:reverseGeoCodeOption];
    
}

- (void)ReversesearchData:(BMKReverseGeoCodeSearchOption *)option {
    //初始化BMKGeoCodeSearch实例
    BMKGeoCodeSearch *geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
    //设置反地理编码检索的代理
    geoCodeSearch.delegate = self;
    //初始化请求参数类BMKReverseGeoCodeOption的实例
    BMKReverseGeoCodeSearchOption *reverseGeoCodeOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    // 待解析的经纬度坐标（必选）
    reverseGeoCodeOption.location = option.location;
    //是否访问最新版行政区划数据（仅对中国数据生效）
    reverseGeoCodeOption.isLatestAdmin = option.isLatestAdmin;
    /**
     根据地理坐标获取地址信息：异步方法，返回结果在BMKGeoCodeSearchDelegate的
     onGetAddrResult里
     reverseGeoCodeOption 反geo检索信息类
     成功返回YES，否则返回NO
     */
    BOOL flag = [geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
    if (flag) {
        NSLog(@"反地理编码检索成功");
    } else {
        NSLog(@"反地理编码检索失败");
    }
}
#pragma mark - <BMKGeoCodeSearchDelegate>
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    if (result.poiList.count!=0) {
        self.city =[NSString stringWithFormat:@"%@",result.cityCode];
        [self.datas removeAllObjects];
        [self.datas addObjectsFromArray:result.poiList];
        [self.tableView reloadData];
        self.ResultVC.city = self.city;
        
    }
    
    else{
        self.city = @"北京";
        self.ResultVC.city = self.city;
    }
    
}
- (NSMutableArray *)datas {
    if (_datas == nil) {
        _datas = [NSMutableArray arrayWithCapacity:0];
    }
    return _datas;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kViewTopHeight, KScreenWidth, KScreenHeight-kViewTopHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView= [UIView new];
    }
    
    return _tableView;
}
#pragma mark - Lazy loading
- (BMKLocationManager *)locationManager {
    if (!_locationManager) {
        //初始化BMKLocationManager类的实例
        _locationManager = [[BMKLocationManager alloc] init];
        _locationManager.delegate =self;
        //设定定位坐标系类型，默认为 BMKLocationCoordinateTypeGCJ02
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        //设定定位精度，可自定义 默认为 kCLLocationAccuracyBest
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        ///设定定位的最小更新距离 默认为 kCLDistanceFilterNone。
        _locationManager.distanceFilter=1000;
        //设定定位类型，默认为 CLActivityTypeAutomotiveNavigation
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //定位是否会被系统自动暂停
        _locationManager.allowsBackgroundLocationUpdates = YES;
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        _locationManager.allowsBackgroundLocationUpdates = NO;
        _locationManager.locationTimeout = 10;
    }
    return _locationManager;
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

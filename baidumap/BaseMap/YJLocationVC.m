//
//  YJLocationVC.m
//  baidumap
//
//  Created by 于英杰 on 2019/4/24.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJLocationVC.h"

@interface YJLocationVC ()<BMKLocationManagerDelegate,UITableViewDelegate, UITableViewDataSource,BMKMapViewDelegate,BMKGeoCodeSearchDelegate,BMKPoiSearchDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象
@property (nonatomic, strong) BMKMapView *midnightMapView;
@property (nonatomic, strong) BMKUserLocation *userLocation; //当前位置对象
@property (nonatomic, strong) NSMutableArray *aressArray;

//如果需要展示搜索的范围 才会用到
@property (nonatomic, strong) BMKCircle *circle; //当前界面的圆

@end

@implementation YJLocationVC
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    //设置midnightMapView的代理
    _midnightMapView.delegate = self;
    //当midnightMapView即将被显示的时候调用，恢复之前存储的midnightMapView状态
    [_midnightMapView viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:NO];
    //当midnightMapView即将被隐藏的时候调用，存储当前midnightMapView的状态
    [_midnightMapView viewWillDisappear];
    //关闭个性化地图
    [BMKMapView enableCustomMapStyle:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];

    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.aressArray=[NSMutableArray array];
    [self createMapView];
    [self.view addSubview:self.tableView];
    
}

-(void)createMapView{
    
    //将midnightMapView添加到当前视图中
    [self.view addSubview:self.midnightMapView];
    //开启个性化地图
    [BMKMapView enableCustomMapStyle:YES];
    //开启定位服务
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    //显示定位图层
    _midnightMapView.showsUserLocation = YES;
}

#pragma mark - <UITableView代理>
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.aressArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    }
    BMKPoiInfo *info = self.aressArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",info.name];
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@",info.address];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
}

#pragma mark - BMKLocationManagerDelegate
/**当定位发生错误时*/
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"定位失败");
}
/**方向*/
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    if (!heading) {
        return;
    }
    NSLog(@"用户方向更新");
    self.userLocation.heading = heading;
    [self.midnightMapView updateLocationData:self.userLocation];
}

/**位置*/
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (!location) {
        return;
    }
    self.userLocation.location = location.location;
    //实现该方法，否则定位图标不出现
    [self.midnightMapView updateLocationData:self.userLocation];
    
    if (self.typr==1) {
        //反编译
        [self ReverseGeoCode:self.userLocation.location];
    }
    else if (self.typr==2){
        [self POINearby:self.userLocation.location];
    }

}

#pragma mark - <周边搜索>

-(void)POINearby:(CLLocation*)location{
    
    BMKPoiSearch *POISearch = [[BMKPoiSearch alloc] init];
    POISearch.delegate = self;
    //初始化请求参数类BMKNearbySearchOption的实例
    BMKPOINearbySearchOption *nearbyOption = [[BMKPOINearbySearchOption alloc]init];
    nearbyOption.keywords = @[@"酒店,医院"];
    //检索中心点的经纬度，必选
    nearbyOption.location = CLLocationCoordinate2DMake(location.coordinate.latitude,location.coordinate.longitude);
    /**
     检索半径，单位是米。
     当半径过大，超过中心点所在城市边界时，会变为城市范围检索，检索范围为中心点所在城市
     */
    nearbyOption.radius = 5000;
    /**
     是否严格限定召回结果在设置检索半径范围内。默认值为false。
     值为true代表检索结果严格限定在半径范围内；值为false时不严格限定。
     注意：值为true时会影响返回结果中total准确性及每页召回poi数量，我们会逐步解决此类问题。
     */
    nearbyOption.isRadiusLimit = YES;

    BOOL flag = [POISearch poiSearchNearBy:nearbyOption];
    if(flag) {
        NSLog(@"POI周边检索成功");
    } else {
        NSLog(@"POI周边检索失败");
    }
    
    self.circle.coordinate=location.coordinate;
    self.circle.radius =nearbyOption.radius;

    
    
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
/**
 反向地理编码检索结果回调
 @param searcher 检索对象
 @param result 反向地理编码检索结果
 @param error 错误码，@see BMKCloudErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (result.poiList.count!=0) {
        [self.aressArray removeAllObjects];
        BMKPoiInfo *POIInfo = result.poiList.firstObject;
        [self.aressArray addObjectsFromArray:result.poiList];
        [self.tableView reloadData];
    }
}

#pragma mark - <BMKPoiSearchDelegate>

- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPOISearchResult *)poiResult errorCode:(BMKSearchErrorCode)error {
  

    if (error == BMK_SEARCH_NO_ERROR) {
        
        [_midnightMapView removeAnnotations:_midnightMapView.annotations];
        NSMutableArray *annotations = [NSMutableArray array];
        for (BMKPoiInfo *POIInfo in poiResult.poiInfoList) {
           
            //初始化标注类BMKPointAnnotation的实例
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc]init];
            //设置标注的经纬度坐标
            annotation.coordinate = POIInfo.pt;
            //设置标注的标题
            annotation.title = POIInfo.name;
            [annotations addObject:annotation];
        }
        //将一组标注添加到当前地图View中
        [_midnightMapView addAnnotations:annotations];
        [self.aressArray addObjectsFromArray:poiResult.poiInfoList];
        [self.tableView reloadData];
    }
}

- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKCircle class]]) {
        //初始化一个overlay并返回相应的BMKCircleView的实例
        BMKCircleView *circleView = [[BMKCircleView alloc] initWithCircle:overlay];
        //设置circleView的填充色
       // circleView.fillColor = [[UIColor alloc] initWithRed:1 green:0 blue:0 alpha:0.5];
        //设置circleView的画笔（边框）颜色
        circleView.strokeColor = [[UIColor alloc] initWithRed:0 green:0 blue:1 alpha:0.5];
        //设置circleView的轮廓宽度
        circleView.lineWidth = 1.0;
        return circleView;
    }
    return nil;
}

//- (void)searchData:(CLLocation *)Location {
//
//    // 周边搜索
//    //初始化BMKPoiSearch实例
//    BMKPoiSearch *POISearch = [[BMKPoiSearch alloc] init];
//    //设置POI检索的代理
//    POISearch.delegate = self;
//    //初始化请求参数类BMKNearbySearchOption的实例
//    BMKPOINearbySearchOption *nearbyOption = [[BMKPOINearbySearchOption alloc]init];
//
//
//
//}



#pragma mark - <laz>
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.midnightMapView.bottom, KScreenWidth, KScreenHeight-self.midnightMapView.bottom) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    
    return _tableView;
}
- (BMKMapView *)midnightMapView {
    if (!_midnightMapView) {
        
        _midnightMapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, kViewTopHeight, KScreenWidth, 300)];
        _midnightMapView.mapType=BMKMapTypeStandard;
//        //设置地图比例尺级别
        _midnightMapView.zoomLevel = 13;
//        //设置定位模式为定位跟随模式
        _midnightMapView.userTrackingMode = BMKUserTrackingModeFollow;
        _midnightMapView.gesturesEnabled=YES;
        [_midnightMapView addOverlay:self.circle];

    }
    return _midnightMapView;
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
       _locationManager.distanceFilter=10;
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

- (BMKUserLocation *)userLocation {
    if (!_userLocation) {
        //初始化BMKUserLocation类的实例
        _userLocation = [[BMKUserLocation alloc] init];
    }
    return _userLocation;
}

- (BMKCircle *)circle {
    if (!_circle) {
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(0, 0);
        /**
         根据中心点和半径生成圆
         @param coord 中心点的经纬度坐标
         @param radius 半径，单位：米
         @return 新生成的BMKCircle实例
         */
        _circle = [BMKCircle circleWithCenterCoordinate:coor radius:0];
    }
    return _circle;
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

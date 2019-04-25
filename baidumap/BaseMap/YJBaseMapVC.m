//
//  YJBaseMapVC.m
//  baidumap
//
//  Created by 于英杰 on 2019/4/22.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJBaseMapVC.h"

@interface YJBaseMapVC ()<BMKMapViewDelegate,BMKLocationManagerDelegate>
@property (nonatomic, strong) BMKMapView *midnightMapView; //午夜蓝个性化地图
@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象
@property (nonatomic, strong) BMKUserLocation *userLocation; //当前位置对象


@end

@implementation YJBaseMapVC

+ (void)initialize {
    //获取个性化地图模板文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:@"custom_config_蓑烟雨" ofType:@""];
    //设置个性化地图样式
    [BMKMapView customMapStyle:path];
 //   [BMKMapView enableCustomMapStyle:YES];//是否开启个性化地图样式
}

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

    [self configUI];
    // 创建mapview
    [self createMapView];


}
- (void)configUI {

    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"个性化地图";
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


- (void)alertMessage:(NSString *)message {
    NSAssert(message && message.length > 0, @"提示信息不能为空");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"事件描述" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}
/**
 点击地图标注会回调此方法
 
 @param mapView 地图View
 @param mapPoi 返回点击地图地图坐标点的经纬度
 */
- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSString *message = [NSString stringWithFormat:@"单击POI标注：%@(latitude:%f,longitude:%f)", mapPoi.text, mapPoi.pt.latitude, mapPoi.pt.longitude];
    [self alertMessage:message];
}








#pragma mark - BMKLocationManagerDelegate

/**
 @brief 当定位发生错误时，会调用代理的此方法
 @param manager 定位 BMKLocationManager 类
 @param error 返回的错误，参考 CLError
 */
- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error {
    NSLog(@"定位失败");
}

/**
 @brief 该方法为BMKLocationManager提供设备朝向的回调方法
 @param manager 提供该定位结果的BMKLocationManager类的实例
 @param heading 设备的朝向结果
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateHeading:(CLHeading *)heading {
    if (!heading) {
        return;
    }
    NSLog(@"用户方向更新");
    
    self.userLocation.heading = heading;
    [_midnightMapView updateLocationData:self.userLocation];
}

/**
 @brief 连续定位回调函数
 @param manager 定位 BMKLocationManager 类
 @param location 定位结果，参考BMKLocation
 @param error 错误信息。
 */
- (void)BMKLocationManager:(BMKLocationManager *)manager didUpdateLocation:(BMKLocation *)location orError:(NSError *)error {
    if (error) {
        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
    }
    if (!location) {
        return;
    }
    
    self.userLocation.location = location.location;
    //实现该方法，否则定位图标不出现
    [_midnightMapView updateLocationData:self.userLocation];
}
/**
 mapType
 底图展示的地图类型
 - BMKMapTypeNone: 空白地图
 - BMKMapTypeStandard: 标准地图
 - BMKMapTypeSatellite: 卫星地图
 */
#pragma mark - Lazy loading
- (BMKMapView *)midnightMapView {
    if (!_midnightMapView) {
        _midnightMapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, kViewTopHeight, KScreenWidth, KScreenHeight - kViewTopHeight)];
        _midnightMapView.mapType=BMKMapTypeStandard;
        //设置当前地图的中心点，改变该值时，地图的比例尺级别不会发生变化
      //  _midnightMapView.centerCoordinate = CLLocationCoordinate2DMake(39.917215, 116.380341);
        //设置地图比例尺级别
       // _midnightMapView.zoomLevel = 14;
        //-----------------------------------------------
        //设置显示室内图
       // _midnightMapView.baseIndoorMapEnabled = YES;
        //设置显示室内图标注
      //  _midnightMapView.showIndoorMapPoi = YES;
        //-----------------------------------------------
        //显示路况图层
      //  _midnightMapView.trafficEnabled = YES;
        //-----------------------------------------------
        //显示热力图
      //  _midnightMapView.baiduHeatMapEnabled = YES;
        //-----------------------------------------------

        //设置定位模式为定位跟随模式
        _midnightMapView.userTrackingMode = BMKUserTrackingModeFollow;
        //-----------------------------------------------
   /*
        // 多点缩放(双指)zoomEnabled 双击或双指单击zoomEnabledWithTap
    支持用户移动地图scrollEnabled  支持旋转rotateEnabled
    支持俯仰角 overlookEnabled //俯仰角为-30度，范围为－45～0度

    */
        _midnightMapView.gesturesEnabled=YES;
        //-----------------------------------------------
        //设置显示比例尺
        _midnightMapView.showMapScaleBar = YES;
        //设置比例尺的位置，以BMKMapView左上角为原点，向右向下增长
        _midnightMapView.mapScaleBarPosition = CGPointMake(0, 0);
        //设置指南针的位置
        [_midnightMapView setCompassPosition:CGPointMake(100, 100)];
        //设置logo位置位于地图左下方
        _midnightMapView.logoPosition = BMKLogoPositionLeftBottom;

//        //初始化BMKMapStatus（地图状态类）的一个实例
//        BMKMapStatus *mapStatus = [[BMKMapStatus alloc] init];
//        [_midnightMapView_mapView setMapStatus:mapStatus];

        
        
    }
    return _midnightMapView;
}

#pragma mark - Lazy loading
- (BMKLocationManager *)locationManager {
    if (!_locationManager) {
        //初始化BMKLocationManager类的实例
        _locationManager = [[BMKLocationManager alloc] init];
        //设置定位管理类实例的代理
        _locationManager.delegate = self;
        //设定定位坐标系类型，默认为 BMKLocationCoordinateTypeGCJ02
        _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
        //设定定位精度，可自定义 默认为 kCLLocationAccuracyBest
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        ///设定定位的最小更新距离 默认为 kCLDistanceFilterNone。
        _locationManager.distanceFilter=kCLDistanceFilterNone;
        //设定定位类型，默认为 CLActivityTypeAutomotiveNavigation
        _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
        //定位是否会被系统自动暂停
        _locationManager.allowsBackgroundLocationUpdates = YES;

        //指定定位是否会被系统自动暂停，默认为NO
        _locationManager.pausesLocationUpdatesAutomatically = NO;
        /**
         是否允许后台定位，默认为NO。只在iOS 9.0及之后起作用。
         设置为YES的时候必须保证 Background Modes 中的 Location updates 处于选中状态，否则会抛出异常。
         由于iOS系统限制，需要在定位未开始之前或定位停止之后，修改该属性的值才会有效果。
         */
        _locationManager.allowsBackgroundLocationUpdates = NO;
        /**
         指定单次定位超时时间,默认为10s，最小值是2s。注意单次定位请求前设置。
         注意: 单次定位超时时间从确定了定位权限(非kCLAuthorizationStatusNotDetermined状态)
         后开始计算。
         */
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

@end

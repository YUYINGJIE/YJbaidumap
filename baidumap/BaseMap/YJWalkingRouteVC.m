//
//  YJWalkingRouteVC.m
//  baidumap
//
//  Created by 于英杰 on 2019/4/24.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJWalkingRouteVC.h"


static NSString *annotationViewIdentifier = @"com.Baidu.BMKWalkingRouteSearch";

@interface YJWalkingRouteVC ()<BMKMapViewDelegate, BMKRouteSearchDelegate,BMKLocationManagerDelegate>
@property (nonatomic, strong) BMKMapView *midnightMapView; 
@property (nonatomic, strong) BMKRouteSearch *walkingRouteSearch;
@property (nonatomic, strong) BMKLocationManager *locationManager; //定位对象
@property (nonatomic, strong) BMKUserLocation *userLocation; //当前位置对象

@end

@implementation YJWalkingRouteVC
- (void)viewWillAppear:(BOOL)animated {
    //当mapView即将被显示的时候调用，恢复之前存储的mapView状态
    [_midnightMapView viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    //当mapView即将被隐藏的时候调用，存储当前mapView的状态
    [_midnightMapView viewWillDisappear];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor= [UIColor whiteColor];
    [self.view addSubview:self.midnightMapView];
    _midnightMapView.delegate = self;
    [self setupDefaultData];
    //开启定位服务
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    //显示定位图层
    _midnightMapView.showsUserLocation = YES;
    
    NSMutableArray *annotations = [NSMutableArray array];
    BMKPointAnnotation *startannotaiton = [[BMKPointAnnotation alloc]init];
    startannotaiton.coordinate = self.startpt;
    startannotaiton.title = self.startname;
    [annotations addObject:startannotaiton];
    
    BMKPointAnnotation *endannotaiton = [[BMKPointAnnotation alloc]init];
    //设置标注的经纬度坐标
    endannotaiton.coordinate = self.endpt;
    //设置标注的标题
    endannotaiton.title = self.endname;
    [annotations addObject:endannotaiton];
    [_midnightMapView addAnnotations:annotations];
    _midnightMapView.centerCoordinate = self.startpt;
    
}

- (void)setupDefaultData {
    //初始化请求参数类BMKWalkingRoutePlanOption的实例
    BMKWalkingRoutePlanOption *walkingRoutePlanOption = [[BMKWalkingRoutePlanOption alloc] init];
    //实例化线路检索节点信息类对象
    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    //起点所在城市
    start.cityName = self.startcityid;
    //起点名称
    start.name = self.startname;
    start.pt=self.startpt;
    //实例化线路检索节点信息类对象
    BMKPlanNode *end = [[BMKPlanNode alloc] init];
    //终点所在城市
    end.cityName = self.endcityid;

    //终点名称
    end.name = self.endname;
    end.pt=self.endpt;
    //检索的起点，可通过关键字、坐标两种方式指定。cityName和cityID同时指定时，优先使用cityID
    walkingRoutePlanOption.from = start;
    //检索的终点，可通过关键字、坐标两种方式指定。cityName和cityID同时指定时，优先使用cityID
    walkingRoutePlanOption.to = end;
    [self searchData:walkingRoutePlanOption];
}
- (void)searchData:(BMKWalkingRoutePlanOption *)option {
    //初始化BMKRouteSearch实例
    _walkingRouteSearch = [[BMKRouteSearch alloc]init];
    //设置步行路径规划的代理
    _walkingRouteSearch.delegate = self;
    //初始化BMKPlanNode实例，检索起点
    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    //起点名称
    start.name = option.from.name;
    //起点所在城市，注：cityName和cityID同时指定时，优先使用cityID
    start.cityName = option.from.cityName;
    //起点所在城市ID，注：cityName和cityID同时指定时，优先使用cityID
    if ((option.from.cityName.length > 0 && option.from.cityID != 0) || (option.from.cityName.length == 0 && option.from.cityID != 0))  {
        start.cityID = option.from.cityID;
    }
    //起点坐标
    start.pt = option.from.pt;
    //初始化BMKPlanNode实例，检索终点
    BMKPlanNode* end = [[BMKPlanNode alloc] init];
    //终点名称
    end.name = option.to.name;
    //终点所在城市，注：cityName和cityID同时指定时，优先使用cityID
    end.cityName = option.to.cityName;
    //终点所在城市，注：cityName和cityID同时指定时，优先使用cityID
    if ((option.to.cityName.length > 0 && option.to.cityID != 0) || (option.to.cityName.length == 0 && option.to.cityID != 0))  {
        end.cityID = option.to.cityID;
    }
    //终点坐标
    end.pt = option.to.pt;
    //初始化请求参数类BMKWalkingRoutePlanOption的实例
    BMKWalkingRoutePlanOption *walkingRoutePlanOption = [[BMKWalkingRoutePlanOption alloc] init];
    //检索的起点，可通过关键字、坐标两种方式指定。cityName和cityID同时指定时，优先使用cityID
    walkingRoutePlanOption.from = start;
    //检索的终点，可通过关键字、坐标两种方式指定。cityName和cityID同时指定时，优先使用cityID
    walkingRoutePlanOption.to = end;
    /**
     发起步行路线检索请求，异步函数，返回结果在BMKRouteSearchDelegate的onGetWalkingRouteResult中
     */
    BOOL flag = [_walkingRouteSearch walkingSearch:walkingRoutePlanOption];
    if (flag) {
        NSLog(@"步行检索成功");
    } else{
        NSLog(@"步行检索失败");
    }
    
   

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
    
}

#pragma mark - BMKRouteSearchDelegate
/**
 返回步行路线检索结果
 
 @param searcher 检索对象
 @param result 检索结果，类型为BMKWalkingRouteResult
 @param error 错误码，@see BMKSearchErrorCode
 */
- (void)onGetWalkingRouteResult:(BMKRouteSearch *)searcher result:(BMKWalkingRouteResult *)result errorCode:(BMKSearchErrorCode)error {
    [_midnightMapView removeOverlays:_midnightMapView.overlays];
    [_midnightMapView removeAnnotations:_midnightMapView.annotations];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        //+polylineWithPoints: count:坐标点的个数
        __block NSUInteger pointCount = 0;
        //获取所有步行路线中第一条路线
        BMKWalkingRouteLine *routeline = (BMKWalkingRouteLine *)result.routes.firstObject;
        //遍历步行路线中的所有路段
        [routeline.steps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //获取步行路线中的每条路段
            BMKWalkingStep *step = routeline.steps[idx];
            //初始化标注类BMKPointAnnotation的实例
            BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];
            //设置标注的经纬度坐标为子路段的入口经纬度
            annotation.coordinate = step.entrace.location;
            //设置标注的标题为子路段的说明
            annotation.title = step.entraceInstruction;
            /**
             
             当前地图添加标注，需要实现BMKMapViewDelegate的-mapView:viewForAnnotation:方法
             来生成标注对应的View
             @param annotation 要添加的标注
             */
            [self.midnightMapView addAnnotation:annotation];
            //统计路段所经过的地理坐标集合内点的个数
            pointCount += step.pointsCount;
        }];
        //+polylineWithPoints: count:指定的直角坐标点数组
       // BMKMapPoint *points = new BMKMapPoint[pointCount];
        BMKMapPoint * points = malloc(sizeof(CLLocationCoordinate2D) * pointCount);
        

        __block NSUInteger j = 0;
        //遍历步行路线中的所有路段
        [routeline.steps enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            //获取步行路线中的每条路段
            BMKWalkingStep *step = routeline.steps[idx];
            //遍历路段所经过的地理坐标集合
            for (NSUInteger i = 0; i < step.pointsCount; i ++) {
                //将每条路段所经过的地理坐标点赋值给points
                points[j].x = step.points[i].x;
                points[j].y = step.points[i].y;
                j ++;
            }
        }];
        //根据指定直角坐标点生成一段折线
        BMKPolyline *polyline = [BMKPolyline polylineWithPoints:points count:pointCount];
        /**
         向地图View添加Overlay，需要实现BMKMapViewDelegate的-mapView:viewForOverlay:方法
         来生成标注对应的View
         
         @param overlay 要添加的overlay
         */
        [_midnightMapView addOverlay:polyline];
        //根据polyline设置地图范围
        [self mapViewFitPolyline:polyline withMapView:self.midnightMapView];
    }
}
//根据polyline设置地图范围
- (void)mapViewFitPolyline:(BMKPolyline *)polyline withMapView:(BMKMapView *)mapView {
    double leftTop_x, leftTop_y, rightBottom_x, rightBottom_y;
    if (polyline.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyline.points[0];
    leftTop_x = pt.x;
    leftTop_y = pt.y;
    //左上方的点lefttop坐标（leftTop_x，leftTop_y）
    rightBottom_x = pt.x;
    rightBottom_y = pt.y;
    //右底部的点rightbottom坐标（rightBottom_x，rightBottom_y）
    for (int i = 1; i < polyline.pointCount; i++) {
        BMKMapPoint point = polyline.points[i];
        if (point.x < leftTop_x) {
            leftTop_x = point.x;
        }
        if (point.x > rightBottom_x) {
            rightBottom_x = point.x;
        }
        if (point.y < leftTop_y) {
            leftTop_y = point.y;
        }
        if (point.y > rightBottom_y) {
            rightBottom_y = point.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(leftTop_x , leftTop_y);
    rect.size = BMKMapSizeMake(rightBottom_x - leftTop_x, rightBottom_y - leftTop_y);
    UIEdgeInsets padding = UIEdgeInsetsMake(20, 10, 20, 10);
    [mapView fitVisibleMapRect:rect edgePadding:padding withAnimated:YES];
}
#pragma mark - BMKMapViewDelegate
/**
 根据anntation生成对应的annotationView
 
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        /**
         根据指定标识查找一个可被复用的标注，用此方法来代替新创建一个标注，返回可被复用的标注
         */
        BMKPinAnnotationView *annotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationViewIdentifier];
        if (!annotationView) {
            /**
             初始化并返回一个annotationView
             
             @param annotation 关联的annotation对象
             @param reuseIdentifier 如果要重用view，传入一个字符串，否则设为nil，建议重用view
             @return 初始化成功则返回annotationView，否则返回nil
             */
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationViewIdentifier];
            NSBundle *bundle = [NSBundle bundleWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"mapapi.bundle"]];
            NSString *file = [[bundle resourcePath] stringByAppendingPathComponent:@"images/icon_nav_bus"];
            //annotationView显示的图片，默认是大头针
            annotationView.image = [UIImage imageWithContentsOfFile:file];
        }
        return annotationView;
    }
    return nil;
}

/**
 根据overlay生成对应的BMKOverlayView
 
 @param mapView 地图View
 @param overlay 指定的overlay
 @return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        //初始化一个overlay并返回相应的BMKPolylineView的实例
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        //设置polylineView的填充色
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        //设置polylineView的画笔（边框）颜色
        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        //设置polylineView的线宽度
        polylineView.lineWidth = 2.0;
        return polylineView;
    }
    return nil;
}
- (BMKMapView *)midnightMapView {
    if (!_midnightMapView) {
        _midnightMapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, kViewTopHeight, KScreenWidth, KScreenHeight-kViewTopHeight)];
        _midnightMapView.mapType=BMKMapTypeStandard;
        //设置地图比例尺级别
        _midnightMapView.zoomLevel = 16;
        //设置定位模式为定位跟随模式
        _midnightMapView.userTrackingMode = BMKUserTrackingModeFollow;
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
        _locationManager.desiredAccuracy = 10;
        ///设定定位的最小更新距离 默认为 kCLDistanceFilterNone。
        _locationManager.distanceFilter=1;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

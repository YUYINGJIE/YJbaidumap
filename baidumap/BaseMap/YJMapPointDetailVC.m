//
//  YJMapPointDetailVC.m
//  baidumap
//
//  Created by 于英杰 on 2019/4/24.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJMapPointDetailVC.h"

@interface YJMapPointDetailVC ()<BMKGeoCodeSearchDelegate>
@property (nonatomic, strong) BMKMapView *midnightMapView;

@end

@implementation YJMapPointDetailVC

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
    
    
    if (self.info) {
        NSMutableArray *annotations = [NSMutableArray array];
        //-------------------------------------------添加大头针标记
        
        //初始化标注类BMKPointAnnotation的实例
        BMKPointAnnotation *annotaiton = [[BMKPointAnnotation alloc]init];
        //设置标注的经纬度坐标
        annotaiton.coordinate = self.info.pt;
        //设置标注的标题
        annotaiton.title = self.info.name;
        annotaiton.subtitle = self.info.address;
        [annotations addObject:annotaiton];
        [_midnightMapView addAnnotations:annotations];
        //-------------------------------------------添加大头针标记
        
        //设置当前地图的中心点
        _midnightMapView.centerCoordinate = annotaiton.coordinate;
    }
    
    if (self.adress) {
        // 此时需编译
        
        [self GeoCode];
    }
    
    else{
        // 此时需要反编译
        [self ReverseGeoCode];
        
    }
    
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

#pragma mark - <地理编译>
-(void)GeoCode{
    BMKGeoCodeSearchOption *geoCodeOption = [[BMKGeoCodeSearchOption alloc]init];
    geoCodeOption.address = self.adress;
    geoCodeOption.city = self.city;
    [self GeoCodesearchData:geoCodeOption];
    
}
- (void)GeoCodesearchData:(BMKGeoCodeSearchOption *)option {
    //初始化BMKGeoCodeSearch实例
    BMKGeoCodeSearch *geoCodeSearch =[[BMKGeoCodeSearch alloc]init];
    //设置地理编码检索的代理
    geoCodeSearch.delegate = self;
    //初始化请求参数类BMKBMKGeoCodeSearchOption的实例
    BMKGeoCodeSearchOption *geoCodeOption = [[BMKGeoCodeSearchOption alloc]init];
    /**
     待解析的地址。必选。
     可以输入2种样式的值，分别是：
     1、标准的结构化地址信息，如北京市海淀区上地十街十号 【推荐，地址结构越完整，解析精度越高】
     2、支持“*路与*路交叉口”描述方式，如北一环路和阜阳路的交叉路口
     注意：第二种方式并不总是有返回结果，只有当地址库中存在该地址描述时才有返回。
     */
    geoCodeOption.address = option.address;
    /**
     地址所在的城市名。可选。
     用于指定上述地址所在的城市，当多个城市都有上述地址时，该参数起到过滤作用。
     注意：指定该字段，不会限制坐标召回城市。
     */
    geoCodeOption.city = option.city;
    /**
     根据地址名称获取地理信息：异步方法，返回结果在BMKGeoCodeSearchDelegate的
     onGetAddrResult里
     
     geoCodeOption geo检索信息类
     成功返回YES，否则返回NO
     */
    BOOL flag = [geoCodeSearch geoCode:geoCodeOption];
    if(flag) {
        NSLog(@"地理编码检索成功");
    } else {
        NSLog(@"地理检索失败");
    }

}


#pragma mark - <反编译>
-(void)ReverseGeoCode{
    //初始化请求参数类BMKReverseGeoCodeOption的实例
    BMKReverseGeoCodeSearchOption *reverseGeoCodeOption = [[BMKReverseGeoCodeSearchOption alloc] init];
    //经纬度
    reverseGeoCodeOption.location = self.pt;
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

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    
    /**
     移除一组标注
     @param annotations 要移除的标注数组
     */
    [_midnightMapView removeAnnotations:_midnightMapView.annotations];
    //BMKSearchErrorCode错误码，BMK_SEARCH_NO_ERROR：检索结果正常返回
    if (error == BMK_SEARCH_NO_ERROR) {
       
        //初始化标注类BMKPointAnnotation的实例
        BMKPointAnnotation *annotaiton = [[BMKPointAnnotation alloc]init];
        //设置标注的经纬度坐标
        annotaiton.coordinate = result.location;
        //设置标注的标题
        annotaiton.title = self.city;
        annotaiton.subtitle = self.adress;
        /**
         当前地图添加标注，需要实现BMKMapViewDelegate的-mapView:viewForAnnotation:方法
         来生成标注对应的View
         @param annotation 要添加的标注
         */
        [_midnightMapView addAnnotation:annotaiton];
        //设置当前地图的中心点
        _midnightMapView.centerCoordinate = annotaiton.coordinate;
    }
    
    
}



/**
 反向地理编码检索结果回调
 @param searcher 检索对象
 @param result 反向地理编码检索结果
 @param error 错误码，@see BMKCloudErrorCode
 */
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    
    if (result.poiList.count!=0) {
        BMKPoiInfo *POIInfo = result.poiList.firstObject;
        NSMutableArray *annotations = [NSMutableArray array];
      
        [_midnightMapView removeAnnotations:_midnightMapView.annotations];
        //初始化标注类BMKPointAnnotation的实例
        BMKPointAnnotation *annotaiton = [[BMKPointAnnotation alloc]init];
        //设置标注的经纬度坐标
        annotaiton.coordinate = POIInfo.pt;
        //设置标注的标题
        annotaiton.title = POIInfo.name;
        annotaiton.subtitle = POIInfo.address;
        [annotations addObject:annotaiton];
        //将一组标注添加到当前地图View中
        [_midnightMapView addAnnotations:annotations];
        BMKPointAnnotation *annotation = annotations[0];
        //设置当前地图的中心点
        _midnightMapView.centerCoordinate = annotation.coordinate;
        
    }
   
    
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

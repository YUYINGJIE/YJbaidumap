//
//  YJBaiduSearchVC.m
//  baidumap
//
//  Created by 于英杰 on 2019/4/23.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJBaiduSearchVC.h"
#import <BMKLocationKit/BMKLocation.h>
#import "YJMapPointDetailVC.h"


/*
 
 BMKPoiSearchDelegate 检索代理
 */

@interface YJBaiduSearchVC ()<UITableViewDelegate, UITableViewDataSource,BMKPoiSearchDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) BMKMapView *midnightMapView; //午夜蓝个性化地图
@property (nonatomic, strong) NSMutableArray *aressArray; //当前位置对象

@end

@implementation YJBaiduSearchVC




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  

    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.midnightMapView];
    [self.view addSubview:self.tableView];
    [self createSearchToolView];

    // 键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    // 键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    self.aressArray =[NSMutableArray arrayWithCapacity:0];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.aressArray.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
    }
    BMKPoiInfo *info = self.aressArray[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@%@%@",info.province,info.city,info.name];
    cell.detailTextLabel.text =[NSString stringWithFormat:@"%@",info.address];
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BMKPoiInfo *info = self.aressArray[indexPath.row];
    YJMapPointDetailVC * PointDetailVC = [[YJMapPointDetailVC alloc]init];
    PointDetailVC.info = info;
    [self.navigationController pushViewController:PointDetailVC animated:YES];
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.midnightMapView.bottom, KScreenWidth, KScreenHeight-self.midnightMapView.bottom-self.toolView.height-kViewTopHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    
    return _tableView;
}


- (BMKMapView *)midnightMapView {
    if (!_midnightMapView) {
        _midnightMapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, kViewTopHeight, KScreenWidth, 200)];
        _midnightMapView.mapType=BMKMapTypeStandard;
        //设置地图比例尺级别
        _midnightMapView.zoomLevel = 14;
        //设置定位模式为定位跟随模式
        _midnightMapView.userTrackingMode = BMKUserTrackingModeFollow;
       
    }
    return _midnightMapView;
}

- (void)createSearchToolView {
    [self createToolBarsWithItemArray:
     @[@{@"leftItemTitle":@"城 市：",
         @"rightItemText":@"北京",
         @"rightItemPlaceholder":@"输入城市"},
       @{@"leftItemTitle":@"关键字：",
         @"rightItemText":@"小吃",
         @"rightItemPlaceholder":@"输入keyword"}
       ]];
}

-(void)searchData{
    
    
    //初始化请求参数类BMKCitySearchOption的实例
    BMKPOICitySearchOption *cityOption = [[BMKPOICitySearchOption alloc]init];
    //区域名称(市或区的名字，如北京市，海淀区)，最长不超过25个字符，必选
    cityOption.city= self.dataArray[0];
    //检索关键字
    cityOption.keyword = self.dataArray[1];
    cityOption.pageSize=20;
    [self searchData:cityOption];
    
    
    
    
}
- (void)searchData:(BMKPOICitySearchOption *)option {
    //初始化BMKPoiSearch实例
    BMKPoiSearch *POISearch = [[BMKPoiSearch alloc] init];
    //设置POI检索的代理
    POISearch.delegate = self;
    //初始化请求参数类BMKCitySearchOption的实例
    BMKPOICitySearchOption *cityOption = [[BMKPOICitySearchOption alloc]init];
    //检索关键字，必选。举例：天安门
    cityOption.keyword = option.keyword;
    //区域名称(市或区的名字，如北京市，海淀区)，最长不超过25个字符，必选
    cityOption.city = option.city;
    //检索分类，与keyword字段组合进行检索，多个分类以","分隔。举例：美食,酒店
    cityOption.tags = option.tags;
    //区域数据返回限制，可选，为true时，仅返回city对应区域内数据
    cityOption.isCityLimit = option.isCityLimit;
    /**
     POI检索结果详细程度
     BMK_POI_SCOPE_BASIC_INFORMATION: 基本信息
     BMK_POI_SCOPE_DETAIL_INFORMATION: 详细信息
     */
    cityOption.scope = option.scope;
    //检索过滤条件，scope字段为BMK_POI_SCOPE_DETAIL_INFORMATION时，filter字段才有效
    cityOption.filter = option.filter;
    //分页页码，默认为0，0代表第一页，1代表第二页，以此类推
    cityOption.pageIndex = option.pageIndex;
    //单次召回POI数量，默认为10条记录，最大返回20条
    cityOption.pageSize = option.pageSize;
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


#pragma mark - BMKPoiSearchDelegate
/**
 POI检索返回结果回调
 @param searcher 检索对象
 @param poiResult POI检索结果列表
 @param error 错误码
 */
- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPOISearchResult *)poiResult errorCode:(BMKSearchErrorCode)error {
    
    //------------------------------------------周边搜索
    [self.aressArray removeAllObjects];
    //POI信息类的实例
    BMKPoiInfo *info = poiResult.poiInfoList[0];
    [self.aressArray addObjectsFromArray:poiResult.poiInfoList];
    [self.tableView reloadData];
    
    //-------------------------------------------添加大头针标记
    [_midnightMapView removeAnnotations:_midnightMapView.annotations];

    if (error==BMK_SEARCH_NO_ERROR) {
        NSMutableArray *annotations = [NSMutableArray array];

        for (BMKPoiInfo *POIInfo in self.aressArray) {
            
            //初始化标注类BMKPointAnnotation的实例
            BMKPointAnnotation *annotaiton = [[BMKPointAnnotation alloc]init];
            //设置标注的经纬度坐标
            annotaiton.coordinate = POIInfo.pt;
            //设置标注的标题
            annotaiton.title = POIInfo.name;
            [annotations addObject:annotaiton];
        }
        //将一组标注添加到当前地图View中
        [_midnightMapView addAnnotations:annotations];
        BMKPointAnnotation *annotation = annotations[0];
        //设置当前地图的中心点
        _midnightMapView.centerCoordinate = annotation.coordinate;
    }
    
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    //当mapView即将被显示的时候调用，恢复之前存储的mapView状态
    [_midnightMapView viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    //当mapView即将被隐藏的时候调用，存储当前mapView的状态
    [_midnightMapView viewWillDisappear];
}

//创建ToolView
- (void)createToolBarsWithItemArray:(NSArray *)itemArray {
    
    [_dataArray removeAllObjects];
    [_toolView removeFromSuperview];
    
    for (int i = 0; i<itemArray.count; i++) {
        NSDictionary *tempDic = itemArray[i];
        
        UILabel *leftTip = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth * 0.05, 0, KScreenWidth * 0.35, 33)];
        leftTip.textAlignment = NSTextAlignmentRight;
        leftTip.text = tempDic[@"leftItemTitle"];
        leftTip.textColor = self.view.tintColor;
        
        UITextField *leftText = [[UITextField alloc] initWithFrame:CGRectMake(KScreenWidth * 0.4, 0, KScreenWidth * 0.35, 33)];
        leftText.returnKeyType = UIReturnKeyDone;
        leftText.delegate = self;
        leftText.tag = 100 + i;
        leftText.text = tempDic[@"rightItemText"];
        leftText.placeholder = tempDic[@"rightItemPlaceholder"];
        [leftText setBorderStyle:UITextBorderStyleRoundedRect];
        //数据初始化并绑定
        [self.dataArray addObject:leftText.text];
        
        UIView *bar = [[UIView alloc] init];
        bar.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:247/255.0];
        bar.frame = CGRectMake(0, 35 * i, KScreenWidth * 0.75, 35);
        [bar addSubview:leftTip];
        [bar addSubview:leftText];
        
        [self.toolView addSubview:bar];
    }
    
    self.toolView.frame = CGRectMake(0, KScreenHeight  - 35 * itemArray.count , KScreenWidth, 35 * itemArray.count);
    self.searchButton.frame = CGRectMake(KScreenWidth * 0.75, 0, KScreenWidth * 0.25, self.toolView.frame.size.height);
    [self.toolView addSubview:self.searchButton];
    [self.view addSubview:self.toolView];
    
    // 键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    // 键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark -懒加载
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (UIButton *)searchButton {
    if (!_searchButton) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _searchButton.frame = CGRectZero;
        [_searchButton setTitle:@"搜 索" forState:UIControlStateNormal];
        [_searchButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(searchData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

- (UIView *)toolView {
    if (!_toolView) {
        _toolView = [[UIView alloc] initWithFrame:CGRectZero];
        [_toolView setBackgroundColor:[UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:247/255.0]];
    }
    return _toolView;
}
#pragma mark -键盘监听方法
- (void)keyboardWasShown:(NSNotification *)notification {
    // 获取键盘的高度
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = [UIScreen mainScreen].bounds.size.height-self.toolView.frame.size.height-frame.size.height;
    self.toolView.frame = CGRectMake(self.toolView.frame.origin.x, y, self.toolView.frame.size.width, self.toolView.frame.size.height);
}

- (void)keyboardWillBeHiden:(NSNotification *)notification {
    if (KScreenHeight -  kViewTopHeight - KiPhoneXSafeAreaDValue - self.toolView.frame.size.height  == self.toolView.frame.origin.y)
        return;
    self.toolView.frame = CGRectMake(self.toolView.frame.origin.x, KScreenHeight - self.toolView.frame.size.height, self.toolView.frame.size.width, self.toolView.frame.size.height);
}
#pragma mark -UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //数据更新
    [textField resignFirstResponder];
    return YES;
}

@end

//
//  YJMapPointDetailVC.h
//  baidumap
//
//  Created by 于英杰 on 2019/4/24.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJMapPointDetailVC : UIViewController
//直接传数据
@property(nonatomic,strong)BMKPoiInfo *info;

// 只传经纬度 进行反编译 Poi坐标
@property (nonatomic, assign) CLLocationCoordinate2D pt;

// 只传位置 进行编译address
@property(nonatomic,strong)NSString *adress;
@property(nonatomic,strong)NSString *city;

@end

NS_ASSUME_NONNULL_END

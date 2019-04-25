//
//  YJBaiduMap.h
//  baidumap
//
//  Created by 于英杰 on 2019/4/22.
//  Copyright © 2019 YYJ. All rights reserved.
//

#ifndef YJBaiduMap_h
#define YJBaiduMap_h


#ifdef __OBJC__
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>//
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Cloud/BMKCloudSearchComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>
#import <BMKLocationkit/BMKLocationComponent.h>
#import "UIView+Extension.h"
#endif

#define widthScale ([UIScreen mainScreen].bounds.size.width/375.0f)
#define heightScale ([UIScreen mainScreen].bounds.size.height/667.0f)
#define BMKMapVersion [NSString stringWithFormat:@"百度地图iOS SDK %@", BMKGetMapApiVersion()]
//屏幕宽度
#define KScreenWidth  ([UIScreen mainScreen].bounds.size.width)
//屏幕高度
#define KScreenHeight ([UIScreen mainScreen].bounds.size.height)
//状态栏高度
#define KStatuesBarHeight  ([UIApplication sharedApplication].statusBarFrame.size.height)
//导航栏高度
#define KNavigationBarHeight 44.0
//导航栏高度+状态栏高度
#define kViewTopHeight (KStatuesBarHeight + KNavigationBarHeight)
//iphoneX适配差值
#define KiPhoneXSafeAreaDValue ([[UIApplication sharedApplication] statusBarFrame].size.height>20?34:0)

#define COLOR(rgbValue)     [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kHeight_SegMentBackgroud  60


#endif /* YJBaiduMap_h */

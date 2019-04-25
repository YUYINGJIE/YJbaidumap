//
//  YJMapDicManager.m
//  baidumap
//
//  Created by 于英杰 on 2019/4/25.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJMapDicManager.h"
#import "JZLocationConverter.h"

@interface YJMapDicManager ()
@property(nonatomic,strong)NSMutableArray*mapsArray;

@end

@implementation YJMapDicManager

+(instancetype)shareManager{
    
    static YJMapDicManager * _MapDicManager=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _MapDicManager = [[YJMapDicManager alloc]init];
        _MapDicManager.mapsArray = [NSMutableArray array];
    });
    return _MapDicManager;
}

-(NSMutableArray*)GetmapsArray{
    return _mapsArray;
}
-(void)setEndPoiInfo:(BMKPoiInfo *)endPoiInfo{
    _endPoiInfo = endPoiInfo;
    [self SaveMapsUseful];
}

- (void)SaveMapsUseful
{
    [self.mapsArray removeAllObjects];
    //http://maps.apple.com/
    //苹果
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com/"]]) {
        
        NSMutableDictionary *iosMapDic = [NSMutableDictionary dictionary];
        NSString *urlString = [[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%f,%f",self.endPoiInfo.pt.latitude, self.endPoiInfo.pt.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        iosMapDic[@"title"] = @"苹果地图";
        iosMapDic[@"url"] = urlString;
        [self.mapsArray addObject:iosMapDic];
    }

    //百度
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
        NSMutableDictionary *baiduMapDic = [NSMutableDictionary dictionary];
        baiduMapDic[@"title"] = @"百度地图";
        NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=latlng:%f,%f|name=%@&mode=driving&coord_type=gcj02",self.endPoiInfo.pt.latitude, self.endPoiInfo.pt.longitude,self.endPoiInfo.address] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        baiduMapDic[@"url"] = urlString;
        [self.mapsArray addObject:baiduMapDic];
    }
    //高德
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        NSMutableDictionary *gaodeMapDic = [NSMutableDictionary dictionary];
        gaodeMapDic[@"title"] = @"高德地图";
        
        NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0",self.endPoiInfo.pt.latitude, self.endPoiInfo.pt.longitude,self.endPoiInfo.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        
        gaodeMapDic[@"url"] = urlString;
        [self.mapsArray addObject:gaodeMapDic];
    }
    
    //腾讯
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
        NSMutableDictionary *qqMapDic = [NSMutableDictionary dictionary];
        qqMapDic[@"title"] = @"腾讯地图";
        NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?from=我的位置&type=drive&tocoord=%f,%f&to=%@&coord_type=1&policy=0",self.endPoiInfo.pt.latitude, self.endPoiInfo.pt.longitude,self.endPoiInfo.name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        qqMapDic[@"url"] = urlString;
        [self.mapsArray addObject:qqMapDic];
    }
    //谷歌
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        NSMutableDictionary *googleMapDic = [NSMutableDictionary dictionary];
        googleMapDic[@"title"] = @"谷歌地图";
        NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?x-source=%@&x-success=%@&saddr=&daddr=%f,%f&directionsmode=driving",@"BaiduMap",@"URLscheme",self.endPoiInfo.pt.latitude, self.endPoiInfo.pt.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        googleMapDic[@"url"] = urlString;
        [self.mapsArray addObject:googleMapDic];
    }
}
-(id)init{
    return self;
}


/*
 记录
 百度:http://lbsyun.baidu.com/index.php?title=uri/api/ios
 高德地图url 官方文档:https://lbs.amap.com/api/amap-mobile/guide/ios/navi
 苹果:https://developer.apple.com/library/archive/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
 腾讯:https://lbs.qq.com/uri_v1/guide-route.html
 谷歌:https://developers.google.com/maps/documentation/ios/urlscheme
 */
@end

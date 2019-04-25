//
//  YJMapDicManager.h
//  baidumap
//
//  Created by 于英杰 on 2019/4/25.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import <Foundation/Foundation.h>


// 百年不变的业务 所以采用单利处理
NS_ASSUME_NONNULL_BEGIN

@interface YJMapDicManager : NSObject
@property(nonatomic,strong) BMKPoiInfo *endPoiInfo;
+(instancetype)shareManager;
-(NSMutableArray*)GetmapsArray;

@end

NS_ASSUME_NONNULL_END

//
//  YJResultVC.h
//  baidumap
//
//  Created by 于英杰 on 2019/4/24.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJResultVC : UIViewController<UISearchResultsUpdating>
@property (nonatomic, strong) NSMutableArray *datas;
@property (strong, nonatomic) UINavigationController *nav;
@property (strong, nonatomic) UISearchBar *searchBar;
@property(nonatomic,copy)NSString*city;

@property(nonatomic,strong)CLLocation *  location;//导航起点
@end

NS_ASSUME_NONNULL_END

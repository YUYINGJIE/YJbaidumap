//
//  YJBaiduSearchVC.h
//  baidumap
//
//  Created by 于英杰 on 2019/4/23.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YJBaiduSearchVC : UIViewController
//搜索按钮
@property (nonatomic, strong) UIButton *searchButton;
//搜索数据
@property (nonatomic, strong) NSMutableArray *dataArray;
//搜索工具视图
@property (nonatomic, strong) UIView *toolView;
- (void)createToolBarsWithItemArray:(NSArray *)itemArray;
@end

NS_ASSUME_NONNULL_END

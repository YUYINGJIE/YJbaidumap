//
//  YJTipCell.m
//  baidumap
//
//  Created by 于英杰 on 2019/4/24.
//  Copyright © 2019 YYJ. All rights reserved.
//

#import "YJTipCell.h"

@implementation YJTipCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)btnClick:(id)sender {
    UIButton*btn = (UIButton*)sender;
    if (self.typeBlock) {
        self.typeBlock(btn.tag);
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

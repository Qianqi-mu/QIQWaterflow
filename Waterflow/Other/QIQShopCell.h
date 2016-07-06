//
//  QIQShopCell.h
//  Waterflow
//
//  Created by qqian on 16/7/6.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "QIQWaterflowViewCell.h"
@class QIQShop, QIQWaterflowView;

@interface QIQShopCell : QIQWaterflowViewCell

@property (nonatomic, strong) QIQShop *shop;

+ (QIQShopCell *)cellWithWaterflowView:(QIQWaterflowView *)waterflowView;

@end

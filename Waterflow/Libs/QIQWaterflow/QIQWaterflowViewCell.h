//
//  QIQWaterflowCell.h
//  Waterflow
//
//  Created by qqian on 16/7/6.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QIQWaterflowViewCell : UIView

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

- (id)initWithIdentifier:(NSString *)reuseIdentifier;

@end

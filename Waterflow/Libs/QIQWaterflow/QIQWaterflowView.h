//
//  QIQWaterflowView.h
//  Waterflow
//
//  Created by qqian on 16/7/6.
//  Copyright © 2016年 QiQ. All rights reserved.
//  基于ScrollView的瀑布流

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, QIQWaterflowViewMarginType){
    QIQWaterflowViewMarginTypeTop,
    QIQWaterflowViewMarginTypeBottom,
    QIQWaterflowViewMarginTypeLeft,
    QIQWaterflowViewMarginTypeRight,
    QIQWaterflowViewMarginTypeColumn,
    QIQWaterflowViewMarginTypeRow,
};

@class QIQWaterflowView, QIQWaterflowViewCell;
@protocol QIQWaterflowViewDataSource <NSObject>
@required
/**
 *  一共有多少的cell
 */
- (NSUInteger)numberOfCellsInWaterflowView:(QIQWaterflowView *)waterflowView;

/**
 *  返回index位置对应的cell
 */
- (QIQWaterflowViewCell *)waterflowView:(QIQWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index;

@optional

/**
 *  瀑布流一共有多少列
 */
- (NSUInteger)numberOfColumnsInWaterflowView:(QIQWaterflowView *)waterflowView;

@end

@protocol QIQWaterflowViewDelegate <UIScrollViewDelegate>
@optional
/**
 *  返回index位置对应cell的高度
 */
- (CGFloat)waterflowView:(QIQWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index;

/**
 *  间距
 */
- (CGFloat)waterflowView:(QIQWaterflowView *)waterflowView marginForType:(QIQWaterflowViewMarginType)marginType;

/**
 *  选中index位置的cell
 */
- (void)waterflowView:(QIQWaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index;


@end

@interface QIQWaterflowView : UIScrollView

@property (nonatomic, weak) id<QIQWaterflowViewDataSource> waterflowDataSource;
@property (nonatomic, weak) id<QIQWaterflowViewDelegate> waterflowDelegate;

/**
 *  刷新数据，只要调用这个方法就会重新像数据源和代理发送请求，重新获取数据
 */
- (void)reloadData;

/**
 *  数据源从缓存池中取可用的cell 
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier;

/**
 *  计算cell的宽度
 */
- (CGFloat)cellWidth;

@end

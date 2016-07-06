//
//  QIQWaterflowView.m
//  Waterflow
//
//  Created by qqian on 16/7/6.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "QIQWaterflowView.h"
#import "QIQWaterflowViewCell.h"


/**
 *  cell的默认高度
 */
static const CGFloat kWaterflowViewDefaultCellHeight = 70.0;

/**
 *  默认统一间距
 */
static const CGFloat kWaterflowDefaultMargin = 10.0;

/**
 *  默认列数
 */
static const NSUInteger kWaterflowDefaultNumberOfColumns = 3;

@interface QIQWaterflowView ()

/**
 *  所有cell的frame
 */
@property (nonatomic, strong) NSMutableArray *cellFrames;

/**
 *  正在展示的cell
 */
@property (nonatomic, strong) NSMutableDictionary *displayingCells;

/**
 *  缓存池（存放不在屏幕上的cell）
 */
@property (nonatomic, strong) NSMutableSet *reusableCells;

@end

@implementation QIQWaterflowView

#pragma mark - 懒加载
- (NSMutableArray *)cellFrames {
    if (!_cellFrames) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells {
    if (!_displayingCells) {
        _displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells {
    if (!_reusableCells) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self reloadData];
}

#pragma mark - 公共接口
/**
 *  1.计算每一个cell的frame
 *  2.缓存所有的cell的frame
 */
- (void)reloadData {
    //刷新瀑布流之前，一定要把原有的缓存清除
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.reusableCells removeAllObjects];
    
    //cell的总数
    NSUInteger numberOfCells = [self.waterflowDataSource numberOfCellsInWaterflowView:self];
    
    //瀑布流的列数
    NSUInteger numberOfColumns =[self numberOfColumns];
    
    //间距
    CGFloat topM = [self marginForType:QIQWaterflowViewMarginTypeTop];
    CGFloat bottomM = [self marginForType:QIQWaterflowViewMarginTypeBottom];
    CGFloat leftM = [self marginForType:QIQWaterflowViewMarginTypeLeft];
    CGFloat columnM = [self marginForType:QIQWaterflowViewMarginTypeColumn];
    CGFloat rowM = [self marginForType:QIQWaterflowViewMarginTypeRow];
    
    //cell的宽度
    CGFloat cellW = [self cellWidth];
    
    //用一个C语言数组存放所有列的最大Y值
    CGFloat maxYOfColumns[numberOfColumns];
    for (int i = 0; i < numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    
    //计算每一个cell的frame
    for (int index = 0; index < numberOfCells; index++) {
        
        //最短的那一列
        NSUInteger cellColumn = 0;
        //最短一列的最大Y值
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
        //求出最短的一列
        for (int j = 1; j < numberOfColumns; j++) {
            if (maxYOfColumns[j] < maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }
        
        //cell的位置
        CGFloat cellX = leftM + (cellW + columnM)*cellColumn;
        CGFloat cellY = 0.0;
        if (maxYOfCellColumn == 0.0) {//首行的Y值
            cellY = topM;
        }else {//其他行的Y值
            cellY = maxYOfCellColumn + rowM;
        }
        
        //cell的高度
        CGFloat cellH = [self cellHeightAtIndex:index];
        
        //cell的frame
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        //更新最短那列的最大Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);

    }
    
    //设置contentSize
    CGFloat contentH = 0.0;
    for (int i = 0; i < numberOfColumns; i++) {
        if (maxYOfColumns[i] > contentH) {
            contentH = maxYOfColumns[i];
        }
    }
    contentH += bottomM;
    self.contentSize = CGSizeMake(0, contentH);
}

/**
 *  计算cell的宽度
 */
- (CGFloat)cellWidth {
    NSUInteger numberOfColumns =[self numberOfColumns];
    CGFloat leftM = [self marginForType:QIQWaterflowViewMarginTypeLeft];
    CGFloat rightM = [self marginForType:QIQWaterflowViewMarginTypeRight];
    CGFloat columnM = [self marginForType:QIQWaterflowViewMarginTypeColumn];
    CGFloat cellW = (self.bounds.size.width - leftM - rightM - (numberOfColumns-1)*columnM) / numberOfColumns;
    return cellW;
}

/**
 *  由数据源从缓存池中取出可用的cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier {
    __block QIQWaterflowViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(QIQWaterflowViewCell *cell, BOOL * _Nonnull stop) {
        if ([reusableCell.reuseIdentifier isEqualToString:reuseIdentifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    //从缓存池中取出一个cell，就要将其从缓存池中移除
    if (reusableCell) {
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}

#pragma mark - 监听瀑布流的滚动
- (void)layoutSubviews {
    [super layoutSubviews];
    
    //向数据源索要对应位置的cell
    NSUInteger numberOfCells = self.cellFrames.count;
    for (int index = 0; index < numberOfCells; index++) {
        //取出i位置cell的frame
        CGRect cellFrame = [self.cellFrames[index] CGRectValue];
        //优先从字典中取出index位置的cell
        QIQWaterflowViewCell *cell = self.displayingCells[@(index)];
        if ([self isInScreen:cellFrame]) {//在屏幕上的cell
            if (!cell) {
                cell = [self.waterflowDataSource waterflowView:self cellAtIndex:index];
                cell.frame = cellFrame;
                [self addSubview:cell];
                
                //存放到字典中
                self.displayingCells[@(index)] = cell;
            }
            
        }else {//不在屏幕上
            if (cell) {
                //放入缓存池
                [self.reusableCells addObject:cell];
                
                //从屏幕上移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(index)];
            }
        }
    }
}



#pragma mark - 私有方法
/**
 *  判断一个cell是否在屏幕上
 *
 *  @param frame cell的frame
 *
 *  @return YES表示在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame {
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMinY(frame) < self.contentOffset.y+self.bounds.size.height);
}

/**
 *  向代理索取间距（默认间距为10)
 */
- (CGFloat)marginForType:(QIQWaterflowViewMarginType)type {
    if ([self.waterflowDelegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.waterflowDelegate waterflowView:self marginForType:type];
    }else {
        return kWaterflowDefaultMargin;
    }
}

/**
 *  向数据源索取瀑布流的列数（默认3列）
 */
- (NSUInteger)numberOfColumns {
    if ([self.waterflowDataSource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
        return [self.waterflowDataSource numberOfColumnsInWaterflowView:self];
    }else {
        return kWaterflowDefaultNumberOfColumns;
    }
}

/**
 *  向代理索取cell的高度（默认高度为70）
 */
- (CGFloat)cellHeightAtIndex:(NSUInteger)index {
    if ([self.waterflowDelegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.waterflowDelegate waterflowView:self heightAtIndex:index];
    }else {
        return kWaterflowViewDefaultCellHeight;
    }
}

#pragma mark - 事件处理
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self.waterflowDelegate respondsToSelector:@selector(waterflowView:didSelectAtIndex:)]) return;
    
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    
    __block NSNumber *selectIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, QIQWaterflowViewCell *cell, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    if (selectIndex) {
        [self.waterflowDelegate waterflowView:self didSelectAtIndex:[selectIndex unsignedIntegerValue]];
    }
}

@end

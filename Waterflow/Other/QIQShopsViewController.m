//
//  ViewController.m
//  Waterflow
//
//  Created by qqian on 16/7/6.
//  Copyright © 2016年 QiQ. All rights reserved.
//

#import "QIQShopsViewController.h"
#import "QIQWaterflowView.h"
#import "QIQShopCell.h"
#import "QIQShop.h"
#import "MJExtension.h"
#import "MJRefresh.h"

@interface QIQShopsViewController ()<QIQWaterflowViewDataSource, QIQWaterflowViewDelegate>

@property (nonatomic, strong) NSMutableArray *shops;

@property (nonatomic, weak) QIQWaterflowView *waterflowView;

@end

@implementation QIQShopsViewController

#pragma mark - 懒加载
- (NSMutableArray *)shops {
    if (!_shops) {
        NSArray *shops = [QIQShop objectArrayWithFilename:@"2.plist"];
        _shops = [NSMutableArray arrayWithArray:shops];
    }
    return _shops;
}

#pragma mark - 视图生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    
    QIQWaterflowView *waterflowView = [[QIQWaterflowView alloc] init];
    self.waterflowView = waterflowView;
    waterflowView.waterflowDelegate = self;
    waterflowView.waterflowDataSource = self;
    waterflowView.frame = CGRectMake(0, 20, self.view.bounds.size.width, self.view.bounds.size.height-20);
    waterflowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:waterflowView];

    //下拉刷新
    [self pullDownRefresh];
    //上拉加载更多
    [self pullUpRefresh];
    
}



#pragma mark - 私有方法
- (void)pullDownRefresh {
    __weak __typeof(self) weakSelf = self;
    self.waterflowView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadNewData];
    }];
}

- (void)loadNewData {
    __weak __typeof(self) weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *newShops = [QIQShop objectArrayWithFilename:@"1.plist"];
        [weakSelf.shops insertObjects:newShops atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newShops.count)]];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.waterflowView reloadData];
        [weakSelf.waterflowView.header endRefreshing];
    });
    
}

- (void)pullUpRefresh {
    __weak __typeof(self) weakSelf = self;
    self.waterflowView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
    }];
}

- (void)loadMoreData {
    __weak __typeof(self) weakSelf = self;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *moreShops = [QIQShop objectArrayWithFilename:@"3.plist"];
        [weakSelf.shops addObjectsFromArray:moreShops];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.waterflowView reloadData];
        [weakSelf.waterflowView.footer endRefreshing];
    });
}

/**
 *  屏幕旋转时调用，刷新瀑布流，适配横竖屏
 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.waterflowView reloadData];
}

#pragma mark - Waterflow DataSource
- (NSUInteger)numberOfColumnsInWaterflowView:(QIQWaterflowView *)waterflowView {
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {//竖屏时，显示3列
        return 3;
    }else{//横屏时，显示5列
        return 5;
    }
}

- (NSUInteger)numberOfCellsInWaterflowView:(QIQWaterflowView *)waterflowView {
    return self.shops.count;
}

- (QIQWaterflowViewCell *)waterflowView:(QIQWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index {
    QIQShopCell *cell = [QIQShopCell cellWithWaterflowView:waterflowView];
    cell.shop = self.shops[index];
    return cell;
}

#pragma mark - Waterflow Delegate
- (CGFloat)waterflowView:(QIQWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index {
    CGFloat cellWidth = [waterflowView cellWidth];
    QIQShop *shop = self.shops[index];
    return cellWidth*shop.h/shop.w;
}

- (CGFloat)waterflowView:(QIQWaterflowView *)waterflowView marginForType:(QIQWaterflowViewMarginType)marginType {
    switch (marginType) {
        case QIQWaterflowViewMarginTypeTop:
            return 10;
            break;
        case QIQWaterflowViewMarginTypeBottom:
            return 10;
            break;
        case QIQWaterflowViewMarginTypeLeft:
            return 10;
            break;
        case QIQWaterflowViewMarginTypeRight:
            return 10;
            break;
        case QIQWaterflowViewMarginTypeColumn:
            return 8;
            break;
        case QIQWaterflowViewMarginTypeRow:
            return 8;
            break;
        default:
            return 10;
            break;
    }
}

- (void)waterflowView:(QIQWaterflowView *)waterflowView didSelectAtIndex:(NSUInteger)index {
    QIQShop *shop = self.shops[index];
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"所选商品价格" message:shop.price preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertView addAction:okAction];
        [self presentViewController:alertView animated:YES completion:nil];
}


@end

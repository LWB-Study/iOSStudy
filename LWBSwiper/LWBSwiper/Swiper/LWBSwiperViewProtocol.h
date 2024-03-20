//
//  LWBSwiperViewProtocol.h
//  LWBSwiper
//
//  Created by liuwenbo on 2024/3/20.
//

#ifndef LWBSwiperViewProtocol_h
#define LWBSwiperViewProtocol_h

/**
 自定义cell 必须遵守 LWBSwiperViewCellProtocol 协议
 */
@protocol LWBSwiperViewCellProtocol <NSObject>

@property (nonatomic, strong) id data;

@end

/**
 Swiper滚动组件需要遵守的协议
 */
@protocol LWBSwiperViewProtocol <NSObject>

@required
- (Class)swiperViewCellClass;

@optional
- (UICollectionViewFlowLayout *)flowLayout;
// 自动滚动的时间间隔
- (NSTimeInterval)autoPlayTimeInterval;
// 是否为loop
- (BOOL)loopPlay;
// 滚动的方向
- (UICollectionViewScrollDirection)swiperViewScrollDirection;
// 两行之间的间距
- (CGFloat)minimumLineSpacing;
// 两列之间的间距
- (CGFloat)minimumInteritemSpacing;
// 是否展示分页指示器
- (BOOL)showPageControl;
// 普通分页指示器颜色
- (UIColor *)pageIndicatorTintColor;
// 当前分页指示器颜色
- (UIColor *)currentPageIndicatorTintColor;
// 分页指示器的位置和大小
- (CGRect)pageControlRect;
// 背景颜色
- (UIColor *)swiperBackgroundColor;
// 是否可以手动滚动
- (BOOL)swiperScrollEnabled;
// 点击了cell
- (void)clickCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;
@end

#endif /* LWBSwiperViewProtocol */

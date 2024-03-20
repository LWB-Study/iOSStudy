//
//  LWBSwiperView.m
//  aiinquiry
//
//  Created by LWB on 2023/5/29.
//
//

#import "LWBSwiperView.h"
#import <Masonry/Masonry.h>

@interface LWBSwiperView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) NSTimer *autoPlayTimer;
@property (nonatomic, weak) id<LWBSwiperViewProtocol>delegate;

@property (nonatomic, weak) UIScrollView *superScrollView;
@property (nonatomic, assign) BOOL superScrollViewScrollEnabled;

@end

@implementation LWBSwiperView

-(void)dealloc {
    [self clearTimer];
    _delegate = nil;
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

- (instancetype)initWithDelegate:(id<LWBSwiperViewProtocol>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        [self setupSubviews];
    }
    return self;
}

- (NSInteger)curDisplayingCellIndex {
    NSInteger curDisplayingIndex = 0;
    if ([self scrollDirection] == UICollectionViewScrollDirectionHorizontal) {
        curDisplayingIndex = self.collectionView.contentOffset.x / self.collectionView.bounds.size.width;
    } else {
        curDisplayingIndex = self.collectionView.contentOffset.y / self.collectionView.bounds.size.height;
    }
    if ([self loopPlay]) {
        if (curDisplayingIndex < 1) {
            curDisplayingIndex = self.dataArray.count - 1;
        } else {
            curDisplayingIndex = curDisplayingIndex - 1;
        }
    }
    return curDisplayingIndex;
}

#pragma mark - private

- (void)setupSubviews {
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
    if ([self showPageControl]) {
        if ([self.delegate showPageControl]) {
            [self addSubview:self.pageControl];
            CGRect pageControlRect = [self.delegate pageControlRect];
            [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(pageControlRect.origin.x);
                make.top.mas_equalTo(pageControlRect.origin.y);
                make.size.mas_equalTo(pageControlRect.size);
            }];
        }
    }
}

- (void)showNext {
    // 手指拖拽时 禁止自动轮播
    if (self.collectionView.isDragging) {
        return;
    }
    CGPoint targetPoint = CGPointZero;
    if ([self scrollDirection] == UICollectionViewScrollDirectionHorizontal) {
        CGFloat targetX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width;
        targetPoint.x = targetX;
    } else {
        CGFloat targetY = self.collectionView.contentOffset.y + self.collectionView.bounds.size.height;
        targetPoint.y = targetY;
    }
    // 如果不能循环播放 且 当前页已经到达最右边或者最下边则退出
    if (![self loopPlay] && [self currentPage] == self.dataArray.count - 1) {
        return;
    }
    // 检查targetPoint的 x 或者 y 值是否一定是 width 或者 heiht 的倍数
    targetPoint = [self checkContentOffset:targetPoint];
    
    [self.collectionView setContentOffset:targetPoint animated:true];
}

// 检查targetPoint的 x 或者 y 值是否一定是 width 或者 heiht 的倍数
- (CGPoint)checkContentOffset:(CGPoint)targetPoint {
    NSInteger numOfX = (int)targetPoint.x % (int)self.collectionView.bounds.size.width;
    NSInteger numOfY = (int)targetPoint.y % (int)self.collectionView.bounds.size.height;
    if (numOfX != 0) {
        targetPoint.x = self.collectionView.bounds.size.width * roundf(targetPoint.x / self.collectionView.bounds.size.width);
    }
    if (numOfY != 0) {
        targetPoint.y = self.collectionView.bounds.size.height * roundf(targetPoint.y / self.collectionView.bounds.size.height);
    }
    return targetPoint;
}

// 循环显示
- (void)cycleScroll {
    if (![self loopPlay]) {
        if ([self showPageControl]) {
            self.pageControl.currentPage = [self currentPage];
        }
        return;
    }
    CGPoint targetPoint = CGPointZero;
    if ([self scrollDirection] == UICollectionViewScrollDirectionHorizontal) {
        NSInteger page = [self currentPage];
        if (page == 0) { //滚动到左边
            // 体验优化：第一个超过展示超过一半时再循环
            CGFloat ratio = (CGFloat)self.collectionView.contentOffset.x / (CGFloat)self.collectionView.bounds.size.width;
            if (ratio >= 0.5) {
                return;
            }
            targetPoint = CGPointMake(self.collectionView.bounds.size.width * (self.dataArray.count - 2) + self.collectionView.bounds.size.width / 2, 0);
            self.pageControl.currentPage = self.dataArray.count - 2;
        } else if (page == self.dataArray.count - 1) { //滚动到右边
            targetPoint = CGPointMake(self.collectionView.bounds.size.width, 0);
            self.pageControl.currentPage = 0;
        } else {
            self.pageControl.currentPage = page - 1;
            return;
        }
    } else {
        NSInteger page = [self currentPage];
        if (page == 0) { //滚动到上边
            // 体验优化：第一个超过展示超过一半时再循环
            CGFloat ratio = (CGFloat)self.collectionView.contentOffset.y / (CGFloat)self.collectionView.bounds.size.height;
            if (ratio >= 0.5) {
                return;
            }
            targetPoint = CGPointMake(0, self.collectionView.bounds.size.height * (self.dataArray.count - 2) + self.collectionView.bounds.size.height / 2);
            self.pageControl.currentPage = self.dataArray.count - 2;
        } else if (page == self.dataArray.count - 1) { //滚动到下边
            targetPoint = CGPointMake(0, self.collectionView.bounds.size.height);
            self.pageControl.currentPage = 0;
        } else {
            self.pageControl.currentPage = page - 1;
            return;
        }
    }
    if (!self.collectionView.isDragging) {
        targetPoint = [self checkContentOffset:targetPoint];
    }
    self.collectionView.contentOffset = targetPoint;
}

- (UICollectionViewFlowLayout *)flowLayout {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:[self scrollDirection]];
    flowLayout.estimatedItemSize = CGSizeMake(100, 100);
    if (self.delegate && [self.delegate respondsToSelector:@selector(flowLayout)]) {
        flowLayout = [self.delegate flowLayout];
    }
    return flowLayout;
}

- (UICollectionViewScrollDirection)scrollDirection {
    UICollectionViewScrollDirection scrollDirection = UICollectionViewScrollDirectionHorizontal;
    if (self.delegate && [self.delegate respondsToSelector:@selector(swiperViewScrollDirection)]) {
        scrollDirection = [self.delegate swiperViewScrollDirection];
    }
    return scrollDirection;
}

- (NSTimeInterval)autoPlayTimeInterval {
    NSTimeInterval timeInterval = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(autoPlayTimeInterval)]) {
        timeInterval = [self.delegate autoPlayTimeInterval];
    }
    return timeInterval;
}

- (BOOL)loopPlay {
    BOOL loopPlay = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(loopPlay)]) {
        loopPlay = [self.delegate loopPlay];
    }
    return loopPlay;
}

- (NSInteger)currentPage {
    NSInteger curPage = 0;
    if ([self scrollDirection] == UICollectionViewScrollDirectionHorizontal) {
        curPage = self.collectionView.contentOffset.x / self.collectionView.bounds.size.width;
    } else {
        curPage = self.collectionView.contentOffset.y / self.collectionView.bounds.size.height;
    }
    return curPage;
}

- (BOOL)showPageControl {
    BOOL showPageControl = NO;
    if (self.delegate &&
        [self.delegate respondsToSelector:@selector(showPageControl)] &&
        [self.delegate respondsToSelector:@selector(pageControlRect)]) {
        showPageControl = [self.delegate showPageControl];
    }
    return showPageControl;
}

- (void)clearTimer {
    if (_autoPlayTimer) {
        [_autoPlayTimer invalidate];
        _autoPlayTimer = nil;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self.delegate swiperViewCellClass]) forIndexPath:indexPath];
    
    // ⚠️ 自定义cell 必须遵守 LWBSwiperViewCellProtocol 协议
    if ([cell conformsToProtocol:@protocol(LWBSwiperViewCellProtocol)]) {
        [cell performSelector:@selector(setData:) withObject:[self.dataArray objectAtIndex:indexPath.row]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat minimumLineSpacing = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(minimumLineSpacing)]) {
        minimumLineSpacing = [self.delegate minimumLineSpacing];
    }
    return minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    CGFloat minimumInteritemSpacing = 0;
    if (self.delegate && [self.delegate respondsToSelector:@selector(minimumInteritemSpacing)]) {
        minimumInteritemSpacing = [self.delegate minimumInteritemSpacing];
    }
    return minimumInteritemSpacing;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 因为为了实现内部循环，在原始数据上首尾各加了一个元素
    NSInteger row = indexPath.row;
    if ([self loopPlay]) {
        if (row < 1) {
            row = self.dataArray.count - 1;
        } else {
            row = row - 1;
        }
    }
    NSIndexPath *tempIndexPath = [NSIndexPath indexPathForRow:row inSection:indexPath.section];
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickCellWithCollectionView:indexPath:)]) {
        [self.delegate clickCellWithCollectionView:collectionView indexPath:tempIndexPath];
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self cycleScroll];
}

// 手动拖拽结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self cycleScroll];
    //拖拽动作后间隔多少s后继续轮播
    if (_autoPlay && [self autoPlayTimeInterval] > 0) {
        self.autoPlayTimer.fireDate = [NSDate dateWithTimeIntervalSinceNow:[self autoPlayTimeInterval]];
    }
    
    // 恢复父视图上的滚动视图 是否可滚动状态
    if (self.superScrollView) {
        self.superScrollView.scrollEnabled = self.superScrollViewScrollEnabled;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 如果父视图链上有滚动视图，为避免滚动冲突先把父视图设置为不可滚动
    if (!_superScrollView) {
        UIResponder *nextResponder = self.nextResponder;
        while (nextResponder != nil) {
            if ([nextResponder isKindOfClass:UIScrollView.class]) {
                UIScrollView *scrollView = (UIScrollView *)nextResponder;
                _superScrollViewScrollEnabled = scrollView.scrollEnabled;
                scrollView.scrollEnabled = NO;
                _superScrollView = scrollView;
                break;
            }
            nextResponder = nextResponder.nextResponder;
        }
    } else {
        _superScrollView.scrollEnabled = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    // 显示
    if (!decelerate) {
        // 恢复父视图上的滚动视图 是否可滚动状态
        if (self.superScrollView) {
            self.superScrollView.scrollEnabled = self.superScrollViewScrollEnabled;
        }
    }
}

#pragma mark - Getter && Setter

- (void)setAutoPlay:(BOOL)autoPlay {
    _autoPlay = autoPlay;
    
    [self clearTimer];
    
    if (self.dataArray.count <= 1) {
        return;
    }
    
    NSDate *fireDate = nil;
    if (autoPlay && [self autoPlayTimeInterval] > 0) {
        fireDate = [NSDate dateWithTimeIntervalSinceNow:[self autoPlayTimeInterval]];
        self.autoPlayTimer.fireDate = fireDate;
        [[NSRunLoop currentRunLoop] addTimer:self.autoPlayTimer forMode:NSRunLoopCommonModes];
    } else {
        // 如果不能自动播放或者自动播放的时间间隔小于 0 则不能自动滚动
        fireDate = [NSDate distantFuture];
    }
}

- (void)setDataArray:(NSArray *)dataArray {
    [self clearTimer];
    if (!dataArray || dataArray.count < 1) {
        return;
    }
    
    if ([self showPageControl]) {
        self.pageControl.numberOfPages = dataArray.count;
    }
    
    // 设置不循环滚动
    if (![self loopPlay]) {
        _dataArray = dataArray;
        [self.collectionView reloadData];
        return;
    }
    // 如果是循环播放，则需要在第一个位置和最后一个位置增加元素
    // 例如 1 2 3 4 5 =》 5 1 2 3 4 5 1
    NSMutableArray *loopArray = [NSMutableArray arrayWithArray:dataArray];
    [loopArray addObject:dataArray.firstObject];
    [loopArray insertObject:dataArray.lastObject atIndex:0];
    _dataArray = loopArray.copy;
    [self.collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self scrollDirection] == UICollectionViewScrollDirectionHorizontal) {
            [self.collectionView setContentOffset:CGPointMake(self.collectionView.bounds.size.width, 0)];
        } else {
            [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.bounds.size.height)];
        }
    });
    
}

- (NSTimer *)autoPlayTimer {
    if (!_autoPlayTimer) {
        __weak typeof (self) weakSelf = self;
        _autoPlayTimer = [NSTimer scheduledTimerWithTimeInterval:[self autoPlayTimeInterval] repeats:YES block:^(NSTimer * _Nonnull timer) {
            __strong typeof (self) self = weakSelf;
            [self showNext];
        }];
        _autoPlayTimer.fireDate = [NSDate distantFuture];
    }
    return _autoPlayTimer;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[self flowLayout]];
        UIColor *backgroundColor = [UIColor whiteColor];
        if (self.delegate && [self.delegate respondsToSelector:@selector(swiperBackgroundColor)]) {
            backgroundColor = [self.delegate swiperBackgroundColor];
        }
        _collectionView.backgroundColor = backgroundColor;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.pagingEnabled = YES;
        BOOL scrollEnabled = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(swiperScrollEnabled)]) {
            scrollEnabled = [self.delegate swiperScrollEnabled];
        }
        _collectionView.scrollEnabled = scrollEnabled;
        [_collectionView registerClass:[self.delegate swiperViewCellClass]
            forCellWithReuseIdentifier:NSStringFromClass([self.delegate swiperViewCellClass])];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        UIColor *pageIndicatorTintColor = [UIColor lightGrayColor];
        if (self.delegate && [self.delegate respondsToSelector:@selector(pageIndicatorTintColor)]) {
            pageIndicatorTintColor = [self.delegate pageIndicatorTintColor];
        }
        _pageControl.pageIndicatorTintColor = pageIndicatorTintColor;
        UIColor *currentPageIndicatorTintColor = [UIColor blackColor];
        if (self.delegate && [self.delegate respondsToSelector:@selector(currentPageIndicatorTintColor)]) {
            currentPageIndicatorTintColor = [self.delegate currentPageIndicatorTintColor];
        }
        _pageControl.currentPageIndicatorTintColor = currentPageIndicatorTintColor;
    }
    return _pageControl;
}

@end

//
//  LWBSwiperView.h
//  aiinquiry
//
//  Created by LWB on 2023/5/29.
//
//

#import <UIKit/UIKit.h>
#import "LWBSwiperViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface LWBSwiperView : UIView

@property (nonatomic, copy) NSArray *dataArray;
@property (nonatomic, assign) BOOL autoPlay;

- (instancetype)initWithDelegate:(id<LWBSwiperViewProtocol>)delegate;
- (NSInteger)curDisplayingCellIndex;

@end

NS_ASSUME_NONNULL_END

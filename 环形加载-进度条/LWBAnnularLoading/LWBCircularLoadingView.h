//
//  LWBCircularLoadingView.h
//  LWBLoading
//
//  Created by lwb on 2024/2/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LWBCircularLoadingType) {
    LWBCircularLoadingDefault  = 0, // 默认，环型加载动画
    LWBCircularLoadingProgress = 1, // 进度环
};

@interface LWBCircularLoadingStyle : NSObject

@property (nonatomic, assign) LWBCircularLoadingType type;
@property (nonatomic, strong) UIColor *fillColor;   // 默认透明色
@property (nonatomic, strong) UIColor *strokeColor; // 默认白色

@end

@interface LWBCircularLoadingView : UIView

/**
*可以从外界控制进度，LWBCircularLoadingProgress 样式下使用
 */
@property (nonatomic, assign) CGFloat progress;

- (instancetype)initWithFrame:(CGRect)frame style:(LWBCircularLoadingStyle *)style;

- (void)start;
- (void)stop;


@end

NS_ASSUME_NONNULL_END

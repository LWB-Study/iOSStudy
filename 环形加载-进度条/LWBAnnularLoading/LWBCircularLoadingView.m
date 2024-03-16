
//
//  LWBCircularLoadingView.m
//  LWBLoading
//
//  Created by lwb on 2024/2/21.
//

#import "LWBCircularLoadingView.h"

#define  kLWBlineWidth 4.0f

@implementation LWBCircularLoadingStyle

- (UIColor *)fillColor {
    if (!_fillColor) {
        return [UIColor clearColor];;
    }
    return _fillColor;
}

- (UIColor *)strokeColor {
    if (!_strokeColor) {
        return [UIColor whiteColor];
    }
    return _strokeColor;
}

@end


@interface LWBCircularLoadingView ()

@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, strong) CAShapeLayer *animationLayer;

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, strong) LWBCircularLoadingStyle *style;

@end

@implementation LWBCircularLoadingView

- (instancetype)initWithFrame:(CGRect)frame style:(LWBCircularLoadingStyle *)style {
    self = [super initWithFrame:frame];
    if (self) {
        _style = style;
//        if (!self.style.fillColor) {
//            self.style.fillColor = [UIColor clearColor];
//        }
//        if (!self.style.strokeColor) {
//            self.style.strokeColor = [UIColor whiteColor];
//        }
        
        [self setupSubViews];
        
        if (self.style.type == LWBCircularLoadingDefault) {
            self.link.paused = YES;
        }
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    return self;
}

- (void)setupSubViews {
    [self.layer addSublayer:self.animationLayer];
}

- (void)start {
    self.link.paused = NO;
}

- (void)stop {
    self.link.paused = YES;
    self.progress = 0;
    [self.link invalidate];
}

- (void)displayLinkAction {
    CGFloat tempProgress = _progress + [self speed];
    if (tempProgress >= 1) {
        tempProgress = 0;
    }
    self.progress = tempProgress;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self updateAnimationLayer];
}

- (void)updateAnimationLayer {
    _startAngle = - M_PI_2;
    _endAngle = - M_PI_2 + _progress * M_PI * 2;
    if (self.style.type == LWBCircularLoadingDefault) {
        if (_endAngle > M_PI) { // 进度大于 3/4
            CGFloat tempProgress = _progress / 0.25;
            _startAngle = - M_PI_2 + tempProgress * M_PI * 2;
        }
    }
    CGFloat radius = self.animationLayer.bounds.size.width / 2.0f - kLWBlineWidth / 2.0f;
    CGFloat centerX = self.animationLayer.bounds.size.width / 2.0f;
    CGFloat centerY = self.animationLayer.bounds.size.height / 2.0f;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(centerX, centerY)
                                                        radius:radius
                                                    startAngle:_startAngle
                                                      endAngle:_endAngle
                                                     clockwise:YES];
    path.lineCapStyle = kCGLineCapRound;
    self.animationLayer.path = path.CGPath;
}

- (CGFloat)speed {
    if (_endAngle > M_PI) {
        return 0.4 / 60.0f;
    }
    return 2 / 60.0f;
}

- (CAShapeLayer *)animationLayer {
    if (!_animationLayer) {
        _animationLayer = [[CAShapeLayer alloc] init];
        _animationLayer.bounds = self.bounds;
        _animationLayer.position = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0);
        _animationLayer.fillColor = self.style.fillColor.CGColor;
        _animationLayer.strokeColor = self.style.strokeColor.CGColor;
        _animationLayer.lineWidth = kLWBlineWidth;
        _animationLayer.lineCap = kCALineCapRound;
    }
    return _animationLayer;
}

- (CADisplayLink *)link {
    if (!_link) {
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
    return _link;
}

@end

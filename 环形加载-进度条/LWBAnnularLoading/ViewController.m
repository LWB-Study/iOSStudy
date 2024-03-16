//
//  ViewController.m
//  LWBAnnularLoading
//
//  Created by lwb on 2024/3/13.
//

#import "ViewController.h"
#import "LWBCircularLoadingView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 环形加载
    UILabel *label1 = [[UILabel alloc] init];
    label1.text = @"环形加载";
    label1.textColor = [UIColor blackColor];
    label1.frame = CGRectMake(100, 70, 100, 20);
    [self.view addSubview:label1];
    LWBCircularLoadingStyle *loadingStyle = [[LWBCircularLoadingStyle alloc] init];
    loadingStyle.type = LWBCircularLoadingDefault;
//    loadingStyle.fillColor = [UIColor clearColor];
//    loadingStyle.strokeColor = [UIColor whiteColor];
    LWBCircularLoadingView *loadingView = [[LWBCircularLoadingView alloc] initWithFrame:CGRectMake(0, 0, 36, 36) style:loadingStyle];
    loadingView.frame = CGRectMake(100, 100, 36, 36);
    [loadingView start];
    [self.view addSubview:loadingView];
    
    
    // 进度环
    UILabel *label2 = [[UILabel alloc] init];
    label2.text = @"进度环";
    label2.textColor = [UIColor blackColor];
    label2.frame = CGRectMake(100, 170, 100, 20);
    [self.view addSubview:label2];
    
    LWBCircularLoadingStyle *progressStyle = [[LWBCircularLoadingStyle alloc] init];
    progressStyle.type = LWBCircularLoadingProgress;
    progressStyle.fillColor = [UIColor clearColor];
    progressStyle.strokeColor = [UIColor redColor];
    LWBCircularLoadingView *progressView = [[LWBCircularLoadingView alloc] initWithFrame:CGRectMake(0, 0, 36, 36) style:progressStyle];
    progressView.frame = CGRectMake(100, 200, 36, 36);
//    [progressView start];
    [self.view addSubview:progressView];
    
    __block CGFloat progress = 0;
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
        progress += 0.01;
        if (progress == 1) {
            progress = 0;
        }
        progressView.progress = progress;
    }];
}


@end

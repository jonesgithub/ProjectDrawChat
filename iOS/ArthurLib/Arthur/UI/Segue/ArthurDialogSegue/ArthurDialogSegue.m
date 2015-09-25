//
//  ArthurDialogSegue.m
//  CustomSegue
//
//  Created by lichen on 6/11/14.
//  Copyright (c) 2014 Minicoder. All rights reserved.
//

#import "ArthurDialogSegue.h"

@interface ArthurModalContainerViewController : UIViewController

@property (nonatomic, strong) UIViewController* destinationController;
- (void)backgroundTouched;

@end

@implementation ArthurModalContainerViewController
- (void)backgroundTouched
{
    [ArthurDialogSegue dismissDialogView:self.destinationController.view];
    //注意，下面这句非常重要
    //点击背景后，滚轮可能还在动
    //如果下面的不置空，会发送事件到controller，所以强制清空view
    self.destinationController.view = nil;
}
@end

@implementation ArthurDialogSegue

static ArthurModalContainerViewController *globalArthurModalContainerViewController;

//重写
- (void)perform
{
    //验证类
    AssertClass(self.sourceViewController, UIViewController);
    AssertClass(self.destinationViewController, UIViewController);
    UIViewController *sourceViewController = (UIViewController *)self.sourceViewController;
    UIViewController *destinationViewController = (UIViewController *)self.destinationViewController;
    
    //全局拥用destinationController
    if (!globalArthurModalContainerViewController) {
        globalArthurModalContainerViewController = [[ArthurModalContainerViewController alloc] init];
    }
    globalArthurModalContainerViewController.destinationController = destinationViewController;
    
    //更改destinationViewController的背景为clear，以显示原有内容
//    destinationViewController.view.backgroundColor = RGBA(255, 255, 255, 0.5);
    destinationViewController.view.backgroundColor = [UIColor clearColor];
    
    //验证背景已改成UIControl, 注册背景触摸事件
    AssertClass(destinationViewController.view, UIControl);
    UITapGestureRecognizer *backgroundTouchedGesture = [[UITapGestureRecognizer alloc] initWithTarget:globalArthurModalContainerViewController action:@selector(backgroundTouched)];
    backgroundTouchedGesture.numberOfTapsRequired = 1;
    
    //保证superview也可被点击
    //下面的代码未按预期运行
//    backgroundTouchedGesture.cancelsTouchesInView = NO;
//    backgroundTouchedGesture.delaysTouchesBegan = NO;
    
    [destinationViewController.view addGestureRecognizer:backgroundTouchedGesture];
    
    //原始frame
    CGRect origialFrame = destinationViewController.view.frame;
    //添加到底部，再动画移到原始位置
    destinationViewController.view.frame = CGRectMake(0, origialFrame.size.height, origialFrame.size.width, origialFrame.size.height*2);
    if (sourceViewController.navigationController) {
        [sourceViewController.navigationController.view addSubview:destinationViewController.view];
    } else {
        [sourceViewController.view addSubview:destinationViewController.view];
    }
    [[self class ] MoveView:destinationViewController.view To:origialFrame During:0.5];
}


//动画地把一个view移动到另一个地方
//注意: 此方法马上返回，不卡time时长
+ (void)MoveView:(UIView *)view To:(CGRect)frame During:(float)time{
    // 动画开始
    [UIView beginAnimations:nil context:nil];
    // 动画时间曲线 EaseInOut效果
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; 
    // 动画时间
    [UIView setAnimationDuration:time];
    view.frame = frame;
    // 动画结束（或者用提交也不错）
    [UIView commitAnimations];
}

//为简化外部需在显示的dialog，提供一个类方法，可以直接显示
+ (void)showDialogController:(UIViewController *) dialogController 
                inController:(UIViewController *) inController 
         withSegueIdentifier: (NSString *)strSegueIdentifier
{
    ArthurDialogSegue *dialogSegue = [[ArthurDialogSegue alloc] initWithIdentifier:strSegueIdentifier source:inController destination:dialogController];
    [dialogSegue perform];
}

+ (void)dismissDialogView:(UIView *)view
{
    //原始frame
    CGRect origialFrame = view.frame;
    CGRect toFrame = CGRectMake(0, origialFrame.size.height, origialFrame.size.width, origialFrame.size.height*2);
    //添加到底部，再动画移到原始位置
    [self MoveView:view To:toFrame During:0.5];
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:[NSBlockOperation blockOperationWithBlock:^{
        [view removeFromSuperview];
    }]
                                   selector:@selector(main)
                                   userInfo:nil
                                    repeats:NO
     ];
}

@end

//
//  NeediatorActivityIndicator.m
//  Neediator
//
//  Created by Vinod Rathod on 28/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NeediatorActivityIndicator.h"

@interface NeediatorActivityIndicator ()
@property (nonatomic, strong) UIImageView *activityImageView;
@property (nonatomic, strong) CABasicAnimation *rotationAnimation;
@end

@implementation NeediatorActivityIndicator

CGFloat RotationDuration = 0.5;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupBar];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupBar];
    }
    return self;
}

- (void)setupBar
{
    
    self.backgroundColor = [NeediatorUtitity defaultColor];
    self.userInteractionEnabled = NO;
    
    UIImage *statusImage = [UIImage imageNamed:@"icon7.png"];
    _activityImageView = [[UIImageView alloc]
                         initWithImage:statusImage];
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, _activityImageView.frame);
    
    _activityImageView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _activityImageView.layer.shadowOffset = CGSizeMake(0.f, 2.f);
    _activityImageView.layer.shadowOpacity = 1;
    _activityImageView.layer.shadowRadius = 2.0;
    _activityImageView.layer.masksToBounds = NO;
//    _activityImageView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_activityImageView.bounds cornerRadius:80.f].CGPath;
    _activityImageView.layer.shadowPath = path;
    
    _activityImageView.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"icon7.png"],
                                         nil];
//    _activityImageView.animationDuration = 0.8 * 2;
    
    
    _activityImageView.frame = CGRectMake(0, 0, statusImage.size.width, statusImage.size.height);
    
    CFRelease(path);
    
    [self layoutSubviews];
    [self addSubview:_activityImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _activityImageView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
}

- (void)fadeInAnimated:(BOOL)animated
{
    [self fadeInAnimated:animated completion:nil];
}

- (void)fadeOutAnimated:(BOOL)animated
{
    [self fadeOutAnimated:animated completion:nil];
}

- (void)fadeInAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    self.alpha = 0;
    [self startAnimating];
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 1;
        } completion:completion];
    }
    
    
}

- (void)fadeOutAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    self.alpha = 1;
    [self stopAnimating];
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:completion];
    }
}

- (void)startAnimating
{
    [self animate:LONG_MAX];
}

- (void)animate:(NSInteger)times
{
    //    CATransform3D rotationTransform = CATransform3DMakeRotation(-1.01f * M_PI, 0, 0, 1.0);
    CATransform3D rotationTransform = CATransform3DMakeRotation(M_PI_2, 0, 1.0, 0);
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    
    rotationAnimation.toValue = [NSValue valueWithCATransform3D:rotationTransform];
    rotationAnimation.duration = RotationDuration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = times;
    [_activityImageView.layer addAnimation:rotationAnimation forKey:@"transform"];
}

- (void)stopAnimating
{
    [self.layer removeAllAnimations];
    [self animate:1];
}

-(UIColor *)overlayColor {
    return self.backgroundColor;
}


-(void)setOverlayColor:(UIColor *)overlayColor {
    self.backgroundColor = overlayColor;
}

@end

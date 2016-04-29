//
//  NeediatorHUD.m
//  Neediator
//
//  Created by adverto on 28/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "NeediatorHUD.h"

@interface NeediatorHUD ()

@property (nonatomic, strong) UIImageView *activityImageView;
@property (nonatomic, strong) CABasicAnimation *rotationAnimation;
@end

@implementation NeediatorHUD

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
    
    
//    UIView *blurView = [[UIView alloc] initWithFrame:[UIWindow ]];
//    blurView.backgroundColor = [UIColor whiteColor];
//    blurView.alpha = 0.6f;
    
    UIImage *statusImage = [UIImage imageNamed:@"icon7.png"];
    _activityImageView = [[UIImageView alloc]
                          initWithImage:statusImage];
    
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(2.5f, 35, 40, 10));
    
    _activityImageView.layer.shadowColor = [UIColor colorWithRed:235/255.f green:235/255.f blue:235/255.f alpha:1.0].CGColor;
    _activityImageView.layer.shadowOffset = CGSizeMake(0.f, (0.44 * _activityImageView.frame.size.height));
    _activityImageView.layer.shadowOpacity = 1;
    _activityImageView.layer.shadowRadius = 2.0;
    _activityImageView.layer.masksToBounds = NO;
//    _activityImageView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2 + 120);
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
    
//    [self addSubview:blurView];
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    _activityImageView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2 + 120.f);
//}

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

-(CGPoint)hudCenter {
    return _activityImageView.center;
}

-(void)setHudCenter:(CGPoint)hudCenter {
    _activityImageView.center = hudCenter;
}


-(CGSize)logoSize {
    return _activityImageView.frame.size;
}

-(void)setLogoSize:(CGSize)logoSize {
    _activityImageView.frame = CGRectMake(0, 0, logoSize.width, logoSize.height);
    _activityImageView.layer.shadowOffset = CGSizeMake(0.f, (0.34 * _activityImageView.frame.size.height));
    NSLog(@"%@", NSStringFromCGSize(CGSizeMake(0.f, (0.44 * _activityImageView.frame.size.height))));
    _activityImageView.layer.shadowOpacity = 1;
    _activityImageView.layer.shadowRadius = 2.0;
    _activityImageView.layer.masksToBounds = NO;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, NULL, CGRectMake(0, _activityImageView.frame.size.height, logoSize.width, (0.24 * _activityImageView.frame.size.height)));
    _activityImageView.layer.shadowPath = path;
    CFRelease(path);
}


-(void)setShadowColor:(UIColor *)shadowColor {
    _activityImageView.layer.shadowColor = shadowColor.CGColor;
}

@end

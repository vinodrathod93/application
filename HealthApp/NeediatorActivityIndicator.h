//
//  NeediatorActivityIndicator.h
//  Neediator
//
//  Created by Vinod Rathod on 28/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NeediatorActivityIndicator : UIView


- (void)fadeInAnimated:(BOOL)animated;
- (void)fadeOutAnimated:(BOOL)animated;

- (void)fadeInAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;
- (void)fadeOutAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion;

- (void)startAnimating;
- (void)stopAnimating;

@property (nonatomic, strong) UIColor *overlayColor;
@end

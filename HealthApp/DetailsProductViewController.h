//
//  DetailsProductViewController.h
//  Chemist Plus
//
//  Created by adverto on 17/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailProductViewModel.h"
#import "ProductDetail.h"
#import "RMPZoomTransitionAnimator.h"


@interface DetailsProductViewController : UITableViewController<UIScrollViewDelegate, RMPZoomTransitionAnimating, RMPZoomTransitionDelegate>

@property (nonatomic, strong) DetailProductViewModel *viewModel;
@property (nonatomic,strong) ProductDetail *detail;

@end



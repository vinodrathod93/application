//
//  ProductDetailsViewController.h
//  Neediator
//
//  Created by adverto on 20/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailProductViewModel.h"
#import "ProductDetail.h"

@interface ProductDetailsViewController : UIViewController<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
@property (weak, nonatomic) IBOutlet UILabel *productDescription;

@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;

@property (nonatomic, strong) DetailProductViewModel *viewModel;
@property (nonatomic,strong) ProductDetail *detail;
@end

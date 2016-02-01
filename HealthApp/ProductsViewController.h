//
//  ProductsViewController.h
//  Chemist Plus
//
//  Created by adverto on 14/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMPZoomTransitionAnimator.h"

@interface ProductsViewController : UICollectionViewController<RMPZoomTransitionAnimating>

@property (nonatomic, strong) NSString *subCategoryID;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) NSString *navigationTitleString;
@property (nonatomic, strong) NSString *taxonProductsURL;


@property (nonatomic, strong) NSString *taxonID;
@property (nonatomic, strong) NSString *taxonomyID;
@property (nonatomic, strong) NSString *storeID;


@end


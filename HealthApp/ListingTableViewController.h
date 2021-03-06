//
//  ListingTableViewController.h
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "FilterTableViewController.h"
#import "iCarousel.h"

@interface ListingTableViewController : UITableViewController<UIGestureRecognizerDelegate,UIScrollViewDelegate, FilterListingDelegate, iCarouselDelegate, iCarouselDataSource>

@property (nonatomic, strong) NSString *root;
@property (nonatomic, strong) NSString *nav_color;

@property (nonatomic, strong) NSString *category_id;
@property (nonatomic, strong) NSString *subcategory_id;



@end

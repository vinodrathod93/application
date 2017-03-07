//
//  OrderReviewViewController.h
//  Chemist Plus
//
//  Created by adverto on 05/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderReviewCell.h"

@interface OrderReviewViewController : UITableViewController

@property (nonatomic, strong) NSArray *line_items;
@property (nonatomic, strong) NSString *order_id;

@property (nonatomic, strong) NSString *purchase_total;
@property (nonatomic, strong) NSString *tax_total;
@property (nonatomic, strong) NSString *complete_total;

@end

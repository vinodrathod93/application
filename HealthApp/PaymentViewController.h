//
//  PaymentViewController.h
//  Chemist Plus
//
//  Created by adverto on 21/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentViewController : UITableViewController


@property (nonatomic, strong) NSString *display_total;
@property (nonatomic, strong) NSString *display_item_total;
@property (nonatomic, strong) NSString *display_delivery_total;

@property (nonatomic, strong) NSDictionary *shipAddress;
@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, strong) NSArray *payment_methods;
@property (nonatomic, strong) NSString *store;

@end

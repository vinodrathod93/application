//
//  PaymentViewController.h
//  Chemist Plus
//
//  Created by adverto on 21/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface PaymentViewController : UITableViewController


@property (nonatomic, strong) Order *orderModel;
@end

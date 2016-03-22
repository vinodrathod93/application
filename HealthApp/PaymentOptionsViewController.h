//
//  PaymentOptionsViewController.h
//  Neediator
//
//  Created by adverto on 01/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Order.h"

@interface PaymentOptionsViewController : UITableViewController

@property (nonatomic, strong) NSString *address_id;
@property (nonatomic, strong) Order *orderModel;
@property (nonatomic, strong) NSArray *payment_types;
@property (nonatomic, strong) NSArray *delivery_types;
@end

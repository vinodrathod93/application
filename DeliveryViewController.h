//
//  DeliveryViewController.h
//  Chemist Plus
//
//  Created by adverto on 02/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeliveryViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *shipping_data;
@property (nonatomic, strong) NSString *order_id;

@end

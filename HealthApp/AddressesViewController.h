//
//  AddressesViewController.h
//  Chemist Plus
//
//  Created by adverto on 20/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressesViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *addresses;
@property (nonatomic, strong) NSString     *order_id;
@property (nonatomic, assign) BOOL isGettingOrder;

@end

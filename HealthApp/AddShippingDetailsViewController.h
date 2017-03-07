//
//  AddShippingDetailsViewController.h
//  Chemist Plus
//
//  Created by adverto on 29/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddShippingViewCell.h"

@interface AddShippingDetailsViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *cartDetails;


- (IBAction)editingChanged:(id)sender;

@end

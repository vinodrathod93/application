//
//  CartViewController.h
//  Chemist Plus
//
//  Created by adverto on 23/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CartViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
- (IBAction)quantityPressed:(id)sender;

@end

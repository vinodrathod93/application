//
//  TaxonsViewController.h
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "RRNCollapsableSectionTableViewController.h"

@interface TaxonsViewController : RRNCollapsableTableViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *storeURL;

@end

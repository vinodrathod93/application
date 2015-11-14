//
//  TaxonsViewController.h
//  Chemist Plus
//
//  Created by adverto on 14/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SLExpandableTableView.h>

@interface TaxonsViewController : UITableViewController<SLExpandableTableViewDatasource, SLExpandableTableViewDelegate>

@property (nonatomic, strong) NSString *storeURL;

@end

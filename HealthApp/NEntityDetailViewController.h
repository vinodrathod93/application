//
//  NEntityDetailViewController.h
//  Neediator
//
//  Created by adverto on 20/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NEntityDetailViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSString *cat_id;
@property (nonatomic, strong) NSString *entity_id;

@end

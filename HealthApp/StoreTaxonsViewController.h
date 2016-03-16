//
//  StoreTaxonsViewController.h
//  Chemist Plus
//
//  Created by adverto on 16/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreTaxonsViewController : UIViewController<UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *storeURL;
@property (nonatomic, strong) NSArray *storeImages;

//Neediator API
@property (nonatomic, strong) NSString *cat_id;
@property (nonatomic, strong) NSString *store_id;

@property (nonatomic, strong) NSArray *storePhoneNumbers;

@end

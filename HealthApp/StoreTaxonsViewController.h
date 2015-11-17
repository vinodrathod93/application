//
//  StoreTaxonsViewController.h
//  Chemist Plus
//
//  Created by adverto on 16/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKSTableView.h"

@interface StoreTaxonsViewController : UIViewController<SKSTableViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet SKSTableView *tableView;
@property (nonatomic, strong) NSString *storeURL;

@end

//
//  MyOrdersVC.h
//  Neediator
//
//  Created by adverto on 17/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrdersVC : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *PrescriptionContainerView;

- (IBAction)OrdersAction:(id)sender;
- (IBAction)PrescriptionAction:(id)sender;


@end

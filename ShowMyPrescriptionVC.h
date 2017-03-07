//
//  ShowMyPrescriptionVC.h
//  Neediator
//
//  Created by adverto on 28/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowMyPrescriptionVC : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource,MWPhotoBrowserDelegate,UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;




@end

//
//  HomeViewController.h
//  Chemist Plus
//
//  Created by adverto on 10/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeaderView.h"

@interface HomeViewController : UITableViewController<UIScrollViewDelegate>



@property (nonatomic, strong) HeaderView *headerView;
@end

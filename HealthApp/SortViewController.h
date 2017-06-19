//
//  SortViewController.h
//  Neediator
//
//  Created by Vinod Rathod on 20/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SortListModel.h"
#import "SortOrderModel.h"

@class SortViewController;

@protocol SortViewDelegate <NSObject>

-(void)sortViewController:(SortViewController *)viewController didSelectSort:(SortListModel *)model withSortOrderModel:(SortOrderModel *)orderModel;

@end

@interface SortViewController : UIViewController

@property (nonatomic, strong) NSArray *sortListing;
@property (nonatomic, weak) id <SortViewDelegate> delegate;

@end

//
//  FilterTableViewController.h
//  Neediator
//
//  Created by adverto on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterListModel.h"
#import "FilterHelperModel.h"
#import "FilterSliderViewCell.h"
#import "FilterSwitchViewCell.h"


@protocol FilterListingDelegate <NSObject>

-(void)appliedFilterListingDelegate:(NSDictionary *)data;

@end

@interface FilterTableViewController : UITableViewController<SliderFilterDelegate>

@property (nonatomic, strong) NSArray *filterArray;
@property (nonatomic, weak) id<FilterListingDelegate> delegate;

@end

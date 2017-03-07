//
//  FilterViewController.h
//  Neediator
//
//  Created by Vinod Rathod on 03/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FilterViewController;

@protocol NewFilterListingDelegate <NSObject>

-(void)appliedFilter:(FilterViewController *)filterVC withSelectedParameter:(NSDictionary *)data;

@end



@interface FilterViewController : UIViewController

@property (nonatomic, strong) NSArray *filterArray;

@property (nonatomic, weak) id<NewFilterListingDelegate> delegate;

@end

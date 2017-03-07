//
//  AreaFilterViewController.h
//  Neediator
//
//  Created by Vinod Rathod on 04/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AreaFilterViewController;

@protocol AreaFilterDelegate <NSObject>

-(void)appliedAreaFilter:(AreaFilterViewController *)viewcontroller withData:(NSDictionary *)data;

@end

@interface AreaFilterViewController : UIViewController

@property (nonatomic, strong) NSArray *areas;

@property (nonatomic, weak) id<AreaFilterDelegate> delegate;


@end

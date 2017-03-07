//
//  WorkingHoursViewController.h
//  Neediator
//
//  Created by Vinod Rathod on 04/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WorkingHoursViewController;

@protocol WorkingHoursDelegate <NSObject>

-(void)workingHoursAppliedFilter:(WorkingHoursViewController *)viewcontroller withData:(NSDictionary *)data;

@end



@interface WorkingHoursViewController : UIViewController

@property (nonatomic, weak) id<WorkingHoursDelegate> delegate;

@end

//
//  ToggleViewController.h
//  Neediator
//
//  Created by Vinod Rathod on 04/03/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ToggleViewController;

@protocol ToggleFilterDelegate <NSObject>

-(void)appliedToggleFilter:(ToggleViewController *)viewcontroller withData:(NSDictionary *)data;

@end



@interface ToggleViewController : UIViewController

@property (nonatomic, strong) NSArray *toggleArray;
@property (nonatomic, strong) NSMutableDictionary *toggleDictionary;
@property (nonatomic, weak) id<ToggleFilterDelegate> delegate;

@end

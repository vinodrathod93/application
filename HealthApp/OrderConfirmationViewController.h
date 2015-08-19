//
//  OrderConfirmationViewController.h
//  Chemist Plus
//
//  Created by adverto on 08/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderConfirmationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *orderMessageView;
@property (weak, nonatomic) IBOutlet UILabel *orderIDLabel;
@property (nonatomic ,strong) NSString *orderIDString;
- (IBAction)continuePressed:(id)sender;
@end

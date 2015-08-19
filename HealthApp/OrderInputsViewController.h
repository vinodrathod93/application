//
//  OrderInputsViewController.h
//  Chemist Plus
//
//  Created by adverto on 27/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderInputsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;

- (IBAction)proceedPressed:(id)sender;
@end

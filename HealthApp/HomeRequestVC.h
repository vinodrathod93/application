//
//  HomeRequestVC.h
//  Neediator
//
//  Created by adverto on 10/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressesViewController.h"


@interface HomeRequestVC : UIViewController<AddressDelegate>


@property (weak, nonatomic) IBOutlet NTextField *Date_TF;
@property (weak, nonatomic) IBOutlet UITextField *TimeSlotFrom_TF;
@property (weak, nonatomic) IBOutlet UITextField *TimeSlotTo_TF;
@property (weak, nonatomic) IBOutlet UIButton *PurposeButton;
@property (weak, nonatomic) IBOutlet UIButton *EDIT_Button;
@property (weak, nonatomic) IBOutlet UIButton *AddressTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *ShowAddressButton;
@property (weak, nonatomic) IBOutlet UIButton *AddNewAddressButton;
@property (weak, nonatomic) IBOutlet UITextField *optionalTF;
@property (weak, nonatomic) IBOutlet UIButton *Proceed_Button;
- (IBAction)proceedAction:(id)sender;


@end

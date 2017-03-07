//
//  AftrCheckoutVC.h
//  Neediator
//
//  Created by adverto on 12/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "AddressesViewController.h"

@interface AftrCheckoutVC : UIViewController<AddressDelegate>


@property (weak, nonatomic) IBOutlet UIButton *orderTypeBtn;
@property (weak, nonatomic) IBOutlet NTextField *Date_TF;
@property (weak, nonatomic) IBOutlet UITextField *Time_slot_from;
@property (weak, nonatomic) IBOutlet UITextField *Time_slot_to;
@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;


@property (weak, nonatomic) IBOutlet UIButton *addressTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *AddressTitle;
@property (weak, nonatomic) IBOutlet UIButton *AddNewAddressBtn;

@property (weak, nonatomic) IBOutlet UITextField *Optional_TF;


- (IBAction)Proceed_Action:(id)sender;








@property(nonatomic,retain)NSString *PayAmount;
@property(nonatomic,retain)NSString *Storename;
@property(nonatomic,retain)NSString *noofItems;



@end

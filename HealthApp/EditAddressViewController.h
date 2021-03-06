//
//  EditAddressViewController.h
//  Neediator
//
//  Created by adverto on 26/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "TPKeyboardAvoidingScrollView.h"


@protocol EditedAddressDelegate <NSObject>

-(void)addressDidSaved:(NSArray *)addresses;

@end

@interface EditAddressViewController : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *billingNametTextField;
@property (weak, nonatomic) IBOutlet UITextField *buildingNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *wingTextFiedl;
@property (weak, nonatomic) IBOutlet UITextField *flatNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *floorNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *roadTextField;
@property (weak, nonatomic) IBOutlet UITextField *landMarkTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *pincodeTextField;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *cityTextfield;
@property (weak, nonatomic) IBOutlet UITextField *areaTextField;

@property (weak, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *saveNContinueButton;

@property (nonatomic, strong) NSDictionary *shipAddress;


@property (nonatomic, weak) id<EditedAddressDelegate> delegate;

@end

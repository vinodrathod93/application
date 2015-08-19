//
//  PlaceOrderViewController.h
//  Chemist Plus
//
//  Created by adverto on 07/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceOrderViewController : UIViewController<UIActionSheetDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *mobileTextField;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *pincode;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (strong, nonatomic) NSDictionary *dataDictionary;

- (IBAction)placeOrderPressed:(id)sender;
- (IBAction)cityPressed:(id)sender;
@end

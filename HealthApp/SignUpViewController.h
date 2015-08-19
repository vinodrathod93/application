//
//  SignUpViewController.h
//  Chemist Plus
//
//  Created by adverto on 06/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignUpViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;

- (IBAction)signUpPressed:(id)sender;
@end

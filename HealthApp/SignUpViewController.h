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
@property (weak, nonatomic) IBOutlet UITextField *mobileField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIView *s_contentView;
@property (weak, nonatomic) IBOutlet UITextField *dateOfBirthField;

- (IBAction)signUpPressed:(id)sender;



@property (weak, nonatomic) IBOutlet UITextField *LastnameTf;



@property (weak, nonatomic) IBOutlet UIButton *malebtn;
@property (weak, nonatomic) IBOutlet UIButton *femalebtn;

@property (weak, nonatomic) IBOutlet UIButton *CheckBoxButton;

- (IBAction)FemaleAction:(id)sender;
- (IBAction)maleAction:(id)sender;



@property(nonatomic,retain)NSString *maleorFemaleString;

@property (nonatomic, assign)BOOL isPlacingOrder;
@end

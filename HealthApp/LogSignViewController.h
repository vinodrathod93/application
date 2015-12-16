//
//  LogSignViewController.h
//  Chemist Plus
//
//  Created by adverto on 07/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NTextField.h"

//#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LogSignViewController : UIViewController<UITextFieldDelegate>
//<FBSDKLoginButtonDelegate>

//@property (weak, nonatomic) IBOutlet FBSDKLoginButton *login_fb_button;
//@property (weak, nonatomic) IBOutlet UIButton *registerButton;
//@property (weak, nonatomic) IBOutlet UIButton *signInButton;
//@property (nonatomic, assign)BOOL isPlacingOrder;

@property (weak, nonatomic) IBOutlet NTextField *emailField;
@property (weak, nonatomic) IBOutlet NTextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, assign) BOOL isPlacingOrder;

@property (weak, nonatomic) IBOutlet UIImageView *emailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImageView;
@end

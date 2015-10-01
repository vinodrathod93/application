//
//  SignUpViewController.m
//  Chemist Plus
//
//  Created by adverto on 06/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "SignUpViewController.h"
#import "User.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSString+SignupValidation.h"

//#define kREGISTER_URL @"http://chemistplus.in/register_test.php"
#define kSign_up_url @"http://www.elnuur.com/api/users/sign_up"

@interface SignUpViewController ()<UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;

@end

typedef void(^completion)(BOOL finished);

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signUpButton.layer.cornerRadius = 3.0f;
    
    self.userName.delegate = self;
    self.passwordField.delegate = self;
    self.emailField.delegate = self;
    self.confirmPasswordField.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.userName becomeFirstResponder];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"viewWillDisappear");
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSLog(@"viewDidDisappear");
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}


-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
     NSLog(@"%f",self.scrollView.frame.origin.y);
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:self.userName]) {
        [self.emailField becomeFirstResponder];
    }
    else if ([textField isEqual:self.emailField]) {
        [self.passwordField becomeFirstResponder];
    }
    else if ([textField isEqual:self.passwordField]) {
        [self.confirmPasswordField becomeFirstResponder];
    }
    else if ([textField isEqual:self.confirmPasswordField]) {
        [self signUpPressed:nil];
    }
    
    return YES;
}


- (IBAction)signUpPressed:(id)sender {
    
    NSString *errorMessage = [self validateForm];
    if (errorMessage) {
        [self alertWithTitle:@"Error" message:errorMessage];
    }
    else if (![self.userName.text isEqualToString:@""] || ![self.emailField.text isEqualToString:@""]) {
        [self submitSignupDataWithCompletion:^(BOOL finished) {
            if (finished) {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    NSLog(@"Placing Order");
                    
                    if (self.isPlacingOrder) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"loggedInSendOrderNotification" object:nil];
                    }
                    
                }];
            } else
                NSLog(@"Could not login");
        }];
    }
}


-(void)submitSignupDataWithCompletion:(completion)isLoggedIn {
    NSURL *url = [NSURL URLWithString:kSign_up_url];
    NSString *user_data = [NSString stringWithFormat:@"user[email]=%@&user[password]=%@&user[password_confirmation]=%@",self.emailField.text,self.passwordField.text, self.confirmPasswordField.text];
    NSData *post_data = [NSData dataWithBytes:[user_data UTF8String] length:[user_data length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = post_data;
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            // Hide the HUD
            [self.hud hide:YES];
            
            if (jsonError) {
                NSLog(@"Error %@",[jsonError localizedDescription]);
            } else {
                NSLog(@"JSON is =====> %@",json);
                
                NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                NSLog(@"Response %ld", (long)[url_response statusCode]);
                
                if (url_response.statusCode == 401) {
                    NSString *error = [json valueForKey:@"error"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self alertWithTitle:@"Error" message:error];
                    });
                    
                    isLoggedIn(NO);
                    
                } else if (url_response.statusCode == 200) {
                    
                    User *user              = [[User alloc]init];
                    user.userID             = [json valueForKey:@"id"];
                    user.access_token       = [json valueForKey:@"access_token"];
                    user.email              = [json valueForKey:@"email"];
                    user.default_country_id = [json valueForKey:@"default_country_id"];
                    user.bill_address       = [json valueForKey:@"bill_address"];
                    user.ship_address       = [json valueForKey:@"ship_address"];
                    
                    [user save];
                    
                    isLoggedIn(YES);
                }
            }
            
        });
        
    }];
    
    [task resume];
    
    // display HUD
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
    
}

-(void)alertWithTitle:(NSString *)status message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}




-(NSString *)validateForm {
    NSString *errorMessage;

    if (![self.userName.text isValidName]) {
        errorMessage = @"Please enter a valid name";
    } else if (![self.emailField.text isValidEmail]) {
        errorMessage = @"Please enter a valid email";
    } else if (![self.passwordField.text isValidPassword]) {
        errorMessage = @"Please enter a valid password";
    } else if (![self.confirmPasswordField.text isEqualToString:self.passwordField.text]) {
        errorMessage = @"Password doesn't match";
    }
    
    return errorMessage;
    
}

@end

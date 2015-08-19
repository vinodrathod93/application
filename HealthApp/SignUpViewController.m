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

#define kREGISTER_URL @"http://chemistplus.in/register_test.php"

@interface SignUpViewController ()<UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic, assign)BOOL isLoggedIn;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

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
        [self submitInfo];
    }
}

-(void)submitInfo {
    NSURL *url = [NSURL URLWithString:kREGISTER_URL];
    NSString *user_data = [NSString stringWithFormat:@"username=%@&email=%@&password=%@",self.userName.text,self.emailField.text, self.confirmPasswordField.text];
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
            NSString *message = [json valueForKey:@"Message"];
            NSString *status = [json valueForKey:@"Status"];
            NSString *userID = [json valueForKey:@"userID"];
            
            // Hide the HUD
            [self.hud hide:YES];
            
            if (jsonError) {
                NSLog(@"Error %@",[jsonError localizedDescription]);
            } else {
                
                if ([status isEqualToString:@"Success"]) {
                    self.isLoggedIn = YES;
                    
                    User *user = [[User alloc]init];
                    user.fullName = self.userName.text;
                    user.email = self.emailField.text;
                    user.userID = userID;
                    [user save];
                    
                    [self alertWithTitle:status message:message];
                    
                }
                else if ([status isEqualToString:@"Error"]) {
                    self.isLoggedIn = NO;
                    
                    [self alertWithTitle:status message:message];
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


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"Cancel pressed");
        if (self.isLoggedIn) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
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

//
//  LogSignViewController.m
//  Chemist Plus
//
//  Created by adverto on 07/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "LogSignViewController.h"
#import "User.h"
#import "SignInViewController.h"
#import "SignUpViewController.h"
#import "AppDelegate.h"

#define REGISTER_URL @"http://chemistplus.in/register_test.php"
#define PROFILE_URL @"https://graph.facebook.com/%@/picture?type=large"

@interface LogSignViewController ()

@end

@implementation LogSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.signInButton.layer.cornerRadius = 3.0f;
    self.registerButton.layer.cornerRadius = 3.0f;
    
    
    self.login_fb_button.delegate = self;
    self.login_fb_button.readPermissions = @[@"email", @"public_profile"];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - FBSDKLoginButtonDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error {
    if (error) {
        NSLog(@"Unexpected login error: %@", error);
        NSString *alertMessage = error.userInfo[FBSDKErrorLocalizedDescriptionKey] ?: @"There was a problem logging in. Please try again later.";
        NSString *alertTitle = error.userInfo[FBSDKErrorLocalizedTitleKey] ?: @"Oops";
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    } else {
        NSLog(@"logged in");
        
        
        FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields":@"email, name, first_name, last_name"}];
        [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
            if (error == nil) {
                NSLog(@"User information ==== %@",result);
                
                [self uploadUserDetailsWithResult:result];
                
            } else {
                NSLog(@"Error getting info %@",error);
            }
        }];
        
    }
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    NSLog(@"Logged out");
}


- (IBAction)signInButtonPressed:(id)sender {
    SignInViewController *signInVC = [self.storyboard instantiateViewControllerWithIdentifier:@"signInVC"];
    signInVC.isPlacingOrder = self.isPlacingOrder;
    [self.navigationController pushViewController:signInVC animated:YES];
}

- (IBAction)registerButtonPressed:(id)sender {
    SignUpViewController *signUpVC = [self.storyboard instantiateViewControllerWithIdentifier:@"registerVC"];
    signUpVC.isPlacingOrder = self.isPlacingOrder;
    [self.navigationController pushViewController:signUpVC animated:YES];
}


-(void)uploadUserDetailsWithResult:(NSDictionary *)result {
    
    NSString *email = result[@"email"];
    NSString *username = result[@"name"];
    NSString *firstName = result[@"first_name"];
    NSString *lastName = result[@"last_name"];
    NSString *userProfilePic = [NSString stringWithFormat:PROFILE_URL,result[@"id"]];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *postString = [NSString stringWithFormat:@"email=%@&username=%@",email, username];
    NSURL *url = [NSURL URLWithString:REGISTER_URL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSData dataWithBytes:[postString UTF8String] length:[postString length]];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSError *response_error;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&response_error];
            
            NSString *message = [json valueForKey:@"Message"];
            NSString *userID = [json valueForKey:@"userID"];
            
            NSLog(@"%@",message);
            
            User *user      = [[User alloc]init];
            user.firstName  = firstName;
            user.lastName   = lastName;
            user.fullName   = username;
            user.email      = email;
            user.profilePic = userProfilePic;
            user.userID     = userID;
            [user save];
            
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
            
            
        });
        
    }];
    
    [task resume];
}

- (IBAction)cancelPressed:(id)sender {
    
    User *user = [User savedUser];
    
    if (user == nil) {
        UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
        [tabBarController setSelectedIndex:0];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

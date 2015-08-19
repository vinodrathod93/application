//
//  LoginPageViewController.m
//  HealthApp
//
//  Created by adverto on 03/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "LoginPageViewController.h"

@interface LoginPageViewController ()
{
    BOOL _viewDidAppear;
    BOOL _viewIsVisible;
}
@end

@implementation LoginPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginButton.readPermissions = @[@"public_profile", @"email"];
    self.loginButton.delegate = self;
    
    
    if ([FBSDKAccessToken currentAccessToken]) {
        NSLog(@"logged in");
    } else {
        NSLog(@"not logged in");
    }
    
    
//    FBSDKLoginManager *login = [[FBSDKLoginManager alloc]init];
//    [login logInWithReadPermissions:@[@"public_profile", @"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//        if (error != nil) {
//            NSLog(@"Error");
//        } else if (result.isCancelled) {
//            NSLog(@"Result Cancelled");
//        } else {
//            NSLog(@"Get userInfo");
//            
//            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:nil];
//            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                if (error == nil) {
//                    NSLog(@"User information ==== %@",result);
//                } else {
//                    NSLog(@"Error getting info %@",error);
//                }
//            }];
//        }
//    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_viewDidAppear) {
        _viewIsVisible = YES;
    } else if ([FBSDKAccessToken currentAccessToken]) {
        _viewIsVisible = YES;
    } else
        _viewDidAppear = YES;
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _viewIsVisible = NO;
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
        if (_viewIsVisible) {
            
            NSLog(@"push view controller");
            NSLog(@"%@",result.grantedPermissions);
            
            FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:nil];
            [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                if (error == nil) {
                    NSLog(@"User information ==== %@",result);
                } else {
                    NSLog(@"Error getting info %@",error);
                }
            }];
            
        }
        
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
    NSLog(@"Log out pressed");
    
}

@end

//
//  SignInViewController.m
//  Chemist Plus
//
//  Created by adverto on 07/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "SignInViewController.h"
#import "User.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSString+SignupValidation.h"
#import "AppDelegate.h"


//#define kSIGN_IN_URL @"http://chemistplus.in/sign_in_test.php"
#define kSign_in_url @"http://www.elnuur.com/api/users/sign_in"

@interface SignInViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

typedef void(^completion)(BOOL finished);

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Sign In";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    
    self.loginButton.layer.cornerRadius = 3.0f;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self.emailField becomeFirstResponder];
}

- (IBAction)loginButtonPressed:(id)sender {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NetworkStatus netStatus = [appDelegate.googleReach currentReachabilityStatus];
    
    NSString *errorMessage = [self validateForm];
    if (errorMessage) {
        [self alertWithTitle:@"Error" message:errorMessage];
    } else {
        if (netStatus != NotReachable) {
            [self submitSigninDataWithCompletion:^(BOOL finished) {
                if (finished) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        
                        if (self.isPlacingOrder) {
                            NSLog(@"Placing Order");
                            
//                            [[NSNotificationCenter defaultCenter] postNotificationName:@"loggedInSendOrderNotification" object:nil];
                        }
                        
                    }];
                } else
                    NSLog(@"Could not login");
            }];

        } else {
            [self displayNoConnection];
        }
        
    }
    
}


-(void)submitSigninDataWithCompletion:(completion)isLoggedIn {
    
    NSURL *url = [NSURL URLWithString:kSign_in_url];
    NSString *user_data = [NSString stringWithFormat:@"user[email]=%@&user[password]=%@",self.emailField.text, self.passwordField.text];
    NSData *post_data = [NSData dataWithBytes:[user_data UTF8String] length:[user_data length]];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = post_data;
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                [self.hud hide:YES];
                
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    
                    NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                    NSLog(@"Response %ld", (long)[url_response statusCode]);
                    
                    if (url_response.statusCode == 401) {
                        NSString *error = [json valueForKey:@"errors"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertWithTitle:@"Error" message:error];
                        });
                        
                        isLoggedIn(NO);
                        
                    } else if (url_response.statusCode == 200) {
                        NSLog(@"JSON %@",json);
                        
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
        } else {
            [self displayConnectionFailed];
        }
        
        
    }];
    
    [task resume];
    
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Logging In...";
    self.hud.detailsLabelText = @"Please wait...";
    self.hud.color = self.view.tintColor;
    
}

-(void)alertWithTitle:(NSString *)status message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}



-(NSString *)validateForm {
    NSString *errorMessage;
    
    if (![self.emailField.text isValidEmail]) {
        errorMessage = @"Enter valid email";
    } else if (![self.passwordField.text isValidPassword]) {
        errorMessage = @"Enter valid password";
    }
    
    return errorMessage;
}

-(void)displayConnectionFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.hud hide:YES];
        UIAlertView *failed_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [failed_alert show];
    });
}

-(void)displayNoConnection {
    
    [self.hud hide:YES];
    UIAlertView *connection_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [connection_alert show];
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if(netStatus != NotReachable) {
        NSLog(@"Reachable");
    } else {
        [self displayNoConnection];
    }
}


@end

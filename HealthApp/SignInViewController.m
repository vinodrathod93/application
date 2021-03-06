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


#define kSign_in_url @"http://neediator.in/NeediatorWS.asmx/checklogin"

@interface SignInViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

typedef void(^completion)(BOOL finished);

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Sign In";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    
    self.loginButton.layer.cornerRadius = 5.0f;
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
    NSString *user_data = [NSString stringWithFormat:@"username=%@&password=%@",self.emailField.text, self.passwordField.text];
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
                    
                    if ([[json valueForKey:@"isError"] boolValue] == true) {
                        NSString *error = [json valueForKey:@"errors"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertWithTitle:@"Error" message:error];
                        });
                        
                        isLoggedIn(NO);
                        
                    } else if (url_response.statusCode == 200) {
                        NSLog(@"JSON %@",json);
                        
                        NSArray *login     = [json valueForKey:@"checklogin"];
                        NSDictionary *data = [login lastObject];
                        
                        User *user              = [[User alloc]init];
                        user.userID             = [data valueForKey:@"Id"];
                        user.email              = [json valueForKey:@"Username"];
                        
                        [user save];
                        [self signInWithUser:user];
                        
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


- (void)signInWithUser:(User *)user {
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // You only need to set User ID on a tracker once. By setting it on the tracker, the ID will be
    // sent with all subsequent hits.
    [tracker set:kGAIUserId
           value:user.userID];
    
    // This hit will be sent with the User ID value and be visible in User-ID-enabled views (profiles).
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Users"            // Event category (required)
                                                          action:@"User Sign In"  // Event action (required)
                                                           label:nil              // Event label
                                                           value:nil] build]];    // Event value
}


@end

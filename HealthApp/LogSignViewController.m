//
//  LogSignViewController.m
//  Chemist Plus
//
//  Created by adverto on 07/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "LogSignViewController.h"
#import "User.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSString+SignupValidation.h"
#import "AppDelegate.h"
#import "SignUpViewController.h"

//#define REGISTER_URL @"http://chemistplus.in/register_test.php"
//#define PROFILE_URL @"https://graph.facebook.com/%@/picture?type=large"


@interface LogSignViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

typedef void(^completion)(BOOL finished);

@implementation LogSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loginButton.layer.cornerRadius = 3.f;
    
    self.emailImageView.image = [self.emailImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.emailImageView setTintColor:[UIColor whiteColor]];
    
    self.passwordImageView.image = [self.passwordImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.passwordImageView setTintColor:[UIColor whiteColor]];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    
    
    //    self.emailField
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // sb   id tracker = [[GAI sharedInstance] defaultTracker];
    //    [tracker set:kGAIScreenName value:@"Login Screen"];
    //    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - self.topLayoutGuide.length - self.bottomLayoutGuide.length);
}



#pragma mark - Button Actions.
- (IBAction)cancelPressed:(id)sender
{
    User *user = [User savedUser];
    
    if (user == nil) {
        UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
        [tabBarController setSelectedIndex:0];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"loggedInSendOrderNotification" object:nil];
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
                        
                    }
                    else if (url_response.statusCode == 200) {
                        NSLog(@"JSON %@",json);
                        
                        NSArray *login     = [json valueForKey:@"signin"];
                        NSDictionary *data = [login lastObject];
                        
                        User *user              = [[User alloc]init];
                        user.userID             = [data valueForKey:@"id"];
                        user.firstName          = [data valueForKey:@"firstname"];
                        user.lastName           = [data valueForKey:@"lastname"];
                        user.email              = [data valueForKey:@"username"];
                        user.addresses          = [data objectForKey:@"addreslist"];
                        user.profilePic         = [data valueForKey:@"imageurl"];
                        
                        
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


#pragma mark - Alert Controller.

-(void)alertWithTitle:(NSString *)status message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}



#pragma mark - Validation.
-(NSString *)validateForm {
    NSString *errorMessage;
    
    if (![self.emailField.text isValidEmail]) {
        errorMessage = @"Enter valid email";
    } else if (![self.passwordField.text isValidPassword]) {
        errorMessage = @"Enter valid password";
    }
    
    return errorMessage;
}


#pragma mark - Helper Methods
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



#pragma mark - Reachability.
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


#pragma mark - Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"registerSegue"])
    {
        SignUpViewController *signupVC = [segue destinationViewController];
        signupVC.isPlacingOrder = self.isPlacingOrder;
        
    }
}



@end

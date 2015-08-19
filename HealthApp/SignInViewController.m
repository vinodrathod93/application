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


#define kSIGN_IN_URL @"http://chemistplus.in/sign_in_test.php"

@interface SignInViewController ()

@property (nonatomic, assign) BOOL isLoggedIn;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Sign In";
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)loginButtonPressed:(id)sender {
    
    NSString *errorMessage = [self validateForm];
    if (errorMessage) {
        [self alertWithTitle:@"Error" message:errorMessage];
    } else {
        [self submitInfo];
    }
    
}


-(void)submitInfo {
    NSURL *url = [NSURL URLWithString:kSIGN_IN_URL];
    NSString *user_data = [NSString stringWithFormat:@"email=%@&password=%@",self.emailField.text, self.passwordField.text];
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
            [self.hud hide:YES];
            
            if (jsonError) {
                NSLog(@"Error %@",[jsonError localizedDescription]);
            } else {
                
                NSString *message = [json valueForKey:@"Message"];
                NSString *status = [json valueForKey:@"Status"];
                NSString *name = [json valueForKey:@"username"];
                NSString *email = [json valueForKey:@"email"];
                NSString *userID = [json valueForKey:@"userID"];
                
                
                if ([status isEqualToString:@"Success"]) {
                    self.isLoggedIn = YES;
                    
                    User *user = [[User alloc]init];
                    user.fullName = name;
                    user.email = email;
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
    
    if (![self.emailField.text isValidEmail]) {
        errorMessage = @"Enter valid email";
    } else if (![self.passwordField.text isValidPassword]) {
        errorMessage = @"Enter valid password";
    }
    
    return errorMessage;
}

@end

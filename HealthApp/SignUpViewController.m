//
//  SignUpViewController.m
//  Chemist Plus
//
//  Created by adverto on 06/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "SignUpViewController.h"
#import "User.h"
#import "AppDelegate.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSString+SignupValidation.h"
#import <NBPhoneNumberUtil.h>


#define kSign_up_url @"http://192.168.1.199/NeediatorWebservice/neediatorWs.asmx/addUser"





@interface SignUpViewController ()<UITextFieldDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;

@end

typedef void(^completion)(BOOL finished);

@implementation SignUpViewController {
    UIDatePicker *datePickerView;
}


#pragma mark - View Did Load..
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.signUpButton.layer.cornerRadius = 5.0f;
    self.userName.delegate = self;
    self.passwordField.delegate = self;
    self.emailField.delegate = self;
    self.mobileField.delegate = self;
    self.dateOfBirthField.delegate = self;
    self.dateOfBirthField.inputView = [self dateOfBirthPickerView];
    self.dateOfBirthField.inputAccessoryView = [self datePickerToolBar];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Signup Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    NSLog(@"viewWillDisappear");
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSLog(@"viewDidDisappear");
}

//-(void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    
//    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height - self.topLayoutGuide.length - self.bottomLayoutGuide.length);
//}




//#pragma mark - Keyboard.
//-(void)keyboardDidShow:(NSNotification *)notification
//{
//    NSLog(@"KeyBoard appeared");
//    NSDictionary *info=[notification userInfo];
//    NSValue *aValue=[info objectForKey:UIKeyboardFrameEndUserInfoKey];
//    
//    CGRect keyBoardRect=[aValue CGRectValue];
//    keyBoardRect=[self.view convertRect:keyBoardRect fromView:nil];
//    CGFloat keyBoardTop=keyBoardRect.origin.y; //i am getting the height of the keyboard
//    
//    self.scrollView.contentInset=UIEdgeInsetsMake(0, 0, keyBoardTop+50, 0); //adjust the height by setting the "contentInset"
//}
//
//-(void)keyboardDidDisappear:(NSNotification *)notification
//{
//    NSLog(@"KeyBoard Disappeared");
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.2];
//    self.scrollView.contentInset=UIEdgeInsetsMake(10, 0, 10, 0); //set to normal by setting the "contentInset"
//    
//    [UIView commitAnimations];
//    
//}




#pragma mark - TextField..
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
        [self.mobileField becomeFirstResponder];
    }
    else if ([textField isEqual:self.mobileField]) {
        [self signUpPressed:nil];
    }
    
    return YES;
}



#pragma mark - SignUp..
- (IBAction)signUpPressed:(id)sender {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NetworkStatus netStatus = [appDelegate.googleReach currentReachabilityStatus];
    
    NSString *errorMessage = [self validateForm];
    if (errorMessage) {
        [self alertWithTitle:@"Error" message:errorMessage];
    }
    else if (![self.userName.text isEqualToString:@""] || ![self.emailField.text isEqualToString:@""]) {
        if (netStatus != NotReachable) {
            [self submitSignupDataWithCompletion:^(BOOL finished) {
                if (finished) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        
                        if (self.isPlacingOrder)
                        {
                            NSLog(@"Placing Order");
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"loggedInSendOrderNotification" object:nil];
                        }
                        
                    }];
                } else {
                    NSLog(@"Could not login");
                }
                
            }];
        }
        else {
            [self displayNoConnection];
        }
        
        
    }
}


-(void)submitSignupDataWithCompletion:(completion)isLoggedIn {
   
    
    
      NSURL *url = [NSURL URLWithString:kSign_up_url];
    
    NSString *user_data = [NSString stringWithFormat:@"password=%@&firstname=%@&lastname=%@&Gender=%@&phoneno=%@&emailid=%@&dob=%@",self.passwordField.text,self.userName.text,self.LastnameTf.text,self.maleorFemaleString,self.mobileField.text,self.emailField.text,self.dateOfBirthField.text];
    
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
                
                // Hide the HUD
                [self.hud hide:YES];
                
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    NSLog(@"JSON is =====> %@",json);
                    
                    NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                    NSLog(@"Response %ld", (long)[url_response statusCode]);
                    
                    if ([json valueForKey:@"errors"] != nil)
                    {
                        NSString *error = [json valueForKey:@"errors"];
                        
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                                       message:error
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        [self presentViewController:alert animated:YES completion:nil];
                        int duration = 1; // duration in seconds
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [alert dismissViewControllerAnimated:YES completion:nil];
                        });

                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertWithTitle:@"Error" message:error];
                        });
                        
                        isLoggedIn(NO);
                        
                    }
                    else {
                        
                        NSArray *userData = [json valueForKey:@"registeruser"];
                        
                        User *user              = [[User alloc]init];
                        user.userID             = [userData[0] valueForKey:@"id"];
                        user.email              = [userData[0] valueForKey:@"email"];
                        user.firstName          = [userData[0] valueForKey:@"name"];
                        user.mobno              = [userData[0] valueForKey:@"phoneno"];
                        
                        [user save];
                        isLoggedIn(YES);
                        
                    }
                }
            });
        }
        else {
            isLoggedIn(NO);
        }
        
    }];
    
    [task resume];
    
//     display HUD
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Signing In...";
    self.hud.detailsLabelText = @"Please wait...";
    self.hud.color = self.view.tintColor;
    
}

-(void)alertWithTitle:(NSString *)status message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}



#pragma mark - Validations..
-(NSString *)validateForm
{
    NSString *errorMessage;
    
    if (![self.userName.text isValidName]) {
        errorMessage = @"Please enter a valid name";
    } else if (![self.emailField.text isValidEmail]) {
        errorMessage = @"Please enter a valid email";
    } else if (![self.passwordField.text isValidPassword]) {
        errorMessage = @"Please enter a valid password";
    } else if (![self validatePhone:self.mobileField.text]) {
        errorMessage = @"Please enter a valid Phone Number";
    } else if (![self.dateOfBirthField.text isValidDOB]) {
        errorMessage = @"Please input your Date of Birth";
    }
    
    return errorMessage;
    
}

- (BOOL)validatePhone:(NSString *)phoneNumber
{
    
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];
    NSError *error = nil;
    NBPhoneNumber *number = [phoneUtil parse:phoneNumber defaultRegion:@"IN" error:&error];
    return [phoneUtil isValidNumber:number];
    
}




#pragma mark - DatePicker..
-(UIDatePicker *)dateOfBirthPickerView {
    datePickerView = [[UIDatePicker alloc] init];
    datePickerView.datePickerMode = UIDatePickerModeDate;
    [datePickerView addTarget:self action:@selector(updateDateOfBirthField:) forControlEvents:UIControlEventValueChanged];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDate * currentDate = [NSDate date];
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: -18];
    NSDate * maxDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    [comps setYear: -100];
    NSDate * minDate = [gregorian dateByAddingComponents: comps toDate: currentDate options: 0];
    
    
    datePickerView.minimumDate = minDate;
    datePickerView.maximumDate = maxDate;
    datePickerView.date = maxDate;
    return datePickerView;
}


-(UIToolbar *)datePickerToolBar {
    UIToolbar *toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 150, 21.f)];
    message.font = [NeediatorUtitity mediumFontWithSize:15.f];
    message.textAlignment = NSTextAlignmentCenter;
    message.backgroundColor = [UIColor clearColor];
    message.textColor = [UIColor lightGrayColor];
    message.text = @"Select Date of Birth";
    
    UIBarButtonItem *flexibleSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithCustomView:message];
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissPickerView)];
    
    [toolbar setItems:@[flexibleSpaceLeft, titleButton, flexibleSpaceRight, doneButton] animated:YES];
    
    return toolbar;
}

-(void)dismissPickerView {
    [self.dateOfBirthField resignFirstResponder];
}


-(void)updateDateOfBirthField:(UIDatePicker *)datePicker {
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    self.dateOfBirthField.text = [dateFormatter stringFromDate:datePicker.date];
}



#pragma mark - Helper Methods.
-(void)displayConnectionFailed {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

-(void)displayNoConnection {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}


- (IBAction)FemaleAction:(id)sender
{
    self.maleorFemaleString=@"female";
    
    
        _femalebtn.layer.cornerRadius = 5.f;
        _femalebtn.layer.borderWidth = 0.5f;
        _femalebtn.layer.borderColor = [UIColor blackColor].CGColor;
        _femalebtn.layer.masksToBounds = YES;
   
        _malebtn.layer.cornerRadius = 5.f;
        _malebtn.layer.borderWidth = 0.5f;
        _malebtn.layer.borderColor = [UIColor clearColor].CGColor;
        _malebtn.layer.masksToBounds = YES;
    

    NSLog(@"Selected btn is %@",self.maleorFemaleString);
    

}

- (IBAction)maleAction:(id)sender
{
    self.maleorFemaleString=@"male";
    
    _malebtn.layer.cornerRadius = 5.f;
    _malebtn.layer.borderWidth = 0.5f;
    _malebtn.layer.borderColor = [UIColor blackColor].CGColor;
    _malebtn.layer.masksToBounds = YES;
    
    _femalebtn.layer.cornerRadius = 5.f;
    _femalebtn.layer.borderWidth = 0.5f;
    _femalebtn.layer.borderColor = [UIColor clearColor].CGColor;
    _femalebtn.layer.masksToBounds = YES;

    NSLog(@"Selected btn is %@",self.maleorFemaleString);

    
}
@end

//
//  AddShippingDetailsViewController.m
//  Chemist Plus
//
//  Created by adverto on 29/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "AddShippingDetailsViewController.h"
#import "AddShippingViewModel.h"
#import "User.h"
#import "Address.h"
#import "PaymentViewController.h"


#define GET_STATES_URL @"http://chemistplus.in/getStates.php"
#define GET_CITIES_URL @"http://chemistplus.in/getCities.php"
#define VERIFY_PINCODE_URL @"http://chemistplus.in/verifyPincode.php"

enum AddressFields {
    NameTextField = 0,
    PincodeTextField,
    AddressTextField,
    LandmarkTextField,
    TownTextField,
    CityTextField,
    StateTextField
};

@interface AddShippingDetailsViewController ()<UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSArray *formFields;
@property (nonatomic, strong) NSArray *addressFields;
@property (nonatomic, strong) NSArray *availablePincodes;

@property (nonatomic, strong) AddShippingViewModel *viewModel;
@property (nonatomic, strong) NSMutableDictionary *detailsDictionary;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, assign) BOOL isCorrectPincode;
@property (nonatomic, assign) BOOL isPincodeAvailable;

@property (nonatomic, strong) UIAlertView *orderConfirmation;
@property (nonatomic, strong) NSArray *cartProducts;
@property (nonatomic, strong) NSString *totalAmount;

@property (nonatomic, strong) Address *address;
@property (nonatomic, strong) User *user;


@end

NSString *cellIdentifier;

@implementation AddShippingDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formFields = @[@"Name", @"Pincode", @"Address", @"Landmark", @"Town", @"City", @"State"];
    
    self.viewModel = [[AddShippingViewModel alloc]init];
    self.detailsDictionary = [NSMutableDictionary dictionary];
    
    [self checkToVerifyPincode];
    
    self.address = [[Address alloc] init];
    self.user = [User savedUser];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.cartProducts = [self.cartDetails valueForKey:@"products"];
    self.totalAmount = [self.cartDetails valueForKey:@"total_amount"];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return self.formFields.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cellIdentifier = @"addDetailCell";
    
    AddShippingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureTextFieldCell:cell forIndexPath:indexPath];
    
    return cell;
}


-(void)configureTextFieldCell:(AddShippingViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%@",self.formFields[indexPath.row]);
    cell.textField.placeholder = self.formFields[indexPath.row];
    cell.textField.tag = indexPath.row;
    cell.textField.delegate = self;
    
    if (cell.textField.tag == NameTextField) {
        cell.textField.text = self.user.fullName;
    }
    
    if (cell.textField.tag == PincodeTextField) {
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        cell.textField.returnKeyType = UIReturnKeyNext;
    }
    else if (cell.textField.tag == AddressTextField)
        cell.textField.returnKeyType = UIReturnKeyDone;
    else
        cell.textField.returnKeyType = UIReturnKeyNext;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 48.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIButton *proceedButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    [proceedButton setTitle:@"Proceed to Payment" forState:UIControlStateNormal];
    [proceedButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:16.0f]];
    [proceedButton setBackgroundColor:[UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f]];
    [proceedButton addTarget:self action:@selector(proceedButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [proceedButton setEnabled:YES];
    
    return proceedButton;
}


-(BOOL)checkAvailablePincode:(UITextField *)sender {
    if (![self.availablePincodes containsObject:sender.text]) {
        
        UITextField *town = (UITextField *)[self.view viewWithTag:TownTextField];
        UITextField *city = (UITextField *)[self.view viewWithTag:CityTextField];
        UITextField *state = (UITextField *)[self.view viewWithTag:StateTextField];
        
        sender.text = @"";
        
        town.text = @"";
        city.text = @"";
        state.text = @"";
        
        UIAlertView *notAvailable = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Currently, service is not provided to the specified pincode" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [notAvailable show];
        
        self.isPincodeAvailable = NO;
        
    } else
        self.isPincodeAvailable = YES;
    
    
    
    return self.isPincodeAvailable;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)sender {
    NSLog(@"textFieldShouldEndEditing");
    __block BOOL status = YES;
    
    
    if (sender.tag == NameTextField) {
        if (![self.viewModel validateName:sender.text]) {
            [self displayError:sender];
            
            return NO;
        }
        
        return YES;
        
    }
    else if (sender.tag == PincodeTextField) {
        
        NSLog(@"%@",sender.text);
        if (![self.viewModel validatePinCode:sender.text]) {
            [self displayError:sender];
            
            return NO;
        }
        else if (![sender.text isEqualToString:@""]) {
            NSLog(@"Sending Pincode = %@",sender.text);
            
            [self requestPincodeTask:sender completion:^{
                status = [self checkAvailablePincode:sender];
                
            }];
            
            return status;
            
        } else
            return NO;
        
    }
    else {
        if (![sender.text isEqualToString:@""]) {
            return YES;
        } else
            return NO;
    }
    
    return status;
}

- (IBAction)textFieldDidEndEditing:(UITextField *)sender {
    
    [self saveToArray:sender];
    
}


- (IBAction)textFieldDidBeginEditing:(UITextField *)sender {
    
    NSLog(@"textFieldDidBeginEditing");
    self.isCorrectPincode = NO;
    
    sender.layer.borderColor = [[UIColor blackColor] CGColor];
    sender.layer.borderWidth = 0.0f;
    sender.layer.cornerRadius = 0.0f;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    NSLog(@"textFieldShouldReturn");
    
    if (sender.tag == NameTextField) {
        
        [self jumpToNext:sender];
        
    } else if (sender.tag == PincodeTextField) {
        
        [self jumpToNext:sender];
        
    } else if (sender.tag == AddressTextField) {
        
        [self jumpToNext:sender];
    
    } else if (sender.tag == LandmarkTextField) {
        
        [self proceedButtonPressed];
        
    } else if (sender.tag == TownTextField) {
        
        [self jumpToNext:sender];
        
    } else if (sender.tag == CityTextField) {
        
        [self jumpToNext:sender];
        
    } else if (sender.tag == StateTextField) {
        
        [self proceedButtonPressed];
    }
    return YES;
}

- (IBAction)editingChanged:(UITextField *)sender {
    
//    [self saveToArray:sender];
}



-(void)loadJSONForTown:(UITextField *)town forCity:(UITextField *)city andForState:(UITextField *)state {
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *postString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%@,%@",self.latitude,self.longitude];
    
    NSLog(@"%@",postString);
    NSURL *getUrl = [NSURL URLWithString:[postString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:getUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSError *jsonError;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            if (dictionary != nil) {
                
                NSArray *results = dictionary[@"results"];
                NSDictionary *address = results[0];
                NSArray *components = [address valueForKey:@"address_components"];
                
                for (NSDictionary *eachAddress in components) {
                    
                    NSString *type = eachAddress[@"types"][0];
                    
                    if ([type isEqualToString:[self.viewModel getCityAttribute]])
                    {
                        NSLog(@"%@",eachAddress[[self.viewModel getAddressValue]]);
                        city.text = eachAddress[[self.viewModel getAddressValue]];
                        city.userInteractionEnabled = NO;
                        
                        if (city.text != nil) {
                            [self.detailsDictionary setObject:city.text forKey:@"city"];
                            self.address.city = city.text;
                        }
                        
                    }
                    else if ([type isEqualToString:[self.viewModel getStateAttribute]])
                    {
                        NSLog(@"%@",eachAddress[[self.viewModel getAddressValue]]);
                        state.text = eachAddress[[self.viewModel getAddressValue]];
                        state.userInteractionEnabled = NO;
                        
                        if (state.text != nil) {
                            [self.detailsDictionary setObject:state.text forKey:@"state"];
                            self.address.state = state.text;
                        }
                        
                    }
                    else if ([type isEqualToString:[self.viewModel getTownAttribute]])
                    {
                        NSLog(@"%@",eachAddress[[self.viewModel getAddressValue]]);
                        town.text = eachAddress[[self.viewModel getAddressValue]];
                        town.userInteractionEnabled = NO;
                        
                        if (town.text != nil) {
                            [self.detailsDictionary setObject:town.text forKey:@"town"];
                            self.address.town = state.text;
                        }
                        
                    }
                }
                
            } else {
                UIAlertView *networkError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Try again - while loading city, town, state" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [networkError show];
            }
            
        });
    }];
    
    [task resume];
}


-(void)requestPincodeTask:(UITextField *)pincode completion:(void (^)(void))completionBlock {
    NSLog(@"Requesting Pincode: %@",pincode.text);
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *postString = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?components=postal_code:%@%%7Ccountry:IN&sensor=false",pincode.text];
    
    NSLog(@"%@",postString);
    
    //        http://maps.google.com/maps/api/geocode/json?components=postal_code:421306%7Ccountry:IN&sensor=false
    
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:postString]];
    NSURL *url = [NSURL URLWithString:postString];
    
    
    NSURLSessionDataTask *task1 = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *pincodeError;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&pincodeError];
            
            if (dict != nil) {
                
                NSArray *results = dict[@"results"];
                NSLog(@"%@",results);
                
                if (results.count != 0) {
                    NSDictionary *address = results[0];
                    NSLog(@"%@",address);
                    
                    self.latitude = [address valueForKeyPath:@"geometry.location.lat"];
                    self.longitude = [address valueForKeyPath:@"geometry.location.lng"];
                    
                    UITextField *town = (UITextField *)[self.view viewWithTag:TownTextField];
                    UITextField *city = (UITextField *)[self.view viewWithTag:CityTextField];
                    UITextField *state = (UITextField *)[self.view viewWithTag:StateTextField];
                    
                    self.isCorrectPincode = YES;
                    
                    if (self.isCorrectPincode) {
                        completionBlock();
                        
                        if (self.isPincodeAvailable) {
                            [self loadJSONForTown:town forCity:city andForState:state];
                        }
                        
                    }
                    
                } else {
                    UIAlertView *pincodeAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Enter the correct pincode" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [pincodeAlert show];
                    
                    pincode.text = @"";
                }
                
            }
            else {
                UIAlertView *networkError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Try again - while requesting Pincode" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [networkError show];
                
                pincode.text =@"";
            }
            
        });
    }];
    
    /*
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *pincodeError;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&pincodeError];
            
            if (dict != nil) {
                
                NSArray *results = dict[@"results"];
                NSLog(@"%@",results);
                
                if (results.count != 0) {
                    NSDictionary *address = results[0];
                    NSLog(@"%@",address);
                    
                    self.latitude = [address valueForKeyPath:@"geometry.location.lat"];
                    self.longitude = [address valueForKeyPath:@"geometry.location.lng"];
                    
                    UITextField *town = (UITextField *)[self.view viewWithTag:TownTextField];
                    UITextField *city = (UITextField *)[self.view viewWithTag:CityTextField];
                    UITextField *state = (UITextField *)[self.view viewWithTag:StateTextField];

                    self.isCorrectPincode = YES;
                    
                    if (self.isCorrectPincode) {
                        completionBlock();
                        
                        if (self.isPincodeAvailable) {
                            [self loadJSONForTown:town forCity:city andForState:state];
                        }
                        
                    }
                    
                } else {
                    UIAlertView *pincodeAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Enter the correct pincode" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [pincodeAlert show];
                    
                    pincode.text = @"";
                }
                
            }
            else {
                UIAlertView *networkError = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please Try again - while requesting Pincode" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [networkError show];
                
                pincode.text =@"";
            }
            
        });
    }];
     
    */
    
    [task1 resume];
}

-(void)displayError:(UITextField *)sender {
    sender.layer.borderColor = [[UIColor redColor] CGColor];
    sender.layer.borderWidth = 1.0f;
    sender.layer.cornerRadius = 2.0f;
}


- (IBAction)cancelPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)proceedButtonPressed {
    NSLog(@"proceedButtonPressed");
    NSLog(@"%@",self.detailsDictionary);
    
    [self.address save];
    NSLog(@"%@",self.address.name);
    NSLog(@"%@",self.cartDetails);
    
    if (self.detailsDictionary.count == self.formFields.count) {
        
        PaymentViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
//        paymentVC.addressDetails = self.detailsDictionary;
//        paymentVC.orderDetails = self.cartDetails;
        [self.navigationController pushViewController:paymentVC animated:YES];
        
        
        /*
        NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:self.cartProducts, @"products",
                              self.detailsDictionary, @"userInfo", self.totalAmount, @"orderAmount", nil];
        
        
        NSLog(@"%@",json);
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://chemistplus.in/storePurchaseDetails.php"]];
        request.HTTPMethod = @"POST";
        request.HTTPBody = jsonData;
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"%@",response);
            
            NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@",string);
            
            dispatch_async(dispatch_get_main_queue(), ^{
//                self.orderConfirmation = [[UIAlertView alloc]initWithTitle:@"Success" message:[NSString stringWithFormat:@"Yeah! Order has been placed and Order ID is \"%@\"",string] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                self.orderConfirmation.delegate = self;
//                [self.orderConfirmation show];
                
                
                
            });
            
            
        }];
        [task resume];
         
         */
    } else
        [self displayErrorMessageFor:@"inputs"];
    
}



-(void)saveToArray:(UITextField *)sender {
    
    switch (sender.tag) {
        case NameTextField: {
            
            NSLog(@"%@",sender.text);
            if (![sender.text isEqualToString:@""]) {
                
                self.address.name = sender.text;
                [self.detailsDictionary setObject:self.address.name forKey:@"name"];
                
            } else
                [self displayErrorMessageFor:self.formFields[sender.tag]];
            
            break;
        }
        case PincodeTextField: {
            if (![sender.text isEqualToString:@""]) {
                [self.detailsDictionary setObject:sender.text forKey:@"pincode"];
                self.address.pincode = sender.text;
                
            } else
                [self displayErrorMessageFor:self.formFields[sender.tag]];
            
            break;
        }
        case AddressTextField: {
            if (![sender.text isEqualToString:@""]) {
                [self.detailsDictionary setObject:sender.text forKey:@"address"];
                self.address.address = sender.text;
                
            } else
                [self displayErrorMessageFor:self.formFields[sender.tag]];
            break;
        }
            
        case LandmarkTextField: {
            if (![sender.text isEqualToString:@""]) {
                [self.detailsDictionary setObject:sender.text forKey:@"landmark"];
                self.address.landmark = sender.text;
                
            } else
                [self displayErrorMessageFor:self.formFields[sender.tag]];
            break;
        }
            
        case TownTextField: {
            if (![sender.text isEqualToString:@""]) {
                [self.detailsDictionary setObject:sender.text forKey:@"town"];
                self.address.town = sender.text;
                
            } else
                [self displayErrorMessageFor:self.formFields[sender.tag]];
            break;
        }
            
        case CityTextField: {
            if (![sender.text isEqualToString:@""]) {
                [self.detailsDictionary setObject:sender.text forKey:@"city"];
                self.address.city = sender.text;
                
            } else
                [self displayErrorMessageFor:self.formFields[sender.tag]];
            break;
        }
            
        case StateTextField: {
            if (![sender.text isEqualToString:@""]) {
                [self.detailsDictionary setObject:sender.text forKey:@"state"];
                self.address.state = sender.text;
                
            } else
                [self displayErrorMessageFor:self.formFields[sender.tag]];
            break;
        }
        default:
            break;
    }
    
}

-(void)jumpToNext:(UITextField *)sender {
    UIView *view = [self.view viewWithTag:sender.tag + 1];
    [view becomeFirstResponder];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == PincodeTextField) {
        int limit = 5;
        return !([textField.text length]>limit && [string length] > range.length);
    }
    return YES;
}


-(void)displayErrorMessageFor:(NSString *)textField {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[NSString stringWithFormat:@"Please Enter %@",textField] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)checkToVerifyPincode {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:VERIFY_PINCODE_URL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *pinError;
            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&pinError];
            
            self.availablePincodes = [dictionary valueForKeyPath:@"availableAt.pincode"];
            NSLog(@"%@",self.availablePincodes);
        });
    }];
    
    [task resume];
}


@end

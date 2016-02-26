//
//  EditAddressViewController.m
//  Neediator
//
//  Created by adverto on 26/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "EditAddressViewController.h"
#import "Order.h"
#import "AppDelegate.h"
#import "PaymentViewController.h"
#import "StatesModel.h"
#import "CitiesModel.h"
#import "NSString+AddressValidation.h"


@implementation EditAddressViewController {
    NSMutableDictionary         *_parameters;
    NSFetchedResultsController  *_orderFetchedResultsController;
    Order                       *_orderModel;
    NSManagedObjectContext      *_managedObjectContext;
    UIPickerView                *_statesPickerView;
    UIPickerView                *_citiesPickerView;
    NSArray                     *_states;
    NSArray                     *_cities;
    MBProgressHUD               *_hud;
    StatesModel                 *_selected_state;
    CitiesModel                 *_selected_city;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = appDelegate.managedObjectContext;
    
    [self checkOrders];
    
    _parameters = [NSMutableDictionary dictionary];
    
    
    self.saveNContinueButton.layer.cornerRadius = 5.0f;
    
    
    if (self.shipAddress != nil) {
        
        NSString *name = self.shipAddress[@"name"];
        NSString *address = self.shipAddress[@"address"];
        
        NSArray *names = [name componentsSeparatedByString:@" "];
//        NSArray *addressLines = [address componentsSeparatedByString:@","];
        
        self.firstNameTextField.text    = [names firstObject];
        self.lastNameTextField.text     = [names lastObject];
        self.address1TextField.text     = address;
        self.address2TextField.text     = @"";
        
        self.pincodeTextField.text      = self.shipAddress[@"pincode"];
        self.cityTextField.text         = self.shipAddress[@"cityname"];
        self.stateTextField.text        = self.shipAddress[@"statename"];
    }
    else {
        
        /* do nothing if adding new address */
        
    }
    
    [self loadStatesPickerView];
    [self loadCitiesPickerView];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText      = @"Loading...";
    hud.dimBackground  = YES;
    
    
    
    [[NAPIManager sharedManager] getNeediatorStatesCityWithSuccess:^(StateCityResponseModel *statesModel) {
        [hud hide:YES];
        
        _states = statesModel.states;
        
        
    } failure:^(NSError *error) {
        [hud hide:YES];
        
        NSLog(@"%@",[error localizedDescription]);
    }];
    
    
    
    // Disable textfields
    
    self.cityTextField.userInteractionEnabled = NO;
    self.cityTextField.backgroundColor = [UIColor lightGrayColor];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}


-(void)dismissPickerView:(id)sender {
    
    NSLog(@"Sender %@", sender);
    
    [_statesPickerView resignFirstResponder];
}



#pragma mark - UIButton Action

- (IBAction)saveNContinueAction:(id)sender {
    
    NSLog(@"Parameters %@", _parameters);
    
    _orderModel = _orderFetchedResultsController.fetchedObjects.lastObject;
    
    // Validate Form
    
    NSString *errorMessage = [self validateForm];
    if (errorMessage) {
        [self alertWithTitle:@"Invalid Address" message:errorMessage];
    }
    else {
        
        User *user = [User savedUser];
        Location *location = [Location savedLocation];
        
        
        
        NSString *path;
        NSString *fullname;
        NSString *parameter;
        NSString *complete_address;
        
        if (self.shipAddress != nil) {
            
            NSString *addressID = self.shipAddress[@"id"];
            
            path = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/updateaddress"];
            complete_address = [NSString stringWithFormat:@"%@, %@", self.address1TextField.text, self.address2TextField.text];
            fullname = [NSString stringWithFormat:@"%@ %@", [self.firstNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] , [self.lastNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
            
            // Parameter
            parameter = [NSString stringWithFormat:@"address=%@&id=%@&latitude=%@&longitude=%@&name=%@&pincode=%@&stateid=%@&cityid=%@", complete_address, addressID, location.latitude, location.longitude, fullname, self.pincodeTextField.text, _selected_state.stateID.stringValue, _selected_city.cityID.stringValue];
            
            NSLog(@"%@", parameter);
            
        }
        else {
            
            /* if adding new address */
            
            
            
            // Path URL
            path = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/address"];
            complete_address = [NSString stringWithFormat:@"%@, %@", self.address1TextField.text, self.address2TextField.text];
            fullname = [NSString stringWithFormat:@"%@ %@", [self.firstNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] , [self.lastNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
            
            // Parameter
            parameter = [NSString stringWithFormat:@"address=%@&user_id=%@&latitude=%@&longitude=%@&name=%@&pincode=%@&stateid=%@&cityid=%@", complete_address, user.userID, location.latitude, location.longitude, fullname, self.pincodeTextField.text, _selected_state.stateID.stringValue, _selected_city.cityID.stringValue];
            
            NSLog(@"%@", parameter);
        }
            
            NSURLSession *session = [NSURLSession sharedSession];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
            request.HTTPMethod = @"POST";
            request.HTTPBody    = [NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            
            
            NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                
                if (data != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"%@",response);
                        NSError *jsonError;
                        
                        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                        
                        NSLog(@"JSON ==> %@",json);
                        
                        [_hud hide:YES];
                        
                        
                        
                        
                        if (jsonError) {
                            NSLog(@"Error %@",[jsonError localizedDescription]);
                            
                            UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:[jsonError localizedFailureReason] message:[jsonError localizedDescription] delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
                            [alertError show];
                            
                            
                            
                            
                        } else {
                            
                            // Save address
                            NSArray *addressesArray = [json objectForKey:@"address"];
                            
                            
                            NSLog(@"Address Saved %@", addressesArray);
                            
                            
                            if ([_delegate respondsToSelector:@selector(addressDidSaved:)]) {
                                [_delegate addressDidSaved:addressesArray];
                            }
                            
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                        
                    });
                } else {
                    
                    NSLog(@"Network error");
                }
                
            }];
            
            [task resume];
            _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _hud.color = self.view.tintColor;
            
            
        }
    
    
}




#pragma mark - Helper Methods


//-(NSDictionary *)addressJSON {
//    
//    NSDictionary *orderAddress = @{
//                                   @"order": @{
//                                           @"bill_address_attributes": _parameters,
//                                           @"ship_address_attributes": _parameters
//                                           }
//                                   };
//    
//    return orderAddress;
//}



//- (IBAction)textFieldDataChanged:(UITextField *)textField {
//    
//    
//    if ([textField isEqual:self.firstNameTextField])
//        [_parameters setValue:textField.text forKey:[self addressKey:@"firstname"]];
//    else if ([textField isEqual:self.lastNameTextField])
//        [_parameters setValue:textField.text forKey:[self addressKey:@"lastname"]];
//    else if ([textField isEqual:self.address1TextField])
//        [_parameters setValue:textField.text forKey:[self addressKey:@"address1"]];
//    else if ([textField isEqual:self.address2TextField])
//        [_parameters setValue:textField.text forKey:[self addressKey:@"address2"]];
//    else if ([textField isEqual:self.phoneTextField])
//        [_parameters setValue:textField.text forKey:[self addressKey:@"phone"]];
//    else if ([textField isEqual:self.pincodeTextField])
//        [_parameters setValue:textField.text forKey:[self addressKey:@"zipcode"]];
//    else if ([textField isEqual:self.cityTextField]) {
//        
//    }
//    else if ([textField isEqual:self.stateTextField]) {
//        
//        
//        
//    }
//    
//    
//}



//-(NSString *)addressKey:(NSString *)key {
//    
//    if (self.shipAddress == nil) {
//        return key;
//    }
//    else
//        return [NSString stringWithFormat:@"address[%@]",key];
//}


-(void)checkOrders {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    //    NSString *cacheName = @"cartOrderCache";
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    _orderFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:_managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if(![_orderFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",[error localizedDescription]);
    }
    
}




-(void)saveAddress:(NSDictionary *)address {
    
    User *user = [User savedUser];
    user.ship_address = address;
    user.bill_address = address;
    
    [user save];
    
}


#pragma mark - Navigation

-(void)proceedToPaymentPage {
    
    PaymentViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
    
    
    [self.navigationController pushViewController:paymentVC animated:YES];
}


#pragma mark - UIPickerView

-(void)loadStatesPickerView {
    
    _statesPickerView                      = [[UIPickerView alloc]init];
    _statesPickerView.delegate             = self;
    
    self.stateTextField.inputView    = _statesPickerView;
    
    // ToolBar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    [toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissPickerView:)];
    toolbar.items = @[doneButton];
    toolbar.tintColor = [UIColor blackColor];
    
    [_statesPickerView addSubview:toolbar];
    
}


-(void)loadCitiesPickerView {
    
    _citiesPickerView                      = [[UIPickerView alloc]init];
    _citiesPickerView.delegate             = self;
    
    self.cityTextField.inputView    = _citiesPickerView;
    
    // ToolBar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    [toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissPickerView:)];
    toolbar.items = @[doneButton];
    toolbar.tintColor = [UIColor blackColor];
    
    [_citiesPickerView addSubview:toolbar];
    
}



#pragma mark - UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == _statesPickerView) {
        return _states.count;
    }
    else {
        
        return _cities.count;
    }
    
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    StatesModel *model = _states[row];
    
    // States Picker
    
    if (pickerView == _statesPickerView) {
        return model.stateName;
    }
    else {
        
        // Cities Picker.
        
        CitiesModel *cityModel = _cities[row];
        return cityModel.cityName;
    }
    
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView == _statesPickerView) {
        
        // Clear Cities field & disable it.
        _cities = nil;
        self.cityTextField.text = nil;
        self.cityTextField.userInteractionEnabled = NO;
        self.cityTextField.backgroundColor = [UIColor lightGrayColor];
        
        StatesModel *model = _states[row];
        self.stateTextField.text = model.stateName;
        _selected_state  = model;
        
        _cities = model.cities;
        
        
        // Enable textfield
        
        self.cityTextField.userInteractionEnabled = YES;
        self.cityTextField.backgroundColor = [UIColor whiteColor];
        
        [_citiesPickerView reloadAllComponents];
    }
    else {
        CitiesModel *cityModel = _cities[row];
        self.cityTextField.text = cityModel.cityName;
        _selected_city = cityModel;
    }
    
}


#pragma mark - Validation Methods

-(NSString *)validateForm {
    NSString *errorMessage;
    
    if (![self.address1TextField.text isValidAddress1]) {
        errorMessage = @"Please enter a valid address";
    } else if (![self.pincodeTextField.text isValidatePinCode]) {
        errorMessage = @"Please enter a valid Pincode";
    } else if (![self.stateTextField.text isValidState]) {
        errorMessage = @"Please select a state";
    } else if (![self.cityTextField.text isValidCity]) {
        errorMessage = @"Please select a city";
    } else if (![self.firstNameTextField.text isValidFirstName]) {
        errorMessage = @"Please enter a valid firstname";
    } else if (![self.lastNameTextField.text isValidLastName])
        errorMessage = @"Please enter a valid lastname";
    
    return errorMessage;
    
}

-(void)alertWithTitle:(NSString *)status message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
}

@end

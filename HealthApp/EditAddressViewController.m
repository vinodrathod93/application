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


@implementation EditAddressViewController {
    NSMutableDictionary         *_parameters;
    NSFetchedResultsController  *_orderFetchedResultsController;
    Order                       *_orderModel;
    NSManagedObjectContext      *_managedObjectContext;
    UIPickerView                *_pickerView;
    NSArray                     *_states;
    MBProgressHUD               *_hud;
    NSString                   *_state_id;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = appDelegate.managedObjectContext;
    
    [self checkOrders];
    
    _parameters = [NSMutableDictionary dictionary];
    
    
    self.saveNContinueButton.layer.cornerRadius = 5.0f;
    
    
    if (self.shipAddress != nil) {
        self.firstNameTextField.text    = @"";
        self.lastNameTextField.text     = @"";
        self.address1TextField.text     = @"";
        
        if (![self.shipAddress[@"address"] isEqual:[NSNull null]])
            self.address2TextField.text     = self.shipAddress[@"address"];
        else
            self.address2TextField.text     = @"";
        
        self.phoneTextField.text        = @"";
        self.pincodeTextField.text      = self.shipAddress[@"pincode"];
        self.cityTextField.text         = @"";
        self.stateTextField.text        = @"";
    }
    else {
        
        /* do nothing if adding new address */
        
    }
    
//    [self loadPickerView];
    
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.labelText      = @"Loading...";
//    hud.dimBackground  = YES;
    
//    [[APIManager sharedManager] getStatesWithSuccess:^(NSArray *states) {
//        
//        [hud hide:YES];
//        
//        _states = states;
//        
//    } failure:^(NSError *error) {
//        
//        [hud hide:YES];
//        
//        NSLog(@"%@",[error localizedDescription]);
//    }];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}


-(void)dismissPickerView:(id)sender {
    [_pickerView resignFirstResponder];
}

- (IBAction)saveNContinueAction:(id)sender {
    
    NSLog(@"Parameters %@", _parameters);
    
    _orderModel = _orderFetchedResultsController.fetchedObjects.lastObject;
    
    
    if (self.shipAddress != nil) {
        
        /* if editing the address */
        
//        NSString *path  = [NSString stringWithFormat:@"/api/orders/%@/addresses/%@", _orderModel.number, self.shipAddress[@"id"]];
//        
//        
//        if (_orderModel.number != nil) {
//            [[APIManager sharedManager] putEditedAddressOfStore:_orderModel.store_id ofPath:path Parameters:_parameters WithSuccess:^(NSString *response) {
//                NSLog(@"%@", response);
//                
//                [self.navigationController popViewControllerAnimated:YES];
//                
//                
//            } failure:^(NSError *error) {
//                NSLog(@"%@", [error localizedDescription]);
//            }];
//        }
//        else
//            NSLog(@"No order exists");
    }
    else {
        
        /* if adding new address */
        
        User *user = [User savedUser];
        Location *location = [Location savedLocation];
        
        
        
        NSString *path = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/address"];
        
//        NSLog(@"%@", _parameters);
//        [_parameters setValue:@"105" forKey:@"country_id"];
//        
////        NSNumber *state_id = [NSNumber numberWithInteger:_state_id];
//        [_parameters setValue:_state_id forKey:[self addressKey:@"state_id"]];
//        
//        NSDictionary *addressJSONParameter = [self addressJSON];
//        NSLog(@"%@", addressJSONParameter);
//
//        [[APIManager sharedManager] putNewAddressForPath:path andParameter:addressJSONParameter WithSuccess:^(NSDictionary *response) {
//            NSLog(@"response %@", response);
//            
//            [self.navigationController popViewControllerAnimated:YES];
//            
//            
//        } failure:^(NSError *error) {
//            NSLog(@"%@", [error localizedDescription]);
//        }];
        
        
        NSString *parameter = [NSString stringWithFormat:@"address=%@&user_id=%@&latitude=%@&longitude=%@", [_parameters valueForKey:@"address[address1]"], user.userID, location.latitude, location.longitude];
        
        
        
        
        
//        NSError *error;
//        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:addressJSONParameter options:NSJSONWritingPrettyPrinted error:&error];
        
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
                        
                        
                        NSDictionary *address = [json objectForKey:@"address"][0];
                        [self saveAddress:address];
                        
                        
                        NSLog(@"Address SAved");
                        
                        [self dismissViewControllerAnimated:YES completion:nil];
//                        [self proceedToPaymentPage];
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


-(NSDictionary *)addressJSON {
    
    NSDictionary *orderAddress = @{
                                   @"order": @{
                                           @"bill_address_attributes": _parameters,
                                           @"ship_address_attributes": _parameters
                                           }
                                   };
    
    return orderAddress;
}



- (IBAction)textFieldDataChanged:(UITextField *)textField {
    
    
    if ([textField isEqual:self.firstNameTextField])
        [_parameters setValue:textField.text forKey:[self addressKey:@"firstname"]];
    else if ([textField isEqual:self.lastNameTextField])
        [_parameters setValue:textField.text forKey:[self addressKey:@"lastname"]];
    else if ([textField isEqual:self.address1TextField])
        [_parameters setValue:textField.text forKey:[self addressKey:@"address1"]];
    else if ([textField isEqual:self.address2TextField])
        [_parameters setValue:textField.text forKey:[self addressKey:@"address2"]];
    else if ([textField isEqual:self.phoneTextField])
        [_parameters setValue:textField.text forKey:[self addressKey:@"phone"]];
    else if ([textField isEqual:self.pincodeTextField])
        [_parameters setValue:textField.text forKey:[self addressKey:@"zipcode"]];
    else if ([textField isEqual:self.cityTextField])
        [_parameters setValue:textField.text forKey:[self addressKey:@"city"]];
    else if ([textField isEqual:self.stateTextField]) {
        
        
        
    }
    
    
}



-(NSString *)addressKey:(NSString *)key {
    
    if (self.shipAddress == nil) {
        return key;
    }
    else
        return [NSString stringWithFormat:@"address[%@]",key];
}


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



-(void)loadPickerView {
    
    _pickerView                      = [[UIPickerView alloc]init];
    _pickerView.delegate             = self;
    
    self.stateTextField.inputView    = _pickerView;
    
    // ToolBar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44)];
    [toolbar setBarStyle:UIBarStyleDefault];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissPickerView:)];
    toolbar.items = @[doneButton];
    toolbar.tintColor = [UIColor blackColor];
    
    [_pickerView addSubview:toolbar];
    
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




#pragma mark - UIPickerViewDelegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _states.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return [_states[row] valueForKey:@"name"];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.stateTextField.text = [_states[row] valueForKey:@"name"];
    _state_id  = [_states[row] valueForKey:@"id"];
    
}




@end

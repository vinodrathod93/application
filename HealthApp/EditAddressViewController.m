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
#import <UIKit+AFNetworking.h>
#import <AFHTTPSessionManager.h>
#import "AFNetworking.h"
#import "NSString+AddressValidation.h"


@implementation EditAddressViewController
{
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
    NSNumber                    *_selectedAddressTypeID;
    
    
    NSNumber *selectedCityID;
    NSNumber *selectedStateID;
    NSNumber *selectedAddTYpeID;
    
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    _parameters = [NSMutableDictionary dictionary];
    [self.AddressTypeButton addTarget:self action:@selector(showaddressTypeSheet:) forControlEvents:UIControlEventTouchUpInside];
    self.saveNContinueButton.layer.cornerRadius = 5.0f;
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = appDelegate.managedObjectContext;
    
    [self checkOrders];
    
    
    
    
    
    
    
    if (self.shipAddress != nil) {
        
        
        self.billingNametTextField.text=self.shipAddress[@"billingname"];
        self.phoneTextField.text=self.shipAddress[@"contactno"];
        self.buildingNameTextField.text=self.shipAddress[@"buildingname"];
        self.wingTextFiedl.text=self.shipAddress[@"wing"];
        self.flatNoTextField.text=self.shipAddress[@"unitno"];
        self.floorNoTextField.text=self.shipAddress[@"floor"];
        self.roadTextField.text=self.shipAddress[@"street_road_name"];
        self.landMarkTextField.text=self.shipAddress[@"landmark"];
        self.areaTextField.text=self.shipAddress[@"area"];
        self.pincodeTextField.text      = self.shipAddress[@"pincode"];
        self.cityTextField.text         = self.shipAddress[@"cityname"];
        self.stateTextField.text        = self.shipAddress[@"statename"];
        [self.AddressTypeButton setTitle:self.shipAddress[@"AddressType"] forState:UIControlStateNormal];
        
        
        selectedCityID =self.shipAddress[@"cityid"];
        selectedStateID=self.shipAddress[@"stateid"];
        selectedAddTYpeID=self.shipAddress[@"addresstypeid"];
        
        
        

//        NSString *str1=self.shipAddress[@"cityid"];
        _selected_city.cityID =selectedCityID;
//
       NSLog(@"str1 is %@",_selected_city.cityID.stringValue);
       
        
//        NSString *name = self.shipAddress[@"name"];
//        NSString *address = self.shipAddress[@"address"];
//        
//        NSArray *names = [name componentsSeparatedByString:@" "];
//        //        NSArray *addressLines = [address componentsSeparatedByString:@","];
//        
//        self.billingNametTextField.text    = [names firstObject];
//        //        self.lastNameTextField.text     = [names lastObject];
//        self.buildingNameTextField.text     = address;
//        self.roadTextField.text = @"";
//        self.areaTextField.text     = @"";
//        
//        self.pincodeTextField.text      = self.shipAddress[@"pincode"];
//        self.cityTextField.text         = self.shipAddress[@"cityname"];
//        self.stateTextField.text        = self.shipAddress[@"statename"];
        
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



-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat lastViewHeight = CGRectGetHeight(((UIView *)[self.contentView.subviews lastObject]).frame);
    int lastViewY = CGRectGetMaxY(((UIView *)[self.contentView.subviews lastObject]).frame);
    
    CGFloat height = lastViewHeight + lastViewY + 50;
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), height);
}



-(void)dismissPickerView:(id)sender {
    
    NSLog(@"Sender %@", sender);
    
    [_statesPickerView resignFirstResponder];
}



#pragma mark - UIButton Action

- (IBAction)saveNContinueAction:(id)sender {
    
    NSLog(@"Parameters %@", _parameters);
    
    _orderModel = _orderFetchedResultsController.fetchedObjects.lastObject;
    
    NSLog(@"%@",_orderModel);
    
    
    // Validate Form
    
    NSString *errorMessage = [self validateForm];
    if (errorMessage) {
        [self alertWithTitle:@"Invalid Address" message:errorMessage];
    }
    else {
        
        User *user = [User savedUser];
        Location *location = [Location savedLocation];
        
        NSString *path;
        NSString *parameter;
        NSString *complete_address;
        
        if (self.shipAddress != nil) {
            
            NSString *addressID = self.shipAddress[@"id"];
            
            
            path = [NSString stringWithFormat:@"http://192.168.1.199/NeediatorWebservice/neediatorWs.asmx/updateAddress"];
            
            complete_address = [NSString stringWithFormat:@"%@, %@, %@, %@, %@",  self.wingTextFiedl.text, self.flatNoTextField.text, self.floorNoTextField.text, self.buildingNameTextField.text, self.roadTextField.text];
            
            if (_selected_city.cityID == nil)
            {
                parameter=[NSString stringWithFormat:@"id=%@&addresstype=%@&billingname=%@&contactno=%@&address=%@&cityid=%@&stateid=%@&pincode=%@&latitude=%@&longitude=%@&unit_no=%@&floor=%@&street_road_name=%@&landmark=%@&area=%@&wing=%@&user_id=%@&buildingname=%@",
                           addressID,selectedAddTYpeID.stringValue,
                           self.billingNametTextField.text,
                           _phoneTextField.text,complete_address,
                           selectedCityID.stringValue,
                           selectedStateID.stringValue,
                           self.pincodeTextField.text,
                           location.latitude,
                           location.longitude,
                           self.flatNoTextField.text,
                           self.floorNoTextField.text,
                           self.roadTextField.text,
                           self.landMarkTextField.text,
                           self.areaTextField.text,
                           self.wingTextFiedl.text,
                           user.userID,
                           self.buildingNameTextField.text];
            }
else
{
    NSLog(@"Changed Format");
                parameter=[NSString stringWithFormat:@"id=%@&addresstype=%@&billingname=%@&contactno=%@&address=%@&cityid=%@&stateid=%@&pincode=%@&latitude=%@&longitude=%@&unit_no=%@&floor=%@&street_road_name=%@&landmark=%@&area=%@&wing=%@&user_id=%@&buildingname=%@",
                           addressID,_selectedAddressTypeID.stringValue,
                           self.billingNametTextField.text,
                           _phoneTextField.text,complete_address,
                           _selected_city.cityID.stringValue,
                           _selected_state.stateID.stringValue,
                           self.pincodeTextField.text,
                           location.latitude,
                           location.longitude,
                           self.flatNoTextField.text,
                           self.floorNoTextField.text,
                           self.roadTextField.text,
                           self.landMarkTextField.text,
                           self.areaTextField.text,
                           self.wingTextFiedl.text,
                           user.userID,
                           self.buildingNameTextField.text];
}
    
            
            
            
          
            
            
//            parameter=[NSString stringWithFormat:@"id=%@&addresstype=%@&billingname=%@&contactno=%@&address=%@&cityid=%@&stateid=%@&pincode=%@&latitude=%@&longitude=%@&unit_no=%@&floor=%@&street_road_name=%@&landmark=%@&area=%@&wing=%@&user_id=%@&buildingname=%@",
//                       addressID,_selectedAddressTypeID.stringValue,
//                       self.billingNametTextField.text,
//                       _phoneTextField.text,complete_address,
//                       _selected_city.cityID.stringValue,
//                       _selected_state.stateID.stringValue,
//                       self.pincodeTextField.text,
//                       location.latitude,
//                       location.longitude,
//                       self.flatNoTextField.text,
//                       self.floorNoTextField.text,
//                       self.roadTextField.text,
//                       self.landMarkTextField.text,
//                       self.areaTextField.text,
//                       self.wingTextFiedl.text,
//                       user.userID,
//                       self.buildingNameTextField.text];

            
            
            NSLog(@" edit address parameter %@",parameter);
            
            
            
            
            
        }
        else {
            
            
            /* if adding new address */
            // Path URL
            path = [NSString stringWithFormat:@"http://192.168.1.199/NeediatorWebservice/neediatorWs.asmx/addAddress"];
            
            complete_address = [NSString stringWithFormat:@"%@, %@, %@, %@, %@ %@", self.wingTextFiedl.text, self.flatNoTextField.text, self.floorNoTextField.text, self.buildingNameTextField.text, self.roadTextField.text,self.cityTextField.text];
            
            parameter=[NSString stringWithFormat:@"billingname=%@&addresstype=%@&contactno=%@&address=%@&cityid=%@&stateid=%@&pincode=%@&latitude=%@&longitude=%@&floor=%@&street_road_name=%@&unit_no=%@&landmark=%@&area=%@&wing=%@&user_id=%@&buildingname=%@",self.billingNametTextField.text,
                       _selectedAddressTypeID.stringValue,
                       _phoneTextField.text,complete_address,
                       _selected_city.cityID.stringValue,
                       _selected_state.stateID.stringValue,
                       self.pincodeTextField.text,
                       location.latitude,
                       location.longitude,
                       self.floorNoTextField.text,
                       self.roadTextField.text,
                       self.flatNoTextField.text,
                       self.landMarkTextField.text,
                       self.areaTextField.text,
                       self.wingTextFiedl.text,
                       user.userID,
                       self.buildingNameTextField.text];
            
            NSLog(@"%@", parameter);
            
            
        }
        
        
        
        
        
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:path]];
        request.HTTPMethod = @"POST";
        request.HTTPBody    = [NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
                                      {
                                          
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
                                                      
                                                  }
                                                  else {
                                                      
                                                      // Save address
                                                      NSArray *addressesArray = [json objectForKey:@"updateaddress"];
                                                      
                                                      NSLog(@"Address Saved %@", addressesArray);
                                                      
                                                      if ([_delegate respondsToSelector:@selector(addressDidSaved:)])
                                                      {
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
    
    _statesPickerView = [[UIPickerView alloc]init];
    _statesPickerView.delegate = self;
    self.stateTextField.inputView  = _statesPickerView;
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
    
    if (![self.billingNametTextField.text isValidAddress1]) {
        errorMessage = @"Please enter a valid address";
    } else if (![self.pincodeTextField.text isValidatePinCode]) {
        errorMessage = @"Please enter a valid Pincode";
    } else if (![self.stateTextField.text isValidState]) {
        errorMessage = @"Please select a state";
    } else if (![self.cityTextField.text isValidCity]) {
        errorMessage = @"Please select a city";
    };
    //        else if (![self.billingNametTextField.text isValidFirstName]) {
    //            errorMessage = @"Please enter a valid firstname";
    //        } else if (![self.roadTextField.text isValidLastName])
    //            errorMessage = @"Please enter a valid lastname";
    
    return errorMessage;
    
}

-(void)alertWithTitle:(NSString *)status message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
}



-(void)showaddressTypeSheet:(UIButton *)sender
{
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Address Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *namess = [self addressTypes];
    NSArray *idss   = [self addressIDs];
    
    [namess enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [sender setTitle:action.title forState:UIControlStateNormal];
            _selectedAddressTypeID = idss[idx];
            
            
            
        }];
        
        [controller addAction:action];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [controller addAction:cancel];
    
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:controller animated:YES completion:nil];
}
-(NSArray *)addressTypes
{
    
    NSArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Address_Types];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [names addObject:[type valueForKey:@"AddressType"]];
    }];
    return names;
}


-(NSArray *)addressIDs {
    NSArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Address_Types];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:[type valueForKey:@"id"]];
    }];
    
    return ids;
}
@end

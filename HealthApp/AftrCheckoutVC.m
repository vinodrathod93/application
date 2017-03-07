//
//  AftrCheckoutVC.m
//  Neediator
//
//  Created by adverto on 12/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "AftrCheckoutVC.h"
#import "PaymentVC.h"

@interface AftrCheckoutVC ()
{
    UIDatePicker *_dateTimePicker;
    NSNumber     *_selectedPurposeTypeID;
    NSNumber     *_selectedAddressTypeID;
    NSNumber     *_selectedDeliveryID;
    NSNumber *_selectedAddressID;
    NSString *_shippingAddress;
    
}

@end

@implementation AftrCheckoutVC

#pragma mark - View Did Load
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self showDateTimePicker];
    
    [self.orderTypeBtn addTarget:self action:@selector(showShippingTypeSheet:) forControlEvents:UIControlEventTouchUpInside];
    self.orderTypeBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.orderTypeBtn.layer.borderWidth = 1.f;
    self.orderTypeBtn.layer.masksToBounds = YES;
    
    
    [self.addressTypeButton addTarget:self action:@selector(showAddressTypeSheet:) forControlEvents:UIControlEventTouchUpInside];
    self.addressTypeButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.addressTypeButton.layer.borderWidth = 1.f;
    self.addressTypeButton.layer.masksToBounds = YES;
    
    
    //    self.EDIT_Button.layer.borderColor = [UIColor darkGrayColor].CGColor;
    //    self.EDIT_Button.layer.borderWidth = 1.f;
    //    self.EDIT_Button.layer.masksToBounds = YES;
    
    
    self.AddNewAddressBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.AddNewAddressBtn.layer.borderWidth = 1.f;
    self.AddNewAddressBtn.layer.masksToBounds = YES;
    [self.AddNewAddressBtn addTarget:self action:@selector(showAddresses:) forControlEvents:UIControlEventTouchUpInside];
    
    self.AddressTitle.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.AddressTitle.layer.borderWidth = 1.f;
    self.AddressTitle.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Show Address Type Sheet
-(void)showAddressTypeSheet:(UIButton *)sender
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



#pragma mark - DatePicker.
-(void)showDateTimePicker
{
    _dateTimePicker = [[UIDatePicker alloc]initWithFrame:CGRectZero];
    _dateTimePicker.datePickerMode = UIDatePickerModeDate;
    
    NSDate *currentDate = [NSDate date];
    NSDate *nextDate = [currentDate dateByAddingTimeInterval:60*60*24*30];
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
    
    
    
    NSLog(@"Current Date = %@", [dateFormat stringFromDate:currentDate]);
    NSLog(@"Next Date = %@", [dateFormat stringFromDate:nextDate]);
    
    [_dateTimePicker setMinimumDate:currentDate];
    [_dateTimePicker setMaximumDate:nextDate];
    
    self.Date_TF.inputView = _dateTimePicker;
    self.Date_TF.inputAccessoryView = [self pickupDateTimePickerToolBar];
    
    [_dateTimePicker addTarget:self action:@selector(setSelectedDateTime:) forControlEvents:UIControlEventValueChanged];
}

-(UIToolbar *)pickupDateTimePickerToolBar {
    UIToolbar *toolbar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,44)];
    toolbar.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 150, 21.f)];
    message.font = [NeediatorUtitity mediumFontWithSize:15.f];
    message.textAlignment = NSTextAlignmentCenter;
    message.backgroundColor = [UIColor clearColor];
    message.textColor = [UIColor darkGrayColor];
    message.text = @"Select Date and Time";
    
    
    
    UIBarButtonItem *flexibleSpaceRight = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithCustomView:message];
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissDateTimePickerView)];
    
    [toolbar setItems:@[flexibleSpaceLeft, titleButton, flexibleSpaceRight, doneButton] animated:YES];
    
    return toolbar;
}

-(void)dismissDateTimePickerView {
    
    [self.Date_TF resignFirstResponder];
}

-(void)setSelectedDateTime:(UIDatePicker *)picker {
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd MMMM yyyy"];
    self.Date_TF.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:picker.date]];
}

-(void)dismissPicker:(UITapGestureRecognizer *)recognizer {
    
    [self.Date_TF resignFirstResponder];
}



#pragma mark - Show Address & Address delegates..
-(void)showAddresses:(UIButton *)button {
    
    User *user = [User savedUser];
    if (user)
    {
        
        AddressesViewController *addressesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesVC"];
        addressesVC.isGettingOrder = YES;
        addressesVC.addressesArray = user.addresses;
        addressesVC.title = @"Addresses";
        addressesVC.delegate = self;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addressesVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
    else
        [NeediatorUtitity showLoginOnController:self isPlacingOrder:NO];
    
}

-(void)deliverableAddressDidSelect:(NSDictionary *)address {
    
    _selectedAddressID = address[@"id"];
    
    NSString *address1 = [[address valueForKey:@"address"] capitalizedString];
    
    if (![address1 isEqual:[NSNull null]])
        address1       = [address1 capitalizedString];
    else
        address1       = @"";
    
    NSString *zipcode  = [address valueForKey:@"pincode"];
    
    NSString *complete_address = [NSString stringWithFormat:@"%@, - %@",address1,zipcode];
    
    _shippingAddress = complete_address;
    [self.AddressTitle setTitle:complete_address forState:UIControlStateNormal];
    
    
}


#pragma mark - Button Action.
- (IBAction)Proceed_Action:(id)sender
{
    NSLog(@"Prpceed Action From AftrCheckoutVC");
    
    PaymentVC *pVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Payment"];
    
    pVC.prefeeredTime=self.Date_TF.text;
    pVC.deliveryType=_selectedDeliveryID.stringValue;
    pVC.addressID=_selectedAddressID.stringValue;
    
    pVC.StoreName=self.Storename;
    pVC.amountPayable=self.PayAmount;
    pVC.NoOfItems=self.noofItems;
    
    
    
    
    [self.navigationController pushViewController:pVC animated:YES];
}


#pragma mark - Show Shipping Type Sheet.
-(void)showShippingTypeSheet:(UIButton *)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Order Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *names = [self deliveryTypes];
    NSArray *ids   = [self deliveryIDs];
    
    [names enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [sender setTitle:action.title forState:UIControlStateNormal];
            _selectedDeliveryID = ids[idx];
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

-(NSArray *)deliveryTypes
{
    
    NSArray *delivery_types = [NeediatorUtitity savedDataForKey:kSAVE_DELIVERY_TYPES];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [delivery_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [names addObject:[type valueForKey:@"type"]];
    }];
    
    return names;
}

-(NSArray *)deliveryIDs {
    NSArray *delivery_types = [NeediatorUtitity savedDataForKey:kSAVE_DELIVERY_TYPES];
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [delivery_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:[type valueForKey:@"id"]];
    }];
    
    return ids;
}
@end

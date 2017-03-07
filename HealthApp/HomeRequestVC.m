//
//  HomeRequestVC.m
//  Neediator
//
//  Created by adverto on 10/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "HomeRequestVC.h"
#import "HomeRequestConfirmVC.h"

@interface HomeRequestVC ()
{
    UIDatePicker *_dateTimePicker;
    NSNumber     *_selectedPurposeTypeID;
    NSNumber     *_selectedAddressTypeID;
    NSNumber *_selectedAddressID;
    NSString *_shippingAddress;



}

@end

@implementation HomeRequestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showDateTimePicker];

    [self.PurposeButton addTarget:self action:@selector(showPurposeTypeSheet:) forControlEvents:UIControlEventTouchUpInside];
    self.PurposeButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.PurposeButton.layer.borderWidth = 1.f;
    self.PurposeButton.layer.masksToBounds = YES;
    
    [self.AddressTypeButton addTarget:self action:@selector(showAddressTypeSheet:) forControlEvents:UIControlEventTouchUpInside];
    self.AddressTypeButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.AddressTypeButton.layer.borderWidth = 1.f;
    self.AddressTypeButton.layer.masksToBounds = YES;

    self.EDIT_Button.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.EDIT_Button.layer.borderWidth = 1.f;
    self.EDIT_Button.layer.masksToBounds = YES;
    
    self.AddNewAddressButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.AddNewAddressButton.layer.borderWidth = 1.f;
    self.AddNewAddressButton.layer.masksToBounds = YES;
     [self.AddNewAddressButton addTarget:self action:@selector(showAddresses:) forControlEvents:UIControlEventTouchUpInside];

    self.ShowAddressButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.ShowAddressButton.layer.borderWidth = 1.f;
    self.ShowAddressButton.layer.masksToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Purpose Type Sheet.
-(void)showPurposeTypeSheet:(UIButton *)sender
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Purpose Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *namess = [self PurposeTypes];
    NSArray *idss   = [self PurposeTypeIDs];
    
    [namess enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [sender setTitle:action.title forState:UIControlStateNormal];
            _selectedPurposeTypeID = idss[idx];
            
           
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

-(NSArray *)PurposeTypes
{
    NSArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Purpose_Types];
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [names addObject:[type valueForKey:@"purposetype"]];
    }];
    return names;
}

-(NSArray *)PurposeTypeIDs {
    NSArray *address_types = [NeediatorUtitity savedDataForKey:kSAVE_Purpose_Types];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [address_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:[type valueForKey:@"id"]];
    }];
    
    return ids;
}





#pragma mark - Address Type Sheet..
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




#pragma mark - Date Picker
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
    [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
    self.Date_TF.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:picker.date]];
}

-(void)dismissPicker:(UITapGestureRecognizer *)recognizer {
    
    [self.Date_TF resignFirstResponder];
}





#pragma mark - Show Address..
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
#pragma mark - Address Delegate

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
    [self.ShowAddressButton setTitle:complete_address forState:UIControlStateNormal];
    
    
}


#pragma mark - Proceed Action.
- (IBAction)proceedAction:(id)sender
{
    HomeRequestConfirmVC *hrvc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeRequestConfirmVC"];
    
    hrvc.Date=self.Date_TF.text;
    hrvc.Time_Slot_From=self.TimeSlotFrom_TF.text;
    hrvc.Time_Slot_To=self.TimeSlotTo_TF.text;
    hrvc.Address_Type_ID=_selectedAddressTypeID.stringValue;
    hrvc.Purpose_Type_ID=_selectedPurposeTypeID.stringValue;
    hrvc.purposeName=self.PurposeButton.titleLabel.text;
    hrvc.AddressString=self.ShowAddressButton.titleLabel.text;
    
    hrvc.refferdby=self.optionalTF.text;

    
    
//    bcvc.PatientID=self.PatientIDOptionalTF.text;
//    bcvc.Commn_Date=self.Communication_Date_TF.text;
//    hrvc.refferdby=self.OptionalTF.text;
//    bcvc.ConsultingString=self.Consulting_String;

   
    [self.navigationController pushViewController:hrvc animated:YES];
    
    
    
}
@end

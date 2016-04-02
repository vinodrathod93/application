//
//  PaymentViewController.m
//  Chemist Plus
//
//  Created by adverto on 21/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "PaymentViewController.h"
#import "PaymentViewCell.h"
#import "CODInputViewCell.h"
#import "User.h"
#import "Address.h"
#import "OrderReviewViewController.h"
#import "AppDelegate.h"
#import "OrderCompleteViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "AddToCart.h"
#import "AddressInPaymentViewCell.h"
#import "PaymentDetailViewCell.h"
#import "AddShippingDetailsViewController.h"
#import "PaymentOptionsViewController.h"


#define kOPTIONS_CELLIDENTIFIER @"paymentCell"
#define kPAYMENT_SUMMARY_CELLIDENTIFIER @"paymentSummaryCell"
#define kPAY_CELLIDENTIFIER @"customPayCell"
#define kADDRESS_CELLIDENTIFIER @"addressInPaymentCell"
#define kPAYMENT_DELVIERY_CELLIDENTIFIER @"paymentDeliveryCellIdentifier"

#define kCheckoutURL @"/api/checkouts"
#define kPAYMENT_OPTIONS_URL @  "/api/checkouts"

#define kSECTION_COUNT 4

enum TABLEVIEWCELL {
    PAY_SECTION = 0,
    ADDRESS_OPTION_SECTION,
    DELIVERY_TYPE_SECTION,
    DELIVERY_TIME_SECTION
};

@interface PaymentViewController ()

// Data source Properties
@property (nonatomic, strong) NSString *display_total;
@property (nonatomic, strong) NSString *display_item_total;
@property (nonatomic, strong) NSString *display_delivery_total;
@property (nonatomic, strong) NSDictionary *shipAddress;
@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, strong) NSString *store;
@property (nonatomic, strong) NSString *store_url;
@property (nonatomic, strong) UIDatePicker *dateTimePickerView;

// Helper Properties
//@property (nonatomic, strong) NSNumber *payment_method_id;
//@property (nonatomic, assign) BOOL isPaymentOptionSelected;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *cartFetchedResultsController;

@end

typedef void(^completion)(BOOL finished);

@implementation PaymentViewController {
    UIButton *_proceedPaymentOption;
    NSInteger _sectionCount;
    NSDictionary *_userData;
    NSDictionary *_addressData;
    NSArray *_addresses;
    NSArray *_payment_methods;
    NSArray *_delivery_methods;
    NSString *_selectedDateTime;
    NSString *_selectedDeliveryID;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Checkout Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _sectionCount = 0;
    
    [self loadCheckoutProcess];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return _sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return (section == PAY_SECTION)? 2: 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *cellIdentifier = (indexPath.section == 0) ? ((indexPath.row == 0) ? kPAYMENT_SUMMARY_CELLIDENTIFIER: kPAY_CELLIDENTIFIER): (indexPath.section == 1)? kADDRESS_CELLIDENTIFIER: (indexPath.section == 2) ? kPAYMENT_DELVIERY_CELLIDENTIFIER : (indexPath.section == 3) ? kPAYMENT_DELVIERY_CELLIDENTIFIER : kOPTIONS_CELLIDENTIFIER;
    
    
    NSString *cellIdentifier;
    
    switch (indexPath.section) {
        case 0:
            cellIdentifier = (indexPath.row == 0) ? kPAYMENT_SUMMARY_CELLIDENTIFIER: kPAY_CELLIDENTIFIER;
            break;
            
        case 1:
            cellIdentifier = kADDRESS_CELLIDENTIFIER;
            break;
            
        case 2:
            cellIdentifier = kPAYMENT_DELVIERY_CELLIDENTIFIER;
            break;
            
        case 3:
            cellIdentifier = kPAYMENT_DELVIERY_CELLIDENTIFIER;
            break;
            
        default:
            cellIdentifier = kOPTIONS_CELLIDENTIFIER;
            break;
    }
    
    
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == PAY_SECTION) {
        if (indexPath.row == 0)
            [self configurePaymentSummaryCell:cell forIndexPath:indexPath];
        else
            [self configurePayCell:cell forIndexPath:indexPath];
        
    }
    else if (indexPath.section == ADDRESS_OPTION_SECTION)
        [self configureAddressOptionsCell:cell forIndexPath:indexPath];
    else if (indexPath.section == DELIVERY_TIME_SECTION) {
        [self configureDeliveryTimeCell:cell forIndexPath:indexPath];
    }
    else if (indexPath.section == DELIVERY_TYPE_SECTION) {
        [self configureDeliveryOptionCell:cell forIndexPath:indexPath];
    }
        
    
    
    return cell;
}


-(void)configureDeliveryOptionCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"Select Delivery Type";
    cell.textLabel.font = [NeediatorUtitity regularFontWithSize:14.f];
}


-(void)configureDeliveryTimeCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = nil;
    BOOL containsTF = NO;
    
    UITextField *unitTextField;
    
    for (id subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            containsTF = YES;
            
            unitTextField = (UITextField *)subView;
        }
    }
    
    if (!containsTF) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, CGRectGetWidth(self.view.frame) - (2*10), 40)];
        textField.placeholder = @"Select Time";
        [cell.contentView addSubview:textField];
        
        unitTextField = textField;
    }
    
    [self showDateTimePicker:unitTextField];
    
    
}

-(void)showDateTimePicker:(UITextField *)textfield {
    
    [self setupDatePicker];
    
    textfield.inputView = _dateTimePickerView;
    textfield.inputAccessoryView = [self pickupDatePickerToolBar];
    
    [_dateTimePickerView addTarget:self action:@selector(setSelectedOrderDateTime:) forControlEvents:UIControlEventValueChanged];
    
    
}

-(void)setSelectedOrderDateTime:(UIDatePicker *)picker {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:DELIVERY_TIME_SECTION]];
    
    for (id subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            
            UITextField *datetimeTextField = (UITextField *)subView;
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
            
            datetimeTextField.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:picker.date]];
            datetimeTextField.font = [NeediatorUtitity regularFontWithSize:14.f];
            
            _selectedDateTime = datetimeTextField.text;
        }
    }
    
}

-(void)setupDatePicker {
    _dateTimePickerView = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame) - 216.f, CGRectGetWidth(self.view.frame), 216.f)];
    _dateTimePickerView.datePickerMode = UIDatePickerModeDateAndTime;
    
    NSDate *currentDate = [NSDate date];
    NSDate *nextDate = [currentDate dateByAddingTimeInterval:60*60*24*3];
    
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
    
    NSLog(@"Current Date = %@", [dateFormat stringFromDate:currentDate]);
    NSLog(@"Next Date = %@", [dateFormat stringFromDate:nextDate]);
    
    [_dateTimePickerView setMinimumDate:currentDate];
    [_dateTimePickerView setMaximumDate:nextDate];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == ADDRESS_OPTION_SECTION) {
        
        if ([self.shipAddress isEqual:[NSNull null]])
            return 44.f;
        else
            return 90.f;
        
    }
    else if (indexPath.section == PAY_SECTION) {
        if (indexPath.row == 0)
            return 66.f;
        else
            return 44.f;
    }
    
    else
        return 44.f;
}

-(UIToolbar *)pickupDatePickerToolBar {
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
    
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dismissPickerView)];
    
    [toolbar setItems:@[flexibleSpaceLeft, titleButton, flexibleSpaceRight, doneButton] animated:YES];
    
    return toolbar;
}


-(void)dismissPickerView {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:DELIVERY_TIME_SECTION]];
    
    for (id subView in cell.contentView.subviews) {
        if ([subView isKindOfClass:[UITextField class]]) {
            
            UITextField *datetimeTextField = (UITextField *)subView;
            
            [datetimeTextField resignFirstResponder];
        }
    }
    
}

-(void)configurePayCell:(PaymentViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    cell.payLabel.text = @"You Pay";
    cell.amountLabel.text = self.display_total;
}



-(void)configurePaymentSummaryCell:(PaymentDetailViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    cell.subTotalValueLabel.text = self.display_item_total;
    cell.deliveryValueLabel.text = self.display_delivery_total;
}


-(void)configureAddressOptionsCell:(AddressInPaymentViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Shipping address %@", self.shipAddress);
    
    if (self.shipAddress != nil) {
        
        cell.textLabel.text = nil;
        
        
        NSString *address1 = [[self.shipAddress valueForKey:@"address"] capitalizedString];
        
        NSString *pincode  = [self.shipAddress valueForKey:@"pincode"];
        
        
        cell.name.text                  = [[self.shipAddress valueForKey:@"name"] capitalizedString];
        cell.addressDetailLabel.text    = [NSString stringWithFormat:@"%@, %@",address1, pincode];
        cell.mobileNumber.text          = [_userData valueForKey:@"phoneno"];
        cell.selectionStyle             = UITableViewCellSelectionStyleNone;
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIButton *edit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [edit setImage:[UIImage imageNamed:@"edit2"] forState:UIControlStateNormal];
        [edit addTarget:self action:@selector(editShippingDetails) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = edit;
    }
    else {
        
        cell.name.text                  = nil;
        cell.addressDetailLabel.text    = nil;
        cell.mobileNumber.text          = nil;
        
        cell.textLabel.text             = @"Add Shipping Address";
        cell.textLabel.font             = [UIFont fontWithName:@"AvenirNext-DemiBold" size:15.f];
        cell.textLabel.textColor        = [UIColor darkGrayColor];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIButton *add = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [add setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [add addTarget:self action:@selector(editShippingDetails) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = add;
        
    }
    
    
}



-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *storeName = self.store;
    NSString *selectedAddressHeader = @"Delivery Address";
    
    if (section == PAY_SECTION)
        return storeName;
    else if(section == ADDRESS_OPTION_SECTION)
        return selectedAddressHeader;
    else if (section == DELIVERY_TYPE_SECTION)
        return @"Select Delivery Type";
    else
        return @"Select Time";
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section == DELIVERY_TIME_SECTION )? 60.0f : 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    
    if (section == DELIVERY_TIME_SECTION) {
        view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60);
        
        _proceedPaymentOption = [[UIButton alloc]initWithFrame:CGRectMake(15, 20, self.view.frame.size.width - (2*15), 40)];
        [_proceedPaymentOption setTitle:@"PROCEED TO PAYMENT" forState:UIControlStateNormal];
        _proceedPaymentOption.layer.cornerRadius = 5.f;
        _proceedPaymentOption.layer.masksToBounds = YES;
        [_proceedPaymentOption.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:16.0f]];
        _proceedPaymentOption.titleLabel.textColor = [UIColor whiteColor];
        [_proceedPaymentOption setBackgroundColor:[UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f]];
        [_proceedPaymentOption addTarget:self action:@selector(proceedToPaymentOptions) forControlEvents:UIControlEventTouchUpInside];
        _proceedPaymentOption.alpha = 1.0f;
        _proceedPaymentOption.enabled = YES;
        
        [view addSubview:_proceedPaymentOption];
    }
    
    return view;
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == DELIVERY_TYPE_SECTION) {
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self showActivitySheet:cell];
    }
    
}

-(void)showActivitySheet:(UITableViewCell *)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Select Delivery Type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray *names = [self deliveryTypes];
    NSArray *ids   = [self deliveryIDs];
    
    [names enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            sender.textLabel.text = action.title;
            _selectedDeliveryID = ids[idx];
            
        }];
        
        [controller addAction:action];
    }];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller dismissViewControllerAnimated:YES completion:^{
            
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            
        }];
    }];
    
    [controller addAction:cancelAction];
    
    controller.popoverPresentationController.sourceView = sender;
    controller.popoverPresentationController.sourceRect = sender.bounds;
    [self presentViewController:controller animated:YES completion:nil];
    
}

-(NSArray *)deliveryTypes {
    NSArray *delivery_types = _delivery_methods;
    
    NSMutableArray *names = [[NSMutableArray alloc] init];
    
    [delivery_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [names addObject:[type valueForKey:@"type"]];
    }];
    
    return names;
}

-(NSArray *)deliveryIDs {
    NSArray *delivery_types = _delivery_methods;
    
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    
    [delivery_types enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        [ids addObject:[type valueForKey:@"id"]];
    }];
    
    return ids;
}


-(void)proceedToPaymentOptions {
    NSLog(@"Payment Options");
    
    
    if (self.shipAddress != nil) {
        
        
        if (_selectedDeliveryID == nil) {
            
            NSArray *allIndexPaths = [self allRowsindexPathsForSection:DELIVERY_TYPE_SECTION];
            [self calloutCells:allIndexPaths];
        }
        else if (_selectedDateTime == nil) {
            NSArray *allIndexPaths = [self allRowsindexPathsForSection:DELIVERY_TIME_SECTION];
            [self calloutCells:allIndexPaths];
        }
        else {
            
            PaymentOptionsViewController *paymentOptionsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentOptionsVC"];
            paymentOptionsVC.orderModel = self.orderModel;
            paymentOptionsVC.address_id = self.shipAddress[@"id"];
            paymentOptionsVC.selectedOrderDeliveryType = _selectedDeliveryID;
            paymentOptionsVC.selectedOrderTime  = _selectedDateTime;
            
            if (_payment_methods != nil) {
                paymentOptionsVC.payment_types  = _payment_methods;
            }
            else
                paymentOptionsVC.payment_types  = @[];
            
            
            NSLog(@"%@", self.shipAddress);
            
            [self.navigationController pushViewController:paymentOptionsVC animated:YES];
        }
        
        
        
    }
    else {
        [self calloutCells:@[[NSIndexPath indexPathForRow:0 inSection:ADDRESS_OPTION_SECTION] ]];
    }
    
}


-(NSArray *)allRowsindexPathsForSection:(NSInteger)section {
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i=0; i < [self.tableView numberOfRowsInSection:section]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        
        [array addObject:indexPath];
    }
    
    return array;
}

//-(void)createPayment {
//    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
//    NetworkStatus netStatus = [appDelegate.googleReach currentReachabilityStatus];
//    
//    if (netStatus != NotReachable) {
//        [self sendPaymentOptionToServer];
//    } else
//        [self displayNoConnection];
//
//}


//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == PAYMENT_OPTION_SECTION) {
//
//        if (self.isPaymentOptionSelected) {
//            [self deselectPaymentOptionForTableview:tableView forIndexPath:indexPath];
//            
//            self.payment_method_id = nil;
//        }
//        else {
//            [self selectPaymentOptionForTableview:tableView forIndexPath:indexPath];
//            
//            self.payment_method_id = [self.payment_methods[indexPath.row] valueForKey:@"id"];
//        }
//    }
//}




-(void)editShippingDetails {
//    AddShippingDetailsViewController *addShippingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingDetailsVC"];
//    [self.navigationController pushViewController:addShippingVC animated:YES];
    
    
    AddressesViewController *addressesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesVC"];
    addressesVC.isGettingOrder = YES;
    addressesVC.addressesArray = _addresses;
    addressesVC.user_data = _userData;
    addressesVC.title = @"Addresses";
    addressesVC.delegate = self;
    
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:addressesVC];
    
    [self presentViewController:navigationController animated:YES completion:nil];
    
//    EditAddressViewController *editAddressVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editAddressVC"];
//    editAddressVC.title = @"Add Address";
//    
//    if (![self.shipAddress isEqual:[NSNull null]]) {
//        
//        editAddressVC.title       = @"Edit Address";
//        editAddressVC.shipAddress = self.shipAddress;
//    }
//    
//    
//    [self.navigationController pushViewController:editAddressVC animated:YES];
    
    
    
}



-(void)deliverableAddressDidSelect:(NSDictionary *)address {
    
//    NSIndexPath *addressIndexPath = [NSIndexPath indexPathForRow:0 inSection:ADDRESS_OPTION_SECTION];
//    
//    AddressInPaymentViewCell *cell = [self.tableView cellForRowAtIndexPath:addressIndexPath];
//    
//    
//    NSString *address1 = [[self.shipAddress valueForKey:@"address"] capitalizedString];
//    
//    NSString *pincode  = [self.shipAddress valueForKey:@"pincode"];
//    
//    
//    cell.name.text                  = [[self.shipAddress valueForKey:@"name"] capitalizedString];
//    cell.addressDetailLabel.text    = [NSString stringWithFormat:@"%@, %@",address1, pincode];
//    cell.mobileNumber.text          = [_userData valueForKey:@"phoneno"];
//    cell.selectionStyle             = UITableViewCellSelectionStyleNone;
//    
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    
//    UIButton *edit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
//    [edit setImage:[UIImage imageNamed:@"edit2"] forState:UIControlStateNormal];
//    [edit addTarget:self action:@selector(editShippingDetails) forControlEvents:UIControlEventTouchUpInside];
//    
//    cell.accessoryView = edit;
    
    NSLog(@"Called Diselect address");
    
    
    self.shipAddress = address;
    [self.tableView reloadData];
}



#pragma mark - Animation

- (void)calloutCells:(NSArray*)indexPaths
{
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^void() {
                         for (NSIndexPath* indexPath in indexPaths)
                         {
                             [[self.tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES animated:YES];
                         }
                     }
                     completion:^(BOOL finished) {
                         for (NSIndexPath* indexPath in indexPaths)
                         {
                             [[self.tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
                         }
                     }];
}




#pragma mark - Network



-(void)loadCheckoutProcess {
    User *user = [User savedUser];
    Location *location = [Location savedLocation];
    
    NSString *url = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/viewCheckout"];
    NSLog(@"URL is --> %@", url);
    
    NSString *parameter = [NSString stringWithFormat:@"user_id=%@&cat_id=%@&store_id=%@&latitude=%@&longitude=%@",user.userID, self.orderModel.cat_id.stringValue, self.orderModel.store_id, location.latitude, location.longitude];
    NSLog(@"Parameter is %@", parameter);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody    = [NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                NSLog(@"%@",json);
                
                NSNumberFormatter *headerCurrencyFormatter = [[NSNumberFormatter alloc] init];
                [headerCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                [headerCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
                
                
                NSArray *totalCart              = [json valueForKey:@"totalcart"];
                NSArray *store                  = [json valueForKey:@"store"];
                NSArray *user                   = [json valueForKey:@"user"];
                _addresses                      = [json objectForKey:@"address"];
                _payment_methods                = [json objectForKey:@"paymenttype"];
                _delivery_methods               = [json objectForKey:@"deliverytype"] != nil ? [json objectForKey:@"deliverytype"]: @[];
                
                NSDictionary *storeData         = [store objectAtIndex:0];
                _userData                       = [user objectAtIndex:0];
                NSDictionary *totalData         = [totalCart objectAtIndex:0];
                
                
                self.display_total          = [headerCurrencyFormatter stringFromNumber:[totalData valueForKey:@"totalamount"]];
                self.display_item_total     = [headerCurrencyFormatter stringFromNumber:[totalData valueForKey:@"subtotal"]];
                
                
                NSInteger deliveryCharges = [[totalData valueForKey:@"deliverycharges"] integerValue];
                
                self.display_delivery_total = [headerCurrencyFormatter stringFromNumber:@(deliveryCharges)];
                self.total                  = [headerCurrencyFormatter stringFromNumber:[totalData valueForKey:@"totalamount"]];
                self.title                  = @"CHECKOUT";
                self.store                  = [[storeData valueForKey:@"name"] capitalizedString];

                _sectionCount               = kSECTION_COUNT;
                
                [self.hud hide:YES];
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    
                    NSLog(@"Checkout Initiated");
                    
                    // Reload Tableview
                    
                    [self.tableView reloadData];
                }
                
            });
        }
        else {
            
            [self.hud hide:YES];
            [self displayConnectionFailed];
        }
        
        
    }];
    
    [task resume];
    
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    [self.hud setCenter:self.view.center];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Checking out...";
}








/*

-(void)sendPaymentOptionToServer {
    User *user = [User savedUser];
    
    NSString *url = [NSString stringWithFormat:@"http://%@%@/%@?token=%@", self.store_url, kPAYMENT_OPTIONS_URL, self.order_id, user.access_token];
    NSLog(@"URL is --> %@", url);
    
    NSDictionary *payment_dictionary = [self createPaymentDictionary];
    NSLog(@"Payment Dictionary ==> %@",payment_dictionary);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payment_dictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                NSLog(@"Payment JSON ==> %@",json);
                
                [self.hud hide:YES];
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                    
                } else {
                    
                    
                    NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                    NSLog(@"Response %ld", (long)[url_response statusCode]);
                    
                    if (url_response.statusCode == 422) {
                        NSString *error = [json valueForKey:@"error"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertWithTitle:@"Error" message:error];
                        });
                        
                    } else if (url_response.statusCode == 200) {
                        NSLog(@"Payment Done");
                        
                        if ([[json valueForKey:@"state"] isEqualToString:@"complete"]) {
                            OrderCompleteViewController *orderCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
                            orderCompleteVC.order_id = self.order_id;
                            
                            
                            [self deleteCartProducts];
                            [self deleteAllLineItems];
                            
                            
                            [self.navigationController pushViewController:orderCompleteVC animated:YES];
                        } else {
                            [self alertWithTitle:@"Oops" message:@"We currently don't accept Credit Card & Paypal Payments"];
                        }
                        
                        
                    }

                    
                }
                
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hide:YES];
                [self displayConnectionFailed];
            });
        }
        
        
    }];
    
    [task resume];
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Making Payment...";
    self.hud.color = self.view.tintColor;
}


-(void)deleteCartProducts {
    
    
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"AddToCart"];
    NSArray *fetchedArray = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    
    for (NSManagedObject *product in fetchedArray) {
        [self.managedObjectContext deleteObject:product];
    }
    NSError *error = nil;
    [self.managedObjectContext save:&error];
}

-(void)deleteAllLineItems {
    
    NSFetchRequest *allLineItems = [[NSFetchRequest alloc] init];
    [allLineItems setEntity:[NSEntityDescription entityForName:@"LineItems" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *lineItems = [self.managedObjectContext executeFetchRequest:allLineItems error:&error];
    
    for (NSManagedObject *lineItem in lineItems) {
        [self.managedObjectContext deleteObject:lineItem];
    }
    
    
    // Order
    NSFetchRequest *orderFetchRequest = [[NSFetchRequest alloc]init];
    [orderFetchRequest setEntity:[NSEntityDescription entityForName:@"Order" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *orderError = nil;
    NSArray *orderArray = [self.managedObjectContext executeFetchRequest:orderFetchRequest error:&orderError];
    
    for (NSManagedObject *order in orderArray) {
        [self.managedObjectContext deleteObject:order];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
    
}
 
 */

//-(NSDictionary *)createPaymentDictionary {
//    
//    
//    NSDictionary *payment = @{
//                              @"order" : @{
//                                            @"payments_attributes": @[
//                                                                        @{
//                                                                            @"payment_method_id": self.payment_method_id.stringValue
//                                                                            }
//                                                                     ],
//                                            
//                                            @"use_existing_card": @"no",
//                                            @"state": @"payment"
//                                            }
//                              };
//    
//    
//    return payment;
//}


-(void)displayNoConnection {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

-(void)displayConnectionFailed {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
    
}

-(void)alertWithTitle:(NSString *)status message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}


/*
-(void)deselectPaymentOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_proceedPaymentOption setEnabled:NO];
    _proceedPaymentOption.alpha = 0.5f;
    
    self.isPaymentOptionSelected = NO;
    
    UITableViewCell *unSelectCell = [tableView cellForRowAtIndexPath:indexPath];
    unSelectCell.accessoryType = UITableViewCellAccessoryNone;
}

-(void)selectPaymentOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_proceedPaymentOption setEnabled:YES];
    _proceedPaymentOption.alpha = 1.f;
    
    UITableViewCell *paymentCell = [tableView cellForRowAtIndexPath:indexPath];
    paymentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.isPaymentOptionSelected = YES;
}

*/













#pragma mark - Not Required 

/*
 
 
 -(void)configurePhoneTextFieldCell:(CODInputViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
 cell.phoneTextField.placeholder = @"Mobile no.";
 }
 
 -(void)dismissCellKeyboard {
 UITextField *textField = (UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:PHONE_NUMBER_SECTION]] viewWithTag:100];
 
 [textField resignFirstResponder];
 }
 
 
 
*/

@end

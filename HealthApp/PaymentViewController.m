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
#import "EditAddressViewController.h"


#define kOPTIONS_CELLIDENTIFIER @"paymentCell"
#define kPAYMENT_SUMMARY_CELLIDENTIFIER @"paymentSummaryCell"
#define kPAY_CELLIDENTIFIER @"customPayCell"
#define kADDRESS_CELLIDENTIFIER @"addressInPaymentCell"

#define kCheckoutURL @"/api/checkouts"
#define kPAYMENT_OPTIONS_URL @  "/api/checkouts"

#define kSECTION_COUNT 3

enum TABLEVIEWCELL {
    PAY_SECTION = 0,
    ADDRESS_OPTION_SECTION,
    PAYMENT_OPTION_SECTION
    
};

@interface PaymentViewController ()

// Data source Properties
@property (nonatomic, strong) NSString *display_total;
@property (nonatomic, strong) NSString *display_item_total;
@property (nonatomic, strong) NSString *display_delivery_total;
@property (nonatomic, strong) NSDictionary *shipAddress;
@property (nonatomic, strong) NSString *total;
@property (nonatomic, strong) NSString *order_id;
@property (nonatomic, strong) NSArray *payment_methods;
@property (nonatomic, strong) NSString *store;
@property (nonatomic, strong) NSString *store_url;

// Helper Properties
@property (nonatomic, strong) NSNumber *payment_method_id;
@property (nonatomic, assign) BOOL isPaymentOptionSelected;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *cartFetchedResultsController;

@end

typedef void(^completion)(BOOL finished);

@implementation PaymentViewController {
    UIButton *_placeOrderButton;
    NSInteger _sectionCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
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
    return (section == PAY_SECTION)? 2: (section == PAYMENT_OPTION_SECTION)? [self.payment_methods count]: 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = (indexPath.section == 0) ? ((indexPath.row == 0) ? kPAYMENT_SUMMARY_CELLIDENTIFIER: kPAY_CELLIDENTIFIER): (indexPath.section == 1)? kADDRESS_CELLIDENTIFIER:kOPTIONS_CELLIDENTIFIER;
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == PAY_SECTION) {
        if (indexPath.row == 0)
            [self configurePaymentSummaryCell:cell forIndexPath:indexPath];
        else
            [self configurePayCell:cell forIndexPath:indexPath];
        
    }
    else if (indexPath.section == ADDRESS_OPTION_SECTION)
        [self configureAddressOptionsCell:cell forIndexPath:indexPath];
    
    else if(indexPath.section == PAYMENT_OPTION_SECTION)
        [self configurePaymentOptionsCell:cell forIndexPath:indexPath];
    
    
    
    return cell;
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


-(void)configurePayCell:(PaymentViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    cell.payLabel.text = @"You Pay";
    cell.amountLabel.text = self.display_total;
}


-(void)configurePaymentOptionsCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    if ([[self.payment_methods[indexPath.row] valueForKey:@"name"] isEqualToString:@"Check"]) {
        cell.textLabel.text = @"Cash on Delivery";
    }
    else
        cell.textLabel.text = [self.payment_methods[indexPath.row] valueForKey:@"name"];
    
}


-(void)configurePaymentSummaryCell:(PaymentDetailViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    cell.subTotalValueLabel.text = self.display_item_total;
    cell.deliveryValueLabel.text = self.display_delivery_total;
}


-(void)configureAddressOptionsCell:(AddressInPaymentViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

    if (![self.shipAddress isEqual:[NSNull null]]) {
        NSString *address1 = [[self.shipAddress valueForKey:@"address1"] capitalizedString];
        NSString *address2;
        
        if (![[self.shipAddress valueForKey:@"address2"] isEqual:[NSNull null]])
            address2           = [[self.shipAddress valueForKey:@"address2"] capitalizedString];
        else
            address2           = @"";
        
        NSString *city     = [[self.shipAddress valueForKey:@"city"] capitalizedString];
        NSString *zipcode  = [self.shipAddress valueForKey:@"zipcode"];
        
        
        cell.name.text                  = self.shipAddress[@"full_name"];
        cell.addressDetailLabel.text    = [NSString stringWithFormat:@"%@, %@, %@ - %@",address1, address2, city, zipcode];
        cell.mobileNumber.text          = self.shipAddress[@"phone"];
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
    NSString *paymentOptionsHeader = @"Select Payment Options";
    NSString *selectedAddressHeader = @"Delivery Address";
    
    return (section == PAY_SECTION) ? storeName: (section == PAYMENT_OPTION_SECTION) ? paymentOptionsHeader: selectedAddressHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section == PAYMENT_OPTION_SECTION )? 60.0f : 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    if (section == PAYMENT_OPTION_SECTION) {
        view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60);
        
        _placeOrderButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
        [_placeOrderButton setTitle:@"PLACE ORDER" forState:UIControlStateNormal];
        [_placeOrderButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:16.0f]];
        _placeOrderButton.titleLabel.textColor = [UIColor whiteColor];
        [_placeOrderButton setBackgroundColor:[UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f]];
        [_placeOrderButton addTarget:self action:@selector(createPayment) forControlEvents:UIControlEventTouchUpInside];
        _placeOrderButton.alpha = 0.5f;
        _placeOrderButton.enabled = NO;
        
        [view addSubview:_placeOrderButton];
    }
    
    return view;
    
}



-(void)createPayment {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NetworkStatus netStatus = [appDelegate.googleReach currentReachabilityStatus];
    
    if (netStatus != NotReachable) {
        [self sendPaymentOptionToServer];
    } else
        [self displayNoConnection];
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == PAYMENT_OPTION_SECTION) {

        if (self.isPaymentOptionSelected) {
            [self deselectPaymentOptionForTableview:tableView forIndexPath:indexPath];
            
            self.payment_method_id = nil;
        }
        else {
            [self selectPaymentOptionForTableview:tableView forIndexPath:indexPath];
            
            self.payment_method_id = [self.payment_methods[indexPath.row] valueForKey:@"id"];
        }
    }
}




-(void)editShippingDetails {
//    AddShippingDetailsViewController *addShippingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingDetailsVC"];
//    [self.navigationController pushViewController:addShippingVC animated:YES];
    
    
    EditAddressViewController *editAddressVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editAddressVC"];
    editAddressVC.title = @"Add Address";
    
    if (![self.shipAddress isEqual:[NSNull null]]) {
        
        editAddressVC.title       = @"Edit Address";
        editAddressVC.shipAddress = self.shipAddress;
    }
    
    
    [self.navigationController pushViewController:editAddressVC animated:YES];
    
    
    
}










#pragma mark - Network



-(void)loadCheckoutProcess {
    User *user = [User savedUser];
    
    NSString *url = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/checkout"];
    NSLog(@"URL is --> %@", url);
    
    NSString *parameter = [NSString stringWithFormat:@"user_id=%@&cat_id=%@&store_id=%@",user.userID, self.orderModel.cat_id.stringValue, self.orderModel.store_id];
    
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
                
                
                NSArray *totalCart          = [json valueForKey:@"totalcart"];
                NSDictionary *totalValue         = [totalCart objectAtIndex:0];
                
                self.order_id               = [json valueForKey:@"number"];
                self.display_total          = [NSString stringWithFormat:@"%@",[headerCurrencyFormatter stringFromNumber:[totalValue valueForKey:@"totalvalue"] ]];
                self.display_item_total     = [json valueForKey:@"display_item_total"];
                self.display_delivery_total = [json valueForKey:@"display_ship_total"];
                self.total                  = [json valueForKey:@"total"];
                self.payment_methods        = [json valueForKey:@"payment_methods"];
                self.title                  = [[json valueForKey:@"state"] capitalizedString];
                self.store                  = [[json valueForKeyPath:@"store.name"] capitalizedString];
                self.store_url              = [json valueForKeyPath:@"store.url"];
                self.shipAddress            = [json valueForKey:@"ship_address"];

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

-(NSDictionary *)createPaymentDictionary {
    
    
    NSDictionary *payment = @{
                              @"order" : @{
                                            @"payments_attributes": @[
                                                                        @{
                                                                            @"payment_method_id": self.payment_method_id.stringValue
                                                                            }
                                                                     ],
                                            
                                            @"use_existing_card": @"no",
                                            @"state": @"payment"
                                            }
                              };
    
    
    return payment;
}


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



-(void)deselectPaymentOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_placeOrderButton setEnabled:NO];
    _placeOrderButton.alpha = 0.5f;
    
    self.isPaymentOptionSelected = NO;
    
    UITableViewCell *unSelectCell = [tableView cellForRowAtIndexPath:indexPath];
    unSelectCell.accessoryType = UITableViewCellAccessoryNone;
}

-(void)selectPaymentOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_placeOrderButton setEnabled:YES];
    _placeOrderButton.alpha = 1.f;
    
    UITableViewCell *paymentCell = [tableView cellForRowAtIndexPath:indexPath];
    paymentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.isPaymentOptionSelected = YES;
}















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

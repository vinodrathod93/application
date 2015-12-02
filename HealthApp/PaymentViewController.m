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


#define kOPTIONS_CELLIDENTIFIER @"paymentCell"
#define kPAY_CELLIDENTIFIER @"customPayCell"
#define kPHONE_CELLIDENTIFIER @"phonenoCell"
#define kPLACE_ORDER_URL @"http://chemistplus.in/storePurchaseDetails.php"
#define kPAYMENT_OPTIONS_URL @  "http://manish.elnuur.com/api/checkouts"

enum TABLEVIEWCELL {
    PAY_SECTION = 0,
    PAYMENT_OPTION_SECTION,
    PHONE_NUMBER_SECTION
};

@interface PaymentViewController ()

@property (nonatomic, strong) NSNumber *payment_method_id;
@property (nonatomic, assign) NSInteger section_count;
@property (nonatomic, assign) BOOL isOptionSelected;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *cartFetchedResultsController;

@end

typedef void(^completion)(BOOL finished);

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.section_count = 2;
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.section_count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return (section == 0)? 1: (section == 1)? [self.payment_methods count]: 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = (indexPath.section == 0) ? kPAY_CELLIDENTIFIER: (indexPath.section == 1)? kOPTIONS_CELLIDENTIFIER:kPHONE_CELLIDENTIFIER;
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == PAY_SECTION) {
        [self configurePayCell:cell forIndexPath:indexPath];
    }
    else if(indexPath.section == PAYMENT_OPTION_SECTION) {
        [self configurePaymentOptionsCell:cell forIndexPath:indexPath];
    }
    else
        [self configurePhoneTextFieldCell:cell forIndexPath:indexPath];
    
    
    return cell;
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

-(void)configurePhoneTextFieldCell:(CODInputViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.phoneTextField.placeholder = @"Mobile no.";
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *payHeader = @"";
    NSString *paymentOptionsHeader = @"Select Payment Options";
    NSString *phoneNumberHeader = @"Enter Mobile Number";
    
    return (section == PAY_SECTION) ? payHeader: (section == PAYMENT_OPTION_SECTION) ? paymentOptionsHeader: phoneNumberHeader;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (section == PHONE_NUMBER_SECTION )? 60.0f : 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    if (section == PHONE_NUMBER_SECTION) {
        view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60);
        
        UIButton *placeOrderbutton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
        [placeOrderbutton setTitle:@"Place Order" forState:UIControlStateNormal];
        [placeOrderbutton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:16.0f]];
        [placeOrderbutton setBackgroundColor:[UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f]];
        [placeOrderbutton addTarget:self action:@selector(createPayment) forControlEvents:UIControlEventTouchUpInside];
        
        [view addSubview:placeOrderbutton];
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

        if (self.isOptionSelected) {
            [self deselectPaymentOptionForTableview:tableView forIndexPath:indexPath];
            self.payment_method_id = nil;
        }
        else {
            [self selectPaymentOptionForTableview:tableView forIndexPath:indexPath];
            self.payment_method_id = [self.payment_methods[indexPath.row] valueForKey:@"id"];
        }
    }
}


-(void)deselectPaymentOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    self.section_count -= 1;
    [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:PHONE_NUMBER_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.isOptionSelected = NO;
    
    UITableViewCell *unSelectCell = [tableView cellForRowAtIndexPath:indexPath];
    unSelectCell.accessoryType = UITableViewCellAccessoryNone;
}

-(void)selectPaymentOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    self.section_count += 1;
    [self.tableView insertSections:[NSIndexSet indexSetWithIndex:PHONE_NUMBER_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *paymentCell = [tableView cellForRowAtIndexPath:indexPath];
    paymentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.isOptionSelected = YES;
}



-(void)dismissCellKeyboard {
    UITextField *textField = (UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:PHONE_NUMBER_SECTION]] viewWithTag:100];
    
    [textField resignFirstResponder];
}




-(void)sendPaymentOptionToServer {
    User *user = [User savedUser];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@?token=%@",kPAYMENT_OPTIONS_URL, self.order_id, user.access_token];
    NSLog(@"URL is --> %@", url);
    
    NSDictionary *payment_dictionary = [self createPaymentDictionary];
    NSLog(@"Payment Dictionary ==> %@",payment_dictionary);
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payment_dictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    NSLog(@"%@",[[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding]);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    
//    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
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

@end

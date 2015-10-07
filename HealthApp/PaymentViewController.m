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
#import <MBProgressHUD/MBProgressHUD.h>


#define kOPTIONS_CELLIDENTIFIER @"paymentCell"
#define kPAY_CELLIDENTIFIER @"customPayCell"
#define kPHONE_CELLIDENTIFIER @"phonenoCell"
#define kPLACE_ORDER_URL @"http://chemistplus.in/storePurchaseDetails.php"
#define kPAYMENT_OPTIONS_URL @  "http://www.elnuur.com/api/checkouts"

enum TABLEVIEWCELL {
    PAY_SECTION = 0,
    PAYMENT_OPTION_SECTION,
    PHONE_NUMBER_SECTION
};

@interface PaymentViewController ()

@property (nonatomic, strong) NSString *payment_method_id;
@property (nonatomic, assign) NSInteger section_count;
@property (nonatomic, assign) BOOL isOptionSelected;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

typedef void(^completion)(BOOL finished);

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.section_count = 2;
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
    
    [self sendPaymentOptionToServer];
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
    
    NSLog(@"%@",payment_dictionary);
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:payment_dictionary options:NSJSONWritingPrettyPrinted error:&error];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"PUT";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",response);
            NSError *jsonError;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            NSLog(@"Payment JSON ==> %@",json);
            
            [self.hud hide:YES];
            if (jsonError) {
                NSLog(@"Error %@",[jsonError localizedDescription]);
                
            } else {
                
                NSLog(@"Payment Done");
                OrderReviewViewController *orderReviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderConfirmVC"];
                orderReviewVC.line_items     = [json valueForKey:@"line_items"];
                orderReviewVC.purchase_total = [json valueForKey:@"display_item_total"];
                orderReviewVC.shipping_total = [json valueForKey:@"display_ship_total"];
                orderReviewVC.complete_total = [json valueForKey:@"display_total"];
                orderReviewVC.order_id       = self.order_id;
                
                [self.navigationController pushViewController:orderReviewVC animated:YES];
                
            }
            
        });
        
    }];
    
    [task resume];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
}


-(NSDictionary *)createPaymentDictionary {
    NSDictionary *payment = @{
                              @"order" : @{
                                            @"payments_attributes": @[
                                                                        @{
                                                                            @"payment_method_id": self.payment_method_id
                                                                            }
                                                                     ]
                                            }
                              };
    
    return payment;
}

@end

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
#import "ProductOrderConfirmationViewController.h"
#import "User.h"
#import "Address.h"


#define kOPTIONS_CELLIDENTIFIER @"paymentCell"
#define kPAY_CELLIDENTIFIER @"customPayCell"
#define kPHONE_CELLIDENTIFIER @"phonenoCell"
#define kPLACE_ORDER_URL @"http://chemistplus.in/storePurchaseDetails.php"

enum TABLEVIEWCELL {
    PAY_SECTION = 0,
    PAYMENT_OPTION_SECTION,
    PHONE_NUMBER_SECTION
};

@interface PaymentViewController ()

@property (nonatomic, strong) NSArray *order_products;
@property (nonatomic, strong) NSString *amount;
@property (nonatomic, assign) NSInteger section_count;
@property (nonatomic, assign) BOOL isOptionSelected;

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.amount = [self.orderDetails valueForKey:@"total_amount"];
    self.order_products = [self.orderDetails valueForKey:@"products"];
    
    User *user = [User savedUser];
    Address *address = [Address savedAddress];
    
    self.section_count = 2;
    
//    UITapGestureRecognizer *keyboardDismissTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissCellKeyboard)];
//    [self.view addGestureRecognizer:keyboardDismissTapGesture];
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
    return (section == 0)? 1:1;
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
    cell.amountLabel.text = [NSString stringWithFormat:@"Rs. %@",self.amount];
}

-(void)configurePaymentOptionsCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"Cash on Delivery";
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
        
        [view addSubview:placeOrderbutton];
    }
    
    return view;
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"placeOrderConfirmationVC"]) {
//        ProductOrderConfirmationViewController *orderConfirmVC = segue.destinationViewController;
        
        
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == PAYMENT_OPTION_SECTION) {

        if (self.isOptionSelected) {
            self.section_count -= 1;
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:PHONE_NUMBER_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            self.isOptionSelected = NO;
            
            UITableViewCell *unSelectCell = [tableView cellForRowAtIndexPath:indexPath];
            unSelectCell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            self.section_count += 1;
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:PHONE_NUMBER_SECTION] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            UITableViewCell *paymentCell = [tableView cellForRowAtIndexPath:indexPath];
            paymentCell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            self.isOptionSelected = YES;
        }
    }
}

/*
-(void)placeOrderAction {
    NSDictionary *json = [NSDictionary dictionaryWithObjectsAndKeys:self.order_products, @"products",
                          self.detailsDictionary, @"userInfo", self.amount, @"orderAmount", nil];
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
#warning push data to confirmation page
        });
        
        
    }];
    [task resume];
}
*/

-(void)dismissCellKeyboard {
    UITextField *textField = (UITextField *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:PHONE_NUMBER_SECTION]] viewWithTag:100];
    
    [textField resignFirstResponder];
}

@end

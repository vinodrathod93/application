//
//  PaymentViewController.m
//  Chemist Plus
//
//  Created by adverto on 21/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "PaymentViewController.h"
#import "PaymentViewCell.h"
#import "ProductOrderConfirmationViewController.h"
#import "User.h"
#import "Address.h"


#define kCELLIDENTIFIER @"paymentCell"
#define kPAY_CELLIDENTIFIER @"customPayCell"
#define kPLACE_ORDER_URL @"http://chemistplus.in/storePurchaseDetails.php"

@interface PaymentViewController ()

@property (nonatomic, strong) NSArray *order_products;
@property (nonatomic, strong) NSString *amount;

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.amount = [self.orderDetails valueForKey:@"total_amount"];
    self.order_products = [self.orderDetails valueForKey:@"products"];
    
    User *user = [User savedUser];
    Address *address = [Address savedAddress];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return (section == 0)? 1:1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellIdentifier = (indexPath.section == 0) ? kPAY_CELLIDENTIFIER: kCELLIDENTIFIER;
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        [self configurePayCell:cell forIndexPath:indexPath];
    } else
        [self configurePaymentOptionsCell:cell forIndexPath:indexPath];
    
    return cell;
}

-(void)configurePayCell:(PaymentViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.payLabel.text = @"You Pay";
    cell.amountLabel.text = [NSString stringWithFormat:@"Rs. %@",self.amount];
}

-(void)configurePaymentOptionsCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"Cash on Delivery";
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *selectOptions = @"Select Payment Options";
    return (section == 0) ? @"": selectOptions;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"placeOrderConfirmationVC"]) {
//        ProductOrderConfirmationViewController *orderConfirmVC = segue.destinationViewController;
        
        
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

@end

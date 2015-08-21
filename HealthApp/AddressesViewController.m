//
//  AddressesViewController.m
//  Chemist Plus
//
//  Created by adverto on 20/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "AddressesViewController.h"
#import "AddShippingDetailsViewController.h"
#import "OrderSummaryViewCell.h"
#import "PaymentViewController.h"

#define kADD_ADDRESS_CELL @"addAddressCell"
#define kAVAILABLE_ADDRESS_CELL @"availabeAddressCell"
#define kORDER_SUMMARY_CELL @"orderSummaryCell"

@interface AddressesViewController ()
{
    NSString *cellIdentifier;
}

@property (nonatomic, weak) NSMutableArray *addressArray;
@end

@implementation AddressesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addressArray = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return (section == 0) ? 1: (section == 1)? 2:1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cellIdentifier = (indexPath.section == 0) ? kADD_ADDRESS_CELL: (indexPath.section == 1)? kAVAILABLE_ADDRESS_CELL:kORDER_SUMMARY_CELL;
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier  forIndexPath:indexPath];
    
    if (indexPath.section == 0)
        [self configureAddAddressCell:cell forIndexPath:indexPath];
    else if(indexPath.section == 1)
        [self configureAvailableAddressCell:cell forIndexPath:indexPath];
    else if (indexPath.section == 2)
        [self configureOrderSummaryCell:cell forIndexPath:indexPath];
    
    return cell;
}


-(void)configureAddAddressCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"Add Address...";
}


-(void)configureAvailableAddressCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"available address";
}

-(void)configureOrderSummaryCell:(OrderSummaryViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSArray *products = [self.cartDetails valueForKey:@"products"];
    cell.itemsLabel.text = [NSString stringWithFormat:@"%lu Item",(unsigned long)products.count];
    cell.amountLabel.text = [NSString stringWithFormat:@"Rs. %@",[self.cartDetails valueForKey:@"total_amount"]];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AddShippingDetailsViewController *addShippingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingDetailsVC"];
        [self.navigationController pushViewController:addShippingVC animated:YES];
    }
        
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *selectAddress = @"Select Delivery Address";
    NSString *orderSummary = @"Order Summary";
    
    return (section == 0)? @"": (section == 1)? selectAddress: orderSummary;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        return 82.0f;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"paymentSegue"]) {
        PaymentViewController *paymentVC = segue.destinationViewController;
        paymentVC.amount = [self.cartDetails valueForKey:@"total_amount"];
    }
}


@end

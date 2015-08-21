//
//  PaymentViewController.m
//  Chemist Plus
//
//  Created by adverto on 21/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "PaymentViewController.h"
#import "PaymentViewCell.h"

#define kCELLIDENTIFIER @"paymentCell"
#define kPAY_CELLIDENTIFIER @"customPayCell"

@interface PaymentViewController ()

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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



@end

//
//  AddressesViewController.m
//  Chemist Plus
//
//  Created by adverto on 20/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "AddressesViewController.h"
#import "AddShippingDetailsViewController.h"

#define kADD_ADDRESS_CELL @"addAddressCell"
#define kAVAILABLE_ADDRESS_CELL @"availabeAddressCell"

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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return (section == 0) ? 1:2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cellIdentifier = (indexPath.section == 0) ? kADD_ADDRESS_CELL: kAVAILABLE_ADDRESS_CELL;
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier  forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        [self configureAddAddressCell:cell forIndexPath:indexPath];
    } else
        [self configureAvailableAddressCell:cell forIndexPath:indexPath];
    
    return cell;
}


-(void)configureAddAddressCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"Add Address...";
}


-(void)configureAvailableAddressCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"available address";
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AddShippingDetailsViewController *addShippingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingDetailsVC"];
        [self.navigationController pushViewController:addShippingVC animated:YES];
    } else
        NSLog(@"available addresses");
}

@end

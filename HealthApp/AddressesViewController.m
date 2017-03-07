//
//  AddressesViewController.m
//  Chemist Plus
//
//  Created by adverto on 20/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "AddressesViewController.h"
#import "AddShippingDetailsViewController.h"
#import "DeliveryViewController.h"
#import "PaymentViewController.h"
#import "AddressCell.h"
#import "AppDelegate.h"
#import "User.h"
#import <MBProgressHUD/MBProgressHUD.h>

#define kADD_ADDRESS_CELL @"addAddressCell"
#define kAVAILABLE_ADDRESS_CELL @"availabeAddressCell"
#define kORDER_SUMMARY_CELL @"orderSummaryCell"
#define kOrders_url @"http://www.elnuur.com/api/orders/"
#define kCheckout_address_url @"http://www.elnuur.com/api/checkouts/"

@interface AddressesViewController ()
{
    NSString *cellIdentifier;
}


@property (nonatomic, strong) NeediatorHUD *hud;
@property (nonatomic, strong) NSMutableArray *available_addresses;


@end

typedef void(^completion)(BOOL finished);

@implementation AddressesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    _available_addresses = [NSMutableArray arrayWithArray:self.addressesArray];
    
    self.title = @"My Addresses";
    
    [self loadAddresses];
    
    if (self.isGettingOrder) {
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed:)];
        self.navigationItem.rightBarButtonItem = cancelButton;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    _available_addresses = [NSMutableArray arrayWithArray:self.addressesArray];
    [self.tableView reloadData];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Addresses Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideHUD];
}

- (void)cancelPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
//    NSLog(@"%@", [self isAddressAvailable]);
    
//    return [self isAddressAvailable] ? 2 : 1;
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return (section == 0) ? 1: _available_addresses.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    cellIdentifier = (indexPath.section == 0) ? kADD_ADDRESS_CELL:  kAVAILABLE_ADDRESS_CELL;
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier  forIndexPath:indexPath];
    
    
    NSLog(@"Sections = %ld",(long)[self numberOfSectionsInTableView:tableView]);
    
    if (indexPath.section == 0) {
        
        [self configureAddAddressCell:cell forIndexPath:indexPath];
    }
    else if(indexPath.section == 1) {
        
        [self configureAvailableAddressCell:cell forIndexPath:indexPath];
        
        
    }
    
    return cell;
}


-(void)configureAddAddressCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    cell.textLabel.text = @"Add Address";
    
//    if ([self isAddressAvailable]) {
//        cell.textLabel.text = @"Add Address";
//    }
//    else
//        cell.textLabel.text = @"No Address";
    
}


-(void)configureAvailableAddressCell:(AddressCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    
    NSDictionary *address = _available_addresses[indexPath.row];
    
    
    NSLog(@" Available Addresses is--\n %@", address);
    
    if (self.isGettingOrder) {
        
//        BOOL deliverable = [[address valueForKey:@"deliverable"] boolValue];
//        if (!deliverable) {
//            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            cell.backgroundColor = [UIColor lightGrayColor];
//            cell.userInteractionEnabled = NO;
//        }
    }
    else
    {
        UIButton *edit = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [edit setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
        [edit addTarget:self action:@selector(editAddress:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.accessoryView = edit;
    }
    
    
    
    cell.full_name.text = [[address valueForKey:@"billingname"]capitalizedString];
    
    NSString *address1 = [[address valueForKey:@"address"] capitalizedString];
    
    if (![address1 isEqual:[NSNull null]])
        address1       = [address1 capitalizedString];
    else
        address1       = @"";
    
    NSString *zipcode  = [address valueForKey:@"pincode"];
    cell.completeAddress.text = [NSString stringWithFormat:@"%@, - %@",address1, zipcode];
    
    cell.AddressTYpe.text=[address valueForKey:@"AddressType"];
    cell.ContactNumber.text=[NSString stringWithFormat:@"Mob.No-%@",[address valueForKey:@"contactno"]];
    
    
}


-(void)editAddress:(UIButton *)sender {
    
    NSLog(@"%@", [sender superview]);
    
    AddressCell *cell = (AddressCell *)[sender superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    EditAddressViewController *editAddressVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editAddressVC"];
    editAddressVC.title = @"Edit Address";
    editAddressVC.shipAddress = _available_addresses[indexPath.row];
    
    NSLog(@"Edited address Should be %@",_available_addresses[indexPath.row]);
    
    editAddressVC.delegate = self;
    
    
    [self.navigationController pushViewController:editAddressVC animated:YES];
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *selectAddress = @"Select Delivery Address";
    if (section == 0) {
        return nil;
    }
    else
        return selectAddress;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 110.0f;
    }
    else
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 1) {
        
        if (self.isGettingOrder) {
            NSDictionary *address = _available_addresses[indexPath.row];
            
            if ([self.delegate respondsToSelector:@selector(deliverableAddressDidSelect:)]) {
                
                NSLog(@"Yes, Its available - %@", address);
                [self.delegate deliverableAddressDidSelect:address];
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else {
        EditAddressViewController *editAddressVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editAddressVC"];
        editAddressVC.title = @"Add Address";
        editAddressVC.delegate = self;
        [self.navigationController pushViewController:editAddressVC animated:YES];
    }
}



#pragma mark - Edit Address Delegate 

-(void)addressDidSaved:(NSArray *)addresses {
    
    NSLog(@"Before %@", _available_addresses);
    
   [_available_addresses removeAllObjects];
    [_available_addresses addObjectsFromArray:addresses];
    
    [self.tableView reloadData];

    
    NSLog(@" addresses array is %@", _available_addresses);
    
}


#pragma mark - Editing Tableview Methods


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.isGettingOrder) {
        if (indexPath.section == 1) {
            return YES;
        }
        else
            return NO;
    }
    else
        return NO;
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        return UITableViewCellEditingStyleDelete;
    }
    else
        return UITableViewCellEditingStyleNone;
    
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        NSDictionary *address = _available_addresses[indexPath.row];
        
        [self deleteAddress:address atIndexPath:indexPath];
        
    }
    
}



#pragma mark - Network

-(void)loadAddresses {
    
    
    [self showHUD];
    
    [[NAPIManager sharedManager] getAllAddressesWithSuccess:^(NSArray *address) {
        NSArray *allAddresses = address;
        
        [_available_addresses removeAllObjects];
        [_available_addresses addObjectsFromArray:allAddresses];
        
        [self hideHUD];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        NSLog(@"Error: %@", error.localizedDescription);
        
        [self alertWithTitle:@"Loading Address" message:error.localizedDescription];
    }];
}



-(void)deleteAddress:(NSDictionary *)address atIndexPath:(NSIndexPath *)indexPath {
     [self showHUD];
    
    NSString *addressID = [address valueForKey:@"id"];
    
    [[NAPIManager sharedManager] deleteAddress:addressID withSuccess:^(BOOL success) {
        
        [self hideHUD];
        
        if (success) {
            
            [_available_addresses removeObject:address];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            NSLog(@"Something went wrong!");
            [self alertWithTitle:@"Delete Address" message:@"Something went wrong. Please try again."];
        }
        
    } failure:^(NSError *error) {
        [self hideHUD];
        NSLog(@"Error: %@", error.localizedDescription);
        
        [self alertWithTitle:@"Delete Address" message:error.localizedDescription];
    }];
}

-(BOOL)isAddressAvailable {
    
    if (_available_addresses.count > 0) {
        return YES;
    }
    else
        return NO;
}

#pragma mark - MBProgressHUD

-(void)showHUD
{
    self.hud = [[NeediatorHUD alloc] initWithFrame:self.tableView.frame];
    self.hud.overlayColor = [UIColor clearColor];
    [self.hud fadeInAnimated:YES];
    self.hud.hudCenter = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) / 2);
    [self.navigationController.view insertSubview:self.hud belowSubview:self.navigationController.navigationBar];
}

-(void)hideHUD {
    [self.hud fadeOutAnimated:YES];
    [self.hud removeFromSuperview];
}


#pragma mark - UIAlertView

-(void)alertWithTitle:(NSString *)status message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil, nil];
    [alert show];
}


-(void)displayConnectionFailed {
    UIAlertView *failed_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [failed_alert show];
}

-(void)displayNoConnection {
    UIAlertView *connection_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [connection_alert show];
}


@end

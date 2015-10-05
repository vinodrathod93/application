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
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSDictionary *shipping_data;

@end

typedef void(^completion)(BOOL finished);

@implementation AddressesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [self deleteCurrentOrder];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSLog(@"%@",self.addresses);
    
    return ([self.addresses isEqual: [NSNull null]]) ? 1 : 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    return (section == 0) ? 1: 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cellIdentifier = (indexPath.section == 0) ? kADD_ADDRESS_CELL:  kAVAILABLE_ADDRESS_CELL;
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier  forIndexPath:indexPath];
    NSLog(@"Sections = %ld",(long)[self numberOfSectionsInTableView:tableView]);
    
    if (indexPath.section == 0)
        [self configureAddAddressCell:cell forIndexPath:indexPath];
    
    else if(indexPath.section == 1)
        [self configureAvailableAddressCell:cell forIndexPath:indexPath];
    
    
    return cell;
}


-(void)configureAddAddressCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = @"Add Address";
}


-(void)configureAvailableAddressCell:(AddressCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.full_name.text = [[self.addresses valueForKey:@"full_name"] capitalizedString];
    
    NSString *address1 = [[self.addresses valueForKey:@"address1"] capitalizedString];
    NSString *address2 = [[self.addresses valueForKey:@"address2"] capitalizedString];
    NSString *city     = [[self.addresses valueForKey:@"city"] capitalizedString];
    NSString *zipcode  = [self.addresses valueForKey:@"zipcode"];
    cell.completeAddress.text = [NSString stringWithFormat:@"%@, %@, %@ - %@",address1, address2, city, zipcode];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        AddShippingDetailsViewController *addShippingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingDetailsVC"];
        [self.navigationController pushViewController:addShippingVC animated:YES];
    }
    else if (indexPath.section == 1) {
        DeliveryViewController *deliveryVC = [self.storyboard instantiateViewControllerWithIdentifier:@"deliveryVC"];
        
        [self sendAddressToServerWithCompletion:^(BOOL finished) {
            if (finished) {
                deliveryVC.shipping_data = self.shipping_data;
                deliveryVC.order_id      = self.order_id;
                
                [self.navigationController pushViewController:deliveryVC animated:YES];
            }
            else
                NSLog(@"Could not send address");
            
        }];
        
        
    }
        
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *selectAddress = @"Select Delivery Address";
    NSString *orderSummary = @"Order Summary";
    
    return (section == 0)? @"": (section == 1)? selectAddress: orderSummary;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return 120.0f;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}



-(void)deleteCurrentOrder {
    User *user = [User savedUser];
    
    
    NSString *url = [NSString stringWithFormat:@"%@%@/empty?token=%@",kOrders_url, self.order_id, user.access_token];
    NSLog(@"URL is --> %@", url);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"PUT";
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",response);
            NSError *jsonError;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            NSLog(@"JSON ==> %@",json);
            
            [self.hud hide:YES];
            if (jsonError) {
                NSLog(@"Error %@",[jsonError localizedDescription]);
            } else {
                
                NSLog(@"Order Line items empty");
                
            }
            
        });
        
    }];
    
    [task resume];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
}


-(void)sendAddressToServerWithCompletion:(completion)isComplete {
    User *user = [User savedUser];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?token=%@",kCheckout_address_url, self.order_id, user.access_token];
    NSLog(@"URL is --> %@", url);
    
    NSDictionary *order_address = [self addressJSON:user];
    
    NSLog(@"Address ===> %@",order_address);
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:order_address options:NSJSONWritingPrettyPrinted error:&error];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"PUT";
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",response);
            NSError *jsonError;
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            NSLog(@"JSON ==> %@",json);
            
            [self.hud hide:YES];
            if (jsonError) {
                NSLog(@"Error %@",[jsonError localizedDescription]);
            } else {
                
                NSDictionary *shippment = [json valueForKey:@"shipments"][0];
                self.shipping_data = [shippment valueForKey:@"selected_shipping_rate"];
                
                isComplete(YES);
            }
            
        });
        
    }];
    
    [task resume];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
    
}


-(NSDictionary *)createAddressesDictionaryForUser:(User *)user {
    
    NSDictionary *shipping_address = @{
                                       @"firstname"     : [user.ship_address valueForKey:@"firstname"],
                                       @"lastname"      : [user.ship_address valueForKey:@"lastname"],
                                       @"address1"      : [user.ship_address valueForKey:@"address1"],
                                       @"city"          : [user.ship_address valueForKey:@"city"],
                                       @"phone"         : [user.ship_address valueForKey:@"phone"],
                                       @"zipcode"       : [user.ship_address valueForKey:@"zipcode"],
                                       @"state_id"      : [user.ship_address valueForKey:@"state_id"],
                                       @"country_id"    : [user.ship_address valueForKey:@"country_id"]
                                       };
    
    return shipping_address;
}


-(NSDictionary *)addressJSON:(User *)user {
    
    NSDictionary *orderAddress = @{
                                   @"order": @{
                                           @"bill_address_attributes": [self createAddressesDictionaryForUser:user],
                                           @"ship_address_attributes": [self createAddressesDictionaryForUser:user]
                                           }
                                   };
    
    return orderAddress;
}

@end

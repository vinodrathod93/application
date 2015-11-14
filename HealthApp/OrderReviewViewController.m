//
//  OrderReviewViewController.m
//  Chemist Plus
//
//  Created by adverto on 05/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "OrderReviewViewController.h"
#import "OrderReviewFooterView.h"
#import "OrderCompleteViewController.h"
#import "User.h"
#import "AddressesViewController.h"
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define cellIdentifier @"reviewProductCell"
#define kComplete_order_url @"http://www.elnuur.com/api/checkouts"

@interface OrderReviewViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

typedef void (^completion)(BOOL finished);

@implementation OrderReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Review Order";
    self.navigationItem.hidesBackButton = YES;
    
    NSLog(@"%@",self.line_items);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.line_items count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    NSString *image = [self productImageForIndexPath:indexPath];
    
    // Configure the cell...
    [cell.product_imageview sd_setImageWithURL:[NSURL URLWithString:image]];
    cell.name.text              = [self productNameForIndexPath:indexPath];
    cell.quantity.text          = [NSString stringWithFormat:@"Qty: %@",[self productQtyForIndexPath:indexPath]];
    cell.variant.text           = [self productVariantForIndexPath:indexPath];
    cell.total_price.text       = [self productAmountForIndexPath:indexPath];
    
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 106.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 165.0f;
}


#pragma mark - Table view delegate

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    OrderReviewFooterView *footerView = [[[NSBundle mainBundle] loadNibNamed:@"OrderReviewFooterView" owner:self options:nil] lastObject];
    footerView.frame = CGRectMake(0, 0, self.view.frame.size.width, 165);
    footerView.purchase_price_label.text = self.purchase_total;
    footerView.tax_label.text = self.tax_total;
    footerView.total_price_label.text    = self.complete_total;
    
    return footerView;
}

- (IBAction)proceedToCheckoutPressed:(id)sender {
    
//    [self sendCompleteRequestWithCompletion:^(BOOL finished) {
//        if (finished) {
//            NSLog(@"finished");
//            OrderCompleteViewController *orderCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
//            orderCompleteVC.order_id = self.order_id;
//            
//            [self.navigationController pushViewController:orderCompleteVC animated:YES];
//
//            
//        } else
//            NSLog(@"Could not send Complete Request");
//    }];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NetworkStatus netStatus = [appDelegate.googleReach currentReachabilityStatus];
    
    if (netStatus != NotReachable) {
        [self sendCheckoutRequestToServer];
    } else
        [self displayNoConnection];
    
    
}




#pragma mark - Helper Methods 


-(void)sendCheckoutRequestToServer {
    User *user = [User savedUser];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/next.json?token=%@",kComplete_order_url, self.order_id, user.access_token];
    NSLog(@"URL is --> %@", url);
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"PUT";
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                [self.hud hide:YES];
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    
                    NSLog(@"JSON ==> %@",json);
                    NSString *order_id = [json valueForKey:@"number"];
                    [self showAddressesPageWithOrderID:order_id];
                    
                }
                
            });

        } else {
            [self displayConnectionFailed];
        }
        
    }];
    
    [task resume];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
}



-(NSString *)productNameForIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *variant   = [self.line_items[indexPath.row] valueForKey:@"variant"];
    NSString *name          = [variant valueForKey:@"name"];
    
    return name;
}

-(NSString *)productVariantForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *variant   = [self.line_items[indexPath.row] valueForKey:@"variant"];
    NSString *option_value  = [variant valueForKey:@"options_text"];
    
    return option_value;
}


-(NSString *)productImageForIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *variant   = [self.line_items[indexPath.row] valueForKey:@"variant"];
    
    NSArray *images         = [variant valueForKey:@"images"];
    
    return (images.count != 0)? [images[0] valueForKey:@"small_url"]: @"";
}

-(NSString *)productAmountForIndexPath:(NSIndexPath *)indexPath {
    NSString *amount        = [self.line_items[indexPath.row] valueForKey:@"display_amount"];
    
    return amount;
}


-(NSString *)productQtyForIndexPath:(NSIndexPath *)indexPath {
    NSNumber *quantity      = [self.line_items[indexPath.row] valueForKey:@"quantity"];
    
    return quantity.stringValue;
}

-(void)showAddressesPageWithOrderID:(NSString *)order_id {
    NSLog(@"order_id %@",order_id);
    
    User *user = [User savedUser];
    AddressesViewController *addressVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesVC"];
    addressVC.addresses = user.ship_address;
    addressVC.order_id  = order_id;
    
    [self.navigationController pushViewController:addressVC animated:YES];
}


-(void)displayConnectionFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *failed_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [failed_alert show];
    });
}

-(void)displayNoConnection {
    UIAlertView *connection_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [connection_alert show];
}

@end

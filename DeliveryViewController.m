//
//  DeliveryViewController.m
//  Chemist Plus
//
//  Created by adverto on 02/10/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "DeliveryViewController.h"
#import "User.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "PaymentViewController.h"
#import "AppDelegate.h"


#define kCheckout_delivery_url @"http://www.elnuur.com/api/checkouts"

@interface DeliveryViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end


@implementation DeliveryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Delivery";
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
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deliveryCell" forIndexPath:indexPath];
    
    
    cell.textLabel.text = [self.shipping_data valueForKey:@"name"];
    cell.detailTextLabel.text = [self.shipping_data valueForKey:@"display_cost"];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return  60.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60);
    
    UIButton *placeOrderbutton = [[UIButton alloc]initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 40)];
    [placeOrderbutton setTitle:@"Proceed" forState:UIControlStateNormal];
    [placeOrderbutton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:16.0f]];
    [placeOrderbutton setBackgroundColor:[UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f]];
    [placeOrderbutton addTarget:self action:@selector(proceedToPayment) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:placeOrderbutton];
    
    
    return view;
    
}


-(void)showPaymentPage {
    User *user = [User savedUser];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/next.json?token=%@",kCheckout_delivery_url, self.order_id, user.access_token];
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
                    
                    PaymentViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
                    paymentVC.order_id               = [json valueForKey:@"number"];
                    paymentVC.display_total          = [json valueForKey:@"display_total"];
                    paymentVC.total                  = [json valueForKey:@"total"];
                    paymentVC.payment_methods        = [json valueForKey:@"payment_methods"];
                    [self.navigationController pushViewController:paymentVC animated:YES];
                    
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
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
}


-(void)proceedToPayment {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NetworkStatus netStatus = [appDelegate.googleReach currentReachabilityStatus];
    
    if (netStatus != NotReachable) {
        [self showPaymentPage];
    } else
        [self displayNoConnection];
    
}




-(void)displayNoConnection {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

-(void)displayConnectionFailed {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
    
}


/*

-(void)sendDeliveryDataToServer {
    User *user = [User savedUser];
    
    NSString *url = [NSString stringWithFormat:@"%@%@?token=%@",kCheckout_delivery_url, self.order_id, user.access_token];
    NSLog(@"URL is --> %@", url);
    
    NSDictionary *delivery_data = [self createDeliveryDictionary];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:delivery_data options:NSJSONWritingPrettyPrinted error:&error];
    
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
            
            
            [self.hud hide:YES];
            if (jsonError) {
                NSLog(@"Error %@",[jsonError localizedDescription]);
            } else {
                
                NSLog(@"JSON ==> %@",json);
                
                PaymentViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
                paymentVC.order_id               = [json valueForKey:@"number"];
                paymentVC.display_total          = [json valueForKey:@"display_total"];
                paymentVC.total                  = [json valueForKey:@"total"];
                [self.navigationController pushViewController:paymentVC animated:YES];
                
            }
            
        });
        
    }];
    
    [task resume];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.view.tintColor;
}



-(NSDictionary *)createDeliveryDictionary {
    NSDictionary *delivery = @{
                               @"order": @{
                                       @"shipments_attributes": @{
                                               @"0": @{
                                                       @"selected_shipping_rate_id": [self.shipping_data valueForKey:@"id"],
                                                       @"id"                       : [self.shipping_data valueForKey:@"shipping_method_id"]
                                                       }
                                               }
                                       }
                               };
    
    return delivery;
}

*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

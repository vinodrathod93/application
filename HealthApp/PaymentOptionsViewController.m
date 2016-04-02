//
//  PaymentOptionsViewController.m
//  Neediator
//
//  Created by adverto on 01/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "PaymentOptionsViewController.h"
#import "OrderCompleteViewController.h"
#import "AppDelegate.h"
#import "LineItems.h"

@interface PaymentOptionsViewController ()

@property (nonatomic, strong) NSNumber *payment_method_id;
@property (nonatomic, assign) BOOL isPaymentOptionSelected;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UIDatePicker *dateTimePickerView;
@property (strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation PaymentOptionsViewController {
    UIButton *_placeOrderButton;
    NSURLSessionDataTask *_task;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"PAYMENT OPTIONS";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Payment Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}



#pragma mark - Table view delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (section == 0) {
        return self.payment_types.count;
    }
    else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"paymentOptionCellIdentifier" forIndexPath:indexPath];
    
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"paymentOptionCellIdentifier"];
//    }
    
    if (indexPath.section == 0) {
        
        NSDictionary *payment_option = self.payment_types[indexPath.row];
        cell.textLabel.text = payment_option[@"paymenttype"];
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17.f];
    }
//    else if (indexPath.section == 2) {
//        
//        cell.textLabel.text = @"";
//        
//        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, CGRectGetWidth(self.view.frame) - (2*10), 40)];
//        textField.placeholder = @"Select Time";
//        [cell.contentView addSubview:textField];
//        
//        [self showDateTimePicker:textField];
//        
//    }
    
    
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 44.f;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return @"Select Payment Option";
    }
    else
        return @"";

    
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        return 60.f;
    }
    else
        return 1.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectZero];
    
    if (section == 0) {
        view.backgroundColor = [UIColor clearColor];
        
        view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 60);
        
        _placeOrderButton = [[UIButton alloc]initWithFrame:CGRectMake(15, 20, self.view.frame.size.width - (2*15), 40)];
        [_placeOrderButton setTitle:@"PLACE ORDER" forState:UIControlStateNormal];
        _placeOrderButton.layer.cornerRadius = 5.f;
        _placeOrderButton.layer.masksToBounds = YES;
        [_placeOrderButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:16.0f]];
        _placeOrderButton.titleLabel.textColor = [UIColor whiteColor];
        [_placeOrderButton setBackgroundColor:[UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f]];
        [_placeOrderButton addTarget:self action:@selector(placeOrderPressed:) forControlEvents:UIControlEventTouchUpInside];
        //    _placeOrderButton.alpha = 0.5f;
        //    _placeOrderButton.enabled = NO;
        
        [view addSubview:_placeOrderButton];
    }
    else
        view.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 1);
    
    return view;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        if (self.isPaymentOptionSelected) {
            [self deselectPaymentOptionForTableview:tableView forIndexPath:indexPath];
            
            self.payment_method_id = nil;
        }
        else {
            [self selectPaymentOptionForTableview:tableView forIndexPath:indexPath];
            
            self.payment_method_id = [self.payment_types[indexPath.row] valueForKey:@"id"];
        }
    }
    
    
}



-(void)deselectPaymentOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_placeOrderButton setEnabled:NO];
    _placeOrderButton.alpha = 0.5f;
    
    self.isPaymentOptionSelected = NO;
    
    UITableViewCell *unSelectCell = [tableView cellForRowAtIndexPath:indexPath];
    unSelectCell.accessoryType = UITableViewCellAccessoryNone;
}

-(void)selectPaymentOptionForTableview:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [_placeOrderButton setEnabled:YES];
    _placeOrderButton.alpha = 1.f;
    
    UITableViewCell *paymentCell = [tableView cellForRowAtIndexPath:indexPath];
    paymentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    self.isPaymentOptionSelected = YES;
}


-(void)placeOrderPressed:(UIButton *)sender {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NetworkStatus netStatus = [appDelegate.googleReach currentReachabilityStatus];
    
    
    if (self.payment_method_id != nil) {
        
        
        
        if (_selectedOrderDeliveryType == nil) {
            
            NSArray *allIndexPaths = [self allRowsindexPathsForSection:1];
            [self calloutCells:allIndexPaths];
        }
        else if (_selectedOrderTime == nil) {
            NSArray *allIndexPaths = [self allRowsindexPathsForSection:2];
            [self calloutCells:allIndexPaths];
        }
        else {
            
            
            if (netStatus != NotReachable) {
                [self sendPaymentOptionToServer];
            } else
                [self displayNoConnection];
        }
        
        
        
    }
    else {
        
        // Highlight cell
        
        NSArray *allIndexPaths = [self allRowsindexPathsForSection:0];
        [self calloutCells:allIndexPaths];
    }
    

}



-(void)sendPaymentOptionToServer {
    User *user = [User savedUser];
    
    NSString *url = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/addOrder"];
    NSLog(@"URL is --> %@", url);
    
    NSString *parameter = [NSString stringWithFormat:@"user_id=%@&payment_id=%@&address_id=%@&store_id=%@&cat_id=%@&delivery_type=%@&preffered_time=%@", user.userID, self.payment_method_id.stringValue, self.address_id, self.orderModel.store_id, self.orderModel.cat_id.stringValue, _selectedOrderDeliveryType, _selectedOrderTime];
    NSLog(@"Payment parameter ==> %@",parameter);
    
    
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[NSData dataWithBytes:[parameter UTF8String] length:[parameter length]]];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                NSLog(@"Payment JSON ==> %@",json);
                
                [self.hud hide:YES];
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                    
                } else {
                    
                    
                    NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                    NSLog(@"Response %ld", (long)[url_response statusCode]);
                    
                    if (url_response.statusCode == 422) {
                        NSString *error = [json valueForKey:@"error"];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self alertWithTitle:@"Error" message:error];
                        });
                        
                    } else if (url_response.statusCode == 200) {
                        NSLog(@"Payment Done");
                        
                        NSString *orderNumberResponse = [json valueForKey:@"orderno"];
                        
                        if (orderNumberResponse != nil) {
                            
                            OrderCompleteViewController *orderCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
                            orderCompleteVC.order_id = orderNumberResponse;
                            
                            
                            [self deleteOrder];
                            
                            [self.navigationController pushViewController:orderCompleteVC animated:YES];
                        }
                        else
                            [self alertWithTitle:@"Response Error" message:@"Something went wrong. Please Try again later"];
                        
                        
                        
                    }
                    else {
                        [self alertWithTitle:@"Error" message:@"Something went wrong. Please Try again later"];
                    }
                    
                    
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
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Making Payment...";
    self.hud.color = self.view.tintColor;
}



-(void)deleteOrder {
    
//    // Order
    NSArray *lineItems = self.orderModel.cartLineItems.allObjects;
    
    for (LineItems *lineItem in lineItems) {
        [self.managedObjectContext deleteObject:lineItem];
    }
    
    
    
    [self.managedObjectContext deleteObject:self.orderModel];
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
    
}




-(void)requestPaymentOptions {
    
    /*
     [self showHUD];
     _task = [[NAPIManager sharedManager] getPaymentOptionsWithSuccess:^(NSDictionary *response) {
     
     [self hideHUD];
     self.payment_methods = response[@"payment"];
     
     [self.tableView reloadData];
     
     } failure:^(NSError *error) {
     
     [self hideHUD];
     NSLog(@"Error in payment %@", error.localizedDescription);
     
     
     [self alertWithTitle:@"Error while Payment" message:error.localizedDescription];
     }];
     */
    
}


#pragma mark - UIAlertView & HUD


-(void)alertWithTitle:(NSString *)status message:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:status message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)displayNoConnection {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

-(void)displayConnectionFailed {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
    
}

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.labelText = @"Loading...";
    self.hud.labelColor = [UIColor darkGrayColor];
    self.hud.activityIndicatorColor = [UIColor blackColor];
    self.hud.detailsLabelColor = [UIColor darkGrayColor];
    self.hud.dimBackground = YES;
}

-(void)hideHUD {
    [self.hud hide:YES];
}



#pragma mark - Animation

- (void)calloutCells:(NSArray*)indexPaths
{
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^void() {
                         for (NSIndexPath* indexPath in indexPaths)
                         {
                             [[self.tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES animated:YES];
                         }
                     }
                     completion:^(BOOL finished) {
                         for (NSIndexPath* indexPath in indexPaths)
                         {
                             [[self.tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
                         }
                     }];
}



-(NSArray *)allRowsindexPathsForSection:(NSInteger)section {
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i=0; i < [self.tableView numberOfRowsInSection:section]; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:section];
        
        [array addObject:indexPath];
    }
    
    return array;
}


@end

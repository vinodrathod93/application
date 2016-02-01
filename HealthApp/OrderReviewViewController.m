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
#import "AddToCart.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "PaymentViewController.h"

#define cellIdentifier @"reviewProductCell"
#define kComplete_order_url @"http://manish.elnuur.com/api/checkouts"
#define kcreateOrderURL @"http://manish.elnuur.com/api/orders"

@interface OrderReviewViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *cartFetchedResultsController;

@end

typedef void (^completion)(BOOL finished);

@implementation OrderReviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.title = @"Review Order";
    self.navigationItem.hidesBackButton = YES;
    
    
    NSLog(@"%@",self.line_items);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = self.appDelegate.managedObjectContext;
    
    [self.cartFetchedResultsController performFetch:nil];
    
//    [self sendOrderToServer];
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

#pragma mark - Fetched Results Controller

-(NSFetchedResultsController *)cartFetchedResultsController {
    if (_cartFetchedResultsController) {
        return _cartFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AddToCart" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"addedDate"
                                        ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _cartFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _cartFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.cartFetchedResultsController performFetch:&error]) {
        NSLog(@"Core data error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _cartFetchedResultsController;
}



#pragma mark - Helper Methods 

-(NSArray *)getCartProducts {
    
    NSMutableArray *jsonarray = [[NSMutableArray alloc] init];
    
    [self.cartFetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(AddToCart *model, NSUInteger idx, BOOL *stop) {
        NSDictionary *dict  = @{
                                @"variant_id"  : model.productID,
                                @"quantity"    : model.quantity
                                };
        
        [jsonarray addObject:dict];
        
    }];
    
    return jsonarray;
    
}

-(NSDictionary *)createOrdersDictionary:(NSArray *)array {
    NSDictionary *orders = @{
                             @"order": @{
                                     @"line_items": array
                                     }
                             };
    return orders;
}

-(void)sendOrderToServer {
    
    User *user = [User savedUser];
    
    NSArray *lineItems = [self getCartProducts];
    
    if (lineItems.count != 0) {
        
        NSDictionary *order = [self createOrdersDictionary:lineItems];
        
        
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:order options:NSJSONWritingPrettyPrinted error:&error];
        
        NSString *url = [NSString stringWithFormat:@"%@?token=%@",kcreateOrderURL, user.access_token];
        NSLog(@"URL is --> %@", url);
        NSLog(@"Dictionary is -> %@",order);
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = @"POST";
        request.HTTPBody = jsonData;
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
        
        
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
                        
                        NSLog(@"Json Cart ===> %@",json);
                        
                        NSLog(@"Order initiated");
//                        [self showOrderReviewPage:json];
                        
                        self.line_items     = [json objectForKey:@"line_items"];
                        self.purchase_total = [json valueForKey:@"display_item_total"];
                        self.tax_total      = [json valueForKey:@"display_tax_total"];
                        self.complete_total = [json valueForKey:@"display_total"];
                        self.order_id       = [json valueForKey:@"number"];
                        
                        [self.tableView reloadData];
                    }
                    
                });
            }
            else {
                [self displayConnectionFailed];
            }
            
            
        }];
        
        [task resume];
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.color = self.view.tintColor;
    }
    else
        NSLog(@"Cart is Empty");
    
}


-(void)sendCheckoutRequestToServer {
    User *user = [User savedUser];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/advance?token=%@",kComplete_order_url, self.order_id, user.access_token];
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
//                    [self showAddressesPageWithOrderID:order_id];
                    
                    PaymentViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
                    
                    /* commented just because all the checkout process in done in viewwillappear of PaymentVC */
                    
//                    paymentVC.order_id               = [json valueForKey:@"number"];
//                    paymentVC.display_total          = [json valueForKey:@"display_total"];
//                    paymentVC.total                  = [json valueForKey:@"total"];
//                    paymentVC.payment_methods        = [json valueForKey:@"payment_methods"];
                    [self.navigationController pushViewController:paymentVC animated:YES];
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
//    addressVC.addresses = user.ship_address;
    addressVC.order_id  = order_id;
    addressVC.isGettingOrder = YES;
    
    [self.navigationController pushViewController:addressVC animated:YES];
}


-(void)displayConnectionFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.hud hide:YES];
        
        UIAlertView *failed_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [failed_alert show];
    });
}

-(void)displayNoConnection {
    [self.hud hide:YES];
    
    UIAlertView *connection_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [connection_alert show];
}

@end

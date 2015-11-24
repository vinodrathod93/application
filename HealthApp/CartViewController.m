 //
//  CartViewController.m
//  Chemist Plus
//
//  Created by adverto on 23/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "CartViewController.h"
#import "CartViewCell.h"
#import "CartViewModel.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "HeaderLabel.h"
#import "OrderInputsViewController.h"
#import "InputFormViewController.h"
#import "AddShippingDetailsViewController.h"
#import "User.h"
#import "StoreRealm.h"
#import "LogSignViewController.h"
#import "AddressesViewController.h"
#import "OrderReviewViewController.h"
#import "PaymentViewController.h"
#import "Order.h"
#import "LineItems.h"

#define kCheckoutURL @"/api/checkouts"
#define kOrderDetailsURL @"/api/orders"

static NSString *cellIdentifier = @"cartCell";

@interface CartViewController ()<NSFetchedResultsControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) NSFetchedResultsController *cartFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *orderNumFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *lineItemsFetchedResultsController;

@property (nonatomic, strong) NSURLSessionDataTask *task;

@property (nonatomic, strong) LineItems *lineItemModel;

@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, strong) CartViewModel *viewModel;
@property (nonatomic, assign) BOOL isAlreadyLoggedIn;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong) AppDelegate *appDelegate;

@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = self.appDelegate.managedObjectContext;
    
    [self.cartFetchedResultsController performFetch:nil];
    [self.orderNumFetchedResultsController performFetch:nil];
    
    [self fetchLineItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCheckoutRequestToServer) name:@"loggedInSendOrderNotification" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.task == nil) {
        [self getOrderLineItemDetails];
    } else if (self.task.state == NSURLSessionTaskStateRunning) {
        NSLog(@"State running");
        
    } else if (self.task.state == NSURLSessionTaskStateCanceling) {
        NSLog(@"State Canceling");
    } else if (self.task.state == NSURLSessionTaskStateCompleted) {
        NSLog(@"State Completed");
        [self getOrderLineItemDetails];
        
    } else if (self.task.state == NSURLSessionTaskStateSuspended) {
        NSLog(@"State Suspended");
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
   

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)removeAllLineItems {
    NSFetchRequest *allLineItems = [[NSFetchRequest alloc] init];
    [allLineItems setEntity:[NSEntityDescription entityForName:@"LineItems" inManagedObjectContext:self.managedObjectContext]];
//    [allLineItems setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *lineItems = [self.managedObjectContext executeFetchRequest:allLineItems error:&error];

    //error handling goes here
    for (NSManagedObject *lineItem in lineItems) {
        [self.managedObjectContext deleteObject:lineItem];
    }
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSLog(@"%lu",(unsigned long)self.lineItemsFetchedResultsController.sections.count);
    
    return self.lineItemsFetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
//    id<NSFetchedResultsSectionInfo> sectionInfo = [self.lineItemsFetchedResultsController sections][section];
//    NSLog(@"%lu",(unsigned long)[sectionInfo numberOfObjects]);
//    [self updateBadgeValue];
    
//    return [sectionInfo numberOfObjects];
    NSLog(@"Count is %lu",self.lineItemsFetchedResultsController.fetchedObjects.count);
    
    return self.lineItemsFetchedResultsController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CartViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
//        AddToCart *model = [self.cartFetchedResultsController objectAtIndexPath:indexPath];
        LineItems *model = [self.lineItemsFetchedResultsController objectAtIndexPath:indexPath];
        
        NSNumberFormatter *cellCurrencyFormatter = [[NSNumberFormatter alloc] init];
        [cellCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [cellCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
        
//        NSString *quantity_price_string = [cellCurrencyFormatter stringFromNumber:model.totalPrice];
        NSString *quantity_price_string = [cellCurrencyFormatter stringFromNumber:model.total];
        
//        [cell.c_imageView sd_setImageWithURL:[NSURL URLWithString:model.productImage]];
        [cell.c_imageView sd_setImageWithURL:[NSURL URLWithString:model.image]];
        
//        cell.c_name.text = model.productName;
        cell.c_name.text = model.name;
        cell.c_name.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.c_name sizeToFit];
        
//        cell.singlePrice.text = model.displayPrice;
        cell.singlePrice.text  = model.singleDisplayPrice;
        [cell.quantity setTitle:model.quantity.stringValue forState:UIControlStateNormal];
        
        cell.quantityPrice.text = quantity_price_string;
//        cell.variant.text = model.variant;
        cell.variant.text = model.option;
    }
    
    
    return cell;
}



#pragma mark - Table view Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    return [self configureHeaderView:headerView forSection:section];
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIButton *placeOrderbutton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [placeOrderbutton setTitle:@"Checkout" forState:UIControlStateNormal];
    [placeOrderbutton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:16.0f]];
    [placeOrderbutton setBackgroundColor:[UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f]];
    
    if (self.lineItemsFetchedResultsController.fetchedObjects.count != 0) {
        [placeOrderbutton setEnabled:YES];
        [placeOrderbutton setBackgroundColor:[UIColor colorWithRed:102/255.0f green:169/255.0f blue:127/255.0f alpha:1.0f]];
        [placeOrderbutton addTarget:self action:@selector(checkoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        
        [placeOrderbutton setEnabled:NO];
        [placeOrderbutton setHidden:YES];
    }
    
    return placeOrderbutton;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    AddToCart *cart = self.cartFetchedResultsController.fetchedObjects[indexPath.row];
    
    [self.managedObjectContext deleteObject:cart];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [UIView animateWithDuration:1 animations:^{
        [self.tableView reloadData];
    }];
}


#pragma mark - <NSFetchedResultsControllerDelegate>

-(void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self tableView:self.tableView viewForHeaderInSection:0];
    [self.tableView endUpdates];
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                break;
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                break;
                
            case NSFetchedResultsChangeMove:
                break;
        }
}


-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
                
            case NSFetchedResultsChangeUpdate:
                break;
                
            case NSFetchedResultsChangeMove:
                break;
        }
}



#pragma mark - Fetched Results Controller

-(NSFetchedResultsController *)cartFetchedResultsController {
    if (_cartFetchedResultsController != nil) {
        return _cartFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AddToCart" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"addedDate"
                                        ascending:YES];
    
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

-(NSFetchedResultsController *)orderNumFetchedResultsController {
    if (_orderNumFetchedResultsController != nil) {
        return _orderNumFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    NSString *cacheName = @"cartOrderCache";
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.orderNumFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
    NSError *error;
    if(![self.orderNumFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",error);
    }
    
    return _orderNumFetchedResultsController;
}


-(void)fetchLineItems {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    NSString *cacheName = @"lineItemsCache";
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineItemID" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.lineItemsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
    NSError *error;
    if(![self.lineItemsFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",error);
    }
    
    
}


#pragma mark - UIActionSheet Methods

- (IBAction)quantityPressed:(UIButton *)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Select Quantity" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"1", @"2", @"3", @"4", @"5", @"6", nil];
    
    CartViewCell *cell = (CartViewCell *)[[sender superview]superview];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    self.selectIndexPath = indexpath;
    
    [actionSheet showInView:self.view];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld",(long)buttonIndex);
    
    
    if (buttonIndex == 6) {
        NSLog(@"Cancel");
        
    } else {
        NSInteger quantity = buttonIndex + 1;
        
        AddToCart *model = self.cartFetchedResultsController.fetchedObjects[self.selectIndexPath.row];
        CartViewCell *cell = (CartViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
        NSNumberFormatter *cartCurrencyFormatter = [[NSNumberFormatter alloc] init];
        [cartCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [cartCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
        
        
        NSInteger totalPrice = [self calculateTotalPrice:quantity andSinglePrice:model.productPrice.intValue];
        [cell.quantity setTitle:@(quantity).stringValue forState:UIControlStateNormal];
        
        NSString *total_price_string = [cartCurrencyFormatter stringFromNumber:[NSNumber numberWithInteger:totalPrice]];
        cell.quantityPrice.text = total_price_string;
        
        [self saveQuantity:quantity andTotalPrice:totalPrice];
        
        [self.tableView reloadData];
    }
    
}


#pragma mark - Helper Methods


-(UIView *)configureHeaderView:(UIView *)header forSection:(NSInteger)section {
    
    [self.lineItemsFetchedResultsController performFetch:nil];
    
    if (self.lineItemsFetchedResultsController.fetchedObjects.count == 0) {
        HeaderLabel *noItems = [[HeaderLabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        noItems.text = @"No Products in Cart";
        noItems.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        noItems.backgroundColor = [UIColor whiteColor];
        
        [header addSubview:noItems];
    } else {
        HeaderLabel *items = [[HeaderLabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 40)];
        items.text = [NSString stringWithFormat:@"Products: %lu",(unsigned long)self.lineItemsFetchedResultsController.fetchedObjects.count];
        items.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        items.backgroundColor = [UIColor whiteColor];
        
        
        HeaderLabel *totalAmount = [[HeaderLabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 , 0, self.view.frame.size.width/2, 40)];
        
        NSNumberFormatter *headerCurrencyFormatter = [[NSNumberFormatter alloc] init];
        [headerCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [headerCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
        NSString *total_price_string = [headerCurrencyFormatter stringFromNumber:[NSNumber numberWithInteger:[self totalAmount]]];
        
        totalAmount.text = [NSString stringWithFormat:@"%@",total_price_string];
        totalAmount.textAlignment = NSTextAlignmentRight;
        totalAmount.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        totalAmount.backgroundColor = [UIColor whiteColor];
        
        [header addSubview:items];
        [header addSubview:totalAmount];
    }
    
    return header;
}


-(void)checkoutButtonPressed:(UIButton *)sender {
    NetworkStatus netStatus = [self.appDelegate.googleReach currentReachabilityStatus];
    User *user = [User savedUser];
    
    
    if (user.access_token == nil) {
        LogSignViewController *logSignVC = (LogSignViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
        logSignVC.isPlacingOrder = YES;
        
        UINavigationController *logSignNav = [[UINavigationController alloc]initWithRootViewController:logSignVC];
        logSignNav.navigationBar.tintColor = self.tableView.tintColor;
        
        [self presentViewController:logSignNav animated:YES completion:nil];
        
    } else {
        
        if (netStatus != NotReachable) {
            [self sendCheckoutRequestToServer];
        }
        else {
            [self displayNoConnection];
        }
    }
}



-(void)saveQuantity:(NSInteger)quantity andTotalPrice:(NSInteger)totalPrice {
    AddToCart *model = self.cartFetchedResultsController.fetchedObjects[self.selectIndexPath.row];
    model.quantity = @(quantity);
    model.totalPrice = @(totalPrice);
    
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}


-(NSInteger)totalAmount {
    __block NSInteger priceInTotal = 0;
    
//    [self.cartFetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(AddToCart *model, NSUInteger idx, BOOL *stop) {
//        NSInteger quantity = model.quantity.integerValue;
//        CGFloat singlePrice = model.productPrice.floatValue;
//        
//        priceInTotal = priceInTotal + [self calculateTotalPrice:quantity andSinglePrice:singlePrice];
//    }];
    
    [self.lineItemsFetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(LineItems *model, NSUInteger idx, BOOL *stop) {
        NSInteger quantity = model.quantity.integerValue;
        CGFloat singlePrice = model.price.floatValue;
        
        priceInTotal = priceInTotal + [self calculateTotalPrice:quantity andSinglePrice:singlePrice];
    }];
    
    return priceInTotal;
}

-(CGFloat)calculateTotalPrice:(NSInteger)quantity andSinglePrice:(CGFloat)price {
    CGFloat total = quantity * price;
    
    return ceil(total);
}

-(void)updateBadgeValue {
    NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)self.lineItemsFetchedResultsController.fetchedObjects.count];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:count];
}




-(void)sendCheckoutRequestToServer {
    
    User *user = [User savedUser];
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    Order *orderModel = self.orderNumFetchedResultsController.fetchedObjects.lastObject;
    
    
    if (orderModel.number != nil) {
        
        
        NSString *url = [NSString stringWithFormat:@"http://%@%@/%@?token=%@", store.storeUrl, kCheckoutURL, orderModel.number, user.access_token];
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
                        
                        NSLog(@"Json Cart ===> %@",json);
                        NSLog(@"Checkout Initiated");
                        
                        // Proceed to payment page
                        [self proceedToPaymentPage:json];
                    }
                    
                });
            }
            else {
                [self displayConnectionFailed];
            }
            
            
        }];
        
        [task resume];
        
        UIWindow *window = [[UIApplication sharedApplication] delegate].window;
        self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        [self.hud setCenter:self.view.center];
        self.hud.dimBackground = YES;
        self.hud.color = self.view.tintColor;
    }
    else
        NSLog(@"No order & Cart is Empty");
    
}


-(void)displayNoConnection {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Connection" message:@"Their is no Internet Connection" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alert show];
}

-(void)displayConnectionFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    });
    
    
}


-(void)proceedToPaymentPage:(NSDictionary *)json {
    PaymentViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
    paymentVC.order_id               = [json valueForKey:@"number"];
    paymentVC.display_total          = [json valueForKey:@"display_total"];
    paymentVC.total                  = [json valueForKey:@"total"];
    paymentVC.payment_methods        = [json valueForKey:@"payment_methods"];
    [self.navigationController pushViewController:paymentVC animated:YES];
}



-(void)getOrderLineItemDetails {
    
    
    User *user = [User savedUser];
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    Order *orderModel = self.orderNumFetchedResultsController.fetchedObjects.lastObject;
    
    if (orderModel.number != nil && user.access_token != nil) {
        NSString *url = [NSString stringWithFormat:@"http://%@%@/%@?token=%@",store.storeUrl, kOrderDetailsURL, orderModel.number, user.access_token];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = @"GET";
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        self.task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
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
                        
                        [self removeAllLineItems];
                        
                        [self fetchLineItems];
                        // store line items data
                        
                        if (self.lineItemsFetchedResultsController.fetchedObjects.count == 0) {
                            
                            NSArray *line_items = [json objectForKey:@"line_items"];
                            
                            for (int i=0; i< line_items.count; i++) {
                                self.lineItemModel = [NSEntityDescription insertNewObjectForEntityForName:@"LineItems" inManagedObjectContext:self.managedObjectContext];
                                self.lineItemModel.lineItemID = [line_items[i] valueForKey:@"id"];
                                self.lineItemModel.quantity   = [line_items[i] valueForKey:@"quantity"];
                                self.lineItemModel.price      = [NSNumber numberWithFloat:[[line_items[i] valueForKey:@"price"] floatValue]];
                                self.lineItemModel.variantID  = [line_items[i] valueForKey:@"variant_id"];
                                self.lineItemModel.singleDisplayPrice   = [line_items[i] valueForKey:@"single_display_amount"];
                                self.lineItemModel.totalDisplayPrice    = [line_items[i] valueForKey:@"display_total"];
                                self.lineItemModel.total                = [NSNumber numberWithFloat:[[line_items[i] valueForKey:@"total"] floatValue]];
                                self.lineItemModel.name                 = [line_items[i] valueForKeyPath:@"variant.name"];
                                self.lineItemModel.option               = [line_items[i] valueForKeyPath:@"variant.options_text"];
                                self.lineItemModel.totalOnHand          = [line_items[i] valueForKeyPath:@"variant.total_on_hand"];
                                
                                NSArray *images                         = [line_items[i] valueForKeyPath:@"variant.images"];
                                if (images.count != 0) {
                                    self.lineItemModel.image            = [images[0] valueForKey:@"small_url"];
                                } else
                                    self.lineItemModel.image            = @"";
                                
                                [orderModel addCartLineItemsObject:self.lineItemModel];
                            }
                            
                            [self.managedObjectContext save:nil];
                            
                            [self.hud hide:YES];
                            
                            [self fetchLineItems];
                            
                            [self.tableView reloadData];
                            
                            
                        } else
                            NSLog(@"Line Items records are not empty");
                        
                        
                    }
                    
                });
            }
            else {
                [self displayConnectionFailed];
            }
            
            
        }];
        
        [self.task resume];
        
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Loading...";
        self.hud.detailsLabelText = @"Cart Details";
        self.hud.center = self.view.center;
        self.hud.dimBackground = YES;
        self.hud.color = self.view.tintColor;
        
    }
    
    
}














#pragma mark - Not needed

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


-(void)showAddressWithOrderID:(NSString *)order_id {
    NSLog(@"order_id %@",order_id);
    
    User *user = [User savedUser];
    AddressesViewController *addressVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesVC"];
    addressVC.addresses = user.ship_address;
    addressVC.order_id  = order_id;
    
    [self.navigationController pushViewController:addressVC animated:YES];
}


-(NSDictionary *)createOrdersDictionary:(NSArray *)array {
    NSDictionary *orders = @{
                             @"order": @{
                                     @"line_items": array
                                     }
                             };
    return orders;
}

-(void)showOrderReviewPage:(NSDictionary *)json {
    OrderReviewViewController *orderReviewVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderReviewVC"];
    orderReviewVC.line_items     = [json objectForKey:@"line_items"];
    orderReviewVC.purchase_total = [json valueForKey:@"display_item_total"];
    
    
    orderReviewVC.tax_total = [json valueForKey:@"display_tax_total"];
    
    
    
    orderReviewVC.complete_total = [json valueForKey:@"display_total"];
    orderReviewVC.order_id       = [json valueForKey:@"number"];
    
    [self.navigationController pushViewController:orderReviewVC animated:YES];
}


@end

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
#import "StoresViewController.h"
#import "Order.h"
#import "LineItems.h"

#define kCheckoutURL @"/api/checkouts"
#define kCurrentOrderDetailsURL @"/api/orders/current"
#define kDeleteLineItemURL @"/api/orders"
#define kUpdateLineItemURL @"/api/orders"

static NSString *cellIdentifier = @"cartCell";

@interface CartViewController ()<NSFetchedResultsControllerDelegate,UIActionSheetDelegate>

//@property (nonatomic, strong) NSFetchedResultsController *cartFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *orderNumFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *lineItemsFetchedResultsController;

@property (nonatomic, strong) NSURLSessionDataTask *task;

@property (nonatomic, strong) LineItems *lineItemModel;
@property (nonatomic, strong) Order *orderModel;

@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, strong) CartViewModel *viewModel;
@property (nonatomic, assign) BOOL isAlreadyLoggedIn;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong) AppDelegate *appDelegate;

@property (nonatomic, strong) UIView *dimmView;

@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = self.appDelegate.managedObjectContext;
    
//    [self.cartFetchedResultsController performFetch:nil];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    [self checkOrders];
    [self checkLineItems];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCheckoutRequestToServer) name:@"loggedInSendOrderNotification" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [self decorateNoCartDimmView];
    
    
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
    
    
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    
    if (self.dimmView) {
        
        NSLog(@"DimmView removeFromSuperview");
        
        
        [self.dimmView removeFromSuperview];
        self.dimmView = nil;
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    
    return self.lineItemsFetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
//    id<NSFetchedResultsSectionInfo> sectionInfo = [self.lineItemsFetchedResultsController sections][section];
//    NSLog(@"%lu",(unsigned long)[sectionInfo numberOfObjects]);
    [self updateBadgeValue];
    
//    return [sectionInfo numberOfObjects];
    
    return self.lineItemsFetchedResultsController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CartViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        LineItems *model = [self.lineItemsFetchedResultsController objectAtIndexPath:indexPath];
        
        NSNumberFormatter *cellCurrencyFormatter = [[NSNumberFormatter alloc] init];
        [cellCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [cellCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
        
        NSString *quantity_price_string = [cellCurrencyFormatter stringFromNumber:model.total];
        
        [cell.c_imageView sd_setImageWithURL:[NSURL URLWithString:model.image]];
        cell.c_name.text = model.name;
        cell.c_name.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.c_name sizeToFit];
        
        cell.singlePrice.text  = model.singleDisplayPrice;
        [cell.quantity setTitle:model.quantity.stringValue forState:UIControlStateNormal];
        
        cell.quantity.tag = indexPath.row;
        
        cell.quantityPrice.text = quantity_price_string;
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
    
    [self checkLineItems];
    
    LineItems *item = self.lineItemsFetchedResultsController.fetchedObjects[indexPath.row];
    
    
    
//    [UIView animateWithDuration:1.f animations:^{
//        [self.tableView reloadData];
//    }];
    
    [self deleteLineItem:item];
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




-(void)checkOrders {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
//    NSString *cacheName = @"cartOrderCache";
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.orderNumFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if(![self.orderNumFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",[error localizedDescription]);
    }
    
}


-(void)checkLineItems {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
//    NSString *cacheName = @"lineItemsCache";
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineItemID" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.lineItemsFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if(![self.lineItemsFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",[error localizedDescription]);
    }
    
    
}


#pragma mark - UIActionSheet Methods

- (IBAction)quantityPressed:(UIButton *)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"Select Quantity" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
    
    CartViewCell *cell = (CartViewCell *)[[sender superview]superview];
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    self.selectIndexPath = indexpath;
    
    
    LineItems *line_item = [self.lineItemsFetchedResultsController.fetchedObjects objectAtIndex:self.selectIndexPath.row];
    int availableQuantity;
    
    if (line_item.totalOnHand.intValue <= 10) {
        
        availableQuantity = line_item.totalOnHand.intValue;
        
    } else {
        NSLog(@"Restricting to 10 line items count");
        
        availableQuantity = 10;
    }
    for (int i=0; i< availableQuantity; i++) {
        NSString *value = [NSString stringWithFormat:@"%d", i + 1];
        
        [actionSheet addButtonWithTitle:value];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    LineItems *line_item = [self.lineItemsFetchedResultsController.fetchedObjects objectAtIndex:self.selectIndexPath.row];
//
//    NSArray *quantityArray = [self getQuantityArrayWithCount:line_item.totalOnHand];
    
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"Cancel Pressed");
    } else {
        
        NSInteger quantity = buttonIndex + 1;
        
//        AddToCart *model = self.cartFetchedResultsController.fetchedObjects[self.selectIndexPath.row];
//        CartViewCell *cell = (CartViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
//        NSNumberFormatter *cartCurrencyFormatter = [[NSNumberFormatter alloc] init];
//        [cartCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
//        [cartCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
//        
//        
//        NSInteger totalPrice = [self calculateTotalPrice:quantity andSinglePrice:model.productPrice.intValue];
//        [cell.quantity setTitle:@(quantity).stringValue forState:UIControlStateNormal];
//        
//        NSString *total_price_string = [cartCurrencyFormatter stringFromNumber:[NSNumber numberWithInteger:totalPrice]];
//        cell.quantityPrice.text = total_price_string;
//        
//        [self saveQuantity:quantity andTotalPrice:totalPrice];
        
        [self updateLineItem:line_item withQuantity:quantity];
    }
    
}



#pragma mark - Helper Methods


-(UIView *)configureHeaderView:(UIView *)header forSection:(NSInteger)section {
    
    [self checkLineItems];
    [self checkOrders];
    
    if (self.lineItemsFetchedResultsController.fetchedObjects.count == 0) {
//        HeaderLabel *noItems = [[HeaderLabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
//        noItems.text = @"No Products in Cart";
//        noItems.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
//        noItems.backgroundColor = [UIColor whiteColor];
//        
//        [header addSubview:noItems];
        
        [self decorateNoCartDimmView];
        
        
        
        
        
        
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
        [self showLoginPageAndIsPlacingOrder:YES];
        
    } else {
        
        if (netStatus != NotReachable) {
            [self sendCheckoutRequestToServer];
        }
        else {
            [self displayNoConnection];
        }
    }
}


-(NSArray *)getQuantityArrayWithCount:(NSNumber *)count {
    NSMutableArray *quantity = [NSMutableArray array];
    
    for (int i=0; i< count.intValue; i++) {
        NSString *value = [NSString stringWithFormat:@"%d", i + 1];
        
        [quantity addObject:value];
    }
    
    
    return quantity;
}


-(void)updateBadgeValue {
    [self checkLineItems];
    
    NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)self.lineItemsFetchedResultsController.fetchedObjects.count];
    
    if ([count isEqualToString:@"0"]) {
        [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:nil];
    } else
        [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:count];
    
}


-(NSInteger)totalAmount {
    __block NSInteger priceInTotal = 0;
    
    
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


-(void)removeAllLineItems {
    
    // Line Items
    NSFetchRequest *allLineItems = [[NSFetchRequest alloc] init];
    [allLineItems setEntity:[NSEntityDescription entityForName:@"LineItems" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *lineItems = [self.managedObjectContext executeFetchRequest:allLineItems error:&error];
    
    for (NSManagedObject *lineItem in lineItems) {
        [self.managedObjectContext deleteObject:lineItem];
    }
    
    
    // Order
    NSFetchRequest *orderFetchRequest = [[NSFetchRequest alloc]init];
    [orderFetchRequest setEntity:[NSEntityDescription entityForName:@"Order" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *orderError = nil;
    NSArray *orderArray = [self.managedObjectContext executeFetchRequest:orderFetchRequest error:&orderError];
    
    for (NSManagedObject *order in orderArray) {
        [self.managedObjectContext deleteObject:order];
    }
    
    NSError *saveError = nil;
    [self.managedObjectContext save:&saveError];
}


-(void)displayNoConnection {
    
    [self.hud hide:YES];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Connection" message:@"Their is no Internet Connection" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alert show];
}

-(void)displayConnectionFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.hud hide:YES];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    });
    
    
}




-(void)decorateNoCartDimmView {
    
    if (self.dimmView) {
        NSLog(@"1. Dimm Already exists");
        
        
    } else {
        self.dimmView = [[UIView alloc]initWithFrame:self.tableView.frame];
        self.dimmView.backgroundColor = [UIColor whiteColor];
        [self.navigationController.view insertSubview:self.dimmView belowSubview:self.navigationController.navigationBar];
    }
    
    
    
    if (self.lineItemsFetchedResultsController.fetchedObjects.count == 0) {
        
        
        if (self.dimmView.subviews.count > 1) {
            NSLog(@"3. Subviews already exists in dimm View %@", self.dimmView.subviews);
            
            
        } else {
            
            UIImageView *shoppingCartImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.dimmView.frame.size.width/2 - 50, self.dimmView.frame.size.height/3, 100, 100)];
            UIImage *cartImage                 = [UIImage imageNamed:@"ShoppingCart"];
            shoppingCartImageView.image        = cartImage;
            shoppingCartImageView.alpha        = 0.5f;
            [self.dimmView addSubview:shoppingCartImageView];
            
            UILabel *cartLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.dimmView.frame.size.width/2 - 150, shoppingCartImageView.frame.origin.y + shoppingCartImageView.frame.size.height + 30, 300, 30)];
            cartLabel.text     = @"Your Shopping Cart is Empty";
            cartLabel.textAlignment = NSTextAlignmentCenter;
            cartLabel.textColor     = [UIColor lightGrayColor];
            cartLabel.font          = [UIFont fontWithName:@"AvenirNext-Regular" size:17.f];
            [self.dimmView addSubview:cartLabel];
            
            UIButton *shoppingButton = [[UIButton alloc] initWithFrame:CGRectMake(self.dimmView.frame.size.width/2 - 100, cartLabel.frame.origin.y + cartLabel.frame.size.height + 50, 200, 30)];
            [shoppingButton setTitle:@"Let's go Shopping" forState:UIControlStateNormal];
            [shoppingButton setTitleColor:self.tableView.tintColor forState:UIControlStateNormal];
            [shoppingButton addTarget:self action:@selector(goToStoresPage:) forControlEvents:UIControlEventTouchUpInside];
            shoppingButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:19.f];
            [self.dimmView addSubview:shoppingButton];
        }
        
    }
    
}



#pragma mark - Network

-(void)sendCheckoutRequestToServer {
    
    User *user = [User savedUser];
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    [self checkOrders];
    
    self.orderModel = self.orderNumFetchedResultsController.fetchedObjects.lastObject;
    
    
    if (self.orderModel.number != nil) {
        
        
        NSString *url = [NSString stringWithFormat:@"http://%@%@/%@/advance?token=%@", store.storeUrl, kCheckoutURL, self.orderModel.number, user.access_token];
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
        self.hud.labelText = @"Checking out...";
        self.hud.color = self.view.tintColor;
    }
    else
        NSLog(@"No order & Cart is Empty");
    
}




-(void)getOrderLineItemDetails {
    
    
    User *user = [User savedUser];
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    [self checkOrders];
    
    if (user.access_token != nil) {
        NSString *url = [NSString stringWithFormat:@"http://%@%@?token=%@",store.storeUrl, kCurrentOrderDetailsURL, user.access_token];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = @"GET";
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        self.task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSLog(@"RESPONSE is %@", response);
            
            NSLog(@"Error is %@", [error localizedDescription]);
            
            if (data != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSError *jsonError;
                    
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                    [self.hud hide:YES];
                    
                    
                    NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                    NSLog(@"Response %ld", (long)[url_response statusCode]);
                    
                    
                    // If new user logins then -
                    if (url_response.statusCode == 204) {
                        
                        if (!self.dimmView) {
                            [self decorateNoCartDimmView];
                        }
                        
                        
                    } else {
                        
                        // if existing user logins then -
                        
                        if (jsonError) {
                            NSLog(@"Error %@",[jsonError localizedDescription]);
                        } else {
                            
                            
                            if (self.orderNumFetchedResultsController.fetchedObjects.count != 0) {
                                [self removeAllLineItems];
                            }
                            
                            [self checkOrders];
                            [self checkLineItems];
                            
                            
                            //  SAVE ORDER
                            
                            if (self.orderNumFetchedResultsController.fetchedObjects.count == 0) {
                                
                                self.orderModel = [NSEntityDescription insertNewObjectForEntityForName:@"Order" inManagedObjectContext:self.managedObjectContext];
                                self.orderModel.number = [json valueForKey:@"number"];
                                self.orderModel.total  = [json valueForKey:@"display_total"];
                                self.orderModel.store  = [json valueForKeyPath:@"store.name"];
                                
                                [self.managedObjectContext save:nil];
                                
                                NSArray *line_items = [json objectForKey:@"line_items"];
                                
                                // IF LINEITEMS ARE EMPTY THEN SHOW CART MESSAGE
                                
                                if (line_items.count == 0) {
                                    
                                    if (!self.dimmView) {
                                        [self decorateNoCartDimmView];
                                    }
                                    
                                    
                                    
                                } else {
                                    [self.dimmView removeFromSuperview];
                                    self.dimmView = nil;
                                    
                                    NSLog(@"GetlineItems DimmView removeFromSuperview");
                                    
                                    // SAVE LINEITEMS
                                    
                                    if (self.lineItemsFetchedResultsController.fetchedObjects.count == 0) {
                                        
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
                                            
                                            [self.orderModel addCartLineItemsObject:self.lineItemModel];
                                        }
                                        
                                        [self.managedObjectContext save:nil];
                                        [self.hud hide:YES];
                                        
                                        
                                        
                                    } else
                                        NSLog(@"Line Item records are not empty");
                                }
                                
                            } else
                                NSLog(@"Order records are not empty");
                            
                        }
                        
                    }
                    
                    [self checkLineItems];
                    [self.tableView reloadData];
                    
                });
            }
            else {
                [self displayConnectionFailed];
            }
            
        }];
        
        [self.task resume];
        
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.dimmView animated:YES];
        self.hud.labelText = @"Loading...";
        self.hud.detailsLabelText = @"Cart Details";
        self.hud.center = self.view.center;
        self.hud.dimBackground = YES;
        self.hud.color = self.view.tintColor;
        
    } else {
        [self showLoginPageAndIsPlacingOrder:NO];
    }
    
    
}



-(void)deleteLineItem:(LineItems *)item {
    
    User *user = [User savedUser];
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    [self checkOrders];
    self.orderModel = self.orderNumFetchedResultsController.fetchedObjects.lastObject;
    
    if (user.access_token != nil) {
        NSString *url = [NSString stringWithFormat:@"http://%@%@/%@/line_items/%d?token=%@",store.storeUrl, kDeleteLineItemURL, self.orderModel.number, item.lineItemID.intValue, user.access_token];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = @"DELETE";
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        self.task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (data != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@",response);
                    
                        
                    NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                    NSLog(@"Response %ld", (long)[url_response statusCode]);
                    
                    if (url_response.statusCode == 204) {
                        [self.hud hide:YES];
                        
                        [self.managedObjectContext deleteObject:item];
                        
                        NSError *error = nil;
                        if (![self.managedObjectContext save:&error]) {
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            abort();
                        }
                        [self checkLineItems];
                        
                        [self.tableView reloadData];
                        
                    } else {
                        [self.hud hide:YES];
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not delete Item. Please Try again..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        
                        [self.tableView reloadData];
                    }
                });
            }
            else {
                [self displayConnectionFailed];
            }
            
        }];
        
        [self.task resume];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Removing...";
        self.hud.detailsLabelText = item.name;
        self.hud.center = self.view.center;
        self.hud.dimBackground = YES;
        self.hud.color = self.view.tintColor;
        
    } else {
        [self showLoginPageAndIsPlacingOrder:NO];
    }
}



-(void)updateLineItem:(LineItems *)line_item withQuantity:(NSInteger)quantity {
    
    User *user = [User savedUser];
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    [self checkOrders];
    
    self.orderModel = self.orderNumFetchedResultsController.fetchedObjects.lastObject;
    
    if (user.access_token != nil) {
        
        NSString *parameter = [NSString stringWithFormat:@"line_item[quantity]=%ld", (long)quantity];
        
        NSLog(@"parameter %@", parameter);
        
        NSString *url = [NSString stringWithFormat:@"http://%@%@/%@/line_items/%d?token=%@",store.storeUrl, kUpdateLineItemURL, self.orderModel.number, line_item.lineItemID.intValue, user.access_token];
        
        NSLog(@"URL is %@",url);
            
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = @"PUT";
        request.HTTPBody   = [parameter dataUsingEncoding:NSUTF8StringEncoding];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        self.task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (data != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@",response);
                    NSError *jsonError;
                    
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                    
                    if (jsonError) {
                        NSLog(@"Update Line Items Error %@",[jsonError localizedDescription]);
                    } else {
                        
                        NSLog(@"Update Line Items Json ===> %@",json);
                        
                        NSNumber *variantID = [json valueForKey:@"variant_id"];
                        NSNumber *lineItemID = [json valueForKey:@"id"];
                        
                        if ([line_item.variantID isEqual:variantID] && [line_item.lineItemID isEqual:lineItemID]) {
                            line_item.quantity = [json valueForKey:@"quantity"];
                            line_item.price    = [NSNumber numberWithFloat:[[json valueForKey:@"price"] floatValue]];
                            line_item.singleDisplayPrice = [json valueForKey:@"single_display_amount"];
                            line_item.totalDisplayPrice  = [json valueForKey:@"display_amount"];
                            line_item.total    = [NSNumber numberWithFloat:[[json valueForKey:@"total"] floatValue]];
                            
                            NSError *error = nil;
                            
                            if (![self.managedObjectContext save:&error]) {
                                NSLog(@"Update lineItems: Managed object  error %@, %@", error, [error userInfo]);
                            }
                            
                            [self.hud hide:YES];
                            
                            [self.tableView reloadData];
                        }
                        
                    }
                    
                    
                });
            }
            else {
                [self displayConnectionFailed];
            }
            
        }];
        
        [self.task resume];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.labelText = @"Updating...";
        self.hud.center = self.view.center;
        self.hud.dimBackground = YES;
        self.hud.color = self.view.tintColor;
        
    } else {
        [self showLoginPageAndIsPlacingOrder:NO];
    }
    
}



#pragma mark - Navigation

-(void)proceedToPaymentPage:(NSDictionary *)json {
    PaymentViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
    paymentVC.order_id               = [json valueForKey:@"number"];
    paymentVC.display_total          = [json valueForKey:@"display_total"];
    paymentVC.total                  = [json valueForKey:@"total"];
    paymentVC.payment_methods        = [json valueForKey:@"payment_methods"];
    paymentVC.title                  = [[json valueForKey:@"state"] capitalizedString];
    paymentVC.store                  = [[json valueForKeyPath:@"store.name"] capitalizedString];
    
    [self.navigationController pushViewController:paymentVC animated:YES];
}



-(void)showLoginPageAndIsPlacingOrder:(BOOL)isPlacing {
    
    LogSignViewController *logSignVC = (LogSignViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
    logSignVC.isPlacingOrder = isPlacing;
    
    UINavigationController *logSignNav = [[UINavigationController alloc]initWithRootViewController:logSignVC];
    logSignNav.navigationBar.tintColor = self.tableView.tintColor;
    
    [self presentViewController:logSignNav animated:YES completion:nil];
}



-(void)goToStoresPage:(UIButton *)sender {
    
    
    StoresViewController *storesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"storesViewController"];
    storesVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:storesVC animated:YES];
    
}






















































#pragma mark -
#pragma mark - Not Needed



//-(void)saveQuantity:(NSInteger)quantity andTotalPrice:(NSInteger)totalPrice {
//    AddToCart *model = self.cartFetchedResultsController.fetchedObjects[self.selectIndexPath.row];
//    model.quantity = @(quantity);
//    model.totalPrice = @(totalPrice);
//
//
//    NSError *error = nil;
//    if (![self.managedObjectContext save:&error]) {
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}




//
//-(NSFetchedResultsController *)cartFetchedResultsController {
//    if (_cartFetchedResultsController != nil) {
//        return _cartFetchedResultsController;
//    }
//
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AddToCart" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
//                                        initWithKey:@"addedDate"
//                                        ascending:YES];
//
//    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
//    [fetchRequest setSortDescriptors:sortDescriptors];
//
//    _cartFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    _cartFetchedResultsController.delegate = self;
//
//    NSError *error = nil;
//    if (![self.cartFetchedResultsController performFetch:&error]) {
//        NSLog(@"Core data error %@, %@", error, [error userInfo]);
//        abort();
//    }
//
//    return _cartFetchedResultsController;
//}


//-(NSArray *)getCartProducts {
//
//    NSMutableArray *jsonarray = [[NSMutableArray alloc] init];
//
//    [self.cartFetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(AddToCart *model, NSUInteger idx, BOOL *stop) {
//        NSDictionary *dict  = @{
//                                @"variant_id"  : model.productID,
//                                @"quantity"    : model.quantity
//                                };
//
//        [jsonarray addObject:dict];
//
//    }];
//
//    return jsonarray;
//
//}


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

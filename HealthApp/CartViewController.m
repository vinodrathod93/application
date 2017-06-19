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
#import "AddShippingDetailsViewController.h"
#import "User.h"
#import "StoreRealm.h"
#import "LogSignViewController.h"
#import "AddressesViewController.h"
#import "OrderReviewViewController.h"
//#import "PaymentViewController.h"
#import "StoresViewController.h"
#import "Order.h"
#import "LineItems.h"
#import "NoConnectionView.h"
#import "EditAddressViewController.h"
#import "OrderCompleteViewController.h"
#import "AftrCheckoutVC.h"


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
@property (nonatomic, assign) NSDictionary *ship_address;

@property (nonatomic, strong) NSIndexPath *selectIndexPath;
@property (nonatomic, strong) CartViewModel *viewModel;
@property (nonatomic, assign) BOOL isAlreadyLoggedIn;
@property (nonatomic, strong) NeediatorHUD *hud;
@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong) UIView *dimmView;

@property (nonatomic, strong) NoConnectionView *connectionErrorView;

@property (nonatomic, strong) NSArray *cartOrdersArray;

@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"Cart viewDidLoad");
    
    self.appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = self.appDelegate.managedObjectContext;
    
    //    [self.cartFetchedResultsController performFetch:nil];
        [self updateBadgeValue];
    self.title = @"CART";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self checkOrders];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCheckoutRequestToServer) name:@"loggedInSendOrderNotification" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"Cart viewWillAppear");
    
    
    
    if (self.task == nil)
    {
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



-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Cart Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}




-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    NSLog(@"Cart viewWillDisappear");
    
    [self removeNoCartDimmView];
    [self removeConnectionErrorView];
    [self hideHUD];
    
    //    if (self.dimmView) {
    //
    //        NSLog(@"DimmView removeFromSuperview");
    //
    //
    //        [self.dimmView removeFromSuperview];
    //        self.dimmView = nil;
    //    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}







#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    [self updateBadgeValue];
    
    return self.orderNumFetchedResultsController.fetchedObjects.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    //    id<NSFetchedResultsSectionInfo> sectionInfo = [self.lineItemsFetchedResultsController sections][section];
    //    NSLog(@"%lu",(unsigned long)[sectionInfo numberOfObjects]);
    
    
    //    if (self.lineItemsFetchedResultsController.fetchedObjects.count == 0) {
    //        [self decorateNoCartDimmView];
    //    }
    Order *model = self.orderNumFetchedResultsController.fetchedObjects[section];
    
    
    return model.cartLineItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CartViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        
    }
    
    
    
    Order *orderModel = [self.orderNumFetchedResultsController.fetchedObjects objectAtIndex:indexPath.section];
    
    NSArray *items    = [orderModel.cartLineItems allObjects];
    LineItems *model = items[indexPath.row];
    
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
    
    cell.quantityPrice.text = [NSString stringWithFormat:@" =   %@", quantity_price_string];
    //sb   cell.variant.text       = model.option;
    cell.metaLabel.text = model.meta;
    
    //sb    NSLog(@"%@", model.option);
    
    
    
    return cell;
}



#pragma mark - Table view Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 160.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    headerView.backgroundColor = [UIColor clearColor];
    
    return [self configureHeaderView:headerView forSection:section];
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
    
    [self checkOrders];
    Order *order = self.orderNumFetchedResultsController.fetchedObjects[section];
    
    NSNumberFormatter *headerCurrencyFormatter = [[NSNumberFormatter alloc] init];
    [headerCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [headerCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
    
    NSInteger itemAmount = order.total.intValue - order.shipping_charge.intValue;
    
    if (itemAmount < 0) {
        itemAmount = 0;
    }
    
    NSString *total_price_string = [headerCurrencyFormatter stringFromNumber:[NSNumber numberWithInteger:order.total.integerValue]];
    
    HeaderLabel *itemLabel = [[HeaderLabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 25)];
    itemLabel.text = @"Sub Total";
    itemLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
    itemLabel.textColor = [UIColor darkGrayColor];
    itemLabel.backgroundColor = [UIColor whiteColor];
    
    
    HeaderLabel *itemTotal = [[HeaderLabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 , 0, self.view.frame.size.width/2, 25)];
    itemTotal.text = [headerCurrencyFormatter stringFromNumber:@(itemAmount)];
    itemTotal.textAlignment = NSTextAlignmentRight;
    itemTotal.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
    itemTotal.textColor = [UIColor darkGrayColor];
    itemTotal.backgroundColor = [UIColor whiteColor];
    
    
//    HeaderLabel *shippingLabel = [[HeaderLabel alloc]initWithFrame:CGRectMake(0, 25, self.view.frame.size.width/2, 25)];
//    shippingLabel.text = @"Shipping";
//    shippingLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
//    shippingLabel.textColor = [UIColor darkGrayColor];
//    shippingLabel.backgroundColor = [UIColor whiteColor];
    
    
    HeaderLabel *shippingLabel = [[HeaderLabel alloc]initWithFrame:CGRectMake(0, 25, self.view.frame.size.width/2, 25)];
    shippingLabel.text = @"Delivery Charges";
    shippingLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
    shippingLabel.textColor = [UIColor darkGrayColor];
    shippingLabel.backgroundColor = [UIColor whiteColor];

    
    
    HeaderLabel *shippingValue = [[HeaderLabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 , 25, self.view.frame.size.width/2, 25)];
    shippingValue.text = [headerCurrencyFormatter stringFromNumber:order.shipping_charge];
    shippingValue.textAlignment = NSTextAlignmentRight;
    shippingValue.textColor = [UIColor darkGrayColor];
    shippingValue.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
    shippingValue.backgroundColor = [UIColor whiteColor];
    
    
    HeaderLabel *freeDeliveryMesage = [[HeaderLabel alloc]initWithFrame:CGRectMake(0 , 50, self.view.frame.size.width, 25)];
    NSString *minOrder = [headerCurrencyFormatter stringFromNumber:order.min_delivery_charge];
    
    freeDeliveryMesage.text = [NSString stringWithFormat:@"( FREE Delivery on orders above %@ )", minOrder];
    freeDeliveryMesage.textAlignment = NSTextAlignmentLeft;
    freeDeliveryMesage.textColor = [UIColor darkGrayColor];
    freeDeliveryMesage.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f];
    freeDeliveryMesage.backgroundColor = [UIColor whiteColor];
    
    
    
    HeaderLabel *totalLabel = [[HeaderLabel alloc]initWithFrame:CGRectMake(0, 75, self.view.frame.size.width/2, 25)];
    totalLabel.text = @"Total";
    totalLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15.0f];
    totalLabel.backgroundColor = [UIColor whiteColor];
    
    
    HeaderLabel *totalAmount = [[HeaderLabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 , 75, self.view.frame.size.width/2, 25)];
    totalAmount.text = total_price_string;
    totalAmount.textAlignment = NSTextAlignmentRight;
    totalAmount.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15.0f];
    totalAmount.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *placeOrderbutton = [[UIButton alloc]initWithFrame:CGRectMake(15, 110, self.view.frame.size.width - (2*15), 40)];
    [placeOrderbutton setTitle:@"CHECKOUT" forState:UIControlStateNormal];
    [placeOrderbutton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:16.0f]];
    [placeOrderbutton setBackgroundColor:[UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f]];
    placeOrderbutton.tag = section;
    placeOrderbutton.layer.cornerRadius = 5.f;
    placeOrderbutton.layer.masksToBounds = YES;
    
    if (self.orderNumFetchedResultsController.fetchedObjects.count != 0) {
        [placeOrderbutton setEnabled:YES];
        [placeOrderbutton setBackgroundColor:[UIColor colorWithRed:102/255.0f green:169/255.0f blue:127/255.0f alpha:1.0f]];
        [placeOrderbutton addTarget:self action:@selector(checkoutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        
        [placeOrderbutton setEnabled:NO];
        [placeOrderbutton setHidden:YES];
    }
    
    [footerView addSubview:totalLabel];
    [footerView addSubview:totalAmount];
    [footerView addSubview:shippingLabel];
    [footerView addSubview:shippingValue];
    [footerView addSubview:freeDeliveryMesage];
    [footerView addSubview:itemLabel];
    [footerView addSubview:itemTotal];
    [footerView addSubview:placeOrderbutton];
    
    return footerView;
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
    
    [self checkOrders];
    
    //    LineItems *item = self.lineItemsFetchedResultsController.fetchedObjects[indexPath.row];
    
    Order *orderModel = [self.orderNumFetchedResultsController.fetchedObjects objectAtIndex:indexPath.section];
    
    [self deleteOrderLineItem:orderModel atIndexPath:indexPath];
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
    for (int i=0; i< availableQuantity; i++)
    {
        NSString *value = [NSString stringWithFormat:@"%d", i + 1];
        
        [actionSheet addButtonWithTitle:value];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    //    LineItems *line_item = [self.lineItemsFetchedResultsController.fetchedObjects objectAtIndex:self.selectIndexPath.row];
    
    
    Order *orderModel       = [self.orderNumFetchedResultsController.fetchedObjects objectAtIndex:self.selectIndexPath.section];
    
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
        
        [self updateOrderLineItem:orderModel withQuantity:quantity];
    }
    
}


#pragma mark - UIButton Action

-(void)checkoutButtonPressed:(UIButton *)sender {
 
    Order *order = self.orderNumFetchedResultsController.fetchedObjects[sender.tag];

    NSString *lineitemsCount=[NSString stringWithFormat:@"%lu",order.cartLineItems.count];
    NSString *abc=order.store_id;
    
    NSLog(@" Store Name Is %@  Order Total Is %@  LineItemsCount Is %@",order.store,order.total,lineitemsCount);
    [NeediatorUtitity save:abc  forKey:CheckOutStoreId];
    NSLog(@" Orders Are %@",[NeediatorUtitity savedDataForKey:CheckOutStoreId]);
    
    AftrCheckoutVC *ACVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AftrCheckoutVC"];
    
    ACVC.PayAmount=order.total;
    ACVC.Storename=order.store;
    ACVC.noofItems=lineitemsCount;
    
    [self.navigationController pushViewController:ACVC animated:YES];
    
    
    //    NetworkStatus netStatus = [self.appDelegate.googleReach currentReachabilityStatus];
    //    User *user = [User savedUser];
    //    [self checkOrders];
    
    //    if (user.userID == nil) {
    //        [self showLoginPageAndIsPlacingOrder:YES];
    //
    //    } else {
    //
    //        if (netStatus != NotReachable) {
    //
    //            [self sendCheckoutOrder:order];
    //        }
    //        else {
    //            [self displayNoConnection];
    //        }
    //    }
    //    User *saved_user = [User savedUser];
    //    NSLog(@"Submit Action Clicked......");
    //    NSString *parameterString = [NSString stringWithFormat:@"user_id=%@&payment_id=%@&address_id=%@&store_id=%@&Section_id=%@&delivery_type=%@&preffered_time=%@",@"8750",@"1",@"149",@"2",@"1",@"1",@"2"];
    //     NSString *url = [NSString stringWithFormat:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/addOrder"];
    //    NSLog(@"URL is --> %@", url);
    //    NSURLSession *session = [NSURLSession sharedSession];
    //NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.199/NeediatorWebservice/NeediatorWS.asmx/addOrder"]];
    //    request.HTTPMethod = @"POST";
    //    request.HTTPBody   = [NSData dataWithBytes:[parameterString UTF8String] length:[parameterString length]];
    //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    //    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    //        NSLog(@"%@",response);
    //        if (error) {
    //            NSLog(@"%@",error.localizedDescription);
    //        }
    //        else
    //        {
    //            NSError *jsonError;
    //            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                 OrderCompleteViewController *orderCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
    //                orderCompleteVC.order_id    = json[@"orderno"];
    //                orderCompleteVC.message     = @"Your order Request  has been successfully Submitted";
    //                //                    orderCompleteVC.additonalInfo = [NSString stringWithFormat:@"Payment Type is %@\n Delivery Date is %@", order[@"PaymentType"], order[@"preferred_time"]];
    //                [self.navigationController pushViewController:orderCompleteVC animated:YES];
    //                NSLog(@"%@",json);
    //            });
    //        }
    //     }];
    //    [task resume];
}


#pragma mark - Helper Methods


-(UIView *)configureHeaderView:(UIView *)header forSection:(NSInteger)section {
    
    [self checkLineItems];
    [self checkOrders];
    
    if (self.orderNumFetchedResultsController.fetchedObjects.count == 0) {
        //        HeaderLabel *noItems = [[HeaderLabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        //        noItems.text = @"No Products in Cart";
        //        noItems.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        //        noItems.backgroundColor = [UIColor whiteColor];
        //
        //        [header addSubview:noItems];
        
        
        /*
         [self decorateNoCartDimmView];
         
         
         */
        
        
    } else {
        
        Order *order = self.orderNumFetchedResultsController.fetchedObjects[section];
        
        NSNumberFormatter *headerCurrencyFormatter = [[NSNumberFormatter alloc] init];
        [headerCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [headerCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
        
        
        
        HeaderLabel *storeName = [[HeaderLabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        storeName.text          = order.store.uppercaseString;
        storeName.font = [UIFont fontWithName:@"AvenirNext-DemiBold" size:15.0f];
        storeName.backgroundColor = [UIColor clearColor];
        storeName.textColor = [UIColor lightGrayColor];
        
        
        
        [header addSubview:storeName];
    }
    
    return header;
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
    
    
    //    [self.orderNumFetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(Order  *_Nonnull order, NSUInteger idx, BOOL * _Nonnull stop) {
    //        countItems = countItems + order.cartLineItems.count;
    //    }];
    
    
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




#pragma mark - UIAlertView & HUD


-(void)displayNoConnection {
    
    [self hideHUD];
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Connection" message:@"Their is no Internet Connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

-(void)displayConnectionFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self hideHUD];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    });
    
    
}






//-(void)showHUD:(NSString *)text andDetailText:(NSString *)detail {
//
//    self.loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), self.view.frame.size.height)];
//    self.loadingView.backgroundColor = [UIColor whiteColor];
////    [self.view addSubview:self.loadingView];
//    [self.navigationController.view insertSubview:self.loadingView belowSubview:self.navigationController.navigationBar];
//
////    [self.view insertSubview:self.loadingView aboveSubview:self.tableView];
//
//    self.hud = [MBProgressHUD showHUDAddedTo:self.loadingView animated:YES];
//    self.hud.color = [UIColor blackColor];
//    self.hud.labelText = text;
//    self.hud.detailsLabelText = detail;
//    self.hud.center = self.loadingView.center;
//    self.hud.dimBackground = YES;
//}
//
//-(void)hideHUD {
//
//    [self.hud hide:YES];
//
//    [self.loadingView removeFromSuperview];
//}



-(void)showHUD {
    self.hud = [[NeediatorHUD alloc] initWithFrame:self.tableView.frame];
    self.hud.overlayColor = [NeediatorUtitity blurredDefaultColor];
    [self.hud fadeInAnimated:YES];
    self.hud.hudCenter = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) / 2);
    [self.navigationController.view insertSubview:self.hud belowSubview:self.navigationController.navigationBar];
    
    
}

-(void)hideHUD {
    [self.hud fadeOutAnimated:YES];
    [self.hud removeFromSuperview];
    
}





#pragma mark - Network

-(void)sendCheckoutOrder:(Order *)orderModel {
    
    //    RLMRealm *realm = [RLMRealm defaultRealm];
    //    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    
    
    
    if (orderModel.number != nil) {
        
        //        if (_ship_address != nil)
        //            [self proceedToPaymentPage:self.orderModel];
        //        else
        //            [self proceedToNewAddressPage];
        
        //    [self proceedToPaymentPage:orderModel];
        
    }
    else
        NSLog(@"No order & Cart is Empty");
    
}




-(void)getOrderLineItemDetails {
    
    // Remove Error view
    [self removeConnectionErrorView];
    
    // Remove Empty Cart View
    //    [self removeEmptyCartView];
    [self removeNoCartDimmView];
    
    User *user = [User savedUser];
    //    RLMRealm *realm = [RLMRealm defaultRealm];
    //    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    [self checkOrders];
    
    if (user.userID != nil) {
        
        NSString *url = [NSString stringWithFormat:@"http://neediator.net/NeediatorWebservice/neediatorWs.asmx/viewCartNew?userid=%@", user.userID];
        
        
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
                    
                    
                    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"STring is %@",string);
                    
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                    NSLog(@"JSON %@", json);
                    [self hideHUD];
                    
                    
                    NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                    NSLog(@"Response %ld", (long)[url_response statusCode]);
                    
                    
                    // If new user logins then -
                    if (url_response.statusCode == 204) {
                        
                        
                        [self decorateNoCartDimmView];
                        
                        
                        
                    } else {
                        
                        // if existing user logins then -
                        
                        if (jsonError) {
                            NSLog(@"Error %@",[jsonError localizedDescription]);
                        } else {
                            
                            
                            
                            if (![[json objectForKey:@"stores"] isKindOfClass:[NSArray class]]) {
                                
                                [self decorateNoCartDimmView];
                                return;
                            }
                            
                            
                            
                            
                            if (self.orderNumFetchedResultsController.fetchedObjects.count != 0) {
                                [self removeAllLineItems];
                            }
                            
                            if (self.lineItemsFetchedResultsController.fetchedObjects.count != 0) {
                                [self removeAllLineItems];
                            }
                            
                            [self checkOrders];
                            [self checkLineItems];
                            
                            
                            //  SAVE ORDER
                            
                            if (self.orderNumFetchedResultsController.fetchedObjects.count == 0) {
                                
                                
                                NSArray *orders = [json objectForKey:@"stores"];
                                
                                
                                if (orders.count == 0) {
                                    [self decorateNoCartDimmView];
                                    
                                    return;
                                }
                                
                                for (int i=0; i<orders.count; i++) {
                                    
                                    NSDictionary *orderJSON = orders[i];
                                    
                                    self.orderModel = [NSEntityDescription insertNewObjectForEntityForName:@"Order" inManagedObjectContext:self.managedObjectContext];
                                    self.orderModel.number              = @(i).stringValue;
                                    self.orderModel.total               = [[orderJSON valueForKey:@"storeamount"] stringValue];
                                    self.orderModel.store               = [orderJSON valueForKey:@"StoreName"];
                                    self.orderModel.shipping_charge     = [orderJSON valueForKey:@"deliverycharges"];
                                    self.orderModel.delivery_time       = [orderJSON valueForKey:@"AvgDeliveryTime"];
                                    self.orderModel.min_delivery_charge = [orderJSON valueForKey:@"MinDeliveryAmount"];
                                    
                                    [self.managedObjectContext save:nil];
                                    
                                    
                                    
                                    if ([[orderJSON objectForKey:@"cart"] isKindOfClass:[NSString class]]) {
                                        [self decorateNoCartDimmView];
                                    }
                                    else {
                                        
                                        NSArray *line_items = [orderJSON objectForKey:@"cart"];
                                        
                                        
                                        if (line_items.count == 0) {
                                            
                                            [self decorateNoCartDimmView];
                                            
                                            
                                            
                                        } else {
                                            
                                            
                                            [self removeNoCartDimmView];
                                            
                                            NSLog(@"GetlineItems DimmView removeFromSuperview");
                                            
                                            // SAVE LINEITEMS
                                            
                                            if (self.lineItemsFetchedResultsController.fetchedObjects.count == 0) {
                                                
                                                for (int i=0; i< line_items.count; i++)
                                                {
                                                    self.lineItemModel = [NSEntityDescription insertNewObjectForEntityForName:@"LineItems" inManagedObjectContext:self.managedObjectContext];
                                                    self.lineItemModel.lineItemID = [line_items[i] valueForKey:@"id"];
                                                    self.lineItemModel.quantity   = [line_items[i] valueForKey:@"qty"];
                                                    self.lineItemModel.price      = [NSNumber numberWithFloat:[[line_items[i] valueForKey:@"price"] floatValue]];
                                                    self.lineItemModel.variantID  = [line_items[i] valueForKey:@"productid"];
                                                    
                                                    
                                                    NSNumberFormatter *headerCurrencyFormatter = [[NSNumberFormatter alloc] init];
                                                    [headerCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                                                    [headerCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
                                                    //
                                                    NSString *display_price_string = [headerCurrencyFormatter stringFromNumber:@(self.lineItemModel.price.floatValue)];
                                                    NSString *display_total_string = [headerCurrencyFormatter stringFromNumber:@([[line_items[i] valueForKey:@"total"] floatValue])];
                                                    //
                                                    self.lineItemModel.singleDisplayPrice   = display_price_string;
                                                    self.lineItemModel.totalDisplayPrice    = display_total_string;
                                                    self.lineItemModel.total                = [NSNumber numberWithFloat:[[line_items[i] valueForKey:@"total"] floatValue]];
                                                    self.lineItemModel.name                 = [[line_items[i] valueForKey:@"productname"] capitalizedString];
                                                    self.lineItemModel.meta               = [[line_items[i] valueForKey:@"brandname"] capitalizedString];
                                                    //sb    self.lineItemModel.option                 = [line_items[i] valueForKey:@"uom"];
                                                    self.lineItemModel.totalOnHand          = [line_items[i] valueForKey:@"total_in_hand"];
                                                    
                                                    
                                                    // NSArray *images = [line_items[i] valueForKeyPath:@"variant.images"];
                                                    if ([line_items[i] valueForKey:@"imageurl"] != nil) {
                                                        self.lineItemModel.image            = [line_items[i] valueForKey:@"imageurl"];
                                                    } else
                                                        self.lineItemModel.image            = @"";
                                                    
                                                    [self.orderModel addCartLineItemsObject:self.lineItemModel];
                                                }
                                                
                                                self.orderModel.cat_id              = [line_items[0] valueForKey:@"catid"];
                                                self.orderModel.store_id           = [[line_items[0] valueForKey:@"storeid"] stringValue];
                                                
                                                [self.managedObjectContext save:nil];
                                                [self hideHUD];
                                                
                                                
                                                
                                            } else
                                                NSLog(@"Line Item records are not empty");
                                        }
                                    }
                                    
                                }
                                
                                
                                /* To check whether the shipping_address already exists or not */
                                //                                _ship_address       = [json objectForKey:@"ship_address"];
                                
                                
                                // IF LINEITEMS ARE EMPTY THEN SHOW CART MESSAGE
                                
                                
                                
                            } else
                                NSLog(@"Order records are not empty");
                            
                        }
                        
                    }
                    
                    [self checkOrders];
                    
                    
                    //                    [self removeNoCartDimmView];
                    [self.tableView reloadData];
                    
                    
                    
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self hideHUD];
                    [self showConnectionErrorView:error];
                    
                });
                
                
                
            }
            
        }];
        
        [self.task resume];
        
        //        [self showHUD:@"Loading..." andDetailText:@"Cart Details"];
        [self showHUD];
        
    } else {
        [self showLoginPageAndIsPlacingOrder:NO];
    }
    
    
}



-(void)deleteOrderLineItem:(Order *)order atIndexPath:(NSIndexPath *)indexPath {
    
    User *user = [User savedUser];
    //    RLMRealm *realm = [RLMRealm defaultRealm];
    //    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    [self checkOrders];
    //    self.orderModel = self.orderNumFetchedResultsController.fetchedObjects.lastObject;
    
    LineItems *item     = [order.cartLineItems.allObjects objectAtIndex:indexPath.row];
    
    NSString *parameter = [NSString stringWithFormat:@"id=%@&userid=%@", item.lineItemID.stringValue, user.userID];
    
    if (user.userID != nil)
    {
        
        NSString *url = [NSString stringWithFormat:@"http://neediator.net/NeediatorWebservice/neediatorWs.asmx/deleteCart"];
        
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = @"POST";
        request.HTTPBody   = [NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        self.task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (data != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@",response);
                    
                    NSError *jsonError;
                    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                    
                    NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                    NSLog(@"Response %ld", (long)[url_response statusCode]);
                    
                    if (url_response.statusCode == 200) {
                        [self hideHUD];
                        
                        [self.managedObjectContext deleteObject:item];
                        
                        
                        NSError *error = nil;
                        if (![self.managedObjectContext save:&error]) {
                            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                            abort();
                        }
                        
                        
                        if (order.cartLineItems.allObjects.count == 0) {
                            [self.managedObjectContext deleteObject:order];
                        }
                        else {
                            
                            order.total         = [[json valueForKey:@"totalamount"] stringValue];
                            
                            NSInteger shipping = [[json valueForKey:@"deliverycharges"] integerValue];
                            order.shipping_charge = @(shipping);
                        }
                        
                        
                        NSError *orderError = nil;
                        if (![self.managedObjectContext save:&orderError]) {
                            NSLog(@"Unresolved Order error %@, %@", orderError, [orderError userInfo]);
                            abort();
                        }
                        
                        [self checkOrders];
                        
                        [self.tableView reloadData];
                        
                        
                        if (self.orderNumFetchedResultsController.fetchedObjects.count == 0) {
                            [self decorateNoCartDimmView];
                        }
                        
                        
                    } else {
                        [self hideHUD];
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
        
        //        [self showHUD:@"Removing..." andDetailText:nil];
        [self showHUD];
        
    } else {
        [self showLoginPageAndIsPlacingOrder:NO];
    }
}



-(void)updateOrderLineItem:(Order *)order withQuantity:(NSInteger)quantity {
    
    User *user = [User savedUser];
    //    RLMRealm *realm = [RLMRealm defaultRealm];
    //    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    [self checkOrders];
    
    //    self.orderModel = self.orderNumFetchedResultsController.fetchedObjects.lastObject;
    
    LineItems *line_item         = [order.cartLineItems.allObjects objectAtIndex:self.selectIndexPath.row];
    
    if (user.userID != nil) {
        
        NSString *parameter = [NSString stringWithFormat:@"id=%@&qty=%ld", line_item.lineItemID.stringValue,(long)quantity];
        
        NSLog(@"parameter %@", parameter);
        
        
        NSString *url = [NSString stringWithFormat:@"http://neediator.net/NeediatorWebservice/neediatorWs.asmx/updateCart"];
        
        
        
        
        NSLog(@"URL is %@",url);
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = @"POST";
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
                        
                        if ([[json objectForKey:@"cart"] isKindOfClass:[NSArray class]]) {
                            
                            order.total         = [[json valueForKey:@"totalamount"] stringValue];
                            
                            NSInteger shipping = [[json valueForKey:@"deliverycharges"] integerValue];
                            order.shipping_charge = @(shipping);
                            
                            
                            NSArray *cartArray = [json objectForKey:@"cart"];
                            NSDictionary *updatedItem = [cartArray lastObject];
                            
                            NSNumber *variantID = [updatedItem valueForKey:@"productid"];
                            NSNumber *lineItemID = [updatedItem valueForKey:@"id"];
                            
                            if ([line_item.variantID isEqual:variantID] && [line_item.lineItemID isEqual:lineItemID]) {
                                line_item.quantity = [updatedItem valueForKey:@"qty"];
                                line_item.price    = [NSNumber numberWithFloat:[[updatedItem valueForKey:@"price"] floatValue]];
                                
                                
                                NSNumberFormatter *headerCurrencyFormatter = [[NSNumberFormatter alloc] init];
                                [headerCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                                [headerCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
                                //
                                NSString *display_price_string = [headerCurrencyFormatter stringFromNumber:@(line_item.price.floatValue)];
                                NSString *display_total_string = [headerCurrencyFormatter stringFromNumber:@([[updatedItem valueForKey:@"total"] floatValue])];
                                
                                line_item.singleDisplayPrice = display_price_string;
                                line_item.totalDisplayPrice  = display_total_string;
                                line_item.total    = [NSNumber numberWithFloat:[[updatedItem valueForKey:@"total"] floatValue]];
                                
                                NSError *error = nil;
                                
                                if (![self.managedObjectContext save:&error]) {
                                    NSLog(@"Update lineItems: Managed object  error %@, %@", error, [error userInfo]);
                                }
                                
                                [self hideHUD];
                                
                                [self.tableView reloadData];
                            }
                        }
                        else {
                            NSString *errorMessage = [json objectForKey:@"cart"];
                            errorMessage           = errorMessage.capitalizedString;
                            
                            [self hideHUD];
                            
                            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorMessage delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                            [alert show];
                        }
                        
                        
                    }
                    
                    
                });
            }
            else {
                [self displayConnectionFailed];
            }
            
        }];
        
        [self.task resume];
        
        //        [self showHUD:@"Updating..." andDetailText:nil];
        [self showHUD];
        
    } else {
        [self showLoginPageAndIsPlacingOrder:NO];
    }
    
}



#pragma mark - Navigation

-(void)proceedToPaymentPage:(Order *)order
{
    //    PaymentViewController *paymentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];
    //     paymentVC.orderModel               = order;
    
    //    paymentVC.order_id               = [json valueForKey:@"number"];
    //    paymentVC.display_total          = [json valueForKey:@"display_total"];
    //    paymentVC.display_item_total     = [json valueForKey:@"display_item_total"];
    //    paymentVC.display_delivery_total = [json valueForKey:@"display_ship_total"];
    //    paymentVC.total                  = [json valueForKey:@"total"];
    //    paymentVC.payment_methods        = [json valueForKey:@"payment_methods"];
    //    paymentVC.title                  = [[json valueForKey:@"state"] capitalizedString];
    //    paymentVC.store                  = [[json valueForKeyPath:@"store.name"] capitalizedString];
    //    paymentVC.store_url              = [json valueForKeyPath:@"store.url"];
    //    paymentVC.shipAddress            = [json valueForKey:@"ship_address"];
    
    
    
    
    
    //    paymentVC.hidesBottomBarWhenPushed = YES;
    //
    //    [self.navigationController pushViewController:paymentVC animated:YES];
}


-(void)proceedToNewAddressPage {
    
    EditAddressViewController *editAddressVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editAddressVC"];
    editAddressVC.title = @"Add Shipping Address";
    
    [self.navigationController pushViewController:editAddressVC animated:YES];
    
}


-(void)showLoginPageAndIsPlacingOrder:(BOOL)isPlacing {
    
    LogSignViewController *logSignVC = (LogSignViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
    logSignVC.isPlacingOrder = isPlacing;
    
    UINavigationController *logSignNav = [[UINavigationController alloc]initWithRootViewController:logSignVC];
    logSignNav.navigationBar.tintColor = self.tableView.tintColor;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        logSignNav.modalPresentationStyle    = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:logSignNav animated:YES completion:nil];
}



-(void)goToStoresPage:(UIButton *)sender {
    
    
    //    StoresViewController *storesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"storesViewController"];
    //    storesVC.hidesBottomBarWhenPushed = YES;
    //
    //    [self.navigationController pushViewController:storesVC animated:YES];
    
    
    UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
    
    [tabBarController setSelectedIndex:0];
    
}


#pragma mark - Custom UIViews

-(void)showConnectionErrorView:(NSError *)error {
    self.connectionErrorView = [[[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil] lastObject];
    self.connectionErrorView.tag = kCartConnectionErrorViewTag;
    self.connectionErrorView.frame = self.tableView.frame;
    self.connectionErrorView.label.text = [error localizedDescription];
    [self.connectionErrorView.retryButton addTarget:self action:@selector(getOrderLineItemDetails) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.view insertSubview:self.connectionErrorView belowSubview:self.navigationController.navigationBar];
}


-(void)removeConnectionErrorView {
    
    if (self.connectionErrorView) {
        [[self.navigationController.view viewWithTag:kCartConnectionErrorViewTag] removeFromSuperview];
    }
    
}

-(void)removeNoCartDimmView {
    if (self.dimmView) {
        
        [[self.navigationController.view viewWithTag:kCartEmptyViewTag] removeFromSuperview];
        //        [self.dimmView removeFromSuperview];
    }
}


-(void)decorateNoCartDimmView {
    
    [self createDimmView];
    
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



-(void)createDimmView {
    
    self.dimmView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, CGRectGetWidth(self.view.frame), self.view.frame.size.height)];
    self.dimmView.backgroundColor = [UIColor whiteColor];
    self.dimmView.tag = kCartEmptyViewTag;
    [self.navigationController.view insertSubview:self.dimmView belowSubview:self.navigationController.navigationBar];
    //    [self.view addSubview:self.dimmView];
    
}


//-(void)removeDecoratedNoCartDimView {
//    if (self.dimmView) {
//
//        [self.dimmView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if ([obj isKindOfClass:[UIButton class]]) {
//
//                [obj removeFromSuperview];
//            }
//
//            if ([obj isKindOfClass:[UIImageView class]]) {
//
//                [obj removeFromSuperview];
//            }
//
//            if ([obj isKindOfClass:[UILabel class]]) {
//
//                [obj removeFromSuperview];
//            }
//        }];
//    }
//}













































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

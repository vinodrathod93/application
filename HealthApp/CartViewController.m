 //
//  CartViewController.m
//  Chemist Plus
//
//  Created by adverto on 23/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "CartViewController.h"
#import "AddToCart.h"
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
#import "LogSignViewController.h"
#import "AddressesViewController.h"

#define kcreateOrderURL @"http://www.elnuur.com/api/orders"
static NSString *cellIdentifier = @"cartCell";

@interface CartViewController ()<NSFetchedResultsControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) NSFetchedResultsController *cartFetchedResultsController;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;
//@property (nonatomic, assign) BOOL hasCheckedOut;
@property (nonatomic, assign) BOOL isAlreadyLoggedIn;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self.cartFetchedResultsController performFetch:nil];
    
    User *isLoggedIn = [User savedUser];
    
    self.isAlreadyLoggedIn = isLoggedIn ? YES: NO;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
    
//    User *didLoggedIn = [User savedUser];
    
//    didLoggedIn ? (self.hasCheckedOut) ? [self showAddressesVC]: NSLog(@"Did not logged in"):NSLog(@"Not Checked out");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    NSLog(@"%lu",(unsigned long)self.cartFetchedResultsController.sections.count);
    
    return self.cartFetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.cartFetchedResultsController sections][section];
    NSLog(@"%lu",(unsigned long)[sectionInfo numberOfObjects]);
    [self updateBadgeValue];
    
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CartViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        AddToCart *model = [self.cartFetchedResultsController objectAtIndexPath:indexPath];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        NSString *quantity_price_string = [numberFormatter stringFromNumber:model.totalPrice];
        
        [cell.c_imageView sd_setImageWithURL:[NSURL URLWithString:model.productImage]];
        cell.c_name.text = model.productName;
        cell.c_name.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.c_name sizeToFit];
        
        cell.singlePrice.text = model.displayPrice;
        [cell.quantity setTitle:model.quantity.stringValue forState:UIControlStateNormal];
        
        cell.quantityPrice.text = quantity_price_string;
        cell.variant.text = model.variant;
    }
    
    
    return cell;
}



#pragma mark - Table view Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 135.0f;
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

-(UIView *)configureHeaderView:(UIView *)header forSection:(NSInteger)section {
    
    [self.cartFetchedResultsController performFetch:nil];
    
    if (self.cartFetchedResultsController.fetchedObjects.count == 0) {
        HeaderLabel *noItems = [[HeaderLabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        noItems.text = @"No Products in Cart";
        noItems.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        noItems.backgroundColor = [UIColor whiteColor];
        
        [header addSubview:noItems];
    } else {
        HeaderLabel *items = [[HeaderLabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 40)];
        items.text = [NSString stringWithFormat:@"Products: %lu",(unsigned long)self.cartFetchedResultsController.fetchedObjects.count];
        items.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        items.backgroundColor = [UIColor whiteColor];
        
        
        HeaderLabel *totalAmount = [[HeaderLabel alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2 , 0, self.view.frame.size.width/2, 40)];
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        NSString *total_price_string = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:[self totalAmount]]];
        
        totalAmount.text = [NSString stringWithFormat:@"%@",total_price_string];
        totalAmount.textAlignment = NSTextAlignmentRight;
        totalAmount.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
        totalAmount.backgroundColor = [UIColor whiteColor];
        
        [header addSubview:items];
        [header addSubview:totalAmount];
    }
    
    
    return header;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIButton *placeOrderbutton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    [placeOrderbutton setTitle:@"Proceed to Submit Order" forState:UIControlStateNormal];
    [placeOrderbutton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:16.0f]];
    [placeOrderbutton setBackgroundColor:[UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f]];
    
    if (self.cartFetchedResultsController.fetchedObjects.count != 0) {
        [placeOrderbutton setEnabled:YES];
        [placeOrderbutton setBackgroundColor:[UIColor colorWithRed:102/255.0f green:169/255.0f blue:127/255.0f alpha:1.0f]];
        [placeOrderbutton addTarget:self action:@selector(placeOrderPressed) forControlEvents:UIControlEventTouchUpInside];
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
    
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
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
        }
}


-(void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
        switch (type) {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                break;
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
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

- (IBAction)deleteCartProduct:(UIButton *)sender {
    CartViewCell *cell = (CartViewCell *)[[sender superview] superview];
    NSLog(@"%ld",(long)[self.tableView indexPathForCell:cell].row);
    
}


-(void)placeOrderPressed {
    
    User *user = [User savedUser];
    
    if (user.access_token == nil) {
        LogSignViewController *logSignVC = [self.storyboard instantiateViewControllerWithIdentifier:@"logSignNVC"];
        [self presentViewController:logSignVC animated:YES completion:nil];
        
    } else {
//        AddShippingDetailsViewController *shippingDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingDetailsVC"];
//        shippingDetails.cartProducts = [self prepareCartProductsArray];
//        shippingDetails.totalAmount = @([self totalAmount]).stringValue;
//        
//        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:shippingDetails];
//        [self presentViewController:nav animated:YES completion:nil];
        
//        [self showAddressesVC];
        
        
        NSArray *lineItems = [self getCartProducts];
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
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                [self.hud hide:YES];
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    
                    NSLog(@"Order initiated");
                    [self showAddressesVC];
                    
                }
                
                
                
            });
            
            
        }];
        
        [task resume];
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.color = self.view.tintColor;
        
    }
}

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
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        
        
        NSInteger totalPrice = [self calculateTotalPrice:quantity andSinglePrice:model.productPrice.intValue];
        [cell.quantity setTitle:@(quantity).stringValue forState:UIControlStateNormal];
        
        NSString *total_price_string = [numberFormatter stringFromNumber:[NSNumber numberWithInteger:totalPrice]];
        cell.quantityPrice.text = total_price_string;
        
        [self saveQuantity:quantity andTotalPrice:totalPrice];
        
        [self.tableView reloadData];
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



-(CGFloat)calculateTotalPrice:(NSInteger)quantity andSinglePrice:(CGFloat)price {
    CGFloat total = quantity * price;
    
    return ceil(total);
}


-(NSInteger)totalAmount {
    __block NSInteger priceInTotal = 0;
    
    [self.cartFetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(AddToCart *model, NSUInteger idx, BOOL *stop) {
        NSInteger quantity = model.quantity.integerValue;
        CGFloat singlePrice = model.productPrice.floatValue;
        
        priceInTotal = priceInTotal + [self calculateTotalPrice:quantity andSinglePrice:singlePrice];
    }];
    
    return priceInTotal;
}


-(void)updateBadgeValue {
    NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)self.cartFetchedResultsController.fetchedObjects.count];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:count];
}


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


-(void)showAddressesVC {
    AddressesViewController *addressVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesVC"];
//    addressVC.cartDetails = [self getCartDetails];
    
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

@end

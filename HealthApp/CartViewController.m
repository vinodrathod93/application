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
#import "AppDelegate.h"
#import "HeaderLabel.h"
#import "OrderInputsViewController.h"
#import "InputFormViewController.h"
#import "AddShippingDetailsViewController.h"

static NSString *cellIdentifier = @"cartCell";

@interface CartViewController ()<NSFetchedResultsControllerDelegate,UIActionSheetDelegate>

@property (nonatomic, strong) NSFetchedResultsController *cartFetchedResultsController;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;

@end

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self.cartFetchedResultsController performFetch:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
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
        
        
        [cell.c_imageView sd_setImageWithURL:[NSURL URLWithString:model.productImage]];
        cell.c_name.text = model.productName;
        cell.c_name.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.c_name sizeToFit];
        
        cell.singlePrice.text = model.productPrice;
        [cell.quantity setTitle:model.quantity forState:UIControlStateNormal];
        
        cell.quantityPrice.text = model.totalPrice;
    }
    
    
    return cell;
}



#pragma mark - Table view Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 156.0f;
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
        totalAmount.text = [NSString stringWithFormat:@"Total Amount: $%ld",(long)[self totalAmount]];
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
    [placeOrderbutton setTitle:@"Place Order" forState:UIControlStateNormal];
    [placeOrderbutton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Medium" size:16.0f]];
    [placeOrderbutton setBackgroundColor:[UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f]];
    [placeOrderbutton setEnabled:NO];
    
    if (self.cartFetchedResultsController.fetchedObjects.count != 0) {
        [placeOrderbutton setEnabled:YES];
        [placeOrderbutton setBackgroundColor:[UIColor colorWithRed:102/255.0f green:169/255.0f blue:127/255.0f alpha:1.0f]];
        [placeOrderbutton addTarget:self action:@selector(placeOrderPressed) forControlEvents:UIControlEventTouchUpInside];
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
//    OrderInputsViewController *orderInputs = [self.storyboard instantiateViewControllerWithIdentifier:@"orderInputsVC"];
//    [self.navigationController presentViewController:orderInputs animated:YES completion:nil];
    
//    InputFormViewController *form = [[InputFormViewController alloc]init];
//    [self.navigationController presentViewController:form animated:YES completion:nil];
    
    AddShippingDetailsViewController *shippingDetails = [self.storyboard instantiateViewControllerWithIdentifier:@"addShippingDetailsVC"];
    shippingDetails.cartProducts = [self prepareCartProductsArray];
    shippingDetails.totalAmount = @([self totalAmount]).stringValue;
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:shippingDetails];
    [self presentViewController:nav animated:YES completion:nil];
    
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
        
        CartViewCell *cell = (CartViewCell *)[self.tableView cellForRowAtIndexPath:self.selectIndexPath];
        CGFloat singlePrice = [self convertToDoubleFromString:cell.singlePrice.text];
        NSInteger totalPrice = [self calculateTotalPriceWithQuantity:quantity andSinglePrice:singlePrice];
        [cell.quantity setTitle:@(quantity).stringValue forState:UIControlStateNormal];
        cell.quantityPrice.text = [NSString stringWithFormat:@"%ld",(long)totalPrice];
        
        
        [self saveQuantity:quantity andTotalPrice:totalPrice];
        
        [self.tableView reloadData];
    }
    
}

-(void)saveQuantity:(NSInteger)quantity andTotalPrice:(NSInteger)totalPrice {
    AddToCart *model = self.cartFetchedResultsController.fetchedObjects[self.selectIndexPath.row];
    model.quantity = @(quantity).stringValue;
    model.totalPrice = @(totalPrice).stringValue;
    
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(CGFloat)convertToDoubleFromString:(NSString *)string {
    NSLog(@"%@",string);
    
    NSString *priceString;
    NSScanner *scanner = [NSScanner scannerWithString:string];
    NSCharacterSet *priceValue = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
    
    [scanner scanUpToCharactersFromSet:priceValue intoString:NULL];
    [scanner scanCharactersFromSet:priceValue intoString:&priceString];
    
    NSLog(@"%ld",(long)[priceString doubleValue]);
    
    return ceil([priceString doubleValue]);
}

-(CGFloat)calculateTotalPriceWithQuantity:(NSInteger)quantity andSinglePrice:(CGFloat)price {
    CGFloat total = quantity * price;
    
    return ceil(total);
}


-(NSInteger)totalAmount {
    __block NSInteger priceInTotal = 0;
    
    [self.cartFetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(AddToCart *model, NSUInteger idx, BOOL *stop) {
        NSInteger quantity = model.quantity.integerValue;
        CGFloat singlePrice = [self convertToDoubleFromString:model.productPrice];
        
        priceInTotal = priceInTotal + [self calculateTotalPriceWithQuantity:quantity andSinglePrice:singlePrice];
    }];
    
    return priceInTotal;
}


-(void)updateBadgeValue {
    NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)self.cartFetchedResultsController.fetchedObjects.count];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:count];
}


-(NSArray *)prepareCartProductsArray {
    
    NSMutableArray *jsonarray = [[NSMutableArray alloc] init];
    
    [self.cartFetchedResultsController.fetchedObjects enumerateObjectsUsingBlock:^(AddToCart *model, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        for (NSAttributeDescription *attribute in [[model entity] properties]) {
            NSString *attributeName = attribute.name;
            
            id attributeValue = [model valueForKey:attributeName];
            if ([attributeValue isKindOfClass:[NSDate class]]) {
                NSString *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                                      dateStyle:NSDateFormatterShortStyle
                                                                      timeStyle:NSDateFormatterFullStyle];
                
                [dict setObject:dateString forKey:attributeName];
            } else {
                [dict setObject:attributeValue forKey:attributeName];
            }
        }
        
        
        [jsonarray addObject:dict];
        
        
    }];
    
   
    return jsonarray;
    
}


@end

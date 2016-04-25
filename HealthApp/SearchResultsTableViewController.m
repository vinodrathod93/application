//
//  SearchResultsTableViewController.m
//  Neediator
//
//  Created by adverto on 07/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "SearchResultsTableViewController.h"
#import "AppDelegate.h"
#import "LineItems.h"
#import "Order.h"

@interface SearchResultsTableViewController ()
{
    NSDictionary *_product;
    NSInteger _footerHeight;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) LineItems *lineItemsModel;
@property (nonatomic, strong) NSFetchedResultsController *pd_orderFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *pd_lineItemFetchedResultsController;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NeediatorHUD *neediatorHUD;

@end

@implementation SearchResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"numberOfRowsInSection");
    
    return [self.searchResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];
    
    
    if (_isQuickOrder) {
        [self configureProductCell:cell forIndexPath:indexPath];
    }
    else {
    
        if (_neediatorSearchScope == searchScopeLocation) {
            [self configureLocationCell:cell forIndexPath:indexPath];
        }
        else if (_neediatorSearchScope == searchScopeCategory) {
            [self configureCategoryCell:cell forIndexPath:indexPath];
        }
        else if (_neediatorSearchScope == searchScopeStore) {
            [self configureStoreCell:cell forIndexPath:indexPath];
        }
        else {
            [self configureProductCell:cell forIndexPath:indexPath];
        }
    }
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_neediatorSearchScope == searchScopeLocation) {
        
        NSDictionary *location = self.searchResults[indexPath.row];
        NSString *place = location[@"description"];
        
        UIView *dimView = [NeediatorUtitity showDimViewWithFrame:self.tableView.frame];
        [dimView addSubview:self.neediatorHUD];
        [self startNeediatorHUD];
        
        
        [[NAPIManager sharedManager] getCoordinatesOf:place withSuccess:^(BOOL success, NSDictionary *locationGeometry) {
            
            [self.neediatorHUD fadeOutAnimated:YES];
            
            NSMutableDictionary *locationData = [[NSMutableDictionary alloc] init];
            [locationData addEntriesFromDictionary:locationGeometry];
            [locationData setValue:place forKey:@"place"];
            [locationData setValue:@(searchScopeLocation) forKey:@"NeediatorSearchScope"];
            
            if ([self.delegate respondsToSelector:@selector(searchResultsTableviewControllerDidSelectResult:)]) {
                
                [self.delegate searchResultsTableviewControllerDidSelectResult:locationData];
            }
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        } failure:^(NSError *error) {
            
            [self.neediatorHUD fadeOutAnimated:YES];
            [NeediatorUtitity alertWithTitle:@"Error" andMessage:error.localizedDescription onController:self];
        }];
    }
    else if (_neediatorSearchScope == searchScopeStore) {
            NSDictionary *store = self.searchResults[indexPath.row];
            NSString *code = store[@"code"];
            
            [[NAPIManager sharedManager] requestStoreByCode:code success:^(NSDictionary *store) {
                // go to storefront page
                
                [self.neediatorHUD fadeOutAnimated:YES];
                
                NSMutableDictionary *storeDataDictionary = [[NSMutableDictionary alloc] init];
                [storeDataDictionary addEntriesFromDictionary:store];
                [storeDataDictionary setValue:@"value" forKey:@"value"];
                [storeDataDictionary setValue:@(searchScopeStore) forKey:@"NeediatorSearchScope"];
                
                if ([self.delegate respondsToSelector:@selector(searchResultsTableviewControllerDidSelectResult:)]) {
                    [self.delegate searchResultsTableviewControllerDidSelectResult:storeDataDictionary];
                }
                
                [self dismissViewControllerAnimated:YES completion:nil];
                
                
            } failure:^(NSError *error) {
                [self.neediatorHUD fadeOutAnimated:YES];
                [NeediatorUtitity alertWithTitle:@"Error" andMessage:error.localizedDescription onController:self];
            }];
            
        }
}



-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (_footerHeight > 0) {
        return [self showNeediatorHUD];
    }
    else
        return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return _footerHeight;
    
}




#pragma mark - Custom Tableviewcell Methods

-(void)configureLocationCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *location = self.searchResults[indexPath.row];
    NSString *place = location[@"description"];
    
    cell.textLabel.text = [self formattedAreaPlace:place];
    cell.detailTextLabel.text = [self formattedLocation:place];
    cell.imageView.image = [UIImage imageNamed:@"store_location"];
    
}

-(void)configureCategoryCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    
    NSDictionary *category = self.searchResults[indexPath.row];
    NSString *name = category[@"Catname"];
    NSString *imageURL = category[@"Imageurl"];
    
    cell.textLabel.text = name;
    cell.detailTextLabel.text = @"";
    
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageURL]
                                                    options:SDWebImageRefreshCached
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      CGSize size = CGSizeMake(25, 25);
                                                      
                                                      cell.imageView.image = [NeediatorUtitity imageWithImage:image scaledToSize:size];
                                                  }];
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:[UIImage imageNamed:@"category"]];
    
}

-(void)configureProductCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    _product = self.searchResults[indexPath.row];
    
    NSNumberFormatter *priceCurrencyFormatter = [[NSNumberFormatter alloc] init];
    [priceCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [priceCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
    
    
//    NSString *price = _product[@"rate"];
    NSString *imageURL = _product[@"imageurl"];
    
    cell.textLabel.text     = [_product[@"productname"] capitalizedString];
    cell.detailTextLabel.text = @"";
//    cell.detailTextLabel.text = [priceCurrencyFormatter stringFromNumber:@(price.intValue)];
    
    
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageURL]
                                                    options:SDWebImageRefreshCached
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      CGSize size = CGSizeMake(25, 25);
                                                      
                                                      cell.imageView.image = [NeediatorUtitity imageWithImage:image scaledToSize:size];
                                                  }];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (_isQuickOrder) {
        if ([cell.textLabel.text isEqualToString:@"No Products"]) {
            cell.detailTextLabel.text = nil;
            cell.accessoryView = nil;
        }
        else {
            UIButton *add = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
            add.tag = indexPath.row;
            
            [add setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            [add addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.accessoryView = add;
        }
    }
    
    
}

-(void)configureStoreCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *store = self.searchResults[indexPath.row];
    NSString *name = store[@"Name"];
    NSString *category = store[@"CatName"];
    NSString *imageurl = store[@"images"];
    
    cell.textLabel.text = [name capitalizedString];
    cell.detailTextLabel.text = category;
    cell.imageView.image = [UIImage imageNamed:@"shop"];
    
    
    if ([imageurl isEqual:[NSNull null]]) {
        cell.imageView.image = [UIImage imageNamed:@"shop"];
    }
    else {
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imageurl]
                                                        options:SDWebImageRefreshCached
                                                       progress:nil
                                                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                          CGSize size = CGSizeMake(25, 25);
                                                          
                                                          cell.imageView.image = [NeediatorUtitity imageWithImage:image scaledToSize:size];
                                                      }];
    }
}




#pragma mark - Quick Order Add_To_Cart

-(void)addToCart:(UIButton *)sender {
    
    NSLog(@"Added to cart");
    
    User *user = [User savedUser];
    
    if (user.userID != nil) {
        
        NSDictionary *product = self.searchResults[sender.tag];
        [self addToCartButtonPressed:product];
        [sender setImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
        
    }
    else {
        // Login presentVC
        
        LogSignViewController *logSignVC = (LogSignViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
        logSignVC.isPlacingOrder = NO;
        
        UINavigationController *logSignNav = [[UINavigationController alloc] initWithRootViewController:logSignVC];
        logSignNav.navigationBar.tintColor = self.tableView.tintColor;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            logSignNav.modalPresentationStyle    = UIModalPresentationFormSheet;
        }
        
        [self presentViewController:logSignNav animated:YES completion:nil];
    }
    
   
}








-(void)addToCartButtonPressed:(NSDictionary *)product {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetch   = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"variantID == %@", product[@"productid"]];
    [fetch setPredicate:predicate];
    
    NSError *productItemCheckError;
    NSArray *fetchedArray   = [self.managedObjectContext executeFetchRequest:fetch error:&productItemCheckError];
    if (productItemCheckError != nil) {
        NSLog(@"ProductItem Check Error: %@", [productItemCheckError localizedDescription]);
    }
    else if (fetchedArray.count == 0) {
        _lineItemsModel            = [NSEntityDescription insertNewObjectForEntityForName:@"LineItems" inManagedObjectContext:self.managedObjectContext];
        
        
        NSString *price = product[@"rate"];
        NSString *qty   = product[@"qty"];
        NSString *product_id = product[@"productid"];
        
        _lineItemsModel.image                 = product[@"imageurl"];
        _lineItemsModel.quantity              = @1;
        _lineItemsModel.variantID             = @(product_id.integerValue);
        _lineItemsModel.name                  = product[@"productname"];
        _lineItemsModel.price                 = @(price.integerValue);
        _lineItemsModel.singleDisplayPrice    = product[@"rate"];
        _lineItemsModel.total                 = @(price.integerValue);
        _lineItemsModel.totalDisplayPrice     = product[@"rate"];
        _lineItemsModel.totalOnHand           = @(qty.integerValue);
        _lineItemsModel.option                = @"";
        
        
        [self sendLineItem:product];
        
        
    }
    else {
//        [self alreadyLabelButton];
        
        NSLog(@"Already added ");
    }

}






-(void)sendLineItem:(NSDictionary *)lineItem {
    
    User *user = [User savedUser];
    
    [self checkOrders];
    
    
    
    
    NSString *url = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/addToCart"];
    NSLog(@"URL is --> %@", url);
    
    NSString *parameter  = [NSString stringWithFormat:@"product_id=%@&qty=%@&user_id=%@&store_id=%@&cat_id=%@", lineItem[@"productid"], @"1", user.userID, lineItem[@"storeid"], lineItem[@"catid"]];
    NSData *parameterData = [NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = parameterData;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)parameterData.length] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                NSLog(@"%@", json);
                
                [self.hud hide:YES];
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    
                    
                    if (_pd_orderFetchedResultsController.fetchedObjects.count != 0) {
                        
                        Order *orderModel = [_pd_orderFetchedResultsController.fetchedObjects lastObject];
                        [orderModel addCartLineItemsObject:_lineItemsModel];
                        
                    }
                    
                    [self.managedObjectContext save:nil];
                    
//                    [self addedLabelButton];
                    
                }
                
            });
        }
        else {
//            [self displayConnectionFailed];
            
            NSLog(@"Something went wrong");
        }
        
        
    }];
    
    [task resume];
    
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Adding To Cart...";
    self.hud.color = self.view.tintColor;
    
    
    
    
    
    
    
}






#pragma mark - Fetched Results Controller

-(void)checkOrders {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.pd_orderFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if(![self.pd_orderFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",error);
    }
}


-(void)checkLineItems {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineItemID" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.pd_lineItemFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if (![self.pd_lineItemFetchedResultsController performFetch:&error]) {
        NSLog(@"LineItems Model Fetch Failure: %@", [error localizedDescription]);
    }
    
}



#pragma mark - Location

-(NSString *)formattedLocation:(NSString *)place {
    
    NSArray *trimmedLocation        = [place componentsSeparatedByString:@","];
    
    NSInteger count = trimmedLocation.count;
    NSString *endingLocation;
    
    if (count == 1) {
        endingLocation          = [NSString stringWithFormat:@"%@", trimmedLocation[count-1]];
    }
    else if (count == 2) {
        endingLocation          = [NSString stringWithFormat:@"%@, %@", trimmedLocation[count-2 ], trimmedLocation[count-1]];
    }
    else if (count == 3) {
        endingLocation          = [NSString stringWithFormat:@"%@, %@", trimmedLocation[count-2 ], trimmedLocation[count-1]];
    }
    else if (count == 4) {
        endingLocation          = [NSString stringWithFormat:@"%@, %@", trimmedLocation[count-3 ], trimmedLocation[count-2]];
    }
    else if (count > 4) {
        endingLocation          = [NSString stringWithFormat:@"%@, %@", trimmedLocation[count-4 ], trimmedLocation[count-3]];
    }
    
    
    return endingLocation;
}

-(NSString *)formattedAreaPlace:(NSString *)place {
    
    NSArray *trimmedLocation        = [place componentsSeparatedByString:@","];
    
    NSInteger count = trimmedLocation.count;
    NSString *area;
    
    if (count > 0) {
        area          = [NSString stringWithFormat:@"%@", trimmedLocation[0]];
    }
    
    return area;
}


-(UIView *)showNeediatorHUD {
    
    
    self.neediatorHUD = [[NeediatorHUD alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _footerHeight)];
    self.neediatorHUD.overlayColor = [UIColor clearColor];
    
    NSLog(@"%@", NSStringFromCGSize(self.neediatorHUD.logoSize));
    self.neediatorHUD.logoSize = CGSizeMake(25, 25);
    self.neediatorHUD.hudCenter = CGPointMake(CGRectGetWidth(self.view.bounds)/2, _footerHeight/2);
    
    return self.neediatorHUD;
}

-(void)startNeediatorHUD {
    _footerHeight = 100;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.neediatorHUD fadeInAnimated:YES];
}

-(void)hideHUD {
    
    _footerHeight = 0;
    
    [self tableView:self.tableView viewForFooterInSection:0];
    
    [self.tableView reloadData];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
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

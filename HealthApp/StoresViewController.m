//
//  StoresViewController.m
//  Chemist Plus
//
//  Created by adverto on 03/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "StoresViewController.h"
#import "APIManager.h"
#import <Realm/Realm.h>
#import "StoreRealm.h"
#import "StoresViewCell.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "TaxonsViewController.h"
#import "StoreTaxonsViewController.h"
#import "User.h"
#import "LogSignViewController.h"
#import "AppDelegate.h"
#import "PresentingAnimator.h"
#import "DismissingAnimator.h"
#import "PopupCartViewController.h"
#import "Order.h"
#import "Location.h"
#import "NoStores.h"
#import "NoConnectionView.h"

#define kNoStoresTag 10
#define kConnectionViewTag 11

@interface StoresViewController ()<NSFetchedResultsControllerDelegate,UIViewControllerTransitioningDelegate>


@property (nonatomic, strong) NSFetchedResultsController *s_lineItemsFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *s_orderFetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

//@property (nonatomic, strong) RLMResults *stores;
@property (nonatomic, strong) NSArray *array_stores;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (strong, nonatomic) UIView *headerContentView;
@property (nonatomic, strong) NoStores *noStoresView;

@end

@implementation StoresViewController {
    NoConnectionView *_connectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Header Content View.
    self.headerContentView = [self loadHeaderContentView];
    self.headerContentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    
    
    
}




-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self requestStores];
}



-(void)requestStores {
    
    
    [self removeConnectionView];
    
    
    Location *location_store = [Location savedLocation];
    
    if (location_store == nil) {
        UIAlertView *select_location = [[UIAlertView alloc] initWithTitle:@"" message:@"Please select the location in Search Menu to browse the stores" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [select_location show];
        
        [self performSelector:@selector(dismissAlertView:) withObject:select_location afterDelay:2];
        
        
    } else {
        
        
        StoreListRequestModel *requestModel = [StoreListRequestModel new];
        requestModel.location = [NSString stringWithFormat:@"%@,%@", location_store.latitude, location_store.longitude];
        
        AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
        self.managedObjectContext = appDelegate.managedObjectContext;
        
        [self showHUD];
        [[APIManager sharedManager] getStoresWithRequestModel:requestModel success:^(StoreListResponseModel *responseModel) {
            
            
            
            //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //            RLMRealm *realm = [RLMRealm defaultRealm];
            //            [realm beginWriteTransaction];
            //            [realm deleteAllObjects];
            //            [realm commitWriteTransaction];
            //
            //            [realm beginWriteTransaction];
            //            for (StoresModel *store in responseModel.stores) {
            //                StoreRealm *storeRealm = [[StoreRealm alloc] initWithMantleModel:store];
            //                [realm addObject:storeRealm];
            //            }
            //            [realm commitWriteTransaction];
            //
            //            dispatch_async(dispatch_get_main_queue(), ^{
            //                RLMRealm *realmMainThread = [RLMRealm defaultRealm];
            //                RLMResults *stores = [StoreRealm allObjectsInRealm:realmMainThread];
            //                self.stores = stores;
            //                [self.tableView reloadData];
            //                [self hideHUD];
            //            });
            //        });
            
            self.array_stores = responseModel.stores;
            
            if (self.array_stores.count == 0) {
                [self showNoStoresView:location_store];
            }
            
            self.navigationItem.title = [NSString stringWithFormat:@"Stores (%lu)", (unsigned long)self.array_stores.count];
            [self.tableView reloadData];
            [self hideHUD];
            
            
        } failure:^(NSError *error) {
            
            [self hideHUD];
            
            
            _connectionView = [[[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil] lastObject];
            _connectionView.tag = kConnectionViewTag;
            _connectionView.frame = self.tableView.frame;
            _connectionView.label.text = [error localizedDescription];
            [_connectionView.retryButton addTarget:self action:@selector(requestStores) forControlEvents:UIControlEventTouchUpInside];
            
            [self.navigationController.view insertSubview:_connectionView belowSubview:self.navigationController.navigationBar];
        }];
        
    }
    
    
}



-(void)removeConnectionView {
    
    if (_connectionView) {
        [[self.navigationController.view viewWithTag:kConnectionViewTag] removeFromSuperview];
    }
    
}



-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    [[self.navigationController.view viewWithTag:kNoStoresTag] removeFromSuperview];
    
    [self removeConnectionView];
    
    
}

-(void)dismissAlertView:(UIAlertView *)alertView {
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [PresentingAnimator new];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [DismissingAnimator new];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.array_stores count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    StoresViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storeCell" forIndexPath:indexPath];
//    StoreRealm *store = self.stores[indexPath.row];
    StoresModel *store = self.array_stores[indexPath.row];
    
    [cell.storeImageView sd_setImageWithURL:[NSURL URLWithString:store.storeImage] placeholderImage:nil];
    cell.storeNameLabel.text = [store.storeName capitalizedString];
    cell.distance.text = [NSString stringWithFormat:@"%.02f KM",store.storeDistance.floatValue];
    cell.localityAddress.text = [NSString stringWithFormat:@"%@, %@, %@", [store.storeStreetAddress capitalizedString], store.storeState, store.storeCountry];
    
    return cell;
}

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    self.hud.color = self.tableView.tintColor;
    self.hud.dimBackground = YES;
    self.hud.color = [UIColor clearColor];
    self.hud.labelText = @"Loading Stores...";
    self.hud.labelColor = [UIColor darkGrayColor];
    self.hud.activityIndicatorColor = [UIColor blackColor];
    self.hud.detailsLabelText = @"(This could take a few minutes)";
    self.hud.detailsLabelColor = [UIColor darkGrayColor];
}

-(void)hideHUD {
    [self.hud hide:YES];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    User *user = [User savedUser];
    StoresModel *store = self.array_stores[indexPath.row];
    
    [self checkOrders];
    [self checkLineItems];
    
    if (store != nil) {
        if (self.s_lineItemsFetchedResultsController.fetchedObjects.count != 0) {
            // Show modal view controller
            
            Order *orderModel = [self.s_orderFetchedResultsController.fetchedObjects lastObject];
            if (![orderModel.store isEqualToString: store.storeName]) {
                
                PopupCartViewController *popupCartVC = [self.storyboard instantiateViewControllerWithIdentifier:@"popupCartViewController"];
                popupCartVC.transitioningDelegate = self;
                popupCartVC.modalPresentationStyle = UIModalPresentationCustom;
                
                [self.navigationController presentViewController:popupCartVC animated:YES completion:NULL];
                
            } else {
                
                [self saveAndProceedWithCurrentStore:store];
            }
        }
        else if (user.access_token == nil) {
            LogSignViewController *logSignVC = (LogSignViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
            logSignVC.isPlacingOrder = NO;
            
            UINavigationController *logSignNav = [[UINavigationController alloc] initWithRootViewController:logSignVC];
            logSignNav.navigationBar.tintColor = self.tableView.tintColor;
            
            [self presentViewController:logSignNav animated:YES completion:nil];
            
        } else {
            
            [self saveAndProceedWithCurrentStore:store];
        }
            
    } else
        NSLog(@"No Stores");
    
    

    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 35.f;
    } else
        return 0.f;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        /*
        UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 25)];
        
        UILabel *location_name = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, locationView.frame.size.width/2, 25)];
        location_name.font     = [UIFont fontWithName:@"AvenirNext-Medium" size:15.f];
        
        _location_store = [Location savedLocation];
        if (_location_store) {
            location_name.text = _location_store.location_name;
        }
        
        location_name.textAlignment = NSTextAlignmentCenter;
        
        UIButton *changeLocation = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, location_name.frame.size.width/2, 25)];
        changeLocation.titleLabel.text = @"Change";
        changeLocation.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:13.f];
        
        [locationView addSubview:location_name];
        [locationView addSubview:changeLocation];
        
        */
        
        
        return [self headerView];
    }
    else
        return nil;
}







- (UIView *)loadHeaderContentView {
    
    
    
    UIButton *changeLocation = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [changeLocation setTitle:@"Change" forState:UIControlStateNormal];
    changeLocation.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.f];
    changeLocation.translatesAutoresizingMaskIntoConstraints = NO;
    [changeLocation setContentHuggingPriority:252 forAxis:UILayoutConstraintAxisHorizontal];
    [changeLocation setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
    [changeLocation addTarget:self action:@selector(goToSearchTab) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *location = [[UILabel alloc] init];
    location.font     = [UIFont fontWithName:@"AvenirNext-Medium" size:14.f];
    location.textColor= [UIColor darkGrayColor];
    
    Location *location_header = [Location savedLocation];
    if (location_header) {
        location.text = location_header.location_name;
    }
    
    location.translatesAutoresizingMaskIntoConstraints = NO;
    location.adjustsFontSizeToFitWidth = YES;
    
    UIView *headerContentView = [[UIView alloc] init];
    [headerContentView addSubview:changeLocation];
    [headerContentView addSubview:location];
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(location, changeLocation);
    
    
    [headerContentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[location]-[changeLocation]-|"
                                                                              options:NSLayoutFormatAlignAllCenterY
                                                                              metrics:nil
                                                                                views:viewsDictionary]];
    [headerContentView addConstraint:[NSLayoutConstraint constraintWithItem:location
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:headerContentView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0]];
    // Here setting the heights of the subviews
    [headerContentView addConstraint:[NSLayoutConstraint constraintWithItem:location
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:headerContentView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.f
                                                                   constant:0]];
    [headerContentView addConstraint:[NSLayoutConstraint constraintWithItem:changeLocation
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:headerContentView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.f
                                                                   constant:0]];
    return headerContentView;
}

- (UIView *)headerView {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:self.headerContentView];
    
    NSDictionary *views = @{@"headerContentView" : self.headerContentView};
    NSArray *hConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[headerContentView]|" options:0 metrics:nil views:views];
    NSArray *vConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[headerContentView]|" options:0 metrics:nil views:views];
    [headerView addConstraints:hConstraints];
    [headerView addConstraints:vConstraints];
    
    return headerView;
}




















-(void)saveAndProceedWithCurrentStore:(StoresModel *)store {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        @autoreleasepool {
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            [realm deleteAllObjects];
            [realm commitWriteTransaction];
            
            [realm beginWriteTransaction];
            
            StoreRealm *storeRealm = [[StoreRealm alloc] initWithMantleModel:store];
            [realm addObject:storeRealm];
            
            [realm commitWriteTransaction];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                RLMRealm *realmMainThread = [RLMRealm defaultRealm];
                RLMResults *stores = [StoreRealm allObjectsInRealm:realmMainThread];
                
                NSLog(@"%@",stores);
            });
        }
        
    });
    
    
    StoreTaxonsViewController *storeTaxonsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"storeTaxonsVC"];
    storeTaxonsVC.title = [store.storeName capitalizedString];
    storeTaxonsVC.storeURL = store.storeUrl;
    [self.navigationController pushViewController:storeTaxonsVC animated:YES];
    
}


-(void)checkLineItems {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineItemID" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.s_lineItemsFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if (![self.s_lineItemsFetchedResultsController performFetch:&error]) {
        NSLog(@"LineItems Model Fetch Failure: %@", [error localizedDescription]);
    }
}

-(void)checkOrders {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.s_orderFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if(![self.s_orderFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",error);
    }
}


-(void)goToSearchTab {
    
    
    [_noStoresView removeFromSuperview];
    
    UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
    
    [tabBarController setSelectedIndex:1];
    
    
}



-(void)showNoStoresView:(Location *)location {
    
    self.noStoresView = [[[NSBundle mainBundle] loadNibNamed:@"NoStores" owner:self options:nil] lastObject];
    self.noStoresView.frame = self.tableView.frame;
    self.noStoresView.tag = kNoStoresTag;
    self.noStoresView.location.text = location.location_name;
    
    
    [self.noStoresView.changeButton addTarget:self action:@selector(goToSearchTab) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.view insertSubview:self.noStoresView belowSubview:self.navigationController.navigationBar];
}


@end

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


@interface StoresViewController ()<NSFetchedResultsControllerDelegate,UIViewControllerTransitioningDelegate>


@property (nonatomic, strong) NSFetchedResultsController *s_lineItemsFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *s_orderFetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

//@property (nonatomic, strong) RLMResults *stores;
@property (nonatomic, strong) NSArray *array_stores;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation StoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    StoreListRequestModel *requestModel = [StoreListRequestModel new];
    requestModel.location = @"19.012156,72.832355";
    
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
        
        [self.tableView reloadData];
        [self hideHUD];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        
        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
    }];
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
    self.hud.color = self.tableView.tintColor;
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


@end

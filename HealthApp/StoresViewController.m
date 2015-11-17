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
#import "TaxonsViewController.h"
#import "StoreTaxonsViewController.h"
#import "User.h"
#import "LogSignViewController.h"

@interface StoresViewController ()

//@property (nonatomic, strong) RLMResults *stores;
@property (nonatomic, strong) NSArray *array_stores;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation StoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    StoreListRequestModel *requestModel = [StoreListRequestModel new];
    requestModel.location = @"19.012156,72.832355";
    
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
    
    cell.storeNameLabel.text = store.storeName;
    cell.distance.text = [NSString stringWithFormat:@"%f km",store.storeDistance.floatValue];
    cell.localityAddress.text = [NSString stringWithFormat:@"%@, %@, %@", store.storeStreetAddress, store.storeState, store.storeCountry];
    
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
    
    if (user.access_token == nil) {
        LogSignViewController *logSignVC = (LogSignViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
        logSignVC.isPlacingOrder = NO;
        
        UINavigationController *logSignNav = [[UINavigationController alloc]initWithRootViewController:logSignVC];
        logSignNav.navigationBar.tintColor = self.tableView.tintColor;
        
        [self presentViewController:logSignNav animated:YES completion:nil];
    } else {
        
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

    
}

@end

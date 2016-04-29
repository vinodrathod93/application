//
//  FavouritesViewController.m
//  Neediator
//
//  Created by adverto on 01/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FavouritesViewController.h"
#import "FavouriteCategoryModel.h"
#import "FavouriteStoreModel.h"
#import "FavouriteStoreDetailModel.h"
#import "StoreTaxonsViewController.h"

@interface FavouritesViewController ()


@property (nonatomic, strong) NeediatorHUD *hud;
@property (nonatomic, strong) NSURLSessionDataTask *task;

@end

@implementation FavouritesViewController {
    NSArray *_favouriteCategories;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fav" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title         = @"My Favourites";
    
    
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    [NeediatorUtitity checkRunningTask:_task withCompletionHandler:^(BOOL success) {
        if (success) {
            [self requestFavourites];
        }
    }];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self hideHUD];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _favouriteCategories.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    FavouriteCategoryModel *category = _favouriteCategories[section];
    
    return category.stores.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"favouriteStoreCellIdentifier" forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"favouriteStoreCellIdentifier"];
    }
    
    FavouriteCategoryModel *category = _favouriteCategories[indexPath.section];
    FavouriteStoreDetailModel *detailModel = category.stores[indexPath.row];
    FavouriteStoreModel *store = detailModel.listing_stores[0];
    
    cell.textLabel.text = store.store_name.capitalizedString;
    cell.detailTextLabel.text = store.city.capitalizedString;
    
    cell.textLabel.font = [NeediatorUtitity mediumFontWithSize:17.f];
    cell.detailTextLabel.font = [NeediatorUtitity regularFontWithSize:14.f];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.f;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    FavouriteCategoryModel *category = _favouriteCategories[section];
    
    return category.category.capitalizedString;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FavouriteCategoryModel *category = _favouriteCategories[indexPath.section];
    FavouriteStoreDetailModel *detailModel = category.stores[indexPath.row];
    FavouriteStoreModel *model = detailModel.listing_stores[0];
    
    StoreTaxonsViewController *storeTaxonsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"storeTaxonsVC"];
    storeTaxonsVC.title = [model.store_name capitalizedString];
    storeTaxonsVC.cat_id = category.cat_id.stringValue;
    storeTaxonsVC.store_id = model.store_id;
    storeTaxonsVC.storeImages = model.images;
    storeTaxonsVC.storePhoneNumbers = model.phone_numbers;
#warning remove this static distance and show the calculated distance.
    storeTaxonsVC.storeDistance = @"2 KM";
    storeTaxonsVC.ratings   = model.ratings;
    storeTaxonsVC.reviewsCount =model.reviews_count;
    storeTaxonsVC.likeUnlikeArray = model.likeDislikes;
    storeTaxonsVC.isFavourite   = model.isFavourite.boolValue;
    storeTaxonsVC.isLikedStore  = model.isLike.boolValue;
    storeTaxonsVC.isDislikedStore = model.isDislike.boolValue;
    
    
    
    storeTaxonsVC.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:storeTaxonsVC animated:YES];
    
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FavouriteCategoryModel *category = _favouriteCategories[indexPath.section];
    FavouriteStoreDetailModel *detailModel = category.stores[indexPath.row];
    
    [[NAPIManager sharedManager] deleteFavouriteStore:detailModel.favouriteID.stringValue WithSuccess:^(BOOL success) {
        if (success) {
            // reload data
            
            [self requestFavourites];
            
        }
    } failure:^(NSError *error) {
        [NeediatorUtitity alertWithTitle:@"Error" andMessage:error.localizedDescription onController:self];
    }];
    
}



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


-(void)requestFavourites {
    [self showHUD];
    _task = [[NAPIManager sharedManager] getMyFavouritesListingWithSuccess:^(FavouritesResponseModel *response) {
        _favouriteCategories = response.favouriteCategories;
        
        [self hideHUD];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        [NeediatorUtitity alertWithTitle:@"Error" andMessage:error.localizedDescription onController:self];
    }];
}

@end

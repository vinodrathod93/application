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
#import "StoreTaxonsViewController.h"

@interface FavouritesViewController ()


@property (nonatomic, strong) NeediatorHUD *hud;

@end

@implementation FavouritesViewController {
    NSArray *_favouriteCategories;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title         = @"My Favourites";
    
    
    [self showHUD];
    [[NAPIManager sharedManager] getMyFavouritesListingWithSuccess:^(FavouritesResponseModel *response) {
        _favouriteCategories = response.favouriteCategories;
        
        [self hideHUD];
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        [NeediatorUtitity alertWithTitle:@"Error" andMessage:error.localizedDescription onController:self];
    }];
    
    
    
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
    FavouriteStoreModel *store = category.stores[indexPath.row];
    
    
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
    FavouriteStoreModel *model = category.stores[indexPath.row];
    
    StoreTaxonsViewController *storeTaxonsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"storeTaxonsVC"];
    storeTaxonsVC.title = [model.store_name capitalizedString];
    storeTaxonsVC.cat_id = category.cat_id.stringValue;
    storeTaxonsVC.store_id = model.store_id.stringValue;
    storeTaxonsVC.storeImages = @[@{ @"image_url" : model.store_image_url }];
    storeTaxonsVC.storePhoneNumbers = @[model.storePhoneNumber];
    storeTaxonsVC.storeDistance = @"? KM";
    storeTaxonsVC.ratings   = model.ratings.stringValue;
    storeTaxonsVC.reviewsCount = @"?";
    storeTaxonsVC.likeUnlikeArray = @[];
    storeTaxonsVC.isFavourite   = YES;
    storeTaxonsVC.isLikedStore  = YES;
    storeTaxonsVC.isDislikedStore = NO;
    
    
    
    storeTaxonsVC.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:storeTaxonsVC animated:YES];
    
    
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


@end

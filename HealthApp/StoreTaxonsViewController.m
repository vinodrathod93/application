//
//  StoreTaxonsViewController.m
//  Chemist Plus
//
//  Created by adverto on 16/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "StoreTaxonsViewController.h"
#import "APIManager.h"
#import <MBProgressHUD.h>
#import "ProductsViewController.h"
#import "StoreRealm.h"
#import "User.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "TaxonHeaderView.h"
#import "UploadPrescriptionViewController.h"
#import "SearchResultsTableViewController.h"

@interface StoreTaxonsViewController ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSMutableArray *taxonomies;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) TaxonHeaderView *taxonHeaderView;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *searchResults;

@end

@implementation StoreTaxonsViewController {
    BOOL _isExpanded;
    NSMutableArray *_dataArray;
    NSURLSessionDataTask *_task;
    NSURLSessionDataTask *_searchTask;
    NSInteger _footerHeight;
    UIActivityIndicatorView *_search_activityIndicator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    
    
//    self.bannerImages = @[@"http://g-ecx.images-amazon.com/images/G/31/img15/video-games/Gateway/new-year._UX1500_SX1500_CB285786565_.jpg", @"http://g-ecx.images-amazon.com/images/G/31/img15/Shoes/December/4._UX1500_SX1500_CB286226002_.jpg", @"http://g-ecx.images-amazon.com/images/G/31/img15/softlines/apparel/201512/GW/New-GW-Hero-1._UX1500_SX1500_CB301105718_.jpg",@"http://img5a.flixcart.com/www/promos/new/20151229_193348_730x300_image-730-300-8.jpg",@"http://img5a.flixcart.com/www/promos/new/20151228_231438_730x300_image-730-300-15.jpg"];
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _footerHeight = 100;
    self.taxonomies = [[NSMutableArray alloc] init];
    
    [self requestTaxons];
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_task cancel];
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _taxonHeaderView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(_taxonHeaderView.scrollView.frame) * self.bannerImages.count, CGRectGetHeight(_taxonHeaderView.scrollView.frame));
}


-(UIView *)layoutBannerHeaderView {
    _taxonHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"TaxonHeaderView" owner:self options:nil] lastObject];
    
    CGRect frame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(0, 0, self.view.frame.size.width, kTaxonHeaderViewHeight_Pad + 10);
    }
    else
        frame = CGRectMake(0, 0, self.view.frame.size.width, kTaxonHeaderViewHeight_Phone + 10);
    
    _taxonHeaderView.frame = frame;
    [_taxonHeaderView layoutIfNeeded];
    
    
    _taxonHeaderView.scrollView.delegate = self;
    
    CGRect scrollViewFrame = _taxonHeaderView.scrollView.frame;
    CGRect currentFrame = self.view.frame;
    
    scrollViewFrame.size.width = currentFrame.size.width;
    _taxonHeaderView.scrollView.frame = scrollViewFrame;
    
    
    [self setupScrollViewImages];
    
    
    _taxonHeaderView.pageControl.numberOfPages = self.bannerImages.count;
    
    
    
    [_taxonHeaderView.uploadPrescriptionButton addTarget:self action:@selector(popUploadPrescriptionVC) forControlEvents:UIControlEventTouchUpInside];
    [_taxonHeaderView.quickOrderButton addTarget:self action:@selector(popQuickOrderSearchVC) forControlEvents:UIControlEventTouchUpInside];
    
    return _taxonHeaderView;
}



-(void)popUploadPrescriptionVC {
    [NeediatorUtitity save:self.store_id forKey:kSAVE_STORE_ID];
    [NeediatorUtitity save:self.cat_id forKey:kSAVE_CAT_ID];
    
    
    UploadPrescriptionViewController *uploadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"uploadPrescriptionVC"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:uploadVC];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}



-(void)popQuickOrderSearchVC {
    
    SearchResultsTableViewController *searchResultsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchResultsVC"];
//    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchResultsVC];
    
    
    
    
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsVC];
    
    [UIView transitionWithView:self.searchController.view duration:0.33 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.searchController.view.backgroundColor = [UIColor whiteColor];
    } completion:^(BOOL finished) {
        NSLog(@"Finished Transition");
    }];
    
    
    self.searchController.searchBar.placeholder = @"Search Product for Quick Order";
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    _search_activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _search_activityIndicator.center = CGPointMake(self.searchController.view.center.x, self.searchController.view.center.y - 100);
    
    
    [self.searchController.view addSubview:_search_activityIndicator];
    
    [self.navigationController presentViewController:self.searchController animated:YES completion:nil];
}



#pragma mark - UISearchControllerDelegate & SearchResultsDelegate



-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = self.searchController.searchBar.text;
    
    NSLog(@"SEarch Results %@", searchString);
    
    NSDictionary *parameter = @{
                                @"cat_id" : self.cat_id,
                                @"store_id" : self.store_id,
                                @"search"   : searchString
                                };
    
    
    [_search_activityIndicator startAnimating];
    
    _searchTask = [[NAPIManager sharedManager] getSearchedProductsWithData:parameter success:^(NSArray *products) {
        
        // search products.
        self.searchResults = [products mutableCopy];
        
        if (self.searchController.searchResultsController) {
            
            SearchResultsTableViewController *vc = (SearchResultsTableViewController *)self.searchController.searchResultsController;
            
            [_search_activityIndicator stopAnimating];
            
            // Update searchResults
            vc.searchResults = self.searchResults;
            
            if (self.searchResults.count == 0) {
                
                NSDictionary *noProduct = @{
                                            @"productname" : @"No Products",
                                            @"brandname"    : @""
                                            };
                [self.searchResults addObject:noProduct];
            }
            // And reload the tableView with the new data
            [vc.tableView reloadData];
        }
        
        
    } failure:^(NSError *error) {
        
        [_search_activityIndicator stopAnimating];
        NSLog(@"Error: %@", [error localizedDescription]);
    }];
    
}



//-(void)willDismissSearchController:(UISearchController *)searchController {
//    self.tabBarController.tabBar.hidden = NO;
//}

//-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    self.tabBarController.tabBar.hidden = NO;
//}


#pragma mark - Scroll view Methods

-(void)setupScrollViewImages {
    
    [self.bannerImages enumerateObjectsUsingBlock:^(NSDictionary *imageData, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_taxonHeaderView.scrollView.frame) * idx, 0, CGRectGetWidth(_taxonHeaderView.scrollView.frame), CGRectGetHeight(_taxonHeaderView.scrollView.frame))];
        imageView.tag = idx;
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *image   = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageData[@"image_url"]]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CIImage *newImage = [[CIImage alloc] initWithImage:image];
                CIContext *context = [CIContext contextWithOptions:nil];
                CGImageRef reference = [context createCGImage:newImage fromRect:newImage.extent];
                
                imageView.image  = [UIImage imageWithCGImage:reference scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            });
        });
        
        [_taxonHeaderView.scrollView addSubview:imageView];
    }];
    
    
}

#pragma mark - Scroll view Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _taxonHeaderView.scrollView) {
        NSInteger index = _taxonHeaderView.scrollView.contentOffset.x / CGRectGetWidth(_taxonHeaderView.scrollView.frame);
        NSLog(@"%ld",(long)index);
        
        _taxonHeaderView.pageControl.currentPage = index;
    }
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%lu", (unsigned long)self.taxonomies.count);
    
    return [self.taxonomies count];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"storeTaxonomyCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    
    
    cell.textLabel.font   = [UIFont fontWithName:@"AvenirNext-Regular" size:15.f];
    cell.indentationWidth = 20;

    
    
    if ([self.taxonomies[indexPath.row] isKindOfClass:[TaxonomyModel class]]) {
        TaxonomyModel *taxonomy = self.taxonomies[indexPath.row];
        
        cell.textLabel.text = taxonomy.taxonomyName;
        cell.indentationLevel = 0;
        
        if (taxonomy.taxons.count > 0) {
            
            taxonomy.canBeExpanded = YES;
            cell.accessoryView  = [self viewForDisclosureForState:_isExpanded];
            
        }
        else {
            
            cell.accessoryView  = nil;
        }
        
    }
    else if ([self.taxonomies[indexPath.row] isKindOfClass:[TaxonModel class]]) {
        TaxonModel *taxon = self.taxonomies[indexPath.row];
        
        cell.textLabel.text = taxon.taxonName;
        cell.indentationLevel = 1;
        
        if (taxon.canBeExpanded) {
            cell.accessoryView = [self viewForDisclosureForState:_isExpanded];
        }
        else
            cell.accessoryView = nil;
        
    }
    
    
    
    
    
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Row: %ld,selected", (long)indexPath.row);
    
    id model = self.taxonomies[indexPath.row];
    
    
    if ([model isKindOfClass:[TaxonomyModel class]]) {
        
        TaxonomyModel *taxonomy = (TaxonomyModel *)model;
        
        UITableViewCell *selected_cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (taxonomy.canBeExpanded) {
            if (taxonomy.isExpanded) {
                [self collapseCellsFromIndexOf:taxonomy indexPath:indexPath tableView:tableView];
                selected_cell.accessoryView = [self viewForDisclosureForState:NO];
            }
            else {
                [self expandCellsFromIndexOf:taxonomy indexPath:indexPath tableView:tableView];
                selected_cell.accessoryView = [self viewForDisclosureForState:YES];
            }
        }
    }
    else {
        NSLog(@"Tapped Heyy");
        
        
//        
//        RLMRealm *realm = [RLMRealm defaultRealm];
//        StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
        
        
        TaxonModel *taxon = (TaxonModel *)model;
        
        NSLog(@"Taxon ID %d", taxon.taxonID.intValue);
        
        ProductsViewController *productsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
        productsVC.navigationTitleString = taxon.taxonName;
        productsVC.taxonID = taxon.taxonID.stringValue;
        productsVC.storeID = self.store_id;
        productsVC.taxonomyID = taxon.taxonomyID.stringValue;
        productsVC.categoryID = self.cat_id;
        
//        productsVC.taxonProductsURL = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/getProductStores2?taxon_id=%@&store_id=%@&taxonomies_id=%@&cat_id=%@&search=&PageNo=1", taxon.taxonID.stringValue, self.store_id, taxon.taxonomyID.stringValue, self.cat_id];
        [self.navigationController pushViewController:productsVC animated:YES];
        
        
        
    }
    
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    return [self layoutBannerHeaderView];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (_footerHeight > 0) {
        return [self getHudView];
    }
    else
        return nil;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return kTaxonHeaderViewHeight_Pad + 10;
    }
    else
        return kTaxonHeaderViewHeight_Phone + 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return _footerHeight;
}


-(void)collapseCellsFromIndexOf:(TaxonomyModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    NSInteger collapseCount = [self numberOfCellsToBeCollapsed:model];
    NSRange collapseRange = NSMakeRange(indexPath.row + 1, collapseCount);
    
    
    [self.taxonomies removeObjectsInRange:collapseRange];
    model.isExpanded = NO;
    
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for (int i = 0; i<collapseRange.length; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:collapseRange.location+i inSection:0]];
    }
    // Animate and delete
    [tableView deleteRowsAtIndexPaths:indexPaths
                     withRowAnimation:UITableViewRowAnimationTop];
    
}



-(void)expandCellsFromIndexOf:(TaxonomyModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    if (model.taxons.count > 0) {
        model.isExpanded = YES;
        
        int i=0;
        
        for (TaxonModel *taxonModel in model.taxons) {
            [self.taxonomies insertObject:taxonModel atIndex:indexPath.row + i + 1];
            i++;
        }
        
        NSRange expandedRange = NSMakeRange(indexPath.row, i);
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i=0; i< expandedRange.length; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:expandedRange.location + i + 1 inSection:0]];
        }
        
        [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    }
}









#pragma mark - Private Methods



-(void)hideHUD {
    [self.hud hide:YES];
    
    _footerHeight = 0;
    
    [self tableView:self.tableView viewForFooterInSection:0];
    
    [self.tableView reloadData];
}


-(UIView *)getHudView {
    
    UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, _footerHeight)];
    
    self.hud = [MBProgressHUD showHUDAddedTo:hudView animated:YES];
    self.hud.color          = [UIColor clearColor];
    self.hud.activityIndicatorColor = [UIColor blackColor];
    
    
    return hudView;
}


-(UIView*) viewForDisclosureForState:(BOOL) isExpanded
{
    NSString *imageName;
    if(isExpanded)
    {
        imageName = @"Expand Arrow";
    }
    else
    {
        imageName = @"Collapse Arrow";
    }
    UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    [imgView setFrame:CGRectMake(0, 6, 24, 24)];
    [myView addSubview:imgView];
    return myView;
}


-(NSInteger) numberOfCellsToBeCollapsed:(TaxonomyModel *) model
{
    NSInteger total = 0;
    
    if(model.isExpanded)
    {
        // Set the expanded status to no
        model.isExpanded = NO;
        NSArray *child = model.taxons;
        
        total = child.count;
        
    }
    return total;
}







#pragma mark  - Network 


-(void)requestTaxons {
    NSDictionary *parameter = @{
                                
                                @"catId" : self.cat_id,
                                @"storeid" : self.store_id
                                
                                };
    
    _task = [[NAPIManager sharedManager] getTaxonomiesWithRequest:parameter WithSuccess:^(TaxonomyListResponseModel *responseModel) {
        [self.taxonomies addObjectsFromArray:responseModel.taxonomies];
        
        [self.tableView reloadData];
        [self hideHUD];
    } failure:^(NSError *error) {
        [self hideHUD];
        
        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
        
    }];
}


-(void)searchProduct:(NSString *)keyword {
    
    
    
}




#pragma mark - Not needed 

/*
- (void)tableView:(UITableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *taxons = [self.taxonomies[indexPath.section] taxons];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    
    if (taxons.count != 0) {
        TaxonModel *taxon = taxons[indexPath.subRow - 1];
        
        NSLog(@"Taxon ID %d", taxon.taxonId.intValue);
        
        ProductsViewController *productsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
        productsVC.navigationTitleString = taxon.taxonName;
        productsVC.taxonProductsURL = [NSString stringWithFormat:@"http://%@/api/taxons/%d/products?token=%@", store.storeUrl, taxon.taxonId.intValue, kStoreTokenKey];
        [self.navigationController pushViewController:productsVC animated:YES];
    }
    
}
 
 
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
 {
 static NSString *CellIdentifier = @"UITableViewCell";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (!cell)
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 
 NSArray *taxons = [self.taxonomies[indexPath.section] taxons];
 
 if (taxons.count != 0) {
 
 TaxonModel *taxon = taxons[indexPath.subRow - 1];
 cell.textLabel.text = taxon.taxonName;
 }
 
 cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
 
 return cell;
 }
 
 
 
 - (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
 {
 TaxonomyModel *taxonomy = self.taxonomies[indexPath.section];
 NSLog(@"%@",taxonomy);
 
 return taxonomy.taxons.count;
 }
 
 - (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
 {
 
 return NO;
 }
 
 */
@end

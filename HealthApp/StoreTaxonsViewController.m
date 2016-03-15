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
#import "StoreTaxonHeaderViewCell.h"
#import "UploadPrescriptionViewController.h"
#import "SearchResultsTableViewController.h"
#import "StoreReviewsView.h"
#import "StoreOptionsView.h"
#import "UploadPrescriptionCellView.h"



#define kImageViewSection 0;
#define kUploadPrescriptionSection 1
#define kTaxonTaxonomySection 2;

typedef NS_ENUM(uint16_t, sections) {
    ImageViewSection = 0,
    UploadPrescriptionSetion,
    TaxonTaxonomySection,
};

@interface StoreTaxonsViewController ()<UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong) NSMutableArray *taxonomies;
@property (nonatomic, strong) MBProgressHUD *hud;

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
    NSArray *_offersArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [NeediatorUtitity defaultColor];
    
    
    _footerHeight = 100;
    self.taxonomies = [[NSMutableArray alloc] init];
    
    
    [self requestTaxons];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_task suspend];
    [self hideHUD];
   
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    StoreTaxonHeaderViewCell *cell = (StoreTaxonHeaderViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    cell.scrollView.contentSize = CGSizeMake(CGRectGetWidth(cell.scrollView.frame) * self.bannerImages.count, CGRectGetHeight(cell.scrollView.frame));
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
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsVC];
    
    [UIView transitionWithView:self.searchController.view duration:0.53 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{
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
    
    [self presentViewController:self.searchController animated:YES completion:nil];
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






#pragma mark - Scroll view Methods

-(void)setupScrollViewImages:(StoreTaxonHeaderViewCell *)cell {
    
    NSLog(@"setupScrollViewImages");
    
    [self.bannerImages enumerateObjectsUsingBlock:^(NSDictionary *imageData, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.scrollView.frame) * idx, 0, CGRectGetWidth(cell.scrollView.frame), CGRectGetHeight(cell.scrollView.frame))];
        imageView.tag = idx;
        
        NSURL *url  =  [NSURL URLWithString:imageData[@"image_url"]];
        NSLog(@"%@",imageData[@"image_url"]);
        
        
         NSLog(@"Start Manager");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                NSLog(@"Image %ld", (long)receivedSize);
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CIImage *newImage = [[CIImage alloc] initWithImage:image];
                        CIContext *context = [CIContext contextWithOptions:nil];
                        CGImageRef reference = [context createCGImage:newImage fromRect:newImage.extent];
                        
                        imageView.image  = [UIImage imageWithCGImage:reference scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
                    });
                
                    
                }
            }];
        });
        
        
        [cell.scrollView addSubview:imageView];
    }];
    
    
}

#pragma mark - Scroll view Delegate

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    if (scrollView == _taxonHeaderView.scrollView) {
//        NSInteger index = _taxonHeaderView.scrollView.contentOffset.x / CGRectGetWidth(_taxonHeaderView.scrollView.frame);
//        NSLog(@"%ld",(long)index);
//        
//        _taxonHeaderView.pageControl.currentPage = index;
//    }
//    
//}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    StoreTaxonHeaderViewCell *cell = (StoreTaxonHeaderViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (scrollView == cell.scrollView) {
        uint page = scrollView.contentOffset.x / CGRectGetWidth(scrollView.frame);
        
        [cell.pageControl setCurrentPage:page];
    }
    
}

#pragma mark
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"numberOfRowsInSection");
    
    if (section == ImageViewSection) {
        return 1;
    }
    else if (section == TaxonTaxonomySection)
        return [self.taxonomies count];
    else
        return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"cellForRowAtIndexPath");
    static NSString *CellIdentifier = @"storeTaxonomyCell";
    
    
    if (indexPath.section == ImageViewSection) {
        // Taxon Header
        StoreTaxonHeaderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"storeTaxonInfoCell"];
        
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"TaxonHeaderView" owner:self options:nil] firstObject];
            
            
            CGRect frame;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                frame = CGRectMake(0, 0, self.view.frame.size.width, kTaxonHeaderViewHeight_Pad + 10);
            }
            else
                frame = CGRectMake(0, 0, self.view.frame.size.width, kTaxonHeaderViewHeight_Phone + 10);
            
            cell.frame = frame;
            [cell layoutIfNeeded];
            
            
            cell.scrollView.delegate = self;
            
            CGRect scrollViewFrame = cell.scrollView.frame;
            CGRect currentFrame = self.view.frame;
            
            scrollViewFrame.size.width = currentFrame.size.width;
            cell.scrollView.frame = scrollViewFrame;
            
            
            [self setupScrollViewImages:cell];
            
            
            /* Upload Prs & Quick Order */
            [cell.uploadPrescriptionButton addTarget:self action:@selector(popUploadPrescriptionVC) forControlEvents:UIControlEventTouchUpInside];
            [cell.quickOrderButton addTarget:self action:@selector(popQuickOrderSearchVC) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
            
            
        
            
            
            cell.pageControl.numberOfPages = self.bannerImages.count;
            
            
            /* Offers View */
            [_offersArray enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull offer, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSString *offerURLString = [offer valueForKey:@"ImageUrl"];
                [cell.offersImageView sd_setImageWithURL:[NSURL URLWithString:offerURLString]];
            }];
        
        
        
            
        
        
        
        return cell;
        
    }
    else if (indexPath.section == TaxonTaxonomySection) {
        
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
    else
        return nil;
    
    
    
    
    
    
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == ImageViewSection) {
        return 200.f;
    }
    else if (indexPath.section == TaxonTaxonomySection)
        return 50.0f;
    else
        return 0.0f;
}



#pragma mark - Header View

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
     UIView *header = [[UIView alloc] initWithFrame:CGRectZero];
                      
    if (section == ImageViewSection) {
       
        /* Load Ratings, Like - Dislike View */
        
        
        StoreReviewsView *storeReviewsView = [[[NSBundle mainBundle] loadNibNamed:@"StoreReviewsView" owner:self options:nil] lastObject];
        storeReviewsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 35);
        
        storeReviewsView.ratingView.rating              = 3.5f;
        
        
        return storeReviewsView;
        
    }
    else if (section == TaxonTaxonomySection) {
        
        
        
        StoreOptionsView *storeOptionView = [[[NSBundle mainBundle] loadNibNamed:@"StoreOptionsView" owner:self options:nil] lastObject];
        storeOptionView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 65);
//        storeOptionView.backgroundColor = [UIColor lightGrayColor];
        
        return storeOptionView;
        
    }
    else if (section == 1) {
        UploadPrescriptionCellView *cell =  [[[NSBundle mainBundle] loadNibNamed:@"UploadPrescriptionCellView" owner:self options:nil] lastObject];
        
        return cell;
    }
    
    return header;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == ImageViewSection) {
        return 35.f;
    }
    else if (section == TaxonTaxonomySection)
        return 65.f;
    else
        return 80;
}







#pragma mark - Footer View

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == TaxonTaxonomySection) {
        if (_footerHeight > 0) {
            return [self getHudView];
        }
        else
            return nil;
    }
//    else if (section == 1) {
//        
//        UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
//        footer.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40);
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, CGRectGetWidth(self.view.frame), 30)];
//        label.backgroundColor = [UIColor clearColor];
//        label.text = @"Browse by Categories";
//        label.textAlignment = NSTextAlignmentCenter;
//        label.font = [NeediatorUtitity mediumFontWithSize:17];
//        
//        [footer addSubview:label];
//        
//        
//        return footer;
//    }
    else
        return nil;
}




-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == TaxonTaxonomySection) {
        return _footerHeight;
    }
//    else if (section == 1)
//        return 40.f;
    else
        return 0;
    
}


#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath");
    NSLog(@"Row: %ld,selected", (long)indexPath.row);
    
    if (indexPath.section == TaxonTaxonomySection) {
        
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
    
    
    
    
}

-(void)collapseCellsFromIndexOf:(TaxonomyModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    NSLog(@"collapseCellsFromIndexOf");
    
    if (indexPath.section == TaxonTaxonomySection) {
        
        NSInteger collapseCount = [self numberOfCellsToBeCollapsed:model];
        NSRange collapseRange = NSMakeRange(indexPath.row + 1, collapseCount);
        
        
        [self.taxonomies removeObjectsInRange:collapseRange];
        model.isExpanded = NO;
        
        NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
        for (int i = 0; i<collapseRange.length; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:collapseRange.location+i inSection:indexPath.section]];
        }
        // Animate and delete
        [tableView deleteRowsAtIndexPaths:indexPaths
                         withRowAnimation:UITableViewRowAnimationTop];
    }
    
    
}



-(void)expandCellsFromIndexOf:(TaxonomyModel *)model indexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView {
    
    NSLog(@"expandCellsFromIndexOf");
    
    if (indexPath.section == TaxonTaxonomySection) {
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
                [indexPaths addObject:[NSIndexPath indexPathForRow:expandedRange.location + i + 1 inSection:indexPath.section]];
            }
            
            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
            
            [tableView scrollToRowAtIndexPath:indexPaths[0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
    
    
}









#pragma mark
#pragma mark - Private Methods



-(void)hideHUD {
    [self.hud hide:YES];
    
    _footerHeight = 0;
    
    [self tableView:self.tableView viewForFooterInSection:1];
    
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
    
    NSLog(@"numberOfCellsToBeCollapsed");
    
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
    
    NSLog(@"requestTaxons");
    
    NSDictionary *parameter = @{
                                
                                @"catId" : self.cat_id,
                                @"storeid" : self.store_id
                                
                                };
    
    _task = [[NAPIManager sharedManager] getTaxonomiesWithRequest:parameter WithSuccess:^(TaxonomyListResponseModel *responseModel) {
        
        NSLog(@"Success");
        
        [self.taxonomies addObjectsFromArray:responseModel.taxonomies];
        
        _offersArray = responseModel.offers;
        
        [self.tableView reloadData];
        [self hideHUD];
        
    } failure:^(NSError *error) {
        
        NSLog(@"Failure");
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

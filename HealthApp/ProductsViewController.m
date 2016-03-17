//
//  ProductsViewController.m
//  Chemist Plus
//
//  Created by adverto on 14/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "ProductsViewController.h"
#import "ProductViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "DetailsProductViewController.h"
#import "DetailViewModel.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import <SVPullToRefresh/SVPullToRefresh.h>

#define kFIRST_PAGE 1
#define kPhoneTitleViewWidth 160
#define kPadTitleViewWidth 250

@interface ProductsViewController ()<UIViewControllerTransitioningDelegate,UISearchBarDelegate, UISearchControllerDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) DetailViewModel *viewModel;
@property (nonatomic, assign) BOOL show;
@property (nonatomic, strong) NSString *itemsCount;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *no_items;

@property (nonatomic, strong) NSString *currentPage;
@property (nonatomic, strong) NSString *nextPage;

// version api 1
@property (nonatomic, strong) NSString *pages;

@property (nonatomic, strong) NSMutableArray *filteredProducts;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic)        float          searchBarBoundsY;


@end

@implementation ProductsViewController {
    int _page;
}

static NSString * const productsReuseIdentifier = @"productsCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sort" style:UIBarButtonItemStylePlain target:self action:@selector(displaySortingSheet)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAddedToCart) name:@"addedToCartNotification" object:nil];

    
    
    _page = 1;
    
    // Reachablity code
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NetworkStatus netStatus = [appDelegate.googleReach currentReachabilityStatus];
    
    if (netStatus != NotReachable) {
        [self loadProductsPage];
    }
    else
        [self displayNoConnection];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    
    // Infinite Products block
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"loadingCell"];
    
    
    __weak typeof(self) weakSelf = self;
    [self.collectionView addInfiniteScrollingWithActionHandler:^{
        [weakSelf loadProductsPage];
    }];
    
}



-(void)displaySortingSheet {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Sort" message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *name = [UIAlertAction actionWithTitle:@"Name" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Sort by name");
    }];
    UIAlertAction *distance = [UIAlertAction actionWithTitle:@"Distance" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Sort by distance");
    }];
    UIAlertAction *rating = [UIAlertAction actionWithTitle:@"Rating" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Sort by ratings");
    }];
    UIAlertAction *likes = [UIAlertAction actionWithTitle:@"Likes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Sort by like");
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel");
    }];
    
    [controller addAction:name];
    [controller addAction:distance];
    [controller addAction:rating];
    [controller addAction:likes];
    [controller addAction:cancel];
    
    [self presentViewController:controller animated:YES completion:nil];
}


-(void)displaySearchBar {
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchBar.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    self.filteredProducts = [NSMutableArray array];
    
    [self presentViewController:self.searchController animated:YES completion:nil];
    
    [self.collectionView reloadData];
    
}

- (IBAction)searchBarButtonPressed:(id)sender {
    [self displaySearchBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [self.task suspend];
}

- (void)viewDidAppear:(BOOL)animated
{
    
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    return (self.searchController.active) ? self.filteredProducts.count : [self.viewModel numberOfProducts];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"cellForItemAtIndexPath");
    
    ProductViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:productsReuseIdentifier forIndexPath:indexPath];
    
    NSString *string = [self.viewModel infiniteImageAtIndex:indexPath.item];
    
    NSURL *url = [NSURL URLWithString:string];
    [cell.productImageView sd_setImageWithURL:url placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            NSLog(@"%@", [error localizedDescription]);
            
            [cell.productImageView setImage:[UIImage imageNamed:@"no_image"]];
        }
    }];
    
    cell.productImageView.clipsToBounds = YES;
    cell.productImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    cell.productLabel.text = [self.viewModel nameAtIndex:indexPath.item];
    cell.productPrice.text = [self.viewModel priceAtIndex:indexPath.item];
    
    if ([self.viewModel isProductOutOfStock:indexPath.item]) {
        
        [cell.soldOutView setImage:[UIImage imageNamed:@"soldout"]];
        
        
    }
    
    return cell;
}




- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger width;
    NSUInteger height;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = self.view.frame.size.width / 4;
        height = (self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height) / 3.5f;
        
        return CGSizeMake(width-1, height-1);
    } else {
        
        width = self.view.frame.size.width / 2;
        height = (self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height) / 2;
        
        return CGSizeMake(width-1, width-1);
    }
}


//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    DetailsProductViewController *details = [self.storyboard instantiateViewControllerWithIdentifier:@"productDetailsVC"];
//    details.detail = self.viewModel.viewModelProducts[indexPath.item];
//    
////    ProductDetailsViewController *details = [self.storyboard instantiateViewControllerWithIdentifier:@"productDetailsViewController"];
////    details.detail = self.viewModel.viewModelProducts[indexPath.item];
//    
//    [self setTabBarVisible:[self tabBarIsVisible] animated:YES completion:^(BOOL finished) {
//        NSLog(@"Finished");
//    }];
//    
//    [self.navigationController pushViewController:details animated:YES];
//}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailsProductViewController *detailsVC = segue.destinationViewController;
    
    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
    detailsVC.detail = self.viewModel.viewModelProducts[selectedIndexPath.row];
    detailsVC.title  = [self.navigationTitleString uppercaseString];
    
    [self setTabBarVisible:[self tabBarIsVisible] animated:YES completion:^(BOOL finished) {
        NSLog(@"Finished Pushed");
    }];
}





#pragma mark -  <UICollectionViewDelegateFlowLayout>
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
//                        layout:(UICollectionViewLayout*)collectionViewLayout
//        insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(self.searchController.searchBar.frame.size.height, 0, 0, 0);
//}


#pragma mark - Search Results Delegate


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    if (self.searchController.active) {
        
        [self.filteredProducts removeAllObjects];
        [self searchProducts:searchBar.text];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    [self loadProducts];
    
    self.currentPage = nil;

    _page = 1;
    
    [self loadProductsPage];
    
    NSLog(@"Load all products");
}




#pragma mark - Helper Methods

-(BOOL)tabBarIsVisible {
    return self.tabBarController.tabBar.frame.origin.y < CGRectGetMaxY(self.view.frame);
}


-(void)setTabBarVisible:(BOOL)visible animated:(BOOL)animated completion:(void (^)(BOOL))completion {
    NSLog(@"visible %hhd",visible);
    
    if ([self tabBarIsVisible] == visible) return;
    
    CGRect frame = self.tabBarController.tabBar.frame;
    CGFloat height = frame.size.height;
    CGFloat offsetY = (visible)? -height: height;
    
    CGFloat duration = (animated)? 0.3: 0.0;
    
    [UIView animateWithDuration:duration animations:^{
        self.tabBarController.tabBar.frame = CGRectOffset(frame, 0, offsetY);
    } completion:completion];
}





-(void)searchProducts:(NSString *)keyword {
    NSLog(@"searching products");
    NSURLSession *session = [NSURLSession sharedSession];
    NSString *url_string = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/getProductStores2?taxon_id=%@&store_id=%@&taxonomies_id=%@&cat_id=%@&PageNo=1&search=%@",self.taxonID, self.storeID, self.taxonomyID, self.categoryID, keyword];
    NSURL *url = [NSURL URLWithString:url_string];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    
    NSURLSessionDataTask *searchTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (data != nil) {
                NSError *jsonError;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                NSLog(@"%@",dictionary);
                
                if (jsonError != nil) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                }
                else if(![dictionary isEqual:nil])
                {
                    
                    self.filteredProducts = (NSMutableArray *)[DetailViewModel infiniteProductsFromJSON:dictionary];
                    self.viewModel = [[DetailViewModel alloc]initWithArray:self.filteredProducts];
                    
                    [self.hud hide:YES];
                    [self.collectionView reloadData];
                }
            }
            else
                [self.hud hide:YES];
            
            
        }];
    }];
    
    [searchTask resume];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.collectionView.tintColor;
}



//-(void)loadProductsPage:(int)page completion:(void(^)(void))completion {

-(void)loadProductsPage {
//    void(^finish)(void) = completion ?: ^{};
    
    __weak typeof(self) weakSelf = self;
    
    NSLog(@"loadProducts");
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    
    NSString *paginatingURLString = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/getProductStores2?taxon_id=%@&store_id=%@&taxonomies_id=%@&cat_id=%@&PageNo=%d&search=", self.taxonID, self.storeID, self.taxonomyID, self.categoryID, _page];
    
    NSURLRequest *spree_request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:paginatingURLString]];
    
    self.task = [session dataTaskWithRequest:spree_request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                NSError *jsonError;
                id dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                NSLog(@"%@",dictionary);
                
                if (jsonError != nil) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                    
//                    finish();
                    [weakSelf.collectionView.infiniteScrollingView stopAnimating];
                    
                }
                else if(![dictionary isEqual:nil])
                {
                    NSArray *array = [DetailViewModel infiniteProductsFromJSON:dictionary];
                    if (_page == 1) {
                        
                        self.viewModel = [[DetailViewModel alloc]initWithArray:array];
                        
                        self.pages = [self.viewModel getPagesCount:dictionary];
                        self.itemsCount = [self.viewModel getItemsCount:dictionary];
                        [self showCustomTitleViewWithCount:self.itemsCount];
                        
                        [self.hud hide:YES];
                        [self.collectionView reloadData];
                        
                    } else {
                        [self.collectionView performBatchUpdates:^{
                            int resultSize = @([self.viewModel numberOfProducts]).intValue;
                            [self.viewModel addProducts:array];
                            
                            NSMutableArray *arrayWithIndexPath = [NSMutableArray array];
                            
                            for (int i=resultSize; i < resultSize + array.count; i++) {
                                [arrayWithIndexPath addObject:[NSIndexPath indexPathForItem:i inSection:0]];
                            }
                            
                            [self.collectionView insertItemsAtIndexPaths:arrayWithIndexPath];
                            
                        } completion:^(BOOL finished) {
                            [weakSelf.collectionView.infiniteScrollingView stopAnimating];
                        }];
                        
                    }
                    
                    self.currentPage = [self.viewModel currentPage:dictionary];
                    self.nextPage = [NSString stringWithFormat:@"%d",[self.viewModel nextPage:dictionary]];
                    _page++;
                }
                
            }];
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hide:YES];
                [self displayConnectionFailed];
            });
        }
        
        
    }];
    
//    if (self.currentPage != nil && (self.currentPage.intValue == self.pages.intValue)) {
//        [weakSelf.collectionView.infiniteScrollingView stopAnimating];
//    } else {
//        [self.task resume];
//    }
    
    [self.task resume];
    
    if (_page == 1) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.color = self.collectionView.tintColor;
        self.hud.labelText = @"Loading items...";
//        self.hud.dimBackground = YES;
    }
    
}





-(void)showCustomTitleViewWithCount:(NSString *)countText {
    
    NSLog(@"Width %f", CGRectGetWidth(self.navigationItem.titleView.frame));
    
    float width;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        width = kPadTitleViewWidth;
    } else {
        width = kPhoneTitleViewWidth;
    }
    
    UILabel *taxon = [[UILabel alloc] initWithFrame:CGRectMake(0, 2, width, 22)];
    taxon.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17.0f];
    taxon.textColor = [UIColor blackColor];
    taxon.text     = self.navigationTitleString;
    taxon.textAlignment = NSTextAlignmentCenter;
    
    UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(0, 22, width, 24)];
    count.font = [UIFont fontWithName:@"AvenirNext-Regular" size:13.0f];
    count.text = [NSString stringWithFormat:@"( %@ Products )",countText];
    count.textColor = [UIColor blackColor];
    count.textAlignment = NSTextAlignmentCenter;
    
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    [titleView addSubview:taxon];
    [titleView addSubview:count];
    
    
    self.navigationItem.titleView = titleView;
    

    
}




-(void)showAddedToCart {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeCustomView;
        hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cart"]];
        hud.labelText = @"Added to Cart";
        hud.tintColor = self.collectionView.tintColor;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
    });
}





-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    
    if(netStatus != NotReachable) {
        NSLog(@"Reachable");
    } else {
        [self displayNoConnection];
    }
}

-(void)displayNoConnection {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
}

-(void)displayConnectionFailed {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [alert show];
    
    
}


/*
#pragma mark - observer
- (void)addObservers{
    [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)removeObservers{
    [self.collectionView removeObserver:self forKeyPath:@"contentOffset" context:Nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UICollectionView *)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentOffset"] && object == self.collectionView ) {
        if (self.searchController.isActive) {
            NSLog(@"Bounds %f, offset %f minus %f and equals to %f",self.searchBarBoundsY, (-1* object.contentOffset.y), self.searchBarBoundsY, self.searchBarBoundsY + ((-1* object.contentOffset.y)-self.searchBarBoundsY));
            
            self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x,
                                                               0,
                                                               self.searchController.searchBar.frame.size.width,
                                                               self.searchController.searchBar.frame.size.height);
        } else {
            NSLog(@"Bounds %f, offset %f minus %f and equals to %f",self.searchBarBoundsY, (-1* object.contentOffset.y), self.searchBarBoundsY, self.searchBarBoundsY + ((-1* object.contentOffset.y)-self.searchBarBoundsY));
            
            self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x,
                                                               self.searchBarBoundsY + ((-1* object.contentOffset.y)-self.searchBarBoundsY),
                                                               self.searchController.searchBar.frame.size.width,
                                                               self.searchController.searchBar.frame.size.height);
        }
        
    }
}


*/




































#pragma Not Needed 

/*
-(UIView *)titleViewWithCount:(NSString *)count {
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat width = 0.95 * self.navigationItem.titleView.frame.size.width;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, navBarHeight)];
    
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, width-70, 20)];
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15.0f];
    titleLabel.text = self.navigationTitleString;
    
    UILabel *countLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, width-70, 20)];
    countLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:12.0f];
    countLabel.text = [NSString stringWithFormat:@"%@ Products",count];
    
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [countLabel setTextAlignment:NSTextAlignmentCenter];
    
    [containerView addSubview:titleLabel];
    [containerView addSubview:countLabel];
    
    return containerView;
}


-(UIView *)customTitleViewWithCount:(NSString *)count {
    
    CGFloat titleHeight = self.navigationController.navigationBar.frame.size.height;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15.0f];
    
    CGFloat desiredWidth = [self.navigationTitleString boundingRectWithSize:CGSizeMake([[UIScreen mainScreen] applicationFrame].size.width, titleLabel.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{
                                                                                                                                                                                                                                     NSFontAttributeName:titleLabel.font
                                                                                                                                                                                                                                     }context:nil].size.width;
    CGRect frame;
    
    frame = titleLabel.frame;
    frame.size.height = titleHeight;
    frame.size.width = desiredWidth;
    titleLabel.frame = frame;
    
    frame = containerView.frame;
    frame.size.height = titleHeight;
    frame.size.width = desiredWidth;
    containerView.frame = frame;
    
    titleLabel.numberOfLines = 1;
    titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    containerView.autoresizesSubviews = YES;
    titleLabel.autoresizingMask = containerView.autoresizingMask;
    
    titleLabel.text = self.navigationTitleString;
    
    [containerView addSubview:titleLabel];
    
    return containerView;
}
*/

/*
 -(void)scrollViewDidScroll:(UIScrollView *)scrollView {
 //    NSLog(@"%f",[scrollView contentOffset].y + scrollView.frame.size.height - 49);
 //    NSLog(@"isEqual to%f",[scrollView contentSize].height);
 
 if (([scrollView contentOffset].y + scrollView.frame.size.height - 49) == [scrollView contentSize].height) {
 
 NSLog(@"Page is %@",self.nextPage);
 self.show = YES;
 
 if (![self.nextPage isEqual:@""]) {
 
 [self loadProductsWithPage:self.nextPage.intValue];
 }
 else if(self.currentPage.intValue == self.pages.intValue){
 
 [self.activityIndicator stopAnimating];
 self.no_items.hidden = NO;
 }
 }
 }
 */


//
//#pragma mark <RMPZoomTransitionAnimating>
//
//- (UIImageView *)transitionSourceImageView
//{
//    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
//    ProductViewCell *cell = (ProductViewCell *)[self.collectionView cellForItemAtIndexPath:selectedIndexPath];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:cell.productImageView.image];
//    imageView.contentMode = cell.productImageView.contentMode;
//    imageView.clipsToBounds = YES;
//    imageView.userInteractionEnabled = NO;
//    imageView.frame = [cell.productImageView convertRect:cell.productImageView.frame toView:self.collectionView.superview];
//    
//    return imageView;
//}
//
//- (UIColor *)transitionSourceBackgroundColor
//{
//    return self.collectionView.backgroundColor;
//}
//
//- (CGRect)transitionDestinationImageViewFrame
//{
//    NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
//    ProductViewCell *cell = (ProductViewCell *)[self.collectionView cellForItemAtIndexPath:selectedIndexPath];
//    CGRect cellFrameInSuperview = [cell.productImageView convertRect:cell.productImageView.frame toView:self.collectionView.superview];
//    
//    return cellFrameInSuperview;
//}


@end

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
#import "UIScrollView+InfiniteScroll.h"
#import "Reachability.h"
#import "AppDelegate.h"

//static NSString * const PRODUCTS_DATA_URL = @"https://itunes.apple.com/us/rss/toppaidebooks/limit=100/explicit=true/json";
//static NSString *name = @"im:name";
//static NSString *image = @"im:image";
//static NSString *price = @"im:price";
//static NSString *summary = @"summary";

//#define kPRODUCTS_DATA_LINK @"http://chemistplus.in/getProducts_test.php"
#define kSPREE_PRODUCTS_URL @"http://www.elnuur.com/api/products.json?token=9dd43e7b3d2a35bad4b22e65cbf92fa854e51fede731f930"
#define kFIRST_PAGE 1

@interface ProductsViewController ()<viewModelDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) DetailViewModel *viewModel;
@property (nonatomic, assign) BOOL show;
@property (nonatomic, strong) NSString *itemsCount;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UILabel *no_items;

@property (nonatomic, strong) NSString *currentPage;
@property (nonatomic, strong) NSString *nextPage;
@property (nonatomic, strong) NSString *pages;

@end

@implementation ProductsViewController

static NSString * const productsReuseIdentifier = @"productsCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",self.subCategoryID);
    NSLog(@"%@",self.categoryID);
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NetworkStatus netStatus = [appDelegate.googleReach currentReachabilityStatus];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"loadingCell"];
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.collectionView.infiniteScrollIndicatorView = activityIndicator;
    self.collectionView.infiniteScrollIndicatorMargin = 40.0f;
    
    
    __weak typeof(self) weakSelf = self;
    
    [self.collectionView addInfiniteScrollWithHandler:^(UICollectionView *collectionView) {
        
        if (netStatus != NotReachable) {
            [weakSelf loadProductsPage:weakSelf.nextPage.intValue completion:^{
                [collectionView finishInfiniteScroll];
            }];
        }
        else {
            [weakSelf displayNoConnection];
        }
        
    }];
    
    
    
    
    if (netStatus != NotReachable) {
        [self loadProductsPage:kFIRST_PAGE completion:^{
            [self.hud hide:YES];
        }];
    }
    else
        [self displayNoConnection];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.task suspend];
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
//    NSLog(@"numberOfItemsInSection");
    return [self.viewModel numberOfProducts];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"cellForItemAtIndexPath");
    
    ProductViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:productsReuseIdentifier forIndexPath:indexPath];
    
    NSString *string = [self.viewModel infiniteImageAtIndex:indexPath.item];
    
    NSURL *url = [NSURL URLWithString:string];
    [cell.productImageView sd_setImageWithURL:url];
    cell.productLabel.text = [self.viewModel nameAtIndex:indexPath.item];
    cell.productPrice.text = [self.viewModel priceAtIndex:indexPath.item];
    
    return cell;
}




- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger width = self.view.frame.size.width / 2;
    
    return CGSizeMake(width-1, width-1);
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DetailsProductViewController *details = [self.storyboard instantiateViewControllerWithIdentifier:@"productDetailsVC"];
    details.detail = self.viewModel.viewModelProducts[indexPath.item];
    
    [self setTabBarVisible:[self tabBarIsVisible] animated:YES completion:^(BOOL finished) {
        NSLog(@"Finished");
    }];
    
    [self.navigationController pushViewController:details animated:YES];
}


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




-(void)loadProductsPage:(int)page completion:(void(^)(void))completion {
    
    void(^finish)(void) = completion ?: ^{};
    
    NSLog(@"loadProducts");
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLRequest *spree_request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:kSPREE_PRODUCTS_URL]];
    
    self.task = [session dataTaskWithRequest:spree_request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                NSError *jsonError;
                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                if (jsonError != nil) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                    
                    finish();
                }
                else if(![dictionary isEqual:nil])
                {
                    NSArray *array = [DetailViewModel infiniteProductsFromJSON:dictionary];
                    if (page == 1) {
                        
                        self.viewModel = [[DetailViewModel alloc]initWithArray:array];
                        
                        self.pages = [self.viewModel getPagesCount:dictionary];
                        self.itemsCount = [self.viewModel getItemsCount:dictionary];
                        [self.navigationItem setTitleView:[self titleViewWithCount:self.itemsCount]];
                        
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
                            finish();
                        }];
                        
                    }
                    
                    self.currentPage = [self.viewModel currentPage:dictionary];
                    self.nextPage = [NSString stringWithFormat:@"%d",[self.viewModel nextPage:dictionary]];
                    
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
    
    if (self.currentPage != nil && (self.currentPage.intValue == self.pages.intValue)) {
        finish();
    } else {
        [self.task resume];
    }
    
    
    
    if (page == 1) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.color = self.collectionView.tintColor;
    }
    
}


-(UIView *)titleViewWithCount:(NSString *)count {
    CGFloat navBarHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat width = 0.95 * self.view.frame.size.width;
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

@end

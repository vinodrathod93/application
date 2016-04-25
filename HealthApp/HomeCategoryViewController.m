//
//  HomeCategoryViewController.m
//  Chemist Plus
//
//  Created by adverto on 10/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "HomeCategoryViewController.h"
#import "CategoryViewCell.h"
#import "HeaderSliderView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "SignUpViewController.h"
#import "StoresViewController.h"
#import "DoctorViewController.h"
#import <AFNetworking.h>
#import "Location.h"
#import "ListingTableViewController.h"
#import "SubCategoryViewController.h"
#import "QRCodeViewController.h"

#import "CategoryModel.h"
#import "SubCategoryModel.h"
#import "PromotionModel.h"
#import "UIColor+HexString.h"
#import "MainCategoryRealm.h"
#import "SubCategoryRealm.h"
#import "MainPromotionRealm.h"
#import "HomeCollectionViewCell.h"
#import "SortListModel.h"
#import "FilterListModel.h"
#import "NotificationViewController.h"



@interface HomeCategoryViewController ()<NSFetchedResultsControllerDelegate, NSXMLParserDelegate>


@property (nonatomic, strong) NSFetchedResultsController *h_lineItemsFetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RLMResults *categoriesArray;
@property (nonatomic, strong) RLMResults *subCategoriesArray;
@property (nonatomic, strong) RLMResults *promotions;

@property (nonatomic, strong) NSArray *categoryIcons;
@property (nonatomic, strong) HeaderSliderView *headerView;

@property (nonatomic, strong) NeediatorHUD *hud;

@property (nonatomic, strong) NSDictionary *xmlDictionary;
@property (nonatomic, strong) NSMutableArray *xmlCategories;
@property (nonatomic, strong) NSMutableString *jsonString;

@end



@implementation HomeCategoryViewController {
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    NSString *_currentPlace;
    UIView *_launchScreen;
    NSURLSessionDataTask *_task;
    
}

static NSString * const reuseIdentifier = @"categoryCellIdentifier";
static NSString * const reuseSupplementaryIdentifier = @"headerViewIdentifier";
static NSString * const JSON_DATA_URL = @"http://chemistplus.in/products.json";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Decorate Navigation Bar */
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    UIImageView *neediatorLogoView    = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"neediator_logo"]];
    self.navigationItem.titleView = neediatorLogoView;

    UIButton *QRButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [QRButton setImage:[UIImage imageNamed:@"QRIcon"] forState:UIControlStateNormal];
    [QRButton addTarget:self action:@selector(QRButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *QRBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:QRButton];
    self.navigationItem.rightBarButtonItem = QRBarButtonItem;
    
    
    UIButton *notificationButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [notificationButton setBackgroundImage:[UIImage imageNamed:@"notification"] forState:UIControlStateNormal];
    [notificationButton addTarget:self action:@selector(notificationDidTapped:) forControlEvents:UIControlEventTouchUpInside];
    BBBadgeBarButtonItem *notificationItem = [[BBBadgeBarButtonItem alloc] initWithCustomUIButton:notificationButton];
    [notificationItem setBadgeValue:@"3"];
    [notificationItem setBadgeOriginX:10];
    [notificationItem setBadgeBGColor:[NeediatorUtitity mainColor]];
    [notificationItem setBadgeTextColor:[UIColor blackColor]];
    
    
    self.navigationItem.leftBarButtonItem = notificationItem;
    
    
    
    /* Start the Location */
//    Location *location = [Location savedLocation];
//    if (location == nil)
        [self startCurrentLocation];
    
    

    
    
    /* Show Badge value for Cart in Tab */
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self checkLineItems];
    NSString *count = [NSString stringWithFormat:@"%lu", self.h_lineItemsFetchedResultsController.fetchedObjects.count];
    
    if ([count isEqualToString:@"0"]) {
        [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:nil];
    } else
        [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:count];
    
    
    self.categoryIcons   = [self getPListIconsArray];
    
    // Register cell classes
    [self.collectionView registerClass:[HomeCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    /* Create Promotion Header View */
    self.headerView = [[HeaderSliderView alloc]init];
    
    
    /* Launch Screen */
    
    [self showLoadingView];
    
    
    
    [self showHUD];

    
    if ([self isCategoriesSaved]) {
        [NSThread sleepForTimeInterval:2.0];
        [self hideHUD];
        
        [self loadSavedCategories];
        
        [self removeLaunchScreen];
    }
    else
        [self requestCategories];
    
    
    
    
    
    // auto sliding of banners
    
    [[NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(changeDot:) userInfo:nil repeats:YES] fire];
    
    
}





- (IBAction)notificationDidTapped:(id)sender {
    
    NotificationViewController *notificationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"notificationListVC"];
    
    [self.navigationController pushViewController:notificationVC animated:YES];
}

-(void)showLoadingView {
    
    self.tabBarController.tabBar.hidden = YES;
    
    _launchScreen = [[[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil] lastObject];
    _launchScreen.frame  = [[UIScreen mainScreen] bounds];
    
    // Add blurview
    UIView *blurView = [[UIView alloc] initWithFrame:_launchScreen.frame];
    blurView.backgroundColor = [UIColor whiteColor];
    blurView.alpha = 0.6f;
    
    [_launchScreen addSubview:blurView];
    
    
    [self.navigationController.view addSubview:_launchScreen];
    
}

-(void)QRButtonTapped:(UIButton *)sender {
    
    QRCodeViewController *QRCodeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"qrCodeVC"];
    [self.navigationController pushViewController:QRCodeVC animated:YES];
    
}

-(void)removeLaunchScreen {
    [_launchScreen removeFromSuperview];
    self.tabBarController.tabBar.hidden = NO;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:238/255.f green:238/255.f blue:243/255.f alpha:1.0]];
//    self.navigationItem.rightBarButtonItem = [NeediatorUtitity locationBarButton];
    
    
    [self.tabBarController.tabBar setBarTintColor:[UIColor colorWithRed:238/255.f green:238/255.f blue:243/255.f alpha:1.0]];
    
    [self.tabBarController.tabBar setTintColor:[UIColor blackColor]];
    
    [self.tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull tabBarItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNext-DemiBold" size:9.f], NSFontAttributeName, nil] forState:UIControlStateNormal];
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNext-DemiBold" size:9.f], NSFontAttributeName, nil] forState:UIControlStateSelected];
    }];
    
    [self.collectionView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_task suspend];
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.headerView.uploadButton.layer.cornerRadius = self.headerView.uploadButton.frame.size.width/2;
    self.headerView.askDoctorButton.layer.cornerRadius = self.headerView.askDoctorButton.frame.size.width/2;
    self.headerView.askPharmacistButton.layer.cornerRadius = self.headerView.askPharmacistButton.frame.size.width/2;
    
    self.headerView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerView.scrollView.frame) * self.promotions.count, CGRectGetHeight(self.headerView.scrollView.frame));
}

-(NSArray *)getPListIconsArray {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
    NSDictionary *rootDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSArray *iconsArray = rootDictionary[@"Icons"];
    
    return iconsArray;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.categoriesArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
    
    CategoryModel *category     = self.categoriesArray[indexPath.row];
    
    
    cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", self.categoryIcons[indexPath.item]]];
    cell.label.text = category.name;
    cell.tag = 30+indexPath.item;
    
    if (cell.isHighlighted) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:244/255.f green:237/255.f blue:7/255.f alpha:1.0];
    }
    else
        cell.contentView.backgroundColor = [UIColor whiteColor];
    
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.view.frame.size.width <= 320) {
            return CGSizeMake(100, 100);
        }
        else
            return CGSizeMake(120, 120);
    }
    else
        return CGSizeMake(148, 148);
    
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.view.frame.size.width <= 320) {
            return UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
        }
    }
    
    return UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
}


-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    
    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor colorWithRed:244/255.f green:237/255.f blue:7/255.f alpha:1.0];
                     }
                     completion:nil];
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    
    [UIView animateWithDuration:0.1
                          delay:0
                        options:(UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         cell.contentView.backgroundColor = [UIColor whiteColor];
                     }
                     completion:nil];
    
}

#pragma mark <UICollectionViewDelegate>


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CategoryModel *model = self.categoriesArray[indexPath.row];
        
    
    NSMutableArray *array = [NSMutableArray array];
    for (SubCategoryModel *subcat_model in self.subCategoriesArray) {
        if ([model.cat_id isEqual:subcat_model.cat_id]) {
            [array addObject:subcat_model];
        }
    }
    
    [NeediatorUtitity save:model.cat_id forKey:kSAVE_CAT_ID];
    
    if (array.count == 0) {
        
        ListingTableViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"listingTableVC"];
        listingVC.root                       = model.name;
        listingVC.nav_color                  = model.color_code;
        listingVC.category_id                 = model.cat_id.stringValue;
        listingVC.subcategory_id              = @"";
        
        [self.navigationController pushViewController:listingVC animated:YES];
        

    }
    else {
        
        SubCategoryViewController *subCatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"subCategoryCollectionVC"];
        subCatVC.subcategoryArray       = array;
        [self.navigationController pushViewController:subCatVC animated:YES];
    }
    
    
    
    
    
}



-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        
        
        self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseSupplementaryIdentifier forIndexPath:indexPath];
        
        self.headerView.scrollView.frame           = self.headerView.frame;
        self.headerView.scrollView.backgroundColor = [UIColor whiteColor];
        
        
        [self setupScrollViewImages];
        
        
        
        // Changed the promotion model with static string url
        
        
//        [self.promotions enumerateObjectsUsingBlock:^(NSString *promotion_url, NSUInteger idx, BOOL *stop) {
//            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.headerView.scrollView.frame) * idx, 0, CGRectGetWidth(self.headerView.scrollView.frame), CGRectGetHeight(self.headerView.scrollView.frame))];
//            imageView.tag = idx;
//            
//            
//            NSURL *image_url = [NSURL URLWithString:promotion_url];
//            
//            
//            [imageView sd_setImageWithURL:image_url placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
//            
//            
//            [self.headerView.scrollView addSubview:imageView];
//        }];
        
        
        
        
        
        self.headerView.pageControl.numberOfPages = self.promotions.count;
        
        reusableView = self.headerView;
    }
    
    return reusableView;
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(CGRectGetWidth(self.view.frame), kHeaderViewHeight_Pad);
    }
    else
        return CGSizeMake(CGRectGetWidth(self.view.frame), kHeaderViewHeight_Phone);

}



#pragma mark - Scroll view Delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.headerView.scrollView) {
        NSInteger index = self.headerView.scrollView.contentOffset.x / CGRectGetWidth(self.headerView.scrollView.frame);
        
        self.headerView.pageControl.currentPage = index;
    }
}

-(void)scrollToPage:(NSInteger)aPage{
    float myPageWidth = [self.headerView.scrollView frame].size.width;
    [self.headerView.scrollView setContentOffset:CGPointMake(aPage*myPageWidth,0) animated:YES];
}

-(void)changeDot:(id)sender {
    
    NSLog(@"%ld and %lu", (long)self.headerView.pageControl.currentPage, (unsigned long)self.promotions.count);
    
    [self scrollToPage:self.headerView.pageControl.currentPage%self.promotions.count];
    
    self.headerView.pageControl.currentPage++;
}

#pragma mark - Scroll view Methods

-(void)setupScrollViewImages {
    
    
    
    for (int idx=0; idx < self.promotions.count; idx++) {
        
        PromotionModel *promotion = self.promotions[idx];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.headerView.scrollView.frame) * idx, 0, CGRectGetWidth(self.headerView.scrollView.frame), CGRectGetHeight(self.headerView.scrollView.frame))];
        imageView.tag = idx;
        
        
        NSURL *image_url = [NSURL URLWithString:promotion.image_url];
        
        [imageView sd_setImageWithURL:image_url placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
        
        
        [self.headerView.scrollView addSubview:imageView];
    }
    
    
    
    
//    [self.promotions enumerateObjectsUsingBlock:^(PromotionModel *promotion, NSUInteger idx, BOOL *stop) {
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.headerView.scrollView.frame) * idx, 0, CGRectGetWidth(self.headerView.scrollView.frame), CGRectGetHeight(self.headerView.scrollView.frame))];
//        imageView.tag = idx;
//        
//        
//        [imageView sd_setImageWithURL:[NSURL URLWithString:promotion.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
//        
//        [self.headerView.scrollView addSubview:imageView];
//    }];

    
}




-(void)checkLineItems {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineItemID" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.h_lineItemsFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if (![self.h_lineItemsFetchedResultsController performFetch:&error]) {
        NSLog(@"LineItems Model Fetch Failure: %@", [error localizedDescription]);
    }
}






#pragma mark - Location

-(void)startCurrentLocation {
    
    _locationManager = [[CLLocationManager alloc] init];
    _geocoder = [[CLGeocoder alloc] init];
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestWhenInUseAuthorization];
    
    [_locationManager startUpdatingLocation];
}



- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSLog(@"%.8f", currentLocation.coordinate.longitude);
        NSLog(@"%.8f", currentLocation.coordinate.latitude);
        
    }
    
    Location *location = [Location savedLocation];
    if (location != nil) {
       // nothing
        
    } else {
        location = [[Location alloc] init];
    }
    
    
    // Reverse Geocoding
    [_geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] > 0) {
            _placemark = [placemarks lastObject];
            NSLog(@"%@ %@\n%@ %@\n%@\n%@",
                  _placemark.subLocality, _placemark.locality,
                  _placemark.postalCode, _placemark.addressDictionary,
                  _placemark.administrativeArea,
                  _placemark.country);
            
            if (_currentPlace) {
                _currentPlace = nil;
            }
            
            _currentPlace = [NSString stringWithFormat:@"%@, %@", _placemark.subLocality, _placemark.locality];
            
            
            location.latitude = [NSString stringWithFormat:@"%.8f",currentLocation.coordinate.latitude];
            location.longitude = [NSString stringWithFormat:@"%.8f",currentLocation.coordinate.longitude];
            location.location_name = _currentPlace;
            location.isCurrentLocation = YES;
            
            [location save];
            
            
            [_locationManager stopUpdatingLocation];
            
//            [self decorateSelectCurrentLocation];
            
//            if (self.storesArray.count != 0) {
//                [self.storesArray removeAllObjects];
//                [self.storesArray addObject:@"Searching..."];
//            }
            
//            [self.tableView reloadData];
            
            
//            [self loadStoresWithLocation:location];
            
            
            
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}

- (IBAction)notificationPressed:(id)sender {
    
    
}


#pragma mark - HUD

-(void)showHUD {
    
    if (_launchScreen) {
        self.hud = [[NeediatorHUD alloc] initWithFrame:_launchScreen.frame];
        self.hud.overlayColor = [UIColor clearColor];
        self.hud.hudCenter = CGPointMake(CGRectGetWidth(_launchScreen.bounds) / 2, CGRectGetHeight(_launchScreen.bounds) / 2 + 120.f);
        [self.hud fadeInAnimated:YES];
        [_launchScreen addSubview:self.hud];
        
        
    }
    
}

-(void)hideHUD {
    
    
    [self.hud fadeOutAnimated:YES];
    [_launchScreen removeFromSuperview];
}



#pragma mark - Network

-(void)requestCategories {
    
    
    
    
    
    self.subCategoriesArray = [[NSMutableArray alloc] init];
    
    
    
    
    /* Get Category names & Promotion Images */
    _task = [[NAPIManager sharedManager] mainCategoriesWithSuccess:^(MainCategoriesResponseModel *response) {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            RLMRealm *realm = [RLMRealm defaultRealm];
            [realm beginWriteTransaction];
            [realm deleteAllObjects];
            [realm commitWriteTransaction];
            
            [realm beginWriteTransaction];
            for (CategoryModel *category in response.categories) {
                MainCategoryRealm *categoryRealm = [[MainCategoryRealm alloc] initWithMantleModel:category];
                [realm addObject:categoryRealm];
                
                
                
                for (SubCategoryModel *subCategory in category.subCat_array) {
                    SubCategoryRealm *subCategoryRealm = [[ SubCategoryRealm alloc] initWithMantleModel:subCategory];
                    
                    [realm addObject:subCategoryRealm];
                }
                
            }
            
            for (PromotionModel *promotion in response.promotions) {
                MainPromotionRealm *promotionRealm = [[MainPromotionRealm alloc] initWithMantleModel:promotion];
                [realm addObject:promotionRealm];
            }
            
            
            [realm commitWriteTransaction];
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                RLMRealm *realmMainThread = [RLMRealm defaultRealm];
                
                RLMResults *categories = [MainCategoryRealm allObjectsInRealm:realmMainThread];
                RLMResults *subCategories = [SubCategoryRealm allObjectsInRealm:realmMainThread];
                RLMResults *promotions = [MainPromotionRealm allObjectsInRealm:realmMainThread];
                
                self.categoriesArray = categories;
                self.subCategoriesArray = subCategories;
                self.promotions = promotions;
                
                [self.collectionView reloadData];
                [self hideHUD];
                [self removeLaunchScreen];
            });
        });
        
//                [NSThread sleepForTimeInterval:2.0];
//        
//                [self hideHUD];
//                self.promotions         = response.promotions;
//        
//        
//        
//        
//                [self.collectionView reloadData];
//                [self removeLaunchScreen];
        
    } failure:^(NSError *error) {
        // Display error
        [NSThread sleepForTimeInterval:2.0];
        [self hideHUD];
        
        [self loadSavedCategories];
        
        [self removeLaunchScreen];
        
        NSLog(@"HomeCategory Error: %@", error.localizedDescription);
    }];
}



-(void)loadSavedCategories {
    
    
    self.categoriesArray = [MainCategoryRealm allObjects];
    self.subCategoriesArray = [SubCategoryRealm allObjects];
    self.promotions = [MainPromotionRealm allObjects];
    
    [self.collectionView reloadData];
    
}

-(BOOL)isCategoriesSaved {
    
    RLMResults *categoriesArray = [MainCategoryRealm allObjects];
    RLMResults *promotions = [MainPromotionRealm allObjects];
    
    return (categoriesArray.count && promotions.count) ? YES : NO;
}


/*
#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.xmlDictionary = [[NSDictionary alloc] init];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"string"]) {
        NSLog(@"Yeah! Found");
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    NSLog(@"JSoN string %@",string);
    if (!self.jsonString) {
        self.jsonString = [[NSMutableString alloc] initWithString:string];
    } else
        [self.jsonString appendString:string];
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"string"]) {
        NSLog(@"Parsing Ended");
    }
}

- (void) parserDidEndDocument:(NSXMLParser *)parser
{
    
    
    NSData *data = [self.jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    NSLog(@"%@", json);
    
    self.xmlDictionary = json;
    
    self.xmlCategories = [NSMutableArray array];
    
    NSArray *allCategories = [json valueForKey:@"Table"];
    
    [allCategories enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull category, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.xmlCategories addObject:[category valueForKey:@"CategoryName"]];
    }];
    
    [self.collectionView reloadData];
    
}


*/








#pragma mark - Not Needed



//-(NSFetchedResultsController *)h_cartFetchedResultsController {
//    if (_h_cartFetchedResultsController) {
//        return _h_cartFetchedResultsController;
//    }
//
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AddToCart" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
//                                        initWithKey:@"addedDate"
//                                        ascending:NO];
//
//    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
//    [fetchRequest setSortDescriptors:sortDescriptors];
//
//    _h_cartFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    _h_cartFetchedResultsController.delegate = self;
//
//    NSError *error = nil;
//    if (![self.h_cartFetchedResultsController performFetch:&error]) {
//        NSLog(@"Core data error %@, %@", error, [error userInfo]);
//        abort();
//    }
//
//    return _h_cartFetchedResultsController;
//}


//-(NSArray *)getPListCategoriesArray {
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
//    NSDictionary *rootDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
//    
//    NSArray *categoryArray = rootDictionary[@"Category"];
//    return categoryArray;
//}
//
//-(NSArray *)getPListIconsArray {
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
//    NSDictionary *rootDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
//    
//    NSArray *iconsArray = rootDictionary[@"Icons"];
//    
//    return iconsArray;
//}


@end

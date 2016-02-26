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
//#import <FBSDKLoginKit/FBSDKLoginKit.h>
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SignUpViewController.h"
#import "StoresViewController.h"
#import "DoctorViewController.h"
#import <AFNetworking.h>
#import "Location.h"
#import "ListingTableViewController.h"
#import "SubCategoryViewController.h"

#import "CategoryModel.h"
#import "SubCategoryModel.h"
#import "PromotionModel.h"
#import "UIColor+HexString.h"
#import <Realm/Realm.h>
#import "MainCategoryRealm.h"
#import "SubCategoryRealm.h"


@interface HomeCategoryViewController ()<NSFetchedResultsControllerDelegate, NSXMLParserDelegate>


@property (nonatomic, strong) NSFetchedResultsController *h_lineItemsFetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) RLMResults *categoriesArray;
@property (nonatomic, strong) RLMResults *subCategoriesArray;

@property (nonatomic, strong) NSArray *categoryIcons;
@property (nonatomic, strong) HeaderSliderView *headerView;
@property (nonatomic, strong) NSArray *promotions;
@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) NSDictionary *xmlDictionary;
@property (nonatomic, strong) NSMutableArray *xmlCategories;
@property (nonatomic, strong) NSMutableString *jsonString;

@end

@implementation HomeCategoryViewController {
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    NSString *_currentPlace;
    
}

static NSString * const reuseIdentifier = @"categoryCellIdentifier";
static NSString * const reuseSupplementaryIdentifier = @"headerViewIdentifier";
static NSString * const JSON_DATA_URL = @"http://chemistplus.in/products.json";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Decorate Navigation Bar */
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.titleView    = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"neediator_logo"]];
    
    
    /* Start the Location */
    Location *location = [Location savedLocation];
    if (location == nil)
        [self startCurrentLocation];
    
    

    
    
    /* Show Badge value for Cart in Tab */
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self checkLineItems];
    NSString *count = [NSString stringWithFormat:@"%u", self.h_lineItemsFetchedResultsController.fetchedObjects.count];
    
    if ([count isEqualToString:@"0"]) {
        [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:nil];
    } else
        [[self.tabBarController.tabBar.items objectAtIndex:3] setBadgeValue:count];
    
    
    self.categoryIcons   = [self getPListIconsArray];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    /* Create Promotion Header View */
    self.headerView = [[HeaderSliderView alloc]init];
    
    
    [self showHUD];
    
    /* Get Category names & Promotion Images */
    [[NAPIManager sharedManager] mainCategoriesWithSuccess:^(MainCategoriesResponseModel *response) {
        
        
        
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
                    
                    #error check for subcategory array.
                    categoryRealm.subCatArray = subCategoryRealm;
                }
                
            }
            [realm commitWriteTransaction];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                RLMRealm *realmMainThread = [RLMRealm defaultRealm];
                RLMResults *categories = [MainCategoryRealm allObjectsInRealm:realmMainThread];
                RLMResults *subCategories = [SubCategoryRealm allObjectsInRealm:realmMainThread];
                
                self.categoriesArray = categories;
                self.subCategoriesArray = subCategories;
                
                [self.collectionView reloadData];
                [self hideHUD];
            });
        });

        
        
        
        
        
        
        [self hideHUD];
        self.promotions         = response.promotions;
        
        [self.collectionView reloadData];
        
    } failure:^(NSError *error) {
        // Display error
        [self hideHUD];
        
        self.categoriesArray = [MainCategoryRealm allObjects];
        [self.collectionView reloadData];
        
        
        NSLog(@"HomeCategory Error: %@", error.localizedDescription);
    }];
    
     
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:238/255.f green:238/255.f blue:243/255.f alpha:1.0]];
    [self.tabBarController.tabBar setBarTintColor:[UIColor colorWithRed:238/255.f green:238/255.f blue:243/255.f alpha:1.0]];
    
    [self.tabBarController.tabBar setTintColor:[UIColor blackColor]];
    
    [self.tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull tabBarItem, NSUInteger idx, BOOL * _Nonnull stop) {
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNext-DemiBold" size:9.f], NSFontAttributeName, nil] forState:UIControlStateNormal];
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNext-DemiBold" size:9.f], NSFontAttributeName, nil] forState:UIControlStateSelected];
    }];
    
    
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
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
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    
    CategoryModel *category     = self.categoriesArray[indexPath.row];
    
    
    // Configure the cell
    cell.backgroundColor = [UIColor clearColor];
    cell.layer.cornerRadius = 3.f;
    cell.layer.masksToBounds = YES;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 10, cell.frame.size.width - (2*25.f), cell.frame.size.height - 10 - 40)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", self.categoryIcons[indexPath.item]]];
//    [imageView sd_setImageWithURL:[NSURL URLWithString:category.image_url]];
//    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [imageView setTintColor:[UIColor blackColor]];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(5.f, imageView.frame.size.height + 10, cell.frame.size.width - 10.f, 40)];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
    label.text = category.name;
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
//    backgroundView.backgroundColor = [UIColor colorFromHexString:category.color_code];
    
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.tag = 30+indexPath.item;
    
    [backgroundView addSubview:imageView];
    [backgroundView addSubview:label];
    
    cell.backgroundView = backgroundView;
    
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
    
    
    
    CategoryModel *model = self.categoriesArray[indexPath.row];
    
    UIView *view = [cell viewWithTag:30+indexPath.item];
    view.backgroundColor = [UIColor colorWithRed:244/255.f green:237/255.f blue:7/255.f alpha:1.0];
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIView *view = [cell viewWithTag:30+indexPath.item];
    view.backgroundColor = [UIColor whiteColor];
}

#pragma mark <UICollectionViewDelegate>


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    
    
    CategoryModel *model = self.categoriesArray[indexPath.row];
    
//    UIView *view = [cell viewWithTag:30+indexPath.item];
//    view.backgroundColor = [UIColor colorFromHexString:model.color_code];
    /*
    if (indexPath.item == 1) {
        
        StoresViewController *storesVC  = [self.storyboard instantiateViewControllerWithIdentifier:@"storesViewController"];
        storesVC.title = model.name;
        storesVC.hidesBottomBarWhenPushed = YES;
        
        [self.navigationController pushViewController:storesVC animated:YES];
    }
    else if (indexPath.item == 8) {
        ListingTableViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"listingTableVC"];
        listingVC.root = @"restaurants";
        listingVC.icon = @"restaurant_cafe";
        [self.navigationController pushViewController:listingVC animated:YES];
    }
    
    else if (indexPath.item == 10) {
        ListingTableViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"listingTableVC"];
        listingVC.root = @"desserts";
        listingVC.icon = @"ice_cream_parlor";
        [self.navigationController pushViewController:listingVC animated:YES];
    }
    else if (indexPath.item == 0) {
        ListingTableViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"listingTableVC"];
        listingVC.root = @"chemists";
        listingVC.icon = @"chemist";
        [self.navigationController pushViewController:listingVC animated:YES];
    }
    else if (indexPath.item == 2) {
        
        DoctorViewController *doctorsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"doctorsVC"];
        [self.navigationController pushViewController:doctorsVC animated:YES];
        
    }
    else if (indexPath.item == 3) {
        ListingTableViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"listingTableVC"];
        listingVC.root = @"hospitals";
        listingVC.icon = @"hospital";
        [self.navigationController pushViewController:listingVC animated:YES];
    }
    */
    
    
//    ListingTableViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"listingTableVC"];
//    listingVC.root                       = model.name;
//    listingVC.nav_color                  = model.color_code;
//    listingVC.category_id                 = model.cat_id.stringValue;
//    [self.navigationController pushViewController:listingVC animated:YES];
//    
    
    
    
    SubCategoryViewController *subCatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"subCategoryCollectionVC"];
    
    subCatVC.subcategoryArray       =
    [self.navigationController pushViewController:subCatVC animated:YES];
    
    
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    
//    UIView *view = [cell viewWithTag:30+indexPath.item];
//    view.backgroundColor = [UIColor whiteColor];
    
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        
        
        self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseSupplementaryIdentifier forIndexPath:indexPath];
        
        
        /*
        CGRect scrollViewFrame = self.headerView.scrollView.frame;
        CGRect currentFrame = self.view.frame;
        
        scrollViewFrame.size.width = currentFrame.size.width;
        
        self.headerView.scrollView.frame = scrollViewFrame;
        */
        
        self.headerView.scrollView.frame           = self.headerView.frame;
        self.headerView.scrollView.backgroundColor = [UIColor whiteColor];
        
        
        [self setupScrollViewImages];
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.headerView.scrollView) {
        NSInteger index = self.headerView.scrollView.contentOffset.x / CGRectGetWidth(self.headerView.scrollView.frame);
        
        self.headerView.pageControl.currentPage = index;
    }
    
    
}

#pragma mark - Scroll view Methods

-(void)setupScrollViewImages {
    
    [self.promotions enumerateObjectsUsingBlock:^(PromotionModel *promotion, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.headerView.scrollView.frame) * idx, 0, CGRectGetWidth(self.headerView.scrollView.frame), CGRectGetHeight(self.headerView.scrollView.frame))];
        imageView.tag = idx;
        
       
        NSURL *image_url = [NSURL URLWithString:promotion.image_url];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *image   = [UIImage imageWithData:[NSData dataWithContentsOfURL:image_url]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CIImage *newImage = [[CIImage alloc] initWithImage:image];
                CIContext *context = [CIContext contextWithOptions:nil];
                CGImageRef reference = [context createCGImage:newImage fromRect:newImage.extent];
                
                imageView.image  = [UIImage imageWithCGImage:reference scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            });
        });
        
        
//        [imageView sd_setImageWithURL:[NSURL URLWithString:promotion.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.headerView.scrollView addSubview:imageView];
    }];
    
    
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



#pragma mark - HUD

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.color = self.collectionView.tintColor;
}

-(void)hideHUD {
    [self.hud hide:YES];
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

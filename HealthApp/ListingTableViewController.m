//
//  ListingTableViewController.m
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ListingTableViewController.h"
#import "ListingCell.h"
#import "ChemistResponseModel.h"
#import "HospitalResponseModel.h"
#import "DessertResponseModel.h"
#import "RestaurantResponseModel.h"
#import "NoStores.h"
#import "NoConnectionView.h"
#import "ListingModel.h"
#import "ImageModalViewController.h"
#import "UIColor+HexString.h"
#import "NEntityDetailViewController.h"
#import "BookCallListingCell.h"
#import "BookingViewController.h"
#import "StoreTaxonsViewController.h"
#import "BannerTableViewCell.h"
#import "SortListModel.h"
#import "FilterListModel.h"
#import "SortOrderModel.h"
#import "StoreReviewsView.h"
#import "FilterViewController.h"

#define kBannerSectionIndex 1

@interface ListingTableViewController ()<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate,UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) NSArray *listingArray;
@property (nonatomic, strong) NSArray *sorting_list;
@property (nonatomic, strong) NSArray *filter_list;
@property (nonatomic, strong) NSArray *bannerImages;

@property (nonatomic, strong) NeediatorHUD *hud;
@property (nonatomic, strong) NoStores *noListingView;

@property (nonatomic, assign) BOOL isFilterApplied;
@property (nonatomic, strong) NSDictionary *filterData;

@property (nonatomic, strong) id previewingContext;

@end

@implementation ListingTableViewController {
    NSURLSessionDataTask *_task;
    NoConnectionView *_connectionView;
    UITapGestureRecognizer *_tap;
    UIImageView *_tappedImageView;
    BOOL _isBooking;
    BOOL _isProductType;
    BOOL _viewDidLoadFlag;
    UIImageView *activityImageView;
    UIView *header;
    UIButton *sort;
    UIView *hudView;
    NSString *_totalCount;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.root.uppercaseString;
    self.tableView.backgroundColor = [UIColor colorFromHexString:@"#EEEEEE"];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.tableView registerClass:[BannerTableViewCell class] forCellReuseIdentifier:@"bannerViewCellIdentifier"];
    
    // Register for 3D Touch Previewing if available
    if ([self isForceTouchAvailable])
    {
        self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
    }
    _viewDidLoadFlag = YES;
    //    self.navigationItem.rightBarButtonItem = [NeediatorUtitity locationBarButton];
    
    if (_isFilterApplied) {
        [self requestListingByFilterData:_filterData sortID:@"" andTypeID:@""];
    }
    else
        [self requestBasicListings];
    
    
    self.bannerImages = @[@"http://g-ecx.images-amazon.com/images/G/31/img15/video-games/Gateway/new-year._UX1500_SX1500_CB285786565_.jpg",
                          @"http://g-ecx.images-amazon.com/images/G/31/img15/Shoes/December/4._UX1500_SX1500_CB286226002_.jpg",
                          @"http://g-ecx.images-amazon.com/images/G/31/img15/softlines/apparel/201512/GW/New-GW-Hero-1._UX1500_SX1500_CB301105718_.jpg",
                          @"http://img5a.flixcart.com/www/promos/new/20151229_193348_730x300_image-730-300-8.jpg",
                          @"http://img5a.flixcart.com/www/promos/new/20151228_231438_730x300_image-730-300-15.jpg"];
}




-(BOOL)isForceTouchAvailable
{
    BOOL isForceTouchAvailable = NO;
    if ([self.traitCollection respondsToSelector:@selector(forceTouchCapability)]) {
        isForceTouchAvailable = self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable;
    }
    return isForceTouchAvailable;
}



-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Listing Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self performSelector:@selector(changeDot:) withObject:nil afterDelay:2.5f];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestBasicListings) name:@"NeediatorLocationChanged" object:nil];
    
    
    
}




-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeDot:) object:nil];
    
    [[self.navigationController.view viewWithTag:kListingNoListingTag] removeFromSuperview];
    [self removeConnectionView];
    [self hideHUD];
    
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}


#pragma mark -
#pragma mark === UIViewControllerPreviewingDelegate Methods ===
#pragma mark -

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext
              viewControllerForLocation:(CGPoint)location
{
    
    if ([self.presentedViewController isKindOfClass:[StoreTaxonsViewController class]] || [self.presentedViewController isKindOfClass:[NEntityDetailViewController class]]) {
        return nil;
    }
    
    CGPoint cellPosition = [self.tableView convertPoint:location fromView:self.view];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:cellPosition];
    ListingModel *model = self.listingArray[indexPath.row - 1];
    
    if (indexPath) {
        ListingCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        //        UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"storeTaxonsNavVC"];
        //        [self configureNavigationController:navController withModel:model];
        
        
        StoreTaxonsViewController *storeTaxonsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"storeTaxonsVC"];
        storeTaxonsVC.title = [model.name capitalizedString];
        storeTaxonsVC.cat_id = self.category_id;
        storeTaxonsVC.store_id = model.list_id;
        storeTaxonsVC.storeImages = model.images;
        storeTaxonsVC.storePhoneNumbers = model.phone_nos;
        storeTaxonsVC.storeDistance = model.nearest_distance.uppercaseString;
        storeTaxonsVC.ratings   = model.ratings;
        storeTaxonsVC.reviewsCount = model.reviews_count;
        storeTaxonsVC.likeUnlikeArray = model.likeUnlike;
        storeTaxonsVC.offersarray=  model.offerArray;
        
        
        previewingContext.sourceRect = [self.view convertRect:cell.frame fromView:self.tableView];
        
        return storeTaxonsVC;
        
    }
    
    return nil;
}

- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    
    //    [self showDetailViewController:viewControllerToCommit sender:self];
    [self.navigationController showViewController:viewControllerToCommit sender:nil];
}


-(void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if ([self isForceTouchAvailable]) {
        if (!self.previewingContext) {
            self.previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.view];
        }
    } else {
        if (self.previewingContext) {
            [self unregisterForPreviewingWithContext:self.previewingContext];
            self.previewingContext = nil;
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listingArray.count + kBannerSectionIndex;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier;
    if (indexPath.row == 0) {
        cellIdentifier = @"bannerViewCellIdentifier";
        
        BannerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell.carousel == nil) {
            
            cell = [[[NSBundle mainBundle] loadNibNamed:@"BannerView" owner:self options:nil] lastObject];
            cell.carousel.delegate = self;
            cell.carousel.dataSource = self;
            cell.pageControl.numberOfPages = self.bannerImages.count;
        }
        
        
        return cell;
        
    }
    else {
        
        id cell;
        
        ListingModel *model = self.listingArray[indexPath.row - 1];
        
        //  if (model.isBook == [NSNumber numberWithBool:YES] || model.isCall == [NSNumber numberWithBool:YES]) {
        
        if (model.isBook == [NSNumber numberWithBool:YES]) {
            _isBooking      = YES;
            cellIdentifier  = @"BookCallCellIdentifier";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            [self configureBookCallCell:cell withModel:model];
        }
        else {
            cellIdentifier = @"listingCellIdentifier";
            cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            [self configureListingCell:cell withModel:model];
        }
        
        return cell;
    }
    
}



-(void)configureListingCell:(ListingCell *)cell withModel:(ListingModel *)model
{
    cell.backgroundColor = [UIColor clearColor];
    
    NSNumberFormatter *minOrderCurrencyFormatter = [[NSNumberFormatter alloc] init];
    [minOrderCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [minOrderCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
    
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayImageFullScreen:)];
    [cell.profileImageview addGestureRecognizer:_tap];
    [cell.profileImageview setUserInteractionEnabled:YES];
    
    cell.roundedContentView.layer.cornerRadius = 5.f;
    cell.roundedContentView.layer.masksToBounds = YES;
    
    cell.name.text = model.name.capitalizedString;
    cell.street.text = [NSString stringWithFormat:@"➥ %@", model.area.capitalizedString];
    
    if(model.isOffer==true)
    {
        cell.offersButton.hidden=NO;}
    else{
        cell.offersButton.hidden=YES;
        cell.ImageViewTopConstraints.constant=18;
        cell.ImageViewBottomConstraints.constant=15;}
    
    NSDictionary *likeUnlikeDict = [model.likeUnlike lastObject];
    NSNumber *likeCount = likeUnlikeDict[@"like"];
    
    
    
    if (likeCount == nil) {
        likeCount = @0;
    }
    
    cell.likesLabel.text = [NSString stringWithFormat:@"👍🏼 %@", likeCount.stringValue];
    cell.rating.text = [NSString stringWithFormat:@"⭐️ %.01f", model.ratings.floatValue];
    cell.distance.text = [NSString stringWithFormat:@"📍%@",[model.nearest_distance lowercaseString]];
    cell.timing.text    = [NSString stringWithFormat:@"🕒 %@",[model.timing lowercaseString]];
    NSString *minOrderString =  [NSString stringWithFormat:@"Min. Order %@", [minOrderCurrencyFormatter stringFromNumber:@(model.minOrder.intValue)]];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:minOrderString];
    NSRange range = [minOrderString rangeOfString:@"Min."];
    
    [attributedString setAttributes:@{
                                      NSForegroundColorAttributeName : [UIColor darkGrayColor]
                                      }range:range];
    
    cell.minOrderLabel.attributedText = attributedString;
    
    
    cell.profileImageview.backgroundColor = [UIColor colorFromHexString:@"#EEEEEE"];
    cell.profileImageview.layer.cornerRadius = 5.f;
    cell.profileImageview.layer.masksToBounds = YES;
    
    
    NSString *image_string;
    
    if (model.images.count > 0) {
        NSDictionary *image_dict = [model.images objectAtIndex:0];
        image_string = image_dict[@"image_url"];
    }
    else
        image_string = @"";
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //sb  [cell.profileImageview sd_setImageWithURL:[NSURL URLWithString:image_string] placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
    [cell.profileImageview sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
    
    cell.ratingView.notSelectedImage    = [UIImage imageNamed:@"star-1"];
    cell.ratingView.halfSelectedImage   = [UIImage imageNamed:@"Star Half Empty"];
    cell.ratingView.fullSelectedImage   = [UIImage imageNamed:@"Star Filled"];
    
    cell.ratingView.rating              = model.ratings.floatValue;
    cell.ratingView.editable            = NO;
    cell.ratingView.maxRating           = 5;
    cell.ratingView.minImageSize        = CGSizeMake(10.f, 10.f);
    cell.ratingView.midMargin           = 0.f;
    cell.ratingView.leftMargin          = 0.f;
    
    //    CAGradientLayer *gradient = [CAGradientLayer layer];
    //    gradient.frame = cell.roundedContentView.bounds;
    
    if (model.premium.count != 0) {
        NSDictionary *premiumDict = model.premium[0];
        
        if (premiumDict != nil) {
            if ([premiumDict[@"name"] isEqualToString:@"Gold"]) {
                
                //sb  cell.roundedContentView.backgroundColor = [UIColor colorWithRed:235/255.f green:197/255.f blue:87/255.f alpha:1.0];
            }
            else if ([premiumDict[@"name"] isEqualToString:@"Silver"]) {
                
                //sb cell.roundedContentView.backgroundColor = [UIColor colorWithRed:192/255.f green:192/255.f blue:192/255.f alpha:1.0];
            }
            else if ([premiumDict[@"name"] isEqualToString:@"Bronze"]) {
                
                
                //sb                cell.roundedContentView.backgroundColor = [UIColor colorWithRed:215/255.f green:173/255.f blue:127/255.f alpha:1.0];
            }
        }
        
        //        [cell.roundedContentView.layer insertSublayer:gradient atIndex:0];
    }
    else {
        
        cell.roundedContentView.backgroundColor = [UIColor whiteColor];
        
    }
    
}


-(void)configureBookCallCell:(BookCallListingCell *)cell withModel:(ListingModel *)model {
    
    NSNumberFormatter *minOrderCurrencyFormatter = [[NSNumberFormatter alloc] init];
    [minOrderCurrencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [minOrderCurrencyFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_IN"]];
    
    cell.backgroundColor = [UIColor clearColor];
    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayImageFullScreen:)];
    [cell.profileImageview addGestureRecognizer:_tap];
    [cell.profileImageview setUserInteractionEnabled:YES];
    cell.corneredView.layer.cornerRadius = 5.f;
    cell.corneredView.layer.masksToBounds = YES;
    
    
    
    cell.name.text = model.name.capitalizedString;
    cell.address.text = model.address.capitalizedString;
    cell.DoctorArea.text=model.area.capitalizedString;
    NSString *minOrderString =  [NSString stringWithFormat:@"Min. Fees %@", [minOrderCurrencyFormatter stringFromNumber:@(model.FeesCharge.intValue)]];
    
    cell.MinimumFees.text=minOrderString;
    
    
    
    cell.ratingLabel.text = [NSString stringWithFormat:@"%.01f", model.ratings.floatValue];
    cell.distance.text = [NSString stringWithFormat:@"📍 %@",[model.nearest_distance uppercaseString]];
    cell.timing.text    = [NSString stringWithFormat:@"🕒 %@",[model.timing uppercaseString]];
    
    cell.profileImageview.backgroundColor = [UIColor colorFromHexString:@"#EEEEEE"];
    cell.profileImageview.layer.cornerRadius = 5.f;
    cell.profileImageview.layer.masksToBounds = YES;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell.profileImageview sd_setImageWithURL:[NSURL URLWithString:model.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
    
    
    cell.ratingView.notSelectedImage    = [UIImage imageNamed:@"Star"];
    cell.ratingView.halfSelectedImage   = [UIImage imageNamed:@"Star Half Empty"];
    cell.ratingView.fullSelectedImage   = [UIImage imageNamed:@"Star Filled"];
    
    cell.ratingView.rating              = model.ratings.floatValue;
    cell.ratingView.editable            = NO;
    cell.ratingView.maxRating           = 5;
    cell.ratingView.minImageSize        = CGSizeMake(10.f, 10.f);
    cell.ratingView.midMargin           = 0.f;
    cell.ratingView.leftMargin          = 0.f;
    
    cell.button.layer.cornerRadius      = 5.f;
    cell.button.layer.masksToBounds     = YES;
    [cell.button addTarget:self action:@selector(goToAppointmentPage:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    NSString *title                     = model.isBook ? @"Offer" : model.isCall ? @"CALL" : @"";
    [cell.button setTitle:title forState:UIControlStateNormal];
    
    if ([title isEqualToString:@""]) {
        [cell.button removeFromSuperview];
    }
    
    if([model.Sunday isEqualToString:@"Holiday"])
        cell.Sunday_lbl.textColor=[UIColor lightGrayColor];
    
    if([model.Monday isEqualToString:@"Holiday"])
        cell.Monday_lbl.textColor=[UIColor lightGrayColor];
    
    if([model.Tuesday isEqualToString:@"Holiday"])
        cell.Tuesday_lbl.textColor=[UIColor lightGrayColor];
    
    if([model.Thursday isEqualToString:@"Holiday"])
        cell.Thrusday_lbl.textColor=[UIColor lightGrayColor];
    if([model.Wednesday isEqualToString:@"Holiday"])
        cell.Wednesday_lbl.textColor=[UIColor lightGrayColor];
    if([model.Friday isEqualToString:@"Holiday"])
        cell.Friday_lbl.textColor=[UIColor lightGrayColor];
    if([model.Saturday isEqualToString:@"Holiday"])
        cell.Saturday_lbl.textColor=[UIColor lightGrayColor];
    
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != 0) {
        ListingModel *model = self.listingArray[indexPath.row - 1];
        
        NSString *image_string;
        
        if (model.images.count > 0)
        {
            NSDictionary *image_dict = [model.images objectAtIndex:0];
            image_string = image_dict[@"image_url"];
        }
        else
            image_string = @"http://www.drcarlito.com/wp-content/uploads/2015/11/Physician-Picture1-deleted-361ff410bd1f74feecdabc3ff33f3b33.jpg";
        
        NSMutableArray *recentStoresArray = [[NSMutableArray alloc] init];
        NSArray *savedStores = [NeediatorUtitity savedDataForKey:kSAVE_RECENT_STORES];
        
        NSDictionary *storeData = @{
                                    @"name"         : model.name,
                                    @"storeid"      : model.list_id,
                                    @"categoryid"   : self.category_id,
                                    @"area"         : model.area,
                                    @"code"         : model.code,
                                    @"image"        : image_string
                                    };
        
        // check if the saved store has reached limit
        if (savedStores != nil && savedStores.count < 10) {
            
            // copy all saved stores to array
            [recentStoresArray addObjectsFromArray:savedStores];
        }
        else {
            // copy the first 9 elements and save to array
            NSRange range = NSMakeRange(0, 9);
            NSArray *array = [savedStores subarrayWithRange:range];
            [recentStoresArray addObjectsFromArray:array];
        }
        // remove duplicates from the array.
        if ([recentStoresArray containsObject:storeData]) {
            [recentStoresArray removeObject:storeData];
        }
        // finally insert the selected store to array and save it.
        [recentStoresArray insertObject:storeData atIndex:0];
        [NeediatorUtitity save:recentStoresArray forKey:kSAVE_RECENT_STORES];
        
        // save the store_id for remembering current store id.
        
        [NeediatorUtitity save:model.list_id forKey:kSAVE_STORE_ID];
        
        //        if (_isProductType == TRUE) {
        // Show taxons VC
        
        StoreTaxonsViewController *storeTaxonsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"storeTaxonsVC"];
        storeTaxonsVC.title =               [model.name capitalizedString];
        storeTaxonsVC.cat_id =              self.category_id;
        storeTaxonsVC.store_id =            model.list_id;
        storeTaxonsVC.storeImages =         model.images;
        storeTaxonsVC.storePhoneNumbers =   model.phone_nos;
        storeTaxonsVC.storeDistance =       model.nearest_distance.uppercaseString;
        storeTaxonsVC.ratings   =           model.ratings;
        storeTaxonsVC.reviewsCount =        model.reviews_count;
        storeTaxonsVC.likeUnlikeArray =     model.likeUnlike;
        storeTaxonsVC.isFavourite   =       model.isFavourite.boolValue;
        storeTaxonsVC.isLikedStore  =       model.isLike.boolValue;
        storeTaxonsVC.isDislikedStore =     model.isDislike.boolValue;
        storeTaxonsVC.offersarray=          model.offerArray;
        storeTaxonsVC.isOffer=              model.isOffer;//sharad testing
        storeTaxonsVC.storeURL=             model.image_url;
        storeTaxonsVC.storeName=            model.name;
        storeTaxonsVC.storearea=            model.area;
        
        
        
        NSLog(@"Model Url IS %@",model.image_url);
        
        /*
         
         if (model.premium.count != 0) {
         NSDictionary *premiumDict = model.premium[0];
         if (premiumDict != nil) {
         if ([premiumDict[@"name"] isEqualToString:@"Gold"]) {
         
         storeTaxonsVC.background_color = [UIColor colorWithRed:255/255.f green:223/255.f blue:0/255.f alpha:1.0];
         }
         else if ([premiumDict[@"name"] isEqualToString:@"Silver"]) {
         
         storeTaxonsVC.background_color = [UIColor colorWithRed:192/255.f green:192/255.f blue:192/255.f alpha:1.0];
         }
         else if ([premiumDict[@"name"] isEqualToString:@"Bronze"]) {
         
         storeTaxonsVC.background_color = [UIColor colorWithRed:205/255.f green:127/255.f blue:50/255.f alpha:1.0];
         }
         }
         }
         else {
         storeTaxonsVC.background_color = [NeediatorUtitity defaultColor];
         }
         */
        storeTaxonsVC.hidesBottomBarWhenPushed = NO;
        [self.navigationController pushViewController:storeTaxonsVC animated:YES];
        
        //        }
        //        else {
        //            NEntityDetailViewController *NEntityVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NEntityVC"];
        //            NEntityVC.cat_id    = self.category_id;
        //            NEntityVC.entity_id = model.list_id;
        //            NEntityVC.title     = model.name.uppercaseString;
        //            NEntityVC.isBooking = _isBooking;
        //            NEntityVC.entity_name = model.name;
        //            NEntityVC.entity_meta_info = self.title;
        //            NEntityVC.entity_image = model.image_url;
        
        //           [self.navigationController pushViewController:NEntityVC animated:YES];
        //        }
    }
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 160;
        }
        else
            return 130.f;
    }
    else {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return kHeaderViewHeight_Pad;
        }
        else
            return kHeaderViewHeight_Phone;
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    /*
    if (section == 0) {
        header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 50)];
        header.backgroundColor = [NeediatorUtitity defaultColor];
        
        UILabel *resultsCount =[[ UILabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(self.view.frame) - 150, 30)];
        
        NSLog(@"Total Count Is %@",_totalCount);
        
       if([_totalCount isEqualToString:@"0"]||[_totalCount isEqualToString:@"1"])
       {
           resultsCount.text = [NSString stringWithFormat:@"Showing %@ result", _totalCount];
       }
        else
        {
            resultsCount.text = [NSString stringWithFormat:@"Showing %@ results", _totalCount];
        }
        
        resultsCount.font = [NeediatorUtitity regularFontWithSize:13.f];
        resultsCount.backgroundColor = [UIColor clearColor];
        
        sort = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 120, 10, 40, 30)];
        [sort setTitle:@"SORT" forState:UIControlStateNormal];
        [sort setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        sort.titleLabel.font = [NeediatorUtitity demiBoldFontWithSize:15.f];
        sort.backgroundColor = [UIColor clearColor];
        [sort addTarget:self action:@selector(displaySortingSheet:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *filter = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) - 70, 10, 60, 30)];
        [filter setTitle:@"FILTER" forState:UIControlStateNormal];
        filter.titleLabel.font = [NeediatorUtitity demiBoldFontWithSize:15.f];
        [filter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        filter.backgroundColor = [UIColor clearColor];
        [filter addTarget:self action:@selector(displayFilterVC:) forControlEvents:UIControlEventTouchUpInside];
        
        [header addSubview:filter];
        [header addSubview:sort];
        [header addSubview:resultsCount];
        
        return header;
    }
    else
        */
        
        
        return nil;
    
}





-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
//    if (section == 0)
//    {
//        return 50.f;
//    }
    //    return 5.f;
    
    /*
     if (section == 0) {
     if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
     return kHeaderViewHeight_Pad + 10;
     }
     else
     return kHeaderViewHeight_Phone + 10;
     }
     else
     return 5.f;
     */
    
    return 0.5f;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 90.f;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    
    UIView *footerView      =       [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 90)];
    footerView.backgroundColor      =   [UIColor clearColor];
    
    
        UILabel *countLabel     =       [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAIN_WIDTH, 40)];
        countLabel.textAlignment    =   NSTextAlignmentCenter;
        countLabel.font             =   regularFont(13);
        countLabel.backgroundColor  =   defaultColor();
    
        if([_totalCount isEqualToString:@"0"]||[_totalCount isEqualToString:@"1"])
        {
            countLabel.text = [NSString stringWithFormat:@"Showing %@ result", _totalCount];
        }
        else
        {
            countLabel.text = [NSString stringWithFormat:@"Showing %@ results", _totalCount];
        }
    
    
        UIButton *sortButton        =   [[UIButton alloc] initWithFrame:CGRectMake(0, 40, MAIN_WIDTH/2, 50)];
        [sortButton setTitle:@"SORT" forState:UIControlStateNormal];
        [sortButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [sortButton.titleLabel setFont:demiBoldFont(15)];
        [sortButton setBackgroundColor:[UIColor blackColor]];
        [sortButton addTarget:self action:@selector(displaySortingSheet:) forControlEvents:UIControlEventTouchUpInside];
    
        
        UIButton *filterButton        =   [[UIButton alloc] initWithFrame:CGRectMake(MAIN_WIDTH/2, 40, MAIN_WIDTH/2, 50)];
        [filterButton setTitle:@"FILTER" forState:UIControlStateNormal];
        [filterButton setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
        [filterButton.titleLabel setFont:demiBoldFont(15)];
        [filterButton setBackgroundColor:[UIColor blackColor]];
        [filterButton addTarget:self action:@selector(displayFilterVC:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [footerView addSubview:countLabel];
    [footerView addSubview:sortButton];
    [footerView addSubview:filterButton];
    
    
    
    return footerView;
}

/*
 -(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
 
 if (section == 0) {
 return [self layoutBannerHeaderView];
 }
 else
 return nil;
 }
 */


-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell  =[tableView cellForRowAtIndexPath:indexPath];
    
    UIView *view = cell.contentView;
    view.backgroundColor = [UIColor colorWithRed:244/255.f green:237/255.f blue:7/255.f alpha:1.0];
    
}

-(void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    UIView *view = [cell contentView];
    view.backgroundColor = [UIColor clearColor];
}




-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != 0) {
        return YES;
    }
    else
        return NO;
}


-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ListingModel *model = self.listingArray[indexPath.row - 1];
    
    UITableViewRowAction *callAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Call" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        NSLog(@" Calling ...");
        
        [self showPhoneNumbers:model.phone_nos];
        
    }];
    callAction.backgroundColor = [UIColor colorWithRed:29/255.f green:162/255.f blue:97/255.f alpha:1.0];
    
    return @[callAction];
    
}


#pragma mark - Helper Methods

-(void)showHUD
{
    self.hud = [[NeediatorHUD alloc] initWithFrame:self.tableView.frame];
    self.hud.overlayColor = [NeediatorUtitity blurredDefaultColor];
    [self.hud fadeInAnimated:YES];
    self.hud.hudCenter = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) / 2);
    [self.navigationController.view insertSubview:self.hud belowSubview:self.navigationController.navigationBar];
}

-(void)hideHUD
{
    
    [self.hud fadeOutAnimated:YES];
    [self.hud removeFromSuperview];
    
}


-(void)listingGoToSearchTab
{
    [self.noListingView removeFromSuperview];
    UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
    [tabBarController setSelectedIndex:1];
}



-(void)shownoListingView:(Location *)location {
    
    self.noListingView = [[[NSBundle mainBundle] loadNibNamed:@"NoStores" owner:self options:nil] lastObject];
    self.noListingView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    self.noListingView.tag = kListingNoListingTag;
    
    if (_isFilterApplied) {
        
        self.noListingView.message.text  = @"'Keep Calm ! Our Team is working to serve in your location'";
        self.noListingView.location.text = @"Filter";
        [self.noListingView.changeButton addTarget:self action:@selector(displayFilterVC:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        self.noListingView.location.text = location.location_name;
        [self.noListingView.changeButton addTarget:self action:@selector(listingGoToSearchTab) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    [self.navigationController.view insertSubview:self.noListingView belowSubview:self.navigationController.navigationBar];
}


-(void)showNoResultsFoundView {}


-(void)removeConnectionView {
    
    if (_connectionView) {
        [[self.navigationController.view viewWithTag:kListingConnectionViewTag] removeFromSuperview];
    }
}


-(void)displayImageFullScreen:(UITapGestureRecognizer *)tapGesture {
    
    _tappedImageView = (UIImageView *)tapGesture.view;
    
    ListingCell *cell = (ListingCell *)[[[_tappedImageView superview] superview] superview];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath.row != 0) {
        ImageModalViewController *imageModalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"imageModalVC"];
        imageModalVC.model                  = self.listingArray[indexPath.row - 1];
        
        imageModalVC.transitioningDelegate = self;
        imageModalVC.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:imageModalVC animated:YES completion:nil];
    }
}

-(void)makeCall:(NSString *)number {
    
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@",number]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
    } else
    {
        UIAlertView *callAlertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Call facility is not available!!!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [callAlertView show];
    }
}

-(void)showPhoneNumbers:(NSArray *)phoneNumbers {
    
    if (phoneNumbers != nil) {
        UIAlertController *phoneAlertController = [UIAlertController alertControllerWithTitle:@"Store Phone Numbers" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        [phoneNumbers enumerateObjectsUsingBlock:^(NSString *_Nonnull phoneNumber, NSUInteger idx, BOOL * _Nonnull stop) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:phoneNumber style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self makeCall:phoneNumber];
            }];
            
            [phoneAlertController addAction:action];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [phoneAlertController dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [phoneAlertController addAction:cancelAction];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:phoneAlertController animated:YES completion:nil];
        }
        else {
            UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:phoneAlertController];
            [popup presentPopoverFromRect:sort.bounds inView:[sort superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
    
    else
        NSLog(@"Phone numbers are nil");
}



-(void)displayFilterVC:(UIButton *)sender
{
//    FilterTableViewController *filterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"filterTableVC"];
//    filterVC.filterArray = self.filter_list;
//    filterVC.delegate = self;
//    [self.navigationController pushViewController:filterVC animated:YES];
    
//
    
    UIStoryboard *storeStoryboard  =   [UIStoryboard storyboardWithName:@"StoreStoryboard" bundle:nil];
    FilterViewController *newFilterVC  =   [storeStoryboard instantiateViewControllerWithIdentifier:@"filterViewControllerID"];
    [self.navigationController pushViewController:newFilterVC animated:YES];

    
}



-(void)appliedFilterListingDelegate:(NSDictionary *)data
{
    
    [self requestListingByFilterData:data sortID:@"" andTypeID:@""];
}


-(void)displaySortingSheet:(UIButton *)sender
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Sort" message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    [self.sorting_list enumerateObjectsUsingBlock:^(SortListModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        if ([model.currentSortOrderIndex  isEqual: @-1]) {
            model.currentSortOrderIndex = @0;
        }
        
        
        SortOrderModel *sortOrderModel = model.typeArray[model.currentSortOrderIndex.intValue];
        
        NSString *code = [sortOrderModel.name substringFromIndex: [sortOrderModel.name length] - 1];
        
        NSLog(@"%@",code);
        
        //        NSString *name = [NSString stringWithFormat:@"%@ - %@", model.name.capitalizedString, sortOrderModel.name.capitalizedString];
        
        //displaying for asc and desc symbol in action sheet
        NSString *name = [NSString stringWithFormat:@"%@  %@", model.name.capitalizedString,code];
        
        UIAlertAction *typeAction = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"Sort by %@", name);
            
            [self requestListingBySortID:model.sortID.stringValue andTypeID:sortOrderModel.sortOrderID.stringValue];
            
            int index = model.currentSortOrderIndex.intValue;
            
            if (++index == model.typeArray.count) {
                model.currentSortOrderIndex = 0;
            }
            else
                model.currentSortOrderIndex = @(index);
            
        }];
        
        [controller addAction:typeAction];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel");
    }];
    [controller addAction:cancel];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:controller animated:YES completion:nil];
    }
    else {
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:controller];
        [popup presentPopoverFromRect:sender.bounds inView:[sender superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


- (void)configureNavigationController:(UINavigationController *)navController withModel:(ListingModel *)model {
    
    if ([navController.topViewController isKindOfClass:[StoreTaxonsViewController class]])
    {
        StoreTaxonsViewController *storeTaxonsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"storeTaxonsVC"];
        storeTaxonsVC.title = [model.name capitalizedString];
        storeTaxonsVC.cat_id = self.category_id;
        storeTaxonsVC.store_id = model.list_id;
        storeTaxonsVC.storeImages = model.images;
        storeTaxonsVC.storePhoneNumbers = model.phone_nos;
        storeTaxonsVC.storeDistance = model.nearest_distance.uppercaseString;
        storeTaxonsVC.ratings   = model.ratings;
        storeTaxonsVC.reviewsCount = model.reviews_count;
        storeTaxonsVC.likeUnlikeArray = model.likeUnlike;
        storeTaxonsVC.offersarray=model.offerArray;
        
        
        //        storeTaxonsVC.hidesBottomBarWhenPushed = NO;
        //        [self.navigationController pushViewController:storeTaxonsVC animated:YES];
        
    }
    else if ([navController.topViewController isKindOfClass:[NEntityDetailViewController class]]) {
        
        //        NEntityDetailViewController *NEntityVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NEntityVC"];
        //        NEntityVC.cat_id    = self.category_id;
        //        NEntityVC.entity_id = model.list_id;
        //        NEntityVC.title     = model.name.uppercaseString;
        //        NEntityVC.isBooking = _isBooking;
        //
        //        NEntityVC.entity_name = model.name;
        //        NEntityVC.entity_meta_info = self.title;
        //        NEntityVC.entity_image = model.image_url;
        
        //        [self.navigationController pushViewController:NEntityVC animated:YES];
    }
}


-(void)goToAppointmentPage:(UIButton *)sender
{
    
    ListingCell *cell = (ListingCell *)[[[sender superview] superview] superview];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Cell index %ld", (long)indexPath.row);
    
    ListingModel *model = self.listingArray[indexPath.row - 1];
    
    BookingViewController *bookingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"makeBookingVC"];
    bookingVC.category_id = self.category_id;
    bookingVC.entity_id  = model.list_id;
    bookingVC.entity_name = model.name;
    bookingVC.image_url = model.image_url;
    
    [self.navigationController pushViewController:bookingVC animated:YES];
}



-(void)changeDot:(id)sender
{
    
    // NSLog(@"changing");
    
    BannerTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // Calclulate new offset
    NSInteger index = cell.carousel.currentItemIndex;
    
    //  NSLog(@"Current Index is %ld", (long)index);
    
    if (index == 0) {
        index = self.bannerImages.count-1;
        
        //     NSLog(@"oval Index is %ld", (long)index);
    }
    else {
        index--;
        //       NSLog(@"deduced Index is %ld", (long)index);
    }
    
    [cell.carousel scrollToItemAtIndex:index animated:YES];
    [self performSelector:@selector(changeDot:) withObject:nil afterDelay:2.5f];
}


#pragma mark - Network


-(void)requestListingByFilterData:(NSDictionary *)data sortID:(NSString *)sort_id andTypeID:(NSString *)type_id {
    
    Location *location_store = [Location savedLocation];
    User *user          = [User savedUser];
    
    NSMutableDictionary *parameter = [[NSMutableDictionary alloc] init];
    
    [parameter addEntriesFromDictionary:data];
    
    [parameter setObject:location_store.latitude forKey:@"latitude"];
    [parameter setObject:location_store.longitude forKey:@"longitude"];
    [parameter setObject:self.category_id forKey:@"Sectionid"];
    [parameter setObject:self.subcategory_id forKey:@"Categoryid"];
    [parameter setObject:@"1" forKey:@"page"];
    [parameter setObject:sort_id forKey:@"type_id"];
    [parameter setObject:type_id forKey:@"sort_type"];
    
    
    if (user.userID != nil) {
        [parameter setObject:user.userID forKey:@"userid"];
    }
    else
        [parameter setObject:@"" forKey:@"userid"];
    
    NSLog(@"%@", parameter);
    
    _isFilterApplied = YES;
    _filterData      = data;
    
    [self requestListings:parameter];
}



-(void)requestListingBySortID:(NSString *)sort_id andTypeID:(NSString *)type_id {
    
    
    Location *location_store = [Location savedLocation];
    User *user          = [User savedUser];
    
    
    if (_filterData == nil)
    {
        ListingRequestModel *requestModel = [ListingRequestModel new];
        requestModel.latitude             = location_store.latitude;
        requestModel.longitude            = location_store.longitude;
        requestModel.category_id          = self.category_id;
        requestModel.subcategory_id       = self.subcategory_id;
        requestModel.page                 = @"1";
        requestModel.sort_id              = sort_id;
        requestModel.sortOrder_id         = type_id;
        requestModel.is24Hrs              = @"";
        requestModel.hasOffers            = @"";
        requestModel.minDelivery_id       = @"";
        requestModel.ratings_id           = @"";
        requestModel.user_id              = (user.userID != nil) ? user.userID : @"";
        
        [self requestListings:requestModel];
    }
    else {
        
        [self requestListingByFilterData:_filterData sortID:sort_id andTypeID:type_id];
    }
    
}

-(void)requestBasicListings {
    
    Location *location_store = [Location savedLocation];
    User *user  = [User savedUser];
    
    
    ListingRequestModel *requestModel = [ListingRequestModel new];
    requestModel.latitude             = location_store.latitude;
    requestModel.longitude            = location_store.longitude;
    requestModel.category_id          = self.category_id;
    requestModel.subcategory_id       = self.subcategory_id;
    
    requestModel.page                 = @"1";
    requestModel.sort_id              = @"2";
    requestModel.sortOrder_id         = @"1";
    
    requestModel.is24Hrs              = @"";
    requestModel.hasOffers            = @"";
    requestModel.minDelivery_id       = @"";
    requestModel.ratings_id           = @"";
    requestModel.user_id              = (user.userID != nil) ? user.userID : @"";
    
    [self requestListings:requestModel];
    
}


-(void)requestListings:(id)requestModel
{
    
    self.navigationItem.rightBarButtonItem = [NeediatorUtitity locationBarButton];
    [self removeConnectionView];
    
    Location *location_store = [Location savedLocation];
    
    
    [self showHUD];
    
    _task   = [[NAPIManager sharedManager] getListingsWithRequestModel:requestModel success:^(ListingResponseModel *response) {
        
        _listingArray = response.records;
        _isProductType  = response.isProductType;
        _totalCount     = response.total_count.stringValue;
        
        if (_listingArray.count == 0) {
            
            [self shownoListingView:location_store];
        }
        
        
        
        if (_viewDidLoadFlag) {
            [NeediatorUtitity save:response.deliveryTypes forKey:kSAVE_DELIVERY_TYPES];
            [NeediatorUtitity save:response.addressTypes forKey:kSAVE_Address_Types];
            [NeediatorUtitity save:response.PurposeType forKey:kSAVE_Purpose_Types];
            
            self.sorting_list = response.sorting_list;
            self.filter_list    = response.filter_list;
            
            _viewDidLoadFlag = NO;
        }
        
        
        [self hideHUD];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error)
               {
                   
                   [self hideHUD];
                   
                   NSLog(@"Error: %@", error.localizedDescription);
                   
                   _connectionView = [[[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil] lastObject];
                   _connectionView.tag = kListingConnectionViewTag;
                   _connectionView.frame = CGRectMake(0, 64.f, self.view.frame.size.width, self.view.frame.size.height);
                   
                   NSLog(@"%f, %f, %@", self.topLayoutGuide.length, self.bottomLayoutGuide.length, NSStringFromCGRect(_connectionView.frame));
                   _connectionView.label.text = [error localizedDescription];
                   [_connectionView.retryButton addTarget:self action:@selector(requestBasicListings) forControlEvents:UIControlEventTouchUpInside];
                   
                   [self.navigationController.view insertSubview:_connectionView belowSubview:self.navigationController.navigationBar];
               }];
}






#pragma mark - UIViewControllerTransitioningDelegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}


#pragma mark - UIViewControllerAnimatedTransitioning

-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1.0;
}

-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    
    UIView *container       = transitionContext.containerView;
    
    UIViewController *fromVC    = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ImageModalViewController *toVC      = (ImageModalViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView            = fromVC.view;
    UIView *toView              = toVC.view;
    
    
    CGRect beginFrame;
    CGRect endFrame             = toView.frame;
    
    if (_isBooking) {
        BookCallListingCell *cell = (BookCallListingCell *)[[[_tappedImageView superview] superview] superview];
        beginFrame           = [container convertRect:cell.profileImageview.frame fromView:cell.profileImageview.superview];
    }
    else {
        ListingCell *cell       = (ListingCell *)[[[_tappedImageView superview] superview] superview];
        beginFrame           = [container convertRect:cell.profileImageview.frame fromView:cell.profileImageview.superview];
    }
    
    
    
    
    NSLog(@"%@",toView.subviews);
    
    UIView *move                = nil;
    
    if (toVC.isBeingPresented) {
        toView.frame            = endFrame;
        move                    = [toView snapshotViewAfterScreenUpdates:YES];
        move.frame              = beginFrame;
        
        if (_isBooking) {
            BookCallListingCell *cell = (BookCallListingCell *)[[[_tappedImageView superview] superview] superview];
            cell.profileImageview.hidden   = YES;
        }
        else {
            ListingCell *cell       = (ListingCell *)[[[_tappedImageView superview] superview] superview];
            cell.profileImageview.hidden   = YES;
        }
        
        
    } else {
        
        ImageModalViewController *modalVC       = (ImageModalViewController *)fromVC;
        modalVC.imageContentView.backgroundColor = [UIColor clearColor];
        
        move        = [fromView snapshotViewAfterScreenUpdates:NO];
        move.frame  = fromView.frame;
        
        [fromView removeFromSuperview];
        
    }
    
    [container addSubview:move];
    
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:500 initialSpringVelocity:15 options:0 animations:^{
        move.frame = toVC.isBeingPresented ? endFrame : beginFrame;
        
    } completion:^(BOOL finished) {
        if (toVC.isBeingPresented) {
            
            [move removeFromSuperview];
            toView.frame    = endFrame;
            [container addSubview:toView];
            
        } else {
            
            if (_isBooking) {
                BookCallListingCell *cell = (BookCallListingCell *)[[[_tappedImageView superview] superview] superview];
                cell.profileImageview.hidden   = NO;
            }
            else {
                ListingCell *cell = (ListingCell *)[[[_tappedImageView superview] superview] superview];
                cell.profileImageview.hidden   = NO;
            }
        }
        [transitionContext completeTransition:YES];
    }];
    
}


#pragma mark -
#pragma mark iCarousel methods

- (NSInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return self.bannerImages.count;
}


- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    
    BannerTableViewCell *cell = (BannerTableViewCell *)[[carousel superview] superview];
    
    
    if (view == nil)
    {
        
        NSString *image_string = self.bannerImages[index];
        
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(cell.carousel.frame), CGRectGetHeight(cell.carousel.frame))];
        NSURL *image_url = [NSURL URLWithString:image_string];
        
        [(UIImageView *)view sd_setImageWithURL:image_url placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
    }
    
    return view;
}


-(void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    
    NSInteger index = self.bannerImages.count -1 - carousel.currentItemIndex;
    
    index ++;
    // NSLog(@"Current Index is %ld and calc. index is %ld", (long)carousel.currentItemIndex, (long)index);
    
    if(index == self.bannerImages.count) {
        index = 0;
    }
    
    BannerTableViewCell *cell = (BannerTableViewCell *)[[carousel superview] superview];
    cell.pageControl.currentPage = index;
}

/*
 
 
 -(void)setupScrollViewImages:(BannerTableViewCell *)cell {
 
 [self.bannerImages enumerateObjectsUsingBlock:^(NSString *imageName, NSUInteger idx, BOOL *stop) {
 UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.scrollView.frame) * idx, 0, CGRectGetWidth(cell.scrollView.frame), CGRectGetHeight(cell.scrollView.frame))];
 imageView.tag = idx;
 
 NSURL *url = [NSURL URLWithString:imageName];
 
 //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 //
 //            SDWebImageManager *manager = [SDWebImageManager sharedManager];
 //
 //            [manager downloadImageWithURL:url options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
 //                NSLog(@"Image %ld of %ld", (long)receivedSize, (long)expectedSize);
 //            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
 //
 //                if (image) {
 //
 //                    dispatch_async(dispatch_get_main_queue(), ^{
 //
 //                        CIImage *newImage = [[CIImage alloc] initWithImage:image];
 //                        CIContext *context = [CIContext contextWithOptions:nil];
 //                        CGImageRef reference = [context createCGImage:newImage fromRect:newImage.extent];
 //
 //                        imageView.image  = [UIImage imageWithCGImage:reference scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
 //                    });
 //                }
 //
 //            }];
 //        });
 
 [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
 
 [cell.scrollView addSubview:imageView];
 }];
 }
 
 -(void)layoutBannerViewCell:(BannerTableViewCell *)cell {
 
 
 
 CGRect frame;
 
 if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
 frame = CGRectMake(0, 0, self.view.frame.size.width, kHeaderViewHeight_Pad + 10);
 }
 else
 frame = CGRectMake(0, 0, self.view.frame.size.width, kHeaderViewHeight_Phone + 10);
 
 cell.frame = frame;
 [cell layoutIfNeeded];
 
 
 
 CGRect scrollViewFrame = cell.scrollView.frame;
 CGRect currentFrame = self.view.frame;
 
 scrollViewFrame.size.width = currentFrame.size.width;
 cell.scrollView.frame = scrollViewFrame;
 
 
 cell.pageControl.numberOfPages = self.bannerImages.count;
 
 }
 */


@end

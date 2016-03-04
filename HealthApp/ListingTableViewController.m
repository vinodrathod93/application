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
#import "BannerView.h"


@interface ListingTableViewController ()<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSArray *listingArray;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NoStores *noListingView;
@property (nonatomic, strong) BannerView *bannerView;
@property (nonatomic, strong) NSArray *bannerImages;

@end

@implementation ListingTableViewController {
    NSURLSessionDataTask *_task;
    NoConnectionView *_connectionView;
    UITapGestureRecognizer *_tap;
    UIImageView *_tappedImageView;
    BOOL _isBooking;
    BOOL _isProductType;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.root.uppercaseString;
    self.tableView.backgroundColor = [UIColor colorFromHexString:@"#EEEEEE"];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    
    
    
    
    self.bannerImages = @[@"http://g-ecx.images-amazon.com/images/G/31/img15/video-games/Gateway/new-year._UX1500_SX1500_CB285786565_.jpg", @"http://g-ecx.images-amazon.com/images/G/31/img15/Shoes/December/4._UX1500_SX1500_CB286226002_.jpg", @"http://g-ecx.images-amazon.com/images/G/31/img15/softlines/apparel/201512/GW/New-GW-Hero-1._UX1500_SX1500_CB301105718_.jpg",@"http://img5a.flixcart.com/www/promos/new/20151229_193348_730x300_image-730-300-8.jpg",@"http://img5a.flixcart.com/www/promos/new/20151228_231438_730x300_image-730-300-15.jpg"];
    
    
   
    
}





-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.navigationItem.rightBarButtonItem = [NeediatorUtitity locationBarButton];
    
    [self requestListings];
    
    
}




-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_task cancel];
    [[self.navigationController.view viewWithTag:kListingNoListingTag] removeFromSuperview];
    [self removeConnectionView];
    
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _bannerView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(_bannerView.scrollView.frame) * self.bannerImages.count, CGRectGetHeight(_bannerView.scrollView.frame));
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listingArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    
    ListingModel *model = self.listingArray[indexPath.section];
    
    NSString *cellIdentifier;
    id cell;
    
    if (model.isBook == [NSNumber numberWithBool:YES] || model.isCall == [NSNumber numberWithBool:YES]) {
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



-(void)configureListingCell:(ListingCell *)cell withModel:(ListingModel *)model {
    
    cell.backgroundColor = [UIColor clearColor];
    
    _tap            = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayImageFullScreen:)];
    [cell.profileImageview addGestureRecognizer:_tap];
    [cell.profileImageview setUserInteractionEnabled:YES];
    
    cell.roundedContentView.layer.cornerRadius = 5.f;
    cell.roundedContentView.layer.masksToBounds = YES;
    
    cell.name.text = model.name;
    cell.street.text = model.address;
    cell.rating.text = [NSString stringWithFormat:@"%.01f", model.ratings.floatValue];
    cell.distance.text = [NSString stringWithFormat:@"📍 %@",model.nearest_distance];
    cell.timing.text    = [NSString stringWithFormat:@"🕒 %@",model.timing];
    
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
    
    
}


-(void)configureBookCallCell:(BookCallListingCell *)cell withModel:(ListingModel *)model {
    
    cell.backgroundColor = [UIColor clearColor];
    
    
    _tap            = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayImageFullScreen:)];
    [cell.profileImageview addGestureRecognizer:_tap];
    [cell.profileImageview setUserInteractionEnabled:YES];
    
    cell.corneredView.layer.cornerRadius = 5.f;
    cell.corneredView.layer.masksToBounds = YES;
    
    cell.name.text = model.name;
    cell.address.text = model.address;
    cell.ratingLabel.text = [NSString stringWithFormat:@"%.01f", model.ratings.floatValue];
    cell.distance.text = [NSString stringWithFormat:@"📍 %@",model.nearest_distance];
    cell.timing.text    = [NSString stringWithFormat:@"🕒 %@",model.timing];
    
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
    
    NSString *title                     = model.isBook ? @"BOOK" : model.isCall ? @"CALL" : @"";
    [cell.button setTitle:title forState:UIControlStateNormal];
    
    if ([title isEqualToString:@""]) {
        [cell.button removeFromSuperview];
    }
    
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ListingModel *model = self.listingArray[indexPath.section];
    
    
    if (_isProductType == TRUE) {
        // Show taxons VC
        
        StoreTaxonsViewController *storeTaxonsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"storeTaxonsVC"];
        storeTaxonsVC.title = [model.name capitalizedString];
        storeTaxonsVC.cat_id = self.category_id;
        storeTaxonsVC.store_id = model.list_id.stringValue;
        
        storeTaxonsVC.hidesBottomBarWhenPushed = NO;
        [self.navigationController pushViewController:storeTaxonsVC animated:YES];
        
    }
    else {
        NEntityDetailViewController *NEntityVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NEntityVC"];
        NEntityVC.cat_id    = self.category_id;
        NEntityVC.entity_id = model.list_id.stringValue;
        NEntityVC.title     = model.name.uppercaseString;
        NEntityVC.isBooking = _isBooking;
        
        NEntityVC.entity_name = model.name;
        NEntityVC.entity_meta_info = self.title;
        NEntityVC.entity_image = model.image_url;
        
        [self.navigationController pushViewController:NEntityVC animated:YES];
    }
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 180;
    }
    else
        return 140.f;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
//    if (section == 0) {
//        return 40.f;
//    }
//    return 5.f;
    
    if (section == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return kHeaderViewHeight_Pad + 10;
        }
        else
            return kHeaderViewHeight_Phone + 10;
    }
    else
        return 5.f;
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.f;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return [self layoutBannerHeaderView];
    }
    else
        return nil;
    
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (section == 0) {
//        Location *savedLocation = [Location savedLocation];
//        
//        NSString *loc_name;
//        
//        if (savedLocation.location_name == nil)
//            loc_name            = @"No Location";
//        else
//            loc_name            = savedLocation.location_name;
//        
//        return [NSString stringWithFormat:@"%@",loc_name];
//    }
//    else
//        return @"";
//}


-(UIView *)layoutBannerHeaderView {
    _bannerView = [[[NSBundle mainBundle] loadNibNamed:@"BannerView" owner:self options:nil] lastObject];
    
    CGRect frame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        frame = CGRectMake(0, 0, self.view.frame.size.width, kHeaderViewHeight_Pad + 10);
    }
    else
        frame = CGRectMake(0, 0, self.view.frame.size.width, kHeaderViewHeight_Phone + 10);
    
    _bannerView.frame = frame;
    [_bannerView layoutIfNeeded];
    
    
    _bannerView.scrollView.delegate = self;
    _bannerView.scrollView.scrollEnabled = YES;
    
    CGRect scrollViewFrame = _bannerView.scrollView.frame;
    CGRect currentFrame = self.view.frame;
    
    scrollViewFrame.size.width = currentFrame.size.width;
    _bannerView.scrollView.frame = scrollViewFrame;
    
    
    [self setupScrollViewImages];
    
    
    _bannerView.pageControl.numberOfPages = self.bannerImages.count;
    
    
    
    
    
    
    return _bannerView;
    
    
}

-(void)setupScrollViewImages {
    
    [self.bannerImages enumerateObjectsUsingBlock:^(NSString *imageName, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_bannerView.scrollView.frame) * idx, 0, CGRectGetWidth(_bannerView.scrollView.frame), CGRectGetHeight(_bannerView.scrollView.frame))];
        imageView.tag = idx;
        //        [imageView sd_setImageWithURL:[NSURL URLWithString:imageName] placeholderImage:[UIImage imageNamed:@"placeholder_neediator"]];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            UIImage *image   = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageName]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CIImage *newImage = [[CIImage alloc] initWithImage:image];
                CIContext *context = [CIContext contextWithOptions:nil];
                CGImageRef reference = [context createCGImage:newImage fromRect:newImage.extent];
                
                imageView.image  = [UIImage imageWithCGImage:reference scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
            });
        });
        
        [_bannerView.scrollView addSubview:imageView];
    }];
    
    
}


#pragma mark - Scroll view Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _bannerView.scrollView) {
        NSInteger index = _bannerView.scrollView.contentOffset.x / CGRectGetWidth(_bannerView.scrollView.frame);
        NSLog(@"%ld",(long)index);
        
        _bannerView.pageControl.currentPage = index;
    }
    
    
}

#pragma mark - Helper Methods

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.color = [UIColor clearColor];
    self.hud.labelText = @"Loading...";
    self.hud.labelColor = [UIColor darkGrayColor];
    self.hud.activityIndicatorColor = [UIColor blackColor];
    self.hud.detailsLabelColor = [UIColor darkGrayColor];
}

-(void)hideHUD {
    [self.hud hide:YES];
}


-(void)goToSearchTab {
    
    
    [self.noListingView removeFromSuperview];
    
    UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
    
    [tabBarController setSelectedIndex:1];
    
    
}

-(void)shownoListingView:(Location *)location {
    
    self.noListingView = [[[NSBundle mainBundle] loadNibNamed:@"NoStores" owner:self options:nil] lastObject];
    self.noListingView.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    self.noListingView.tag = kListingNoListingTag;
    self.noListingView.location.text = location.location_name;
    
    
    [self.noListingView.changeButton addTarget:self action:@selector(goToSearchTab) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.view insertSubview:self.noListingView belowSubview:self.navigationController.navigationBar];
}


-(void)removeConnectionView {
    
    if (_connectionView) {
        [[self.navigationController.view viewWithTag:kListingConnectionViewTag] removeFromSuperview];
    }
    
}

-(void)requestListings {
    
    
    [self removeConnectionView];
    
    Location *location_store = [Location savedLocation];
    
    ListingRequestModel *requestModel = [ListingRequestModel new];
    requestModel.latitude             = location_store.latitude;
    requestModel.longitude            = location_store.longitude;
    requestModel.category_id          = self.category_id;
    requestModel.subcategory_id       = self.subcategory_id;
    requestModel.page                 = @"1";
    
    [self showHUD];
    
    
    
    _task   = [[NAPIManager sharedManager] getListingsWithRequestModel:requestModel success:^(ListingResponseModel *response) {
        
        _listingArray = response.records;
        _isProductType  = response.isProductType;
        
        if (_listingArray.count == 0) {
            [self shownoListingView:location_store];
        }
        
        
        [NeediatorUtitity save:response.deliveryTypes forKey:kDELIVERY_TYPES];
        
        
        [self hideHUD];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        
        NSLog(@"Error: %@", error.localizedDescription);
        
        _connectionView = [[[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil] lastObject];
        _connectionView.tag = kListingConnectionViewTag;
        _connectionView.frame = CGRectMake(0, 64.f, self.view.frame.size.width, self.view.frame.size.height);
        
        NSLog(@"%f, %f, %@", self.topLayoutGuide.length, self.bottomLayoutGuide.length, NSStringFromCGRect(_connectionView.frame));
        _connectionView.label.text = [error localizedDescription];
        [_connectionView.retryButton addTarget:self action:@selector(requestListings) forControlEvents:UIControlEventTouchUpInside];
        
        [self.navigationController.view insertSubview:_connectionView belowSubview:self.navigationController.navigationBar];
    }];
    
}




-(void)displayImageFullScreen:(UITapGestureRecognizer *)tapGesture {
    
    _tappedImageView = (UIImageView *)tapGesture.view;
    
    ListingCell *cell = (ListingCell *)[[[_tappedImageView superview] superview] superview];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    ImageModalViewController *imageModalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"imageModalVC"];
    imageModalVC.model                  = self.listingArray[indexPath.section];
    
    imageModalVC.transitioningDelegate = self;
    imageModalVC.modalPresentationStyle = UIModalPresentationCustom;
    
    [self presentViewController:imageModalVC animated:YES completion:nil];
    
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
                ListingCell *cell       = (ListingCell *)[[[_tappedImageView superview] superview] superview];
                cell.profileImageview.hidden   = NO;
            }
            
        }
        
        [transitionContext completeTransition:YES];
    }];
    
}


-(void)goToAppointmentPage:(UIButton *)sender {
    
    ListingCell *cell = (ListingCell *)[[[sender superview] superview] superview];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Cell index %ld", (long)indexPath.section);
    
    ListingModel *model = self.listingArray[indexPath.section];
    
    BookingViewController *bookingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"makeBookingVC"];
    bookingVC.category_id               = self.category_id;
    bookingVC.entity_id                 = model.list_id.stringValue;
    bookingVC.entity_name               = model.name;
    bookingVC.image_url                 = model.image_url;
    
    [self.navigationController pushViewController:bookingVC animated:YES];
}

@end

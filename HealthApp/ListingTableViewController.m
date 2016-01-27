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


@interface ListingTableViewController ()<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSArray *listingArray;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NoStores *noListingView;

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
    
    
    [self requestListings];
   
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorFromHexString:self.nav_color]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                    [UIColor whiteColor], NSForegroundColorAttributeName,
                                                                    [UIFont fontWithName:@"AvenirNext-DemiBold" size:19.f], NSFontAttributeName , nil]];
    
    [self.tabBarController.tabBar setBarTintColor:[UIColor colorFromHexString:self.nav_color]];
    [self.tabBarController.tabBar setTintColor:[UIColor whiteColor]];
    
    NSLog(@"%@", self.tabBarController.tabBar.items);
    
    
    [self.tabBarController.tabBar.items enumerateObjectsUsingBlock:^(UITabBarItem * _Nonnull tabBarItem, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"AvenirNext-DemiBold" size:9.f], NSFontAttributeName, nil] forState:UIControlStateSelected];
    }];
    
    
}




-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_task cancel];
    [[self.navigationController.view viewWithTag:kListingNoListingTag] removeFromSuperview];
    [self removeConnectionView];
    
    
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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
    return 140.f;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return 40.f;
    }
    return 5.f;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5.f;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        Location *savedLocation = [Location savedLocation];
        
        NSString *loc_name;
        
        if (savedLocation.location_name == nil)
            loc_name            = @"No Location";
        else
            loc_name            = savedLocation.location_name;
        
        return [NSString stringWithFormat:@"%@",loc_name];
    }
    else
        return @"";
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
    requestModel.page                 = @"1";
    
    [self showHUD];
    
    
    
    _task   = [[NAPIManager sharedManager] getListingsWithRequestModel:requestModel success:^(ListingResponseModel *response) {
        
        _listingArray = response.records;
        _isProductType  = response.isProductType;
        
        if (_listingArray.count == 0) {
            [self shownoListingView:location_store];
        }
        
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
    bookingVC.entity_meta_info          = model.image_url;
    
    [self.navigationController pushViewController:bookingVC animated:YES];
}

@end

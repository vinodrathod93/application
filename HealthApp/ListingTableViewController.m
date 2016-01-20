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


@interface ListingTableViewController ()<UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) NSArray *listingArray;
@property (nonatomic, strong) NSArray *promotionArray;

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NoStores *noListingView;

@end

@implementation ListingTableViewController {
    NSURLSessionDataTask *_task;
    NoConnectionView *_connectionView;
    UITapGestureRecognizer *_tap;
    UIImageView *_tappedImageView;
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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
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
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [[self.navigationController.view viewWithTag:kListingNoListingTag] removeFromSuperview];
    
    [self removeConnectionView];
    
    [_task cancel];
}





#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.listingArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listingCellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.tag             = indexPath.section;
    
    ListingModel *model = self.listingArray[indexPath.section];
    
    
    _tap            = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayImageFullScreen:)];
    [cell.profileImageview addGestureRecognizer:_tap];
    [cell.profileImageview setUserInteractionEnabled:YES];
    
    cell.roundedContentView.layer.cornerRadius = 5.f;
    cell.roundedContentView.layer.masksToBounds = YES;
    
    cell.name.text = model.name;
    cell.street.text = model.address;
    cell.rating.text = [NSString stringWithFormat:@"%.01f", model.ratings.floatValue];
    cell.distance.text = model.nearest_distance;
    
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
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ListingModel *model = self.listingArray[indexPath.section];
    
    NEntityDetailViewController *NEntityVC = [self.storyboard instantiateViewControllerWithIdentifier:@"NEntityVC"];
    NEntityVC.cat_id    = self.category_id;
    NEntityVC.entity_id = model.list_id.stringValue;
    NEntityVC.title     = model.name.uppercaseString;
    
    [self.navigationController pushViewController:NEntityVC animated:YES];
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



#define Helper Methods

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
    self.noListingView.frame = self.tableView.frame;
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
    
    /*_task = [[APIManager sharedManager] GET:kSERVICES_LISTING_PATH parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSLog(@"Response = %@",responseDictionary);
        
        NSError *error;
        
        [self hideHUD];
        
        
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self hideHUD];
        
        // failure
        if (error) {
            NSLog(@"Error %@",[error localizedDescription]);
            
            
            _connectionView = [[[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil] lastObject];
            _connectionView.tag = kListingConnectionViewTag;
            _connectionView.frame = self.tableView.frame;
            _connectionView.label.text = [error localizedDescription];
            [_connectionView.retryButton addTarget:self action:@selector(requestListings) forControlEvents:UIControlEventTouchUpInside];
            
            [self.navigationController.view insertSubview:_connectionView belowSubview:self.navigationController.navigationBar];
            
        }
        
    }];*/
    
    
    
    _task   = [[NAPIManager sharedManager] getServicesWithRequestModel:requestModel success:^(ListingResponseModel *response) {
        
        _listingArray = response.services;
        _promotionArray = response.promotions;
        
        [self hideHUD];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        
        NSLog(@"Error: %@", error.localizedDescription);
        
        _connectionView = [[[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil] lastObject];
        _connectionView.tag = kListingConnectionViewTag;
        _connectionView.frame = self.tableView.frame;
        _connectionView.label.text = [error localizedDescription];
        [_connectionView.retryButton addTarget:self action:@selector(requestListings) forControlEvents:UIControlEventTouchUpInside];
        
        [self.navigationController.view insertSubview:_connectionView belowSubview:self.navigationController.navigationBar];
    }];
    
}


-(void)displayImageFullScreen:(UITapGestureRecognizer *)tapGesture {
    
    _tappedImageView = (UIImageView *)tapGesture.view;
    
    ListingCell *cell = (ListingCell *)[[[_tappedImageView superview] superview] superview];
    
    ImageModalViewController *imageModalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"imageModalVC"];
    imageModalVC.model                  = self.listingArray[cell.tag];
    
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
    
    ListingCell *cell       = (ListingCell *)[[[_tappedImageView superview] superview] superview];
    
    NSLog(@"%@", NSStringFromCGRect(cell.profileImageview.frame));
    UIView *container       = transitionContext.containerView;
    
    UIViewController *fromVC    = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    ImageModalViewController *toVC      = (ImageModalViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *fromView            = fromVC.view;
    UIView *toView              = toVC.view;
    
    
    
    CGRect beginFrame           = [container convertRect:cell.profileImageview.frame fromView:cell.profileImageview.superview];
    CGRect endFrame             = toView.frame;
    
    NSLog(@"%@",toView.subviews);
    
    UIView *move                = nil;
    
    if (toVC.isBeingPresented) {
        toView.frame            = endFrame;
        move                    = [toView snapshotViewAfterScreenUpdates:YES];
        move.frame              = beginFrame;
        cell.profileImageview.hidden   = YES;
        
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
            
            
            cell.profileImageview.hidden = NO;
        }
        
        [transitionContext completeTransition:YES];
    }];
    
}


@end

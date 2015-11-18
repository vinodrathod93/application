//
//  DetailsProductViewController.m
//  Chemist Plus
//
//  Created by adverto on 17/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "DetailsProductViewController.h"
#import "ProductImageViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "AppDelegate.h"
#import "AddToCart.h"
#import "OrderInputsViewController.h"
#import "VariantsViewController.h"
#import "YSLTransitionAnimator.h"
#import "UIViewController+YSLTransition.h"
#import <MWPhotoBrowser.h>


#define FOOTER_HEIGHT 35

@interface DetailsProductViewController ()<NSFetchedResultsControllerDelegate,YSLTransitionAnimatorDataSource,MWPhotoBrowserDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) AddToCart *addToCartModel;
@property (nonatomic, strong) NSFetchedResultsController *pd_cartFetchedResultsController;
@property (nonatomic, strong) UIButton *cartButton;
@property (nonatomic, strong) NSMutableArray *largePhotos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) UITapGestureRecognizer *imageViewTapGestureRecognizer;

@end

NSString *cellReuseIdentifier;

@implementation DetailsProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel = [[DetailProductViewModel alloc]initWithModel:self.detail];
    
    UIBarButtonItem *cartItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cart"] style:UIBarButtonItemStylePlain target:self action:@selector(showCartView:)];
    self.navigationItem.rightBarButtonItem = cartItem;
    
    _imageViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLargeImage:)];
    _imageViewTapGestureRecognizer.numberOfTapsRequired = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedLabelButton) name:@"updateAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alreadyLabelButton) name:@"updateAlreadyAdded" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAlpha) name:@"updateAlpha" object:nil];
    
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    
    
    self.tableView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    ProductImageViewCell *cell = (ProductImageViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    cell.productImage.delegate = self;
    cell.productImage.contentSize = CGSizeMake(CGRectGetWidth(cell.productImage.frame) * self.viewModel.images.count, CGRectGetHeight(cell.productImage.frame));
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [self ysl_removeTransitionDelegate];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self ysl_addTransitionDelegate:self];
    [self ysl_popTransitionAnimationWithCurrentScrollView:nil
                                    cancelAnimationPointY:0
                                        animationDuration:0.3
                                  isInteractiveTransition:YES];
}


- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)showCartView:(UIBarButtonItem *)sender {
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (section == 0) {
        return [self.viewModel numberOfRows];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cellReuseIdentifier = @"imageDetailsCell";
        }
    }
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureImageViewCell:cell forIndexPath:indexPath];
        }
    }
    
    return cell;
}

-(void)configureImageViewCell:(ProductImageViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    [self prepareImageView:cell forIndexPath:indexPath];
    
    cell.productLabel.text = [self.viewModel name];
    cell.summaryLabel.text = [self.viewModel summary];
    cell.priceLabel.text = [self.viewModel display_price];
}


-(void)prepareImageView:(ProductImageViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    
    
    CGRect scrollViewFrame = cell.productImage.frame;
    CGRect currentFrame = self.view.frame;
    
    scrollViewFrame.size.width = currentFrame.size.width;
    cell.productImage.frame = scrollViewFrame;
    
    [self.viewModel.images enumerateObjectsUsingBlock:^(NSString *image_url, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.productImage.frame) * idx, 0, CGRectGetWidth(cell.productImage.frame), CGRectGetHeight(cell.productImage.frame))];
        
        NSLog(@"%@", NSStringFromCGRect(imageView.frame));
        
        imageView.tag = idx;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [cell.productImage addGestureRecognizer:_imageViewTapGestureRecognizer];
        [cell.productImage addSubview:imageView];
        
//        id views = @{@"image": imageView};
        [cell.productImage addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.productImage attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
//        [cell.productImage addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[image]-|" options:NSLayoutFormatAlignAllCenterX metrics:nil views:views]];
        
//        NSLayoutConstraint *width =[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:0 toItem:cell.productImage attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f];
//        NSLayoutConstraint *height =[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:0 toItem:cell.productImage attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
//        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.productImage attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f];
//        NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.productImage attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.f];
//        [cell.productImage addConstraint:width];
//        [cell.productImage addConstraint:height];
//        [cell.productImage addConstraint:top];
//        [cell.productImage addConstraint:leading];
//        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [imageView sd_setImageWithURL:[NSURL URLWithString:image_url]];
        });
        
    }];
    
    
    cell.pageControl.numberOfPages = self.viewModel.images.count;
    
}



-(void)drawImageView:(ProductImageViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    __block CGRect cRect = cell.productImage.bounds;
    
    [self.viewModel.images enumerateObjectsUsingBlock:^(NSString *imageURL, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = cRect;
        imageView.tag   = idx;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        [cell.productImage addSubview:imageView];
        
        cRect.origin.x += cRect.size.width;
    }];
    
    NSLog(@"%@",NSStringFromCGSize(CGSizeMake(cRect.origin.x, cell.productImage.bounds.size.height)));
    
    cell.productImage.contentSize = CGSizeMake(cRect.origin.x, cell.productImage.bounds.size.height);
    cell.productImage.contentOffset = CGPointMake(cell.productImage.bounds.size.width, 0);
    cell.pageControl.numberOfPages = self.viewModel.images.count;
}



-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    ProductImageViewCell *cell = (ProductImageViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (scrollView == cell.productImage) {
        NSInteger index = cell.productImage.contentOffset.x / CGRectGetWidth(cell.productImage.frame);
        
        cell.pageControl.currentPage = index;
    }
}

 

-(void)configureProductDetail:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self.viewModel name];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            CGFloat summaryHeight = [self.viewModel heightForSummaryTextInTableViewCellWithWidth:self.tableView.frame.size.width];
            return 400 + summaryHeight;
            
        }
    }
    
    return 250.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return FOOTER_HEIGHT;
    } else
        return 0.0f;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        self.footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FOOTER_HEIGHT)];
        
        [self addToCartButton];
        
        return self.footerView;
    }
    
    return nil;
    
}


-(void)addToCartButton {
    
    
    self.cartButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FOOTER_HEIGHT)];
    self.cartButton.backgroundColor = [UIColor lightGrayColor];
    [self.cartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cartButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    [self.cartButton addTarget:self action:@selector(addToCartButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    if ([self.viewModel isOutOfStock]) {
        [self.cartButton setTitle:@"Out of Stock" forState:UIControlStateNormal];
        self.cartButton.userInteractionEnabled = NO;
    } else {
        [self.cartButton setTitle:@"Add to Cart" forState:UIControlStateNormal];
        self.cartButton.userInteractionEnabled = YES;
    }
    
    
    [self.footerView addSubview:self.cartButton];
}

//-(void)buyButton {
//    UIButton *buyButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, FOOTER_HEIGHT)];
//    buyButton.backgroundColor = [UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f];
//    [buyButton setTitle:@"Buy Now" forState:UIControlStateNormal];
//    [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    buyButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
//    [buyButton addTarget:self action:@selector(buyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//    [self.footerView addSubview:buyButton];
//}

-(void)addToCartButtonPressed {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"AddToCart"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productID == %@",[self.viewModel productID]];
    [fetch setPredicate:predicate];
    NSArray *fetchedArray = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    
    if (self.detail.hasVariant) {
        
        VariantsViewController *variantVC = [self.storyboard instantiateViewControllerWithIdentifier:@"variantVC"];
        
        variantVC.providesPresentationContextTransitionStyle = YES;
        variantVC.definesPresentationContext = YES;
        [variantVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        
        variantVC.variants = [self.detail variants];
        variantVC.productTitle = [self.detail name];
        variantVC.productImage = [self.viewModel images][0];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 0.5f;
        }];
        
        [self presentViewController:variantVC animated:YES completion:nil];
        
    }
    else {
        
        NSLog(@"%@",fetchedArray);
        
        if (fetchedArray.count == 0) {
            self.addToCartModel = [NSEntityDescription insertNewObjectForEntityForName:@"AddToCart" inManagedObjectContext:self.managedObjectContext];
            self.addToCartModel.productID = [self.viewModel productID];
            self.addToCartModel.productName = [self.viewModel name];
            self.addToCartModel.productPrice = [self.viewModel price];
            self.addToCartModel.displayPrice = [self.viewModel display_price];
            self.addToCartModel.addedDate = [NSDate date];
            self.addToCartModel.productImage = [self.viewModel images][0];
            self.addToCartModel.quantity = [self.viewModel quantity];
            self.addToCartModel.totalPrice = [self.viewModel price];
            
            [self.managedObjectContext save:nil];
            [self addedLabelButton];
            
        }
        else {
            [self alreadyLabelButton];
        }
        
    }
}


-(void)addedLabelButton {
    [self updateAlpha];
    [self updateBadgeValue];
    
    [self.cartButton setTitle:@"Added" forState:UIControlStateNormal];
    [self.cartButton setBackgroundColor:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f]];
    
    
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addedToCartNotification" object:nil];
    
}

-(void)alreadyLabelButton {
    [self updateAlpha];
    
    [self.cartButton setTitle:@"Already Added" forState:UIControlStateNormal];
    [self.cartButton setBackgroundColor:[UIColor colorWithRed:52/255.0f green:152/255.0f blue:219/255.0f alpha:1.0f]];
}


-(void)buyButtonPressed {
    
    OrderInputsViewController *orderInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderInputsVC"];
    [self.navigationController presentViewController:orderInputVC animated:YES completion:nil];
    
}

-(void)updateBadgeValue {
    [self.pd_cartFetchedResultsController performFetch:nil];
    
    NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)self.pd_cartFetchedResultsController.fetchedObjects.count];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:count];
}


-(NSFetchedResultsController *)pd_cartFetchedResultsController {
    if (_pd_cartFetchedResultsController) {
        return _pd_cartFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"AddToCart" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"addedDate"
                                        ascending:NO];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    _pd_cartFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _pd_cartFetchedResultsController.delegate = self;
    
    NSError *error = nil;
    if (![self.pd_cartFetchedResultsController performFetch:&error]) {
        NSLog(@"Core data error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _pd_cartFetchedResultsController;
}


-(void)updateAlpha {
    
    [UIView animateWithDuration:0.2 animations:^{
        self.view.alpha = 1.0f;
    }];
    
}

-(void)getPhotosArray {
    
    self.largePhotos = [NSMutableArray array];
    self.thumbs = [NSMutableArray array];
    
    NSArray *largePhotos = [self.viewModel largeImages];
    
    if (largePhotos.count != 0) {
        for (NSString *largeImageString in largePhotos) {
            [self.largePhotos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:largeImageString]]];
        }
    }
    
    NSArray *thumbPhotos = [self.viewModel smallImages];
    
    if (thumbPhotos.count != 0) {
        for (NSString *smallImageString in thumbPhotos) {
            [self.thumbs addObject:[MWPhoto photoWithURL:[NSURL URLWithString:smallImageString]]];
        }
    }
}


- (void)handleLargeImage:(UITapGestureRecognizer *)recognizer
{
    [self getPhotosArray];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc]initWithDelegate:self];
    browser.displayActionButton = NO;
    browser.zoomPhotosToFill = YES;
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nc animated:YES completion:nil];
    
    
}


#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _largePhotos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _largePhotos.count)
        return [_largePhotos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _thumbs.count)
        return [_thumbs objectAtIndex:index];
    return nil;
}



- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser {
    // If we subscribe to this method we must dismiss the view controller ourselves
    NSLog(@"Did finish modal presentation");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index {
    
    return [self.viewModel name];
}


#pragma mark -- YSLTransitionAnimatorDataSource

- (UIImageView *)popTransitionImageView
{
    ProductImageViewCell *cell = (ProductImageViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    
    for (UIView *view in cell.productImage.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            UIImageView *image = (UIImageView *)view;
            
            return image;
        }
    }
    
    return nil;
}

- (UIImageView *)pushTransitionImageView
{
    return nil;
}




@end

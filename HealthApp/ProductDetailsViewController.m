//
//  ProductDetailsViewController.m
//  Neediator
//
//  Created by adverto on 20/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "ProductDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "AppDelegate.h"
#import "AddToCart.h"
#import "OrderInputsViewController.h"
#import "VariantsViewController.h"
#import <MWPhotoBrowser.h>

@interface ProductDetailsViewController ()<NSFetchedResultsControllerDelegate,MWPhotoBrowserDelegate, UIGestureRecognizerDelegate>
{
    int currentIndex;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) AddToCart *addToCartModel;
@property (nonatomic, strong) NSFetchedResultsController *pd_cartFetchedResultsController;
@property (nonatomic, strong) NSMutableArray *largePhotos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) UITapGestureRecognizer *imageViewTapGestureRecognizer;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation ProductDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentIndex = 0;
    
    self.viewModel = [[DetailProductViewModel alloc]initWithModel:self.detail];
    
//    UIBarButtonItem *cartItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cart"] style:UIBarButtonItemStylePlain target:self action:@selector(showCartView:)];
//    self.navigationItem.rightBarButtonItem = cartItem;
    
    _imageViewTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLargeImage:)];
    _imageViewTapGestureRecognizer.numberOfTapsRequired = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedLabelButton) name:@"updateAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alreadyLabelButton) name:@"updateAlreadyAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAlpha) name:@"updateAlpha" object:nil];
    
    
    [self prepareImageView];
    
    self.pageControl = [[UIPageControl alloc]init];
    [self.imagesScrollView addSubview:self.pageControl];
    
//    [self.pageControl addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f]];
//    [self.pageControl addConstraint:[NSLayoutConstraint constraintWithItem:self.pageControl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.imagesScrollView attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f]];
    
    self.productName.text = [self.viewModel name];
    self.productDescription.text = [self.viewModel summary];
    self.productPrice.text = [self.viewModel display_price];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.imagesScrollView.delegate = self;
    
    self.imagesScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.imagesScrollView.frame) * self.viewModel.images.count, CGRectGetHeight(self.imagesScrollView.frame));
    
}



- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationNone;
}


-(void)prepareImageView {
    
    
    
    CGRect scrollViewFrame = self.imagesScrollView.frame;
    CGRect currentFrame = self.view.frame;
    
    scrollViewFrame.size.width = currentFrame.size.width;
    self.imagesScrollView.frame = scrollViewFrame;
    
    __block UIImageView *previousImageView;
    
    [self.viewModel.images enumerateObjectsUsingBlock:^(NSString *image_url, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.imagesScrollView.frame) * idx, 0, CGRectGetWidth(self.imagesScrollView.frame), CGRectGetHeight(self.imagesScrollView.frame))];
        
        NSLog(@"%@", NSStringFromCGRect(imageView.frame));
        
        imageView.tag = idx;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.imagesScrollView addGestureRecognizer:_imageViewTapGestureRecognizer];
        [self.imagesScrollView addSubview:imageView];
        
        if (idx == 0) {
            [self.imagesScrollView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.imagesScrollView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
        } else {
            [self.imagesScrollView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousImageView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            
            if (idx == [self.viewModel.images indexOfObject:[self.viewModel.images lastObject]]) {
                [self.imagesScrollView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.imagesScrollView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            }
            
        }
        
//        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.imagesScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:self.view.frame.size.height/2]];
        
        
        // Imageview constraints
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:self.view.frame.size.height/2]];
        
        
        [self.imagesScrollView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.imagesScrollView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        
        previousImageView = imageView;
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [imageView sd_setImageWithURL:[NSURL URLWithString:image_url]];
        });
        
    }];
    
    
    self.pageControl.numberOfPages = self.viewModel.images.count;
    
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //
    //    if (scrollView == cell.productImage) {
    //        NSInteger index = cell.productImage.contentOffset.x / CGRectGetWidth(cell.productImage.frame);
    //
    //        cell.pageControl.currentPage = index;
    //        [cell.pageControl updateCurrentPageDisplay];
    //    }
    
    
    if ([scrollView isEqual:self.imagesScrollView]) {
        float pageWith = scrollView.frame.size.width;
        int page = (int)floorf(((scrollView.contentOffset.x * 2.0 + pageWith) / (pageWith * 2.0)));
        
        currentIndex = page;
        self.pageControl.currentPage = currentIndex;
        [self.pageControl updateCurrentPageDisplay];
    }
    
    
}

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
    
    [self.addToCartButton setTitle:@"Added" forState:UIControlStateNormal];
    [self.addToCartButton setBackgroundColor:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f]];
    
    
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addedToCartNotification" object:nil];
    
}

-(void)alreadyLabelButton {
    [self updateAlpha];
    
    [self.addToCartButton setTitle:@"Already Added" forState:UIControlStateNormal];
    [self.addToCartButton setBackgroundColor:[UIColor colorWithRed:52/255.0f green:152/255.0f blue:219/255.0f alpha:1.0f]];
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
    browser.enableSwipeToDismiss = NO;
    
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
    
    for (UIView *view in self.imagesScrollView.subviews) {
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




- (IBAction)addToCartPressed:(id)sender {
    
    [self addToCartButtonPressed];
}

@end

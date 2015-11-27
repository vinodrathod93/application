//
//  DetailsProductViewController.m
//  Chemist Plus
//
//  Created by adverto on 17/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "DetailsProductViewController.h"
#import "ProductImageViewCell.h"
#import "ProductDetailsViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MBProgressHUD.h>
#import "AppDelegate.h"
//#import "AddToCart.h"
#import "Order.h"
#import "LineItems.h"
#import "OrderInputsViewController.h"
#import "VariantsViewController.h"
#import "YSLTransitionAnimator.h"
#import "UIViewController+YSLTransition.h"
#import <MWPhotoBrowser.h>
#import "User.h"
#import "StoreRealm.h"


#define FOOTER_HEIGHT 35

@interface DetailsProductViewController ()<NSFetchedResultsControllerDelegate,YSLTransitionAnimatorDataSource,MWPhotoBrowserDelegate, UIGestureRecognizerDelegate>
{
    int currentIndex;
}
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, strong) AddToCart *addToCartModel;
//@property (nonatomic, strong) NSFetchedResultsController *pd_cartFetchedResultsController;

@property (nonatomic, strong) LineItems *lineItemsModel;
@property (nonatomic, strong) NSFetchedResultsController *pd_orderFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *pd_lineItemFetchedResultsController;
@property (nonatomic, strong) UIButton *cartButton;
@property (nonatomic, strong) NSMutableArray *largePhotos;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) UITapGestureRecognizer *imageViewTapGestureRecognizer;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

NSString *cellReuseIdentifier;

@implementation DetailsProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentIndex = 0;
    
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
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.viewModel numberOfRows];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cellReuseIdentifier = @"imageDetailsCell";
        }
    } else {
        cellReuseIdentifier     = @"productDetailsCell";
    }
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
   
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureImageViewCell:cell forIndexPath:indexPath];
        }
    } else if (indexPath.section == 1) {
        [self configureProductDetailCell:cell forIndexPath:indexPath];
    }
    
    return cell;
}

-(void)configureImageViewCell:(ProductImageViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    [self prepareImageView:cell forIndexPath:indexPath];
}


-(void)prepareImageView:(ProductImageViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    
    
    CGRect scrollViewFrame = cell.productImage.frame;
    CGRect currentFrame = self.view.frame;
    
    scrollViewFrame.size.width = currentFrame.size.width;
    cell.productImage.frame = scrollViewFrame;
    
    __block UIImageView *previousImageView;
    
    [self.viewModel.images enumerateObjectsUsingBlock:^(NSString *image_url, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(cell.productImage.frame) * idx, 0, CGRectGetWidth(cell.productImage.frame), CGRectGetHeight(cell.productImage.frame))];
        
        NSLog(@"%@", NSStringFromCGRect(imageView.frame));
        
        imageView.tag = idx;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [cell.productImage addGestureRecognizer:_imageViewTapGestureRecognizer];
        [cell.productImage addSubview:imageView];
        
        if (idx == 0) {
            [cell.productImage addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.productImage attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
        } else {
            [cell.productImage addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousImageView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            
            if (idx == [self.viewModel.images indexOfObject:[self.viewModel.images lastObject]]) {
                
                
                [cell.productImage addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.productImage attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            }
            
        }
        
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.productImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:300.f]];
//        } else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.productImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:450.f]];
//        }
        
        
        
        // Imageview constraints
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:cell.productImage.frame.size.height]];
        
        
        [cell.productImage addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.productImage attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        
        previousImageView = imageView;
        

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
//
//    if (scrollView == cell.productImage) {
//        NSInteger index = cell.productImage.contentOffset.x / CGRectGetWidth(cell.productImage.frame);
//        
//        cell.pageControl.currentPage = index;
//        [cell.pageControl updateCurrentPageDisplay];
//    }
    
    if ([scrollView isEqual:cell.productImage]) {
        float pageWith = scrollView.frame.size.width;
        int page = (int)floorf(((scrollView.contentOffset.x * 2.0 + pageWith) / (pageWith * 2.0)));
        
        currentIndex = page;
        cell.pageControl.currentPage = currentIndex;
        [cell.pageControl updateCurrentPageDisplay];
    }
    
    
}

 

-(void)configureProductDetailCell:(ProductDetailsViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.productLabel.text = [self.viewModel name];
    cell.priceLabel.text   = [self.viewModel display_price];
    cell.summaryLabel.text = [self.viewModel summary];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == 0) {
        return self.view.frame.size.height/2;
    }
    
    else if (indexPath.section == 1) {
        CGFloat summaryHeight = [self.viewModel heightForSummaryTextInTableViewCellWithWidth:self.tableView.frame.size.width];
        return 100.f + summaryHeight;
    }
    
    return 250.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return FOOTER_HEIGHT;
    } else
        return 0.0f;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 1) {
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
        
//        NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"AddToCart"];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productID == %@",[self.viewModel productID]];
//        [fetch setPredicate:predicate];
//        NSArray *fetchedArray = [self.managedObjectContext executeFetchRequest:fetch error:nil];
//
//        
//        NSLog(@"%@",fetchedArray);
//        
//        if (fetchedArray.count == 0) {
//            self.addToCartModel = [NSEntityDescription insertNewObjectForEntityForName:@"AddToCart" inManagedObjectContext:self.managedObjectContext];
//            self.addToCartModel.productID = [self.viewModel productID];
//            self.addToCartModel.productName = [self.viewModel name];
//            self.addToCartModel.productPrice = [self.viewModel price];
//            self.addToCartModel.displayPrice = [self.viewModel display_price];
//            self.addToCartModel.addedDate = [NSDate date];
//            self.addToCartModel.productImage = [self.viewModel images][0];
//            self.addToCartModel.quantity = [self.viewModel quantity];
//            self.addToCartModel.totalPrice = [self.viewModel price];
//            
//            NSDictionary *line_item = [self lineItemDictionaryWithVariantID:self.addToCartModel.productID quantity:self.addToCartModel.quantity];
//            [self sendLineItem:line_item];
//            
//        }
//        else {
//            [self alreadyLabelButton];
//        }
        
        NSNumber *productID                 = [self.viewModel productID];
        NSNumber *quantity                  = [self.viewModel quantity];
        
        NSFetchRequest *fetch   = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
        NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"variantID == %@", [self.viewModel productID]];
        [fetch setPredicate:predicate];
        
        NSError *productItemCheckError;
        NSArray *fetchedArray   = [self.managedObjectContext executeFetchRequest:fetch error:&productItemCheckError];
        if (productItemCheckError != nil) {
            NSLog(@"ProductItem Check Error: %@", [productItemCheckError localizedDescription]);
        }
        else if (fetchedArray.count == 0) {
            _lineItemsModel            = [NSEntityDescription insertNewObjectForEntityForName:@"LineItems" inManagedObjectContext:self.managedObjectContext];
            
            _lineItemsModel.image                 = [self.viewModel images][0];
            _lineItemsModel.quantity              = [self.viewModel quantity];
            _lineItemsModel.variantID             = [self.viewModel productID];
            _lineItemsModel.name                  = [self.viewModel name];
            _lineItemsModel.price                 = [self.viewModel price];
            _lineItemsModel.singleDisplayPrice    = [self.viewModel display_price];
            _lineItemsModel.total                 = [self.viewModel price];
            _lineItemsModel.totalDisplayPrice     = [self.viewModel display_price];
            _lineItemsModel.totalOnHand           = [self.viewModel total_on_hand];
            _lineItemsModel.option                = @"";
            
            
            NSDictionary *line_item             = [self lineItemDictionaryWithVariantID:productID quantity:quantity];
            [self sendLineItem:line_item];
        }
        else {
            [self alreadyLabelButton];
        }
        
    }
}




-(void)sendLineItem:(NSDictionary *)lineItem {
    
    User *user = [User savedUser];
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    NSDictionary *objectData;
    NSString *kOrderURL;
    
    
    if (self.pd_orderFetchedResultsController.fetchedObjects.count == 0) {
        
        // create order
        NSArray *lineItemArray = [self getCartProductsArray:lineItem];
        NSDictionary *order = [self getOrdersDictionary:lineItemArray];
        
        objectData = order;
        kOrderURL = @"/api/orders";
    } else {
        
        // add line items
        NSLog(@"Adding line items to existing order");
        
        Order *orderModel = self.pd_orderFetchedResultsController.fetchedObjects.lastObject;
        
        if (orderModel.number != nil) {
            kOrderURL  = [NSString stringWithFormat:@"/api/orders/%@/line_items.json",orderModel.number];
        }
        
        
        objectData = [self getLineItemDictionaryWithLineItem:lineItem];
        
    }
    
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:objectData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *url = [NSString stringWithFormat:@"http://%@%@?token=%@", store.storeUrl, kOrderURL, user.access_token];
    NSLog(@"URL is --> %@", url);
    NSLog(@"Dictionary is -> %@",objectData);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = jsonData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                
                [self.hud hide:YES];
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    
                    NSLog(@"Json Cart ===> %@",json);
                    
                    if (self.pd_orderFetchedResultsController.fetchedObjects.count == 0) {
                        NSEntityDescription *orderEntityDescription = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:self.managedObjectContext];
                        
                        Order *orderModel = (Order *)[[NSManagedObject alloc] initWithEntity:orderEntityDescription
                                                              insertIntoManagedObjectContext:self.managedObjectContext];
                        
                        orderModel.number = [json valueForKey:@"number"];
                        
                        [orderModel addCartLineItemsObject:_lineItemsModel];
                        
                    } else {
                        Order *orderModel = [self.pd_orderFetchedResultsController.fetchedObjects lastObject];
                        [orderModel addCartLineItemsObject:_lineItemsModel];
                        
                    }
                    
                    [self.managedObjectContext save:nil];
                    
                    [self addedLabelButton];
                    
                }
                
            });
        }
        else {
            [self displayConnectionFailed];
        }
        
        
    }];
    
    [task resume];
    
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Adding To Cart...";
    self.hud.color = self.view.tintColor;

    
    
    
    
    
    
}


-(void)displayConnectionFailed {
    UIAlertView *failed_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [failed_alert show];
}


-(NSArray *)getCartProductsArray:(NSDictionary *)lineItem {
    
    NSMutableArray *jsonarray = [[NSMutableArray alloc] init];
    
    [jsonarray addObject:lineItem];
    
    return jsonarray;
    
}



-(NSDictionary *)getOrdersDictionary:(NSArray *)array {
    NSDictionary *orders = @{
                             @"order": @{
                                     @"line_items": array
                                     }
                             };
    return orders;
}

-(NSDictionary *)getLineItemDictionaryWithLineItem:(NSDictionary *)item {
    NSDictionary *line_items = @{
                                 @"line_item": item
                                 };
    
    return line_items;
}


-(NSDictionary *)lineItemDictionaryWithVariantID:(NSNumber *)variantID quantity:(NSNumber *)quantity {
    return @{
             @"variant_id": variantID,
             @"quantity"  : quantity
             };
}









#pragma mark - Fetched Results Controller

//-(NSFetchedResultsController *)pd_cartFetchedResultsController {
//    if (_pd_cartFetchedResultsController != nil) {
//        return _pd_cartFetchedResultsController;
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
//    _pd_cartFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    _pd_cartFetchedResultsController.delegate = self;
//    
//    NSError *error = nil;
//    if (![self.pd_cartFetchedResultsController performFetch:&error]) {
//        NSLog(@"Core data error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return _pd_cartFetchedResultsController;
//}


-(NSFetchedResultsController *)pd_orderFetchedResultsController {
    if (_pd_orderFetchedResultsController != nil) {
        return _pd_orderFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
//    NSString *cacheName = @"pdOrderCache";
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.pd_orderFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if(![self.pd_orderFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",error);
    }
    
    return _pd_orderFetchedResultsController;
}


-(NSFetchedResultsController *)pd_lineItemFetchedResultsController {
    if (_pd_lineItemFetchedResultsController != nil) {
        return _pd_lineItemFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineItemID" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.pd_lineItemFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if (![self.pd_lineItemFetchedResultsController performFetch:&error]) {
        NSLog(@"LineItems Model Fetch Failure: %@", [error localizedDescription]);
    }
    
    return _pd_lineItemFetchedResultsController;
}



#pragma mark - Helper Methods


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
    
    [self.cartButton setTitle:@"Already In Cart" forState:UIControlStateNormal];
    [self.cartButton setBackgroundColor:[UIColor colorWithRed:52/255.0f green:152/255.0f blue:219/255.0f alpha:1.0f]];
}


-(void)buyButtonPressed {
    
    OrderInputsViewController *orderInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderInputsVC"];
    [self.navigationController presentViewController:orderInputVC animated:YES completion:nil];
    
}

-(void)updateBadgeValue {
    [self.pd_lineItemFetchedResultsController performFetch:nil];
    
    NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)self.pd_lineItemFetchedResultsController.fetchedObjects.count];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:count];
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

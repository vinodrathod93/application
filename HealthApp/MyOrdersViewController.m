//
//  MyOrdersViewController.m
//  Neediator
//
//  Created by adverto on 16/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "MyOrdersViewController.h"
#import "MyOrdersCell.h"
#import "APIManager.h"
#import "MyOrdersModel.h"
#import "LineItemsModel.h"
#import "CustomCollectionViewCell.h"
#import "TrackPipelineView.h"
#import "CancelOrderView.h"

@interface MyOrdersViewController ()

@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;
@property (nonatomic, strong) NeediatorHUD *hud;

@end

@implementation MyOrdersViewController {
    NSMutableArray *_itemsImages;
    NSArray *_orders;
    BOOL _isTrackTapped;
    BOOL _isCancelTapped;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title         = @"My Orders";
    
    [self showHUD];
    
    
    _itemsImages = [NSMutableArray array];
    
    
    
    [[NAPIManager sharedManager] getMyOrdersListingWithSuccess:^(MyOrdersResponseModel *myOrdersModel) {
        
        [self hideHUD];
        
        NSLog(@"%@", myOrdersModel.orders);
        
        _orders = myOrdersModel.orders;
        
        
        [self getImagesForAll];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
    }];
    
    
    
    
    /*
    const NSInteger numberOfTableViewRows = 20;
    const NSInteger numberOfCollectionViewCells = 15;
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            
            CGFloat red = arc4random() % 255;
            CGFloat green = arc4random() % 255;
            CGFloat blue = arc4random() % 255;
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0f];
            
            [colorArray addObject:color];
        }
        
        [mutableArray addObject:colorArray];
    }
    
    self.colorArray = [NSArray arrayWithArray:mutableArray];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
    */
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self hideHUD];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _orders.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyOrdersCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"myOrdersCell" forIndexPath:indexPath];
    
    MyOrdersModel *model = _orders[indexPath.section];
    
    if (!cell) {
        cell = [[MyOrdersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myOrdersCell"];
    }
    
    
//    NSArray *lineItems = model.line_items;
    
//    cell.orderState.text         = [model.orderState capitalizedString];
//    cell.orderNumber.text        = [NSString stringWithFormat:@"Order #%@",model.orderNumber];
//    cell.orderDate.text          = [NSString stringWithFormat:@"%@/%lu Items/%@", [self getFormattedDate:model.completed_date], (unsigned long)lineItems.count, model.orderTotal];
    
    
    cell.n_orderAmount.text = [NSString stringWithFormat:@"Rs.%@",model.orderTotal];
    cell.n_orderNumber.text = model.orderNumber;
    cell.n_orderStatus.text = model.orderState;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    [cell hideButtonsSeenAfter7Days:YES];
    
    [cell.trackButton addTarget:self action:@selector(showTrackView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.beforeCompleteTrackOrderButton addTarget:self action:@selector(showTrackView:) forControlEvents:UIControlEventTouchUpInside];
    [cell.cancelOrderButton addTarget:self action:@selector(showCancelView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    return cell;
}





-(void)showTrackView:(UIButton *)sender {
    
    MyOrdersCell *cell = (MyOrdersCell *)[[sender superview] superview];
    
    if (![cell isKindOfClass:[MyOrdersCell class]]) {
        cell = (MyOrdersCell *)[[[sender superview] superview] superview];
    }
    
    if (!_isCancelTapped) {
        
        cell.cancelOrderButton.alpha = 0.5;
        cell.beforeCompleteTrackOrderButton.alpha = 1.0;
        
        _isTrackTapped = !_isTrackTapped;
        
        
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        MyOrdersModel *model = _orders[indexPath.section];
        model.isExpanded = _isTrackTapped;
        
        TrackPipelineView *trackView = [[[NSBundle mainBundle] loadNibNamed:@"TrackPipelineView" owner:self options:nil] firstObject];
        [trackView drawCurrentOrderState:model.orderState orderDateTime:model.completed_date withCode:model.statusCode.intValue];
        [cell.contentView addSubview:trackView];
        
        trackView.frame = CGRectMake(0, 230, self.view.frame.size.width, 186);
        
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
}





-(void)showCancelView:(UIButton *)sender {
    
    MyOrdersCell *cell = (MyOrdersCell *)[[sender superview] superview];
    
    if (![cell isKindOfClass:[MyOrdersCell class]]) {
        cell = (MyOrdersCell *)[[[sender superview] superview] superview];
    }
    
    if (!_isTrackTapped) {
        _isCancelTapped = !_isCancelTapped;
        
        cell.beforeCompleteTrackOrderButton.alpha = 0.5;
        cell.cancelOrderButton.alpha = 1.0;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        MyOrdersModel *model = _orders[indexPath.section];
        model.isCancelExpanded = _isCancelTapped;
        
        CancelOrderView *cancelView = [[[NSBundle mainBundle] loadNibNamed:@"CancelOrderView" owner:self options:nil] firstObject];
        [cell.contentView addSubview:cancelView];
        
        cancelView.frame = CGRectMake(0, 230, self.view.frame.size.width, 134);
        
        
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    
    
    
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(MyOrdersCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyOrdersModel *model = _orders[indexPath.section];
    
    if (model.isExpanded) {
        return 196+230;
    }
    else if (model.isCancelExpanded) {
        return 134+230;
    }
    else
        return 230.f;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    MyOrdersModel *model = _orders[section];
    
    return model.completed_date;
}


#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionImages = _itemsImages[[(HorizontalCollectionView *)collectionView indexPath].section];
    
    return collectionImages.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyOrderCollectionViewCellIdentifier" forIndexPath:indexPath];
    cell.tag    = indexPath.item;
    
    NSLog(@"%@",_itemsImages[[(HorizontalCollectionView *)collectionView indexPath].section]);
    
    
    NSArray *collectionImages = _itemsImages[[(HorizontalCollectionView *)collectionView indexPath].section];
    
    if (collectionImages[indexPath.item] != nil) {
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", collectionImages[indexPath.item]]];
        
        [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"placeholder_neediator"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error) {
                [cell.imageView setImage:[UIImage imageNamed:@"no_image"]];
            }
        }];

    }
    else {
        [cell.imageView setImage:[UIImage imageNamed:@"small_no_image"]];
    }
    
    return cell;
    
}


#pragma mark - UIScrollViewDelegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UICollectionView class]]) return;
    
    CGFloat horizontalOffset = scrollView.contentOffset.x;
    
    UICollectionView *collectionView = (UICollectionView *)scrollView;
    NSInteger index = collectionView.tag;
    self.contentOffsetDictionary[[@(index) stringValue]] = @(horizontalOffset);
}








-(NSArray *)getImagesForAll {
    
    for (int i=0; i< _orders.count; i++) {
        
        NSMutableArray *imagesParticularOrder = [NSMutableArray array];
        
        MyOrdersModel *model = _orders[i];
        NSArray *items;
        
        if (model.isPrescription.boolValue) {
            items = model.prescriptionArray;
        }
        else
            items = model.line_items;
        
        
        
        
//        [items enumerateObjectsUsingBlock:^(LineItemsModel * _Nonnull line_item, NSUInteger idx, BOOL * _Nonnull stop) {
//            
////            if (line_item.images.count != 0) {
////                VariantImagesModel *image = line_item.images[0];
////                
////                [imagesParticularOrder addObject:image.small_url];
////            }
//            
//            
//            [imagesParticularOrder addObject:line_item.imageURL];
//            
//        }];
        
        
        for (id item in items) {
            if ([item isKindOfClass:[LineItemsModel class]]) {
                
                LineItemsModel *model = (LineItemsModel *)item;
                
                [imagesParticularOrder addObject:model.imageURL];
            }
            else {
                NSDictionary *prescription = (NSDictionary *)item;
                
                [imagesParticularOrder addObject:prescription[@"image_url"]];
            }
        }
        
        
        
        [_itemsImages addObject:imagesParticularOrder];
        
    }
    
    NSLog(@"%@", _itemsImages);
    
    return _itemsImages;
    /*
    
    // get scrollview & view frame
    CGRect scrollViewFrame = cell.scrollView.frame;
    CGRect currentFrame = cell.contentView.frame;
    
    // assign the visible frame to scrollview
    scrollViewFrame.size.width = currentFrame.size.width;
    cell.scrollView.frame = scrollViewFrame;
    
    __block UIImageView *previousImageView;
    
    [_itemsImages enumerateObjectsUsingBlock:^(NSString *image_url, NSUInteger idx, BOOL *stop)  {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(80 * idx, 0, 80, CGRectGetHeight(cell.scrollView.frame))];
        
        imageView.tag = idx;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [cell.scrollViewContentView addSubview:imageView];
        
        if (idx == 0) {
            
            [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:cell.scrollViewContentView attribute:NSLayoutAttributeLeading multiplier:1.f constant:0.f]];
            
        } else {
            [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:previousImageView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            
            if (idx == [_itemsImages indexOfObject:[_itemsImages lastObject]]) {
                
                [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:cell.scrollViewContentView attribute:NSLayoutAttributeTrailing multiplier:1.f constant:0.f]];
            }
            
        }
        
        
        // Imageview constraints
//        [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0.f]];
//        [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:cell.scrollViewContentView.frame.size.height]];
        
        
        [cell.scrollViewContentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:cell.scrollViewContentView attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        
        previousImageView = imageView;
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:image_url]];
        
     
        
        
    }];
     
     */
}

 
 

-(NSString *)getFormattedDate:(NSString *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
    
    NSDate *completedDate = [dateFormatter dateFromString:date];
    
    [dateFormatter setDateFormat:@"EEEE, MMMM dd, yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:completedDate];
    
    [dateFormatter setDateFormat:@"hh:mm a"];
    NSString *timeString = [dateFormatter stringFromDate:completedDate];
    
    return [NSString stringWithFormat:@"%@ at %@", dateString, timeString];
}




#pragma mark - HUD

-(void)showHUD {
    self.hud = [[NeediatorHUD alloc] initWithFrame:self.tableView.frame];
    self.hud.overlayColor = [NeediatorUtitity blurredDefaultColor];
    [self.hud fadeInAnimated:YES];
    self.hud.hudCenter = CGPointMake(CGRectGetWidth(self.view.bounds) / 2, CGRectGetHeight(self.view.bounds) / 2);
    [self.navigationController.view insertSubview:self.hud belowSubview:self.navigationController.navigationBar];
    
    
}

-(void)hideHUD {
    [self.hud fadeOutAnimated:YES];
    [self.hud removeFromSuperview];
    
}



@end

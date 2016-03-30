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
//#import "VariantImagesModel.h"
#import "CustomCollectionViewCell.h"

@interface MyOrdersViewController ()

@property (nonatomic, strong) NSArray *colorArray;
@property (nonatomic, strong) NSMutableDictionary *contentOffsetDictionary;

@end

@implementation MyOrdersViewController {
    NSMutableArray *_itemsImages;
    NSArray *_orders;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title         = @"My Orders";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText      = @"Loading...";
    hud.dimBackground  = YES;
    
    
    _itemsImages = [NSMutableArray array];
    
    
    
    [[NAPIManager sharedManager] getMyOrdersListingWithSuccess:^(MyOrdersResponseModel *myOrdersModel) {
        
        [hud hide:YES];
        
        NSLog(@"%@", myOrdersModel.orders);
        
        _orders = myOrdersModel.orders;
        
        
        [self getImagesForAll];
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [hud hide:YES];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _orders.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyOrdersCell *cell = (MyOrdersCell *)[tableView dequeueReusableCellWithIdentifier:@"myOrdersCell"];
    
    MyOrdersModel *model = _orders[indexPath.section];
    
    if (!cell) {
        cell = [[MyOrdersCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myOrdersCell"];
    }
    
    
    NSArray *lineItems = model.line_items;
    
    cell.orderState.text         = [model.orderState capitalizedString];
    cell.orderNumber.text        = [NSString stringWithFormat:@"Order #%@",model.orderNumber];
    cell.orderDate.text          = [NSString stringWithFormat:@"%@/%lu Items/%@", [self getFormattedDate:model.completed_date], (unsigned long)lineItems.count, model.orderTotal];
    
    return cell;
}




-(void)tableView:(UITableView *)tableView willDisplayCell:(MyOrdersCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 193.f;
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
//        [cell.imageView sd_setImageWithURL:url completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            if(error) {
//                NSLog(@"Image error %@", [error localizedDescription]);
//            }
//        }];
        
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
        NSArray *lineItems = model.line_items;
        
        [lineItems enumerateObjectsUsingBlock:^(LineItemsModel * _Nonnull line_item, NSUInteger idx, BOOL * _Nonnull stop) {
            
//            if (line_item.images.count != 0) {
//                VariantImagesModel *image = line_item.images[0];
//                
//                [imagesParticularOrder addObject:image.small_url];
//            }
            
            
            [imagesParticularOrder addObject:line_item.imageURL];
            
        }];
        
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








@end

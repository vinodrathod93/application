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
#import "VariantImagesModel.h"

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
    
    /*
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText      = @"Loading...";
    hud.dimBackground  = YES;
    
    
    _itemsImages = [NSMutableArray array];
    
    
    [[APIManager sharedManager] getMyOrdersWithSuccess:^(MyOrdersResponseModel *myOrdersModel) {
        
        [hud hide:YES];
        
        NSLog(@"%@", myOrdersModel.orders);
        
        _orders = myOrdersModel.orders;
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        [hud hide:YES];
        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
    }];
    */
    
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
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return _orders.count;
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 1;
    
    return self.colorArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MyOrdersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myOrdersCell" forIndexPath:indexPath];
    
    MyOrdersModel *model = _orders[indexPath.section];
    
    
    
    cell.orderState.text         = [model.orderState capitalizedString];
    cell.orderNumber.text        = model.orderNumber;
    cell.orderDate.text          = [NSString stringWithFormat:@"%@/%@", [self getFormattedDate:model.completed_date], model.orderTotal];
    
    
    
    
//    [self prepareVariantImageViewForCell:cell forIndexPath:indexPath];
    
    return cell;
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(MyOrdersCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
    NSInteger index = cell.collectionView.tag;
    
    CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}






#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *collectionViewArray = self.colorArray[[(HorizontalCollectionView *)collectionView indexPath].row];
    return collectionViewArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyOrderCollectionViewCellIdentifier" forIndexPath:indexPath];
    
    NSArray *collectionViewArray = self.colorArray[[(HorizontalCollectionView *)collectionView indexPath].row];
    cell.backgroundColor = collectionViewArray[indexPath.item];
    
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








/*
-(void)prepareVariantImageViewForCell:(MyOrdersCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    [_itemsImages removeAllObjects];
    
    MyOrdersModel *model = _orders[indexPath.section];
    NSArray *lineItems = model.line_items;
    
    [lineItems enumerateObjectsUsingBlock:^(LineItemsModel * _Nonnull line_item, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        
        if (line_item.images.count != 0) {
            VariantImagesModel *image = line_item.images[0];
            
            [_itemsImages addObject:image.small_url];
        }
        
        
    }];
    
    
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
}

 */

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






/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

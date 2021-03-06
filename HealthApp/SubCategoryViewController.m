//
//  SubCategoryViewController.m
//  
//
//  Created by adverto on 30/01/16.
//
//

#import "SubCategoryViewController.h"
#import "SubCategoryHeaderView.h"
#import "ListingTableViewController.h"
#import "SubCategoryModel.h"
#import "PromotionModel.h"

static NSString * const reuseIdentifier = @"subcategoryCellIdentifier";
static NSString * const reuseSupplementaryIdentifier = @"subcategoryHeaderViewIdentifier";

@interface SubCategoryViewController ()

@property (nonatomic, strong) NSArray *subcategoryIcons;
@property (nonatomic, strong) NSArray *subcategoryPromotions;
//@property (nonatomic, strong) SubCategoryHeaderView *headerView;

@end

@implementation SubCategoryViewController {
    SDWebImageManager *manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /* Decorate Navigation Bar */
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    
    manager = [SDWebImageManager sharedManager];
    
    self.subcategoryIcons   = [self getPListIconsArray];
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    
    /* Create Promotion Header View */
//    self.headerView = [[SubCategoryHeaderView alloc]init];
    
    
    
    
    
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.rightBarButtonItem = [NeediatorUtitity locationBarButton];
}



-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
//    self.headerView.scrollview.contentSize = CGSizeMake(CGRectGetWidth(self.headerView.scrollview.frame) * self.subcategoryPromotions.count, CGRectGetHeight(self.headerView.scrollview.frame));
}

-(NSArray *)getPListIconsArray {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
    NSDictionary *rootDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSArray *iconsArray = rootDictionary[@"Icons"];
    
    return iconsArray;
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.subcategoryArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    NSLog(@"Index of %lu SubCat. count %lu", (long)indexPath.item, (unsigned long)self.subcategoryArray.count);
    
    SubCategoryModel *category     = self.subcategoryArray[indexPath.row];
    
    
    // Configure the cell
    
    
    
    cell.contentView.layer.cornerRadius = 3.f;
    cell.contentView.layer.borderWidth = 1.0f;
    cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    cell.contentView.layer.masksToBounds = YES;
    
    cell.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.layer.shadowOffset = CGSizeMake(0, 5.f);
    cell.layer.shadowOpacity = 1.0f;
    cell.layer.shadowRadius = 2.0f;
    cell.layer.masksToBounds = NO;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.contentView.layer.cornerRadius].CGPath;
    
    
    UIImageView *imageView;
    UILabel *label;
    
    if(self.view.frame.size.width <= 320) {
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(30, 20, cell.frame.size.width - (2*30.f), cell.frame.size.height - 60)];
        label = [[UILabel alloc]initWithFrame:CGRectMake(5.f, imageView.frame.size.height + 20, cell.frame.size.width - 10.f, 40)];
    }
    else
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(35, 25, cell.frame.size.width - (2*35.f), cell.frame.size.height - 10 - 70)];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    
    [manager downloadImageWithURL:[NSURL URLWithString:category.image_url] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        UIImage* imageForRendering = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageView.image = imageForRendering;
        imageView.tintColor = [UIColor colorWithRed:4/255.f green:29/255.f blue:187/255.f alpha:1.0];
    }];
    
    
    
    label = [[UILabel alloc]initWithFrame:CGRectMake(5.f, imageView.frame.size.height + 10 + 20, cell.frame.size.width - 10.f, 40)];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:@"AvenirNext-Medium" size:14];
    label.text = category.name.capitalizedString;
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    
    backgroundView.backgroundColor = [UIColor whiteColor];
    backgroundView.tag = 30+indexPath.item;
    
    [backgroundView addSubview:imageView];
    [backgroundView addSubview:label];
    
    cell.backgroundView = backgroundView;
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.view.frame.size.width <= 320) {
            return CGSizeMake(152.5f, 100);
        }
        else
            return CGSizeMake(120, 120);
    }
    else
        return CGSizeMake(148, 148);
    
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.view.frame.size.width <= 320) {
            return UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
        }
    }
    
        return UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f);
}


-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIView *view = [cell viewWithTag:30+indexPath.item];
    view.backgroundColor = [UIColor colorWithRed:244/255.f green:237/255.f blue:7/255.f alpha:1.0];
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    UIView *view = [cell viewWithTag:30+indexPath.item];
    view.backgroundColor = [UIColor whiteColor];
}

#pragma mark <UICollectionViewDelegate>


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    
    
    SubCategoryModel *model = self.subcategoryArray[indexPath.row];
   
    
    
    ListingTableViewController *listingVC = [self.storyboard instantiateViewControllerWithIdentifier:@"listingTableVC"];
    listingVC.root                       = model.name;
    listingVC.subcategory_id                = model.subCat_id.stringValue;
    listingVC.category_id                 = model.cat_id.stringValue;
    [self.navigationController pushViewController:listingVC animated:YES];
    
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    //
    //    UIView *view = [cell viewWithTag:30+indexPath.item];
    //    view.backgroundColor = [UIColor whiteColor];
    
}

/*
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        
        
        self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseSupplementaryIdentifier forIndexPath:indexPath];
        
        
        self.headerView.scrollview.frame           = self.headerView.frame;
        self.headerView.scrollview.backgroundColor = [UIColor whiteColor];
        
        
//        [self setupScrollViewImages];
//        self.headerView.pageControl.numberOfPages = self.promotions.count;
        
        reusableView = self.headerView;
    }
    
    return reusableView;
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return CGSizeMake(CGRectGetWidth(self.view.frame), kHeaderViewHeight_Pad);
    }
    else
        return CGSizeMake(CGRectGetWidth(self.view.frame), kHeaderViewHeight_Phone);
    
}
*/

//
//#pragma mark - Scroll view Delegate
//
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    
//    if (scrollView == self.headerView.scrollview) {
//        NSInteger index = self.headerView.scrollview.contentOffset.x / CGRectGetWidth(self.headerView.scrollview.frame);
//        
//        self.headerView.pageControl.currentPage = index;
//    }
//    
//    
//}
//
//#pragma mark - Scroll view Methods
//
//-(void)setupScrollViewImages {
//    
//    [self.subcategoryPromotions enumerateObjectsUsingBlock:^(PromotionModel *promotion, NSUInteger idx, BOOL *stop) {
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.headerView.scrollview.frame) * idx, 0, CGRectGetWidth(self.headerView.scrollview.frame), CGRectGetHeight(self.headerView.scrollview.frame))];
//        imageView.tag = idx;
//        
//        
//        NSURL *image_url = [NSURL URLWithString:promotion.image_url];
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//            UIImage *image   = [UIImage imageWithData:[NSData dataWithContentsOfURL:image_url]];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                CIImage *newImage = [[CIImage alloc] initWithImage:image];
//                CIContext *context = [CIContext contextWithOptions:nil];
//                CGImageRef reference = [context createCGImage:newImage fromRect:newImage.extent];
//                
//                imageView.image  = [UIImage imageWithCGImage:reference scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
//            });
//        });
//        
//        
//        [self.headerView.scrollview addSubview:imageView];
//    }];
//    
//    
//}

@end

//
//  HomeCategoryViewController.m
//  Chemist Plus
//
//  Created by adverto on 10/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "HomeCategoryViewController.h"
#import "CategoryViewCell.h"
#import "HomeViewController.h"
#import "HeaderSliderView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SubCategoryViewController.h"
#import "UploadPrescriptionViewController.h"
#import "AppDelegate.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "SignUpViewController.h"
#import "StoresViewController.h"


@interface HomeCategoryViewController ()<NSFetchedResultsControllerDelegate>

//@property (nonatomic, strong) NSFetchedResultsController *h_cartFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *h_lineItemsFetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSArray *categoriesArray;
@property (nonatomic, strong) HeaderSliderView *headerView;
@property (nonatomic, strong) NSArray *imagesData;

@end

@implementation HomeCategoryViewController

static NSString * const reuseIdentifier = @"categoryCellIdentifier";
static NSString * const reuseSupplementaryIdentifier = @"headerViewIdentifier";
static NSString * const JSON_DATA_URL = @"http://chemistplus.in/products.json";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
//    NSString *count = [NSString stringWithFormat:@"%lu",(unsigned long)self.h_cartFetchedResultsController.fetchedObjects.count];
    
    [self checkLineItems];
    NSString *count = [NSString stringWithFormat:@"%lu", self.h_lineItemsFetchedResultsController.fetchedObjects.count];
    [[self.tabBarController.tabBar.items objectAtIndex:1]setBadgeValue:count];
    
    
//    // Is Logged with facebook.
//    if (![FBSDKAccessToken currentAccessToken]) {
//        NSLog(@"Not logged in");
//        SignUpViewController *signupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"signupVC"];
//        [self presentViewController:signupVC animated:YES completion:nil];
//        
//    }
    
    
    // Register cell classes
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // Do any additional setup after loading the view.
    self.headerView = [[HeaderSliderView alloc]init];
    
    
    self.imagesData = @[@"http://sonuspa.com/_imgstore/6/1763516/page_products_f3TjqUdDHPzkPxaNuSr6c/WVYFA9KEJ3I5d_O74U7j72ypUg8.png", @"http://www.cimg.in/images/2010/05/14/10/5242691_20100517541_large.jpg", @"http://4.bp.blogspot.com/-E4VpMa6zZMo/TcLt9mEFuMI/AAAAAAAAAmQ/mvCHbz1YWGk/s320/1.jpg",@"http://img.click.in/classifieds/images/75/5_8_2011_18_45_6599_Nutrilite.jpg"];
    self.categoriesArray = [self getPListCategoriesArray];
    
}

-(NSArray *)getPListCategoriesArray {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"];
    NSDictionary *rootDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    NSArray *categoryArray = rootDictionary[@"Category"];
    return categoryArray;
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.headerView.uploadButton.layer.cornerRadius = self.headerView.uploadButton.frame.size.width/2;
    self.headerView.askDoctorButton.layer.cornerRadius = self.headerView.askDoctorButton.frame.size.width/2;
    self.headerView.askPharmacistButton.layer.cornerRadius = self.headerView.askPharmacistButton.frame.size.width/2;
    
    self.headerView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.headerView.scrollView.frame) * self.imagesData.count, CGRectGetHeight(self.headerView.scrollView.frame));
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%lu",(unsigned long)self.categoriesArray.count);
    return self.categoriesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(25, 0, 50, 50)];
    imageView.image = [UIImage imageNamed:@"pharma.png"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, cell.frame.size.width, 40)];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:14];
    label.text = self.categoriesArray[indexPath.item];
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    [backgroundView addSubview:imageView];
    [backgroundView addSubview:label];
    
    cell.backgroundView = backgroundView;
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(100, 100);
}



#pragma mark <UICollectionViewDelegate>


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    StoresViewController *storesVC  = [self.storyboard instantiateViewControllerWithIdentifier:@"storesViewController"];
    
//    SubCategoryViewController *subCatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"subCatViewController"];
    storesVC.title = self.categoriesArray[indexPath.item];
//    subCatVC.categoryID = [NSString stringWithFormat:@"%ld",(long)indexPath.item + 1];
    
    [self.navigationController pushViewController:storesVC animated:YES];
    
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *reusableView = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:reuseSupplementaryIdentifier forIndexPath:indexPath];

        CGRect scrollViewFrame = self.headerView.scrollView.frame;
        CGRect currentFrame = self.view.frame;
        
        scrollViewFrame.size.width = currentFrame.size.width;
        
        self.headerView.scrollView.frame = scrollViewFrame;
        
        
        [self setupScrollViewImages];
        self.headerView.pageControl.numberOfPages = self.imagesData.count;
        
        reusableView = self.headerView;
    }
    
    return reusableView;
    
}



//-(IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue {
//    NSLog(@"Rollback to Home VC");
//    
//    
//}



#pragma mark - Scroll view Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.headerView.scrollView) {
        NSInteger index = self.headerView.scrollView.contentOffset.x / CGRectGetWidth(self.headerView.scrollView.frame);
        NSLog(@"%ld",(long)index);
        
        self.headerView.pageControl.currentPage = index;
    }
    
    
}

#pragma mark - Scroll view Methods

-(void)setupScrollViewImages {
    
    [self.imagesData enumerateObjectsUsingBlock:^(NSString *imageName, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.headerView.scrollView.frame) * idx, 0, CGRectGetWidth(self.headerView.scrollView.frame), CGRectGetHeight(self.headerView.scrollView.frame))];
        NSLog(@"%@",NSStringFromCGRect(self.headerView.scrollView.frame));
        NSLog(@"%lu",(unsigned long)idx);
        imageView.tag = idx;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageName]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self.headerView.scrollView addSubview:imageView];
    }];
    
    
}


//-(NSFetchedResultsController *)h_cartFetchedResultsController {
//    if (_h_cartFetchedResultsController) {
//        return _h_cartFetchedResultsController;
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
//    _h_cartFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    _h_cartFetchedResultsController.delegate = self;
//    
//    NSError *error = nil;
//    if (![self.h_cartFetchedResultsController performFetch:&error]) {
//        NSLog(@"Core data error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return _h_cartFetchedResultsController;
//}



-(void)checkLineItems {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineItemID" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.h_lineItemsFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if (![self.h_lineItemsFetchedResultsController performFetch:&error]) {
        NSLog(@"LineItems Model Fetch Failure: %@", [error localizedDescription]);
    }
}



- (IBAction)uploadPrescription:(id)sender {
    UploadPrescriptionViewController *uploadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"uploadPrescriptionNVC"];
    
    [self.navigationController presentViewController:uploadVC animated:YES completion:nil];
    
}
@end

//
//  StoreTaxonsViewController.m
//  Chemist Plus
//
//  Created by adverto on 16/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "StoreTaxonsViewController.h"
#import "APIManager.h"
#import "SKSTableViewCell.h"
#import <MBProgressHUD.h>
#import "ProductsViewController.h"
#import "StoreRealm.h"
#import "User.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "BannerView.h"

@interface StoreTaxonsViewController ()

@property (nonatomic, strong) NSArray *taxonomies;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSArray *bannerImages;
@property (nonatomic, strong) BannerView *bannerView;

@end

@implementation StoreTaxonsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.SKSTableViewDelegate = self;
    
    self.bannerImages = @[@"http://sonuspa.com/_imgstore/6/1763516/page_products_f3TjqUdDHPzkPxaNuSr6c/WVYFA9KEJ3I5d_O74U7j72ypUg8.png", @"http://www.cimg.in/images/2010/05/14/10/5242691_20100517541_large.jpg", @"http://4.bp.blogspot.com/-E4VpMa6zZMo/TcLt9mEFuMI/AAAAAAAAAmQ/mvCHbz1YWGk/s320/1.jpg",@"http://img.click.in/classifieds/images/75/5_8_2011_18_45_6599_Nutrilite.jpg"];
    
    [self layoutBannerHeaderView];
    
    [self setupScrollViewImages];
    
    [self showHUD];
    
    [[APIManager sharedManager] getTaxonomiesForStore:self.storeURL WithSuccess:^(TaxonomyListResponseModel *responseModel) {
        self.taxonomies = responseModel.taxonomies;
        
        [self.tableView reloadData];
        [self hideHUD];
        
    } failure:^(NSError *error) {
        
        [self hideHUD];
        
        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    _bannerView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(_bannerView.scrollView.frame) * self.bannerImages.count, CGRectGetHeight(_bannerView.scrollView.frame));
}


-(void)layoutBannerHeaderView {
    _bannerView = [[[NSBundle mainBundle] loadNibNamed:@"BannerView" owner:self options:nil] lastObject];
    _bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    
//    CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, 130);
//    _bannerView.frame = frame;
//    [_bannerView layoutIfNeeded];
//    
//    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
//    [_bannerView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
    _bannerView.scrollView.delegate = self;
    
    CGRect scrollViewFrame = _bannerView.scrollView.frame;
    CGRect currentFrame = self.view.frame;
    
    scrollViewFrame.size.width = currentFrame.size.width;
    _bannerView.scrollView.frame = scrollViewFrame;
    
    _bannerView.pageControl.numberOfPages = self.bannerImages.count;
    
//    [self.tableView.tableFooterView addSubview:_bannerView];
    self.tableView.tableHeaderView = _bannerView;
    
    
    
    
    
    
    
    
    
    
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:_bannerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.tableView.tableHeaderView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0.f]];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:_bannerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.tableView.tableHeaderView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:0.f]];
    
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:_bannerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.tableView.tableHeaderView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.f]];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:_bannerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.tableView.tableHeaderView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.f]];
    
    
    
    
    
}


#pragma mark - Scroll view Methods

-(void)setupScrollViewImages {
    
    [self.bannerImages enumerateObjectsUsingBlock:^(NSString *imageName, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(_bannerView.scrollView.frame) * idx, 0, CGRectGetWidth(_bannerView.scrollView.frame), CGRectGetHeight(_bannerView.scrollView.frame))];
        imageView.tag = idx;
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageName]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [_bannerView.scrollView addSubview:imageView];
    }];
    
    
}

#pragma mark - Scroll view Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == _bannerView.scrollView) {
        NSInteger index = _bannerView.scrollView.contentOffset.x / CGRectGetWidth(_bannerView.scrollView.frame);
        NSLog(@"%ld",(long)index);
        
        _bannerView.pageControl.currentPage = index;
    }
    
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"%lu", (unsigned long)self.taxonomies.count);
    
    return [self.taxonomies count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)tableView:(SKSTableView *)tableView numberOfSubRowsAtIndexPath:(NSIndexPath *)indexPath
{
    TaxonomyModel *taxonomy = self.taxonomies[indexPath.section];
    NSLog(@"%@",taxonomy);
    
    return taxonomy.taxons.count;
}

- (BOOL)tableView:(SKSTableView *)tableView shouldExpandSubRowsOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"storeTaxonomyCell";
    
    SKSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[SKSTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = [self.taxonomies[indexPath.section] taxonomyName];
    cell.expandable = YES;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    NSArray *taxons = [self.taxonomies[indexPath.section] taxons];
    
    if (taxons.count != 0) {
        
        TaxonModel *taxon = taxons[indexPath.subRow - 1];
        cell.textLabel.text = taxon.taxonName;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (CGFloat)tableView:(SKSTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Section: %ld,selected", (long)indexPath.section);
}

- (void)tableView:(SKSTableView *)tableView didSelectSubRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *taxons = [self.taxonomies[indexPath.section] taxons];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    User *user = [User savedUser];
    
    if (taxons.count != 0) {
        TaxonModel *taxon = taxons[indexPath.subRow - 1];
        
        NSLog(@"Taxon ID %d", taxon.taxonId.intValue);
        
        ProductsViewController *productsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
        productsVC.navigationTitleString = taxon.taxonName;
        productsVC.taxonProductsURL = [NSString stringWithFormat:@"http://%@/api/taxons/%d/products?token=%@",store.storeUrl,taxon.taxonId.intValue,user.access_token];
        [self.navigationController pushViewController:productsVC animated:YES];
    }
    
}

//
//-(NSString *)tableView:(SKSTableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Header";
//}



#pragma mark - Private Methods

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    self.hud.color = self.tableView.tintColor;
}

-(void)hideHUD {
    [self.hud hide:YES];
}

@end

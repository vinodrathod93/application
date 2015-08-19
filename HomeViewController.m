//
//  HomeViewController.m
//  Chemist Plus
//
//  Created by adverto on 10/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "HomeViewController.h"
#import "HeaderView.h"
#import "UploadPrescriptionViewController.h"

#define HEADER_VIEW_HEIGHT 220;

@interface HomeViewController ()

@property (nonatomic, strong) NSArray *imagesData;
@property (nonatomic, strong) UISearchBar *searchBar;

@end

NSString * const CELL_IDENTIFIER = @"categoryCell";

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headerView = [[HeaderView alloc]init];
    self.headerView.imagePagesView.delegate = self;
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:102/255.0f green:169/255.0f blue:127/255.0f alpha:1.0];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HeaderView" bundle:nil] forHeaderFooterViewReuseIdentifier:@"headerViewIdentifier"];
    
    
    [self setupSearchBarOnTableViewHeader];
    [self loadHeaderViewImageData];
    [self loadAllNotifications];
    

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"%f",self.tableView.sectionHeaderHeight);
}

-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.headerView.imagePagesView.contentSize = CGSizeMake(CGRectGetWidth(self.headerView.imagePagesView.frame) * self.imagesData.count, CGRectGetHeight(self.headerView.imagePagesView.frame));
}

-(void)setupSearchBarOnTableViewHeader {
    self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44.0f)];
    self.searchBar.barTintColor = [UIColor colorWithRed:102/255.0f green:169/255.0f blue:127/255.0f alpha:1.0];
    self.searchBar.layer.borderColor = [[UIColor clearColor] CGColor];
    [self.searchBar sizeToFit];
    
    self.tableView.tableHeaderView = self.searchBar;
}

-(void)loadHeaderViewImageData {
    self.imagesData = @[@"image-1.jpg", @"image-2.jpeg", @"image-3.jpg"];
    self.headerView.pageControl.numberOfPages = self.imagesData.count;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://chemistplus.in/products.json"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",response);
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    
    [task resume];
    
}

-(void)loadAllNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showUploadPrescriptionViewController:)
                                                 name:@"uploadPrescriptionPressed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAskTheDoctorViewController:)
                                                 name:@"askDoctorPressed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAskThePharmacistViewController:)
                                                 name:@"askPharmacistPressed"
                                               object:nil];
}

-(void)setupScrollViewImages {
    
    [self.imagesData enumerateObjectsUsingBlock:^(NSString *imageName, NSUInteger idx, BOOL *stop) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.headerView.imagePagesView.frame) * idx, 0, CGRectGetWidth(self.headerView.imagePagesView.frame), CGRectGetHeight(self.headerView.imagePagesView.frame))];
        NSLog(@"%@",NSStringFromCGRect(self.headerView.imagePagesView.frame));
        NSLog(@"%lu",(unsigned long)idx);
        imageView.tag = idx;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:imageName];
        [self.headerView.imagePagesView addSubview:imageView];
    }];
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}


#pragma mark - Table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEADER_VIEW_HEIGHT;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        CGRect scrollViewFrame = self.headerView.imagePagesView.frame;
        CGRect currentFrame = self.view.frame;
        
        scrollViewFrame.size.width = currentFrame.size.width;
        
        self.headerView.imagePagesView.frame = scrollViewFrame;
        
        
        [self setupScrollViewImages];
    }
    
    return self.headerView;
}



#pragma mark - Scroll view Delegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView == self.headerView.imagePagesView) {
        NSInteger index = self.headerView.imagePagesView.contentOffset.x / CGRectGetWidth(self.headerView.imagePagesView.frame);
        NSLog(@"%ld",(long)index);
        
        self.headerView.pageControl.currentPage = index;
    }
    
    
}




#pragma mark - Button Pressed Selectors

-(void)showUploadPrescriptionViewController:(NSNotification *)notification {
    UploadPrescriptionViewController *uploadVC = [self.storyboard instantiateViewControllerWithIdentifier:@"uploadPrescriptionNVC"];
    
    [self.navigationController presentViewController:uploadVC animated:YES completion:nil];
}

-(void)showAskTheDoctorViewController:(NSNotification *)notification {
    NSLog(@"Ask the doctor pressed");
}

-(void)showAskThePharmacistViewController:(NSNotification *)notification {
    NSLog(@"Ask the pharmacist pressed");
}

@end

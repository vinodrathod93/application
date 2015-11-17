//
//  SubCategoryViewController.m
//  Chemist Plus
//
//  Created by adverto on 14/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "SubCategoryViewController.h"
#import "ProductsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "DoctorViewController.h"


NSString * const SUB_CAT_CELL_IDENTIFIER = @"subCategoryTableViewCell";
static NSString * const SUBCAT_DATA_URL = @"http://chemistplus.in/subCategory.php";

#define DOCTORS_ID 5

@interface SubCategoryViewController ()

@property (nonatomic,strong) NSDictionary *subCategoryDictionary;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation SubCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@",self.categoryID);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    [self getData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.task suspend];
    [self hideHUD];
}

-(void)getData {
    NSURL *url = [NSURL URLWithString:SUBCAT_DATA_URL];
    NSString *postString = [NSString stringWithFormat:@"category_id=%@",self.categoryID];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [postString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSession *session = [NSURLSession sharedSession];
    self.task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getJSONDataWithData:data andError:error];
                [self.tableView reloadData];
                [self hideHUD];
                
            });
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideHUD];
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Could not fetch data" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alert show];
            });
        }
        
    }];
    
    [self showHUD];
    [self.task resume];
    
}

-(void)getJSONDataWithData:(NSData *)data andError:(NSError *)error {
    self.subCategoryDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    if (error != nil) {
        NSLog(@"Error %@",error);
    } else {
        NSLog(@"%@",self.subCategoryDictionary);
    }
}

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.color = self.tableView.tintColor;
}

-(void)hideHUD {
    [self.hud hide:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (self.subCategoryDictionary != nil) {
        return self.subCategoryDictionary.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SUB_CAT_CELL_IDENTIFIER forIndexPath:indexPath];
    
    // Configure the cell...
    
    if (self.subCategoryDictionary != nil) {
        cell.textLabel.text = [[self.subCategoryDictionary valueForKey:@"subcat_name"] objectAtIndex:indexPath.item];
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductsViewController *productsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"productsVC"];
    
    if (self.categoryID.intValue == DOCTORS_ID) {
        
        DoctorViewController *doctorsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"doctorsVC"];
        doctorsVC.title = [[self.subCategoryDictionary valueForKey:@"subcat_name"] objectAtIndex:indexPath.item];
        doctorsVC.subCategoryID = [[self.subCategoryDictionary valueForKey:@"subcat_id"] objectAtIndex:indexPath.item];
        [self.navigationController pushViewController:doctorsVC animated:YES];
    }
    else if (self.subCategoryDictionary != nil) {
        productsVC.navigationTitleString = [[self.subCategoryDictionary valueForKey:@"subcat_name"] objectAtIndex:indexPath.item];
        productsVC.subCategoryID = [[self.subCategoryDictionary valueForKey:@"subcat_id"] objectAtIndex:indexPath.item];
        productsVC.categoryID = self.categoryID;
        [self.navigationController pushViewController:productsVC animated:YES];
    }
    
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 130.0f)];
    scrollView.pagingEnabled = YES;
    
    
    
    UIView *blurView = [[UIView alloc]initWithFrame:CGRectMake(0, 110, self.view.frame.size.width, 20)];
    blurView.backgroundColor = [UIColor colorWithRed:170/255.0f green:170/255.0f blue:170/255.0f alpha:0.40];
    
    
    UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, 0, 39, 37)];
    pageControl.backgroundColor = [UIColor blackColor];
    pageControl.center = blurView.center;
    
    
    
    [blurView addSubview:pageControl];
    [scrollView addSubview:blurView];
    
    return scrollView;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 130.0f;
}


@end

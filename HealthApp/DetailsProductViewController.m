//
//  DetailsProductViewController.m
//  Chemist Plus
//
//  Created by adverto on 17/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "DetailsProductViewController.h"
#import "ProductImageViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AppDelegate.h"
#import "AddToCart.h"
#import "OrderInputsViewController.h"


#define FOOTER_HEIGHT 35

@interface DetailsProductViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) AddToCart *addToCartModel;
@property (nonatomic, strong) NSFetchedResultsController *pd_cartFetchedResultsController;
@property (nonatomic, strong) UIButton *cartButton;

@end

NSString *cellReuseIdentifier;

@implementation DetailsProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Product Detail";
    self.viewModel = [[DetailProductViewModel alloc]initWithModel:self.detail];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    if (section == 0) {
        return [self.viewModel numberOfRows];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cellReuseIdentifier = @"imageDetailsCell";
        }
    }
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureImageViewCell:cell forIndexPath:indexPath];
        }
    }
    
    return cell;
}

-(void)configureImageViewCell:(ProductImageViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {

    [cell.productImage sd_setImageWithURL:[NSURL URLWithString:[self.viewModel image]]];
    
    cell.productLabel.text = [self.viewModel name];
    cell.summaryLabel.text = [self.viewModel summary];
    cell.priceLabel.text = [self.viewModel price];
}


-(void)configureProductDetail:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [self.viewModel name];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            CGFloat summaryHeight = [self.viewModel heightForSummaryTextInTableViewCellWithWidth:self.tableView.frame.size.width];
            return 350 + summaryHeight;
            
        }
    }
    
    return 250.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return FOOTER_HEIGHT;
    } else
        return 0.0f;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 0) {
        self.footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, FOOTER_HEIGHT)];
        
        [self addToCartButton];
        [self buyButton];
        
        return self.footerView;
    }
    
    return nil;
    
}


-(void)addToCartButton {
    self.cartButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, FOOTER_HEIGHT)];
    self.cartButton.backgroundColor = [UIColor lightGrayColor];
    [self.cartButton setTitle:@"Add to Cart" forState:UIControlStateNormal];
    [self.cartButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.cartButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    [self.cartButton addTarget:self action:@selector(addToCartButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:self.cartButton];
}

-(void)buyButton {
    UIButton *buyButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, FOOTER_HEIGHT)];
    buyButton.backgroundColor = [UIColor colorWithRed:22/255.0f green:160/255.0f blue:133/255.0f alpha:1.0f];
    [buyButton setTitle:@"Buy Now" forState:UIControlStateNormal];
    [buyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    buyButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:16.0f];
    [buyButton addTarget:self action:@selector(buyButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:buyButton];
}

-(void)addToCartButtonPressed {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"AddToCart"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productName == %@",[self.viewModel name]];
    [fetch setPredicate:predicate];
    NSArray *fetchedArray = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    
    NSLog(@"%@",fetchedArray);
    
    if (fetchedArray.count == 0) {
        self.addToCartModel = [NSEntityDescription insertNewObjectForEntityForName:@"AddToCart" inManagedObjectContext:self.managedObjectContext];
        self.addToCartModel.productID = @(11).stringValue;
        self.addToCartModel.productName = [self.viewModel name];
        self.addToCartModel.productPrice = [self.viewModel price];
        self.addToCartModel.addedDate = [NSDate date];
        
        self.addToCartModel.productImage = [self.viewModel image];
        self.addToCartModel.quantity = @(1).stringValue;
        self.addToCartModel.totalPrice = [self.viewModel price];
        
        [self.managedObjectContext save:nil];
        
        [self.cartButton setTitle:@"Added" forState:UIControlStateNormal];
        [self.cartButton setBackgroundColor:[UIColor colorWithRed:26/255.0f green:188/255.0f blue:156/255.0f alpha:1.0f]];
    }
    else {
        [self.cartButton setTitle:@"Already Added" forState:UIControlStateNormal];
        [self.cartButton setBackgroundColor:[UIColor colorWithRed:52/255.0f green:152/255.0f blue:219/255.0f alpha:1.0f]];
    }
    [self updateBadgeValue];
    
    

}

-(void)buyButtonPressed {
    
    OrderInputsViewController *orderInputVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderInputsVC"];
    [self.navigationController presentViewController:orderInputVC animated:YES completion:nil];
    
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


@end

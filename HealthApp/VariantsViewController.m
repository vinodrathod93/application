//
//  VariantsViewController.m
//  Chemist Plus
//
//  Created by adverto on 28/09/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "VariantsViewController.h"
#import "AddToCart.h"
#import "AppDelegate.h"

@interface VariantsViewController ()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) AddToCart *addToCartModel;

@end

@implementation VariantsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.headerTitle.text = self.productTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.variants.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"variantCell"];
    
    cell.textLabel.text = [self.variants[indexPath.row] valueForKey:@"options_text"];
    cell.detailTextLabel.text = [self.variants[indexPath.row ] valueForKey:@"display_price"];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"AddToCart"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productID == %@",[self.variants[indexPath.row] valueForKey:@"id"]];
    [fetch setPredicate:predicate];
    NSArray *fetchedArray = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    
    if (fetchedArray.count == 0) {
        self.addToCartModel = [NSEntityDescription insertNewObjectForEntityForName:@"AddToCart" inManagedObjectContext:self.managedObjectContext];
        self.addToCartModel.productID = [self.variants[indexPath.row] valueForKey:@"id"];
        self.addToCartModel.productName = [self.variants[indexPath.row] valueForKey:@"name"];
        
        NSString *price = [self.variants[indexPath.row] valueForKey:@"price"];
        NSLog(@"Selected Variant Price %@",price);
        
        self.addToCartModel.productPrice = [NSNumber numberWithInt:price.intValue];
        self.addToCartModel.addedDate = [NSDate date];
        
        self.addToCartModel.productImage = self.productImage;
        self.addToCartModel.quantity = @(1);
        self.addToCartModel.totalPrice = [NSNumber numberWithInt:price.intValue];
        self.addToCartModel.displayPrice = [self.variants[indexPath.row] valueForKey:@"display_price"];
        self.addToCartModel.variant = [self.variants[indexPath.row] valueForKey:@"options_text"];
        
        [self.managedObjectContext save:nil];
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"updateAdded" object:nil];
        }];
        
    }
    else {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter]postNotificationName:@"updateAlreadyAdded" object:nil];
        }];
    }
    
    
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = @"Select a variant";
    
    return title;
}

- (IBAction)headerButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAlpha" object:nil];
    }];
}
@end

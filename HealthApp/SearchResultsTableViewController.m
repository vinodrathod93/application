//
//  SearchResultsTableViewController.m
//  Neediator
//
//  Created by adverto on 07/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "SearchResultsTableViewController.h"
#import "AppDelegate.h"
#import "LineItems.h"
#import "Order.h"

@interface SearchResultsTableViewController ()
{
    NSDictionary *_product;
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) LineItems *lineItemsModel;
@property (nonatomic, strong) NSFetchedResultsController *pd_orderFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *pd_lineItemFetchedResultsController;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation SearchResultsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y - 100);
    
    [self.view addSubview:activityIndicator];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSLog(@"numberOfRowsInSection");
    
    return [self.searchResults count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell" forIndexPath:indexPath];
    
    _product = self.searchResults[indexPath.row];
    
    cell.textLabel.text     = [_product[@"productname"] capitalizedString];
    cell.detailTextLabel.text = [_product[@"brandname"] capitalizedString];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIButton *add = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    add.tag = indexPath.row;
    
    [add setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [add addTarget:self action:@selector(addToCart:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.accessoryView = add;
    
    
    return cell;
}




-(void)addToCart:(UIButton *)sender {
    
    NSLog(@"Added to cart");
    
    
    NSDictionary *product = self.searchResults[sender.tag];
    
    [self addToCartButtonPressed:product];
    [sender setImage:[UIImage imageNamed:@"done"] forState:UIControlStateNormal];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}




-(void)addToCartButtonPressed:(NSDictionary *)product {
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    NSFetchRequest *fetch   = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"variantID == %@", product[@"productid"]];
    [fetch setPredicate:predicate];
    
    NSError *productItemCheckError;
    NSArray *fetchedArray   = [self.managedObjectContext executeFetchRequest:fetch error:&productItemCheckError];
    if (productItemCheckError != nil) {
        NSLog(@"ProductItem Check Error: %@", [productItemCheckError localizedDescription]);
    }
    else if (fetchedArray.count == 0) {
        _lineItemsModel            = [NSEntityDescription insertNewObjectForEntityForName:@"LineItems" inManagedObjectContext:self.managedObjectContext];
        
        
        NSString *price = product[@"rate"];
        NSString *qty   = product[@"qty"];
        NSString *product_id = product[@"productid"];
        
        _lineItemsModel.image                 = product[@"imageurl"];
        _lineItemsModel.quantity              = @1;
        _lineItemsModel.variantID             = @(product_id.integerValue);
        _lineItemsModel.name                  = product[@"productname"];
        _lineItemsModel.price                 = @(price.integerValue);
        _lineItemsModel.singleDisplayPrice    = product[@"rate"];
        _lineItemsModel.total                 = @(price.integerValue);
        _lineItemsModel.totalDisplayPrice     = product[@"rate"];
        _lineItemsModel.totalOnHand           = @(qty.integerValue);
        _lineItemsModel.option                = @"";
        
        
        
        User *user = [User savedUser];
        
        if (user.userID != nil) {
            [self sendLineItem:product];
        }
        else {
            // Login presentVC
            
            LogSignViewController *logSignVC = (LogSignViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
            logSignVC.isPlacingOrder = NO;
            
            UINavigationController *logSignNav = [[UINavigationController alloc] initWithRootViewController:logSignVC];
            logSignNav.navigationBar.tintColor = self.tableView.tintColor;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                logSignNav.modalPresentationStyle    = UIModalPresentationFormSheet;
            }
            
            [self presentViewController:logSignNav animated:YES completion:nil];
        }
        
    }
    else {
//        [self alreadyLabelButton];
        
        NSLog(@"Already added ");
    }

}






-(void)sendLineItem:(NSDictionary *)lineItem {
    
    User *user = [User savedUser];
    
    [self checkOrders];
    
    
    
    
    NSString *url = [NSString stringWithFormat:@"http://neediator.in/NeediatorWS.asmx/addToCart"];
    NSLog(@"URL is --> %@", url);
    
    NSString *parameter  = [NSString stringWithFormat:@"product_id=%@&qty=%@&user_id=%@&store_id=%@&cat_id=%@", lineItem[@"productid"], @"1", user.userID, lineItem[@"storeid"], lineItem[@"catid"]];
    NSData *parameterData = [NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = parameterData;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)parameterData.length] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                NSLog(@"%@", json);
                
                [self.hud hide:YES];
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    
                    
                    if (_pd_orderFetchedResultsController.fetchedObjects.count != 0) {
                        
                        Order *orderModel = [_pd_orderFetchedResultsController.fetchedObjects lastObject];
                        [orderModel addCartLineItemsObject:_lineItemsModel];
                        
                    }
                    
                    [self.managedObjectContext save:nil];
                    
//                    [self addedLabelButton];
                    
                }
                
            });
        }
        else {
//            [self displayConnectionFailed];
            
            NSLog(@"Something went wrong");
        }
        
        
    }];
    
    [task resume];
    
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Adding To Cart...";
    self.hud.color = self.view.tintColor;
    
    
    
    
    
    
    
}






#pragma mark - Fetched Results Controller

-(void)checkOrders {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.pd_orderFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if(![self.pd_orderFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",error);
    }
}


-(void)checkLineItems {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineItemID" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.pd_lineItemFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if (![self.pd_lineItemFetchedResultsController performFetch:&error]) {
        NSLog(@"LineItems Model Fetch Failure: %@", [error localizedDescription]);
    }
    
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

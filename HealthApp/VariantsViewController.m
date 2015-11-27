//
//  VariantsViewController.m
//  Chemist Plus
//
//  Created by adverto on 28/09/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "VariantsViewController.h"
#import "AppDelegate.h"
#import "Order.h"
#import "User.h"
#import "StoreRealm.h"
#import <MBProgressHUD.h>
#import "LineItems.h"
//#import "AddToCart.h"


@interface VariantsViewController ()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController *orderFetchedResultsController;
//@property (nonatomic, strong) NSFetchedResultsController *cartFetchedResultsController;
//@property (nonatomic, strong) AddToCart *addToCartModel;

@property (nonatomic, strong) LineItems *lineItemsModel;
@property (nonatomic, strong) MBProgressHUD *hud;

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
    
    NSLog(@"%@",self.variants[indexPath.row]);
    
    cell.textLabel.text = [self.variants[indexPath.row] valueForKey:@"options_text"];
    cell.detailTextLabel.text = [self.variants[indexPath.row ] valueForKey:@"display_price"];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    
//    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"AddToCart"];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productID == %@",[self.variants[indexPath.row] valueForKey:@"id"]];
//    [fetch setPredicate:predicate];
//    NSArray *fetchedArray = [self.managedObjectContext executeFetchRequest:fetch error:nil];
    
//    if (fetchedArray.count == 0) {
//        self.addToCartModel                 = [NSEntityDescription insertNewObjectForEntityForName:@"AddToCart" inManagedObjectContext:self.managedObjectContext];
//        self.addToCartModel.productID       = [self.variants[indexPath.row] valueForKey:@"id"];
//        self.addToCartModel.productName     = [self.variants[indexPath.row] valueForKey:@"name"];
//        
//        NSString *price                     = [self.variants[indexPath.row] valueForKey:@"price"];
//        
//        self.addToCartModel.productPrice    = [NSNumber numberWithInt:price.intValue];
//        self.addToCartModel.addedDate       = [NSDate date];
//        
//        self.addToCartModel.productImage    = self.productImage;
//        self.addToCartModel.quantity        = @(1);
//        self.addToCartModel.totalPrice      = [NSNumber numberWithInt:price.intValue];
//        self.addToCartModel.displayPrice    = [self.variants[indexPath.row] valueForKey:@"display_price"];
//        self.addToCartModel.variant         = [self.variants[indexPath.row] valueForKey:@"options_text"];
//        
//        NSDictionary *line_item             = [self lineItemDictionaryWithVariantID:self.addToCartModel.productID quantity:self.addToCartModel.quantity];
//        [self sendLineItem:line_item];
//        
//    }
//    else {
//        [self dismissViewControllerAnimated:YES completion:^{
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"updateAlreadyAdded" object:nil];
//        }];
//    }
    
    NSNumber *productID                 = [self.variants[indexPath.row] valueForKey:@"id"];
    NSNumber *quantity                  = @(1);
    
    NSFetchRequest *fetch   = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    NSPredicate *predicate  = [NSPredicate predicateWithFormat:@"variantID == %@", [self.variants[indexPath.row] valueForKey:@"id"]];
    [fetch setPredicate:predicate];
    
    NSError *lineItemCheckError;
    NSArray *fetchedArray   = [self.managedObjectContext executeFetchRequest:fetch error:&lineItemCheckError];
    if (lineItemCheckError != nil) {
        NSLog(@"LineItems Check Error: %@", [lineItemCheckError localizedDescription]);
    }
    else if (fetchedArray.count == 0) {
        
        _lineItemsModel            = [NSEntityDescription insertNewObjectForEntityForName:@"LineItems" inManagedObjectContext:self.managedObjectContext];
        
        NSString *price                     = [self.variants[indexPath.row] valueForKey:@"price"];
        
        _lineItemsModel.image                 = self.productImage;
        _lineItemsModel.quantity              = @(1);
        _lineItemsModel.variantID             = [self.variants[indexPath.row] valueForKey:@"id"];
        _lineItemsModel.name                  = [self.variants[indexPath.row] valueForKey:@"name"];
        _lineItemsModel.price                 = [NSNumber numberWithInt:price.intValue];
        _lineItemsModel.singleDisplayPrice    = [self.variants[indexPath.row] valueForKey:@"display_price"];
        _lineItemsModel.total                 = [NSNumber numberWithInt:price.intValue];
        _lineItemsModel.totalDisplayPrice     = [self.variants[indexPath.row] valueForKey:@"display_price"];
        _lineItemsModel.totalOnHand           = [self.variants[indexPath.row] valueForKey:@"total_on_hand"];
        _lineItemsModel.option                = [self.variants[indexPath.row] valueForKey:@"options_text"];;
        
        NSDictionary *line_item             = [self lineItemDictionaryWithVariantID:productID quantity:quantity];
        [self sendLineItem:line_item];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateAlreadyAdded" object:nil];
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




#pragma mark - Helper methods


-(void)sendLineItem:(NSDictionary *)lineItem {
    
    User *user = [User savedUser];
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    NSDictionary *objectData;
    NSString *kOrderURL;
    
    
    if (self.orderFetchedResultsController.fetchedObjects.count == 0) {
        
        // create order
        NSArray *lineItemArray = [self getCartProductsArray:lineItem];
        NSDictionary *order = [self getOrdersDictionary:lineItemArray];
        
        objectData = order;
        kOrderURL = @"/api/orders";
    } else {
        
        // add line items
        NSLog(@"Adding line items to existing order");
        
        Order *orderModel = self.orderFetchedResultsController.fetchedObjects.lastObject;
        
        if (orderModel.number != nil) {
            kOrderURL  = [NSString stringWithFormat:@"/api/orders/%@/line_items.json",orderModel.number];
        }
        
        
        objectData = [self getLineItemDictionaryWithLineItem:lineItem];
        
    }
    
    
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:objectData options:NSJSONWritingPrettyPrinted error:&error];
    
    NSString *url = [NSString stringWithFormat:@"http://%@%@?token=%@", store.storeUrl, kOrderURL, user.access_token];
    NSLog(@"URL is --> %@", url);
    NSLog(@"Dictionary is -> %@",objectData);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = jsonData;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                NSError *jsonError;
                
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
                
                
                [self.hud hide:YES];
                if (jsonError) {
                    NSLog(@"Error %@",[jsonError localizedDescription]);
                } else {
                    
                    NSLog(@"Json Cart ===> %@",json);
                    
                    if (self.orderFetchedResultsController.fetchedObjects.count == 0) {
                        NSEntityDescription *orderEntityDescription = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:self.managedObjectContext];
                        
                        Order *orderModel = (Order *)[[NSManagedObject alloc] initWithEntity:orderEntityDescription
                                                                  insertIntoManagedObjectContext:self.managedObjectContext];
                        
                        orderModel.number = [json valueForKey:@"number"];
                        
                        [orderModel addCartLineItemsObject:_lineItemsModel];
                        
                    } else {
                        Order *orderModel = [self.orderFetchedResultsController.fetchedObjects lastObject];
                        orderModel.number = [json valueForKey:@"number"];
                        [orderModel addCartLineItemsObject:_lineItemsModel];
    
                    }
                    
                    
                    [self.managedObjectContext save:nil];
                    [self dismissViewControllerAnimated:YES completion:^{
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"updateAdded" object:nil];
                    }];
                    
                }
                
            });
        }
        else {
               [self displayConnectionFailed];
        }
        
        
    }];
    
    [task resume];
    UIWindow *window = [[UIApplication sharedApplication] delegate].window;
    self.hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    self.hud.dimBackground = YES;
    self.hud.labelText = @"Adding To Cart...";
    self.hud.color = self.view.tintColor;
    
    
}



-(NSArray *)getCartProductsArray:(NSDictionary *)lineItem {
    
    NSMutableArray *jsonarray = [[NSMutableArray alloc] init];
    
    [jsonarray addObject:lineItem];
    
    return jsonarray;
    
}



-(NSDictionary *)getOrdersDictionary:(NSArray *)array {
    NSDictionary *orders = @{
                             @"order": @{
                                     @"line_items": array
                                     }
                             };
    return orders;
}

-(NSDictionary *)getLineItemDictionaryWithLineItem:(NSDictionary *)item {
    NSDictionary *line_items = @{
                                 @"line_item": item
                                 };
    
    return line_items;
}


-(NSDictionary *)lineItemDictionaryWithVariantID:(NSNumber *)variantID quantity:(NSNumber *)quantity {
    return @{
             @"variant_id": variantID,
             @"quantity"  : quantity
             };
}


-(void)displayConnectionFailed {
    UIAlertView *failed_alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    [failed_alert show];
}


#pragma mark Feteched Results Controller

//-(NSFetchedResultsController *)cartFetchedResultsController {
//    if (_cartFetchedResultsController != nil) {
//        return _cartFetchedResultsController;
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
//    _cartFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
//    _cartFetchedResultsController.delegate = self;
//    
//    NSError *error = nil;
//    if (![self.cartFetchedResultsController performFetch:&error]) {
//        NSLog(@"Core data error %@, %@", error, [error userInfo]);
//        abort();
//    }
//    
//    return _cartFetchedResultsController;
//}


-(NSFetchedResultsController *)orderFetchedResultsController {
    if (_orderFetchedResultsController != nil) {
        return _orderFetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    NSString *cacheName = @"OrderCache";
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.orderFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:cacheName];
    NSError *error;
    if(![self.orderFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",error);
    }
    
    return _orderFetchedResultsController;
}



@end

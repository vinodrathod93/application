//
//  PopupCartViewController.m
//  Neediator
//
//  Created by adverto on 27/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "PopupCartViewController.h"
#import "AppDelegate.h"
#import "LineItems.h"
#import "Order.h"
#import "User.h"
#import "StoreRealm.h"
#import <CoreData/CoreData.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define kEmptyCartURL @"/api/orders"

@interface PopupCartViewController ()

@property (nonatomic, strong) NSFetchedResultsController *pop_lineItemsFetchedResultsController;
@property (nonatomic, strong) NSFetchedResultsController *pop_orderFetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Order *orderModel;
@property (nonatomic, strong) MBProgressHUD *hud;

@end

typedef void(^completion)(BOOL finished);

@implementation PopupCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self checkLineItems];
    [self checkOrders];
    
    _orderModel = [self.pop_orderFetchedResultsController.fetchedObjects lastObject];
    
    self.warningMessageLabel.text = [NSString stringWithFormat:@"You have %lu Items in the Cart from %@, Do Checkout unless your Order gets lost", self.pop_lineItemsFetchedResultsController.fetchedObjects.count, _orderModel.store];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pop_lineItemsFetchedResultsController.fetchedObjects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"popupCartCell"];
    
    if (self.pop_lineItemsFetchedResultsController.fetchedObjects.count != 0) {
        LineItems *model = self.pop_lineItemsFetchedResultsController.fetchedObjects[indexPath.row];
        cell.textLabel.text = model.name;
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:13.0f];
    }
    
    return cell;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _orderModel.store;
}


- (IBAction)emptyCart:(id)sender {
    
    
    [self emptyWholeCart:^(BOOL finished) {
        
        [self.hud hide:YES];
        
        if (finished) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"Could not delete. Please try again");
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not Remove Items. Please Try again..." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
            }];
            
        }
        
    }];
    
    
}

- (IBAction)goToCart:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        // go to cart tab bar
        
        UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
        [tabBarController setSelectedIndex:1];
        
        
        
    }];
    
}


-(void)checkLineItems {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"LineItems"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lineItemID" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.pop_lineItemsFetchedResultsController = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if (![self.pop_lineItemsFetchedResultsController performFetch:&error]) {
        NSLog(@"LineItems Model Fetch Failure: %@", [error localizedDescription]);
    }
}


-(void)checkOrders {
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Order"];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    self.pop_orderFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    NSError *error;
    if(![self.pop_orderFetchedResultsController performFetch:&error])
    {
        
        NSLog(@"Order Model Fetch Failure: %@",error);
    }
    
}




-(void)emptyWholeCart:(completion)success {
    User *user = [User savedUser];
    RLMRealm *realm = [RLMRealm defaultRealm];
    StoreRealm *store = [[StoreRealm allObjectsInRealm:realm] lastObject];
    
    [self checkOrders];
    self.orderModel = self.pop_orderFetchedResultsController.fetchedObjects.lastObject;
    
    if (user.access_token != nil) {
        NSString *url = [NSString stringWithFormat:@"http://%@%@/%@/empty?token=%@",store.storeUrl, kEmptyCartURL, self.orderModel.number, user.access_token];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
        request.HTTPMethod = @"PUT";
        [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        
        
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (data != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@",response);
                    
                    
                    NSHTTPURLResponse *url_response = (NSHTTPURLResponse *)response;
                    NSLog(@"Response %ld", (long)[url_response statusCode]);
                    
                    if (url_response.statusCode == 204) {
                        
                        
                        // Remove from core data.
                        [self deleteAllObjects:@"Order"];
                        
                        [self deleteAllObjects:@"LineItems"];
                        
                        
                        success(YES);
                        
                    } else {
                        
                        success(NO);
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
        self.hud.labelText = @"Removing all...";
        self.hud.center = self.view.center;
        self.hud.dimBackground = YES;
        self.hud.color = self.view.tintColor;
        
    } else {
        
        // login page.
        
        NSLog(@"Not logged in");
    }
}

-(void)displayConnectionFailed {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.hud hide:YES];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Network Error" message:@"The Internet Connection Seems to be not available, error while connecting" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    });
    
    
}



- (void) deleteAllObjects: (NSString *) entityDescription  {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    
    for (NSManagedObject *managedObject in items) {
        [self.managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted",entityDescription);
    }
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
    
}

@end

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
#import <CoreData/CoreData.h>

@interface PopupCartViewController ()

@property (nonatomic, strong) NSFetchedResultsController *pop_lineItemsFetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation PopupCartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self checkLineItems];
    
    self.warningMessageLabel.text = [NSString stringWithFormat:@"You have %lu Items in the Cart, Do Checkout otherwise your Order will be lost", self.pop_lineItemsFetchedResultsController.fetchedObjects.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
    return @"Manish Store";
}


- (IBAction)emptyCart:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)goToCart:(id)sender {
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

@end

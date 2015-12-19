//
//  MyAccountViewController.m
//  Chemist Plus
//
//  Created by adverto on 06/08/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "MyAccountViewController.h"
#import "ProfileViewCell.h"
#import "User.h"
#import "LogSignViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "LogSignViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AddressesViewController.h"
#import "AppDelegate.h"
#import "MyOrdersViewController.h"

enum MyAccountCells {
    MyOrdersCell = 0,
    MyAddressesCell,
    TrackOrdersCell
};

@interface MyAccountViewController ()
{
    NSString *cellIdentifier;
    
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation MyAccountViewController {
    NSArray  *_iconsArray;
    NSArray  *_options;
    MBProgressHUD *_hud;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    
    
    
    _options = @[ @"", @[@"My Orders", @"My Addresses", @"Track Order"],
                  @"Sign Out"];
    _iconsArray  = @[
                     @"",
                     @[@"my_orders", @"address", @"track"],
                     @"signout"
                     ];
    
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _options.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if ([_options[section] isKindOfClass:[NSArray class]]) {
        
        NSArray *array = _options[section];
        
        return array.count;
        
    }
    else
        return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        cellIdentifier = @"profileViewCell";
    } else
        cellIdentifier = @"optionsCell";
    
    id cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    
    if (indexPath.section == 0) {
        [self configureProfileViewCell:cell forIndexPath:indexPath];
    } else
        [self configureBasicViewCell:cell forIndexPath:indexPath];
    
    return cell;
}


-(void)configureProfileViewCell:(ProfileViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    User *user = [User savedUser];
    
    NSLog(@"%f",cell.profileImage.frame.size.width);
    
    cell.userName.text = user.fullName;
    cell.userEmail.text = user.email;
    
    NSURL *url = [NSURL URLWithString:user.profilePic];
    [cell.profileImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile_placeholder"] options:SDWebImageRefreshCached];
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2.0f;
    cell.profileImage.clipsToBounds = YES;
    
}


-(void)configureBasicViewCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    
    if ([_options[indexPath.section] isKindOfClass:[NSArray class]]) {
        
        NSArray *array = _options[indexPath.section];
        NSArray *icons = _iconsArray[indexPath.section];
        
        cell.textLabel.text = array[indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", icons[indexPath.row]]];
    }
    else if(indexPath.section != 0) {
        cell.textLabel.text = _options[indexPath.section];
        cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", _iconsArray[indexPath.section]]];
    }
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 212.0f;
    } else
        return 44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == MyOrdersCell) {
//            MyOrdersViewController *myOrdersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"myOrdersVC"];
            
            MyOrdersViewController *myOrdersVC = [[MyOrdersViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:myOrdersVC animated:YES];
        }
        else if (indexPath.row == MyAddressesCell) {
            
            AddressesViewController *addressesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesVC"];
            addressesVC.isGettingOrder = NO;
            [self.navigationController pushViewController:addressesVC animated:YES];
        }
        

    }
    else if (indexPath.section == 2) {
        
//        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc]init];
//        [manager logOut];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        [self showWarningBeforeSignoutForCell:cell];
    }
    
}


-(void)removeLastObject {
    _options = @[
                  @[@"My Orders", @"My Addresses", @"Track Order"]
                 ];
}



-(void)showWarningBeforeSignoutForCell: (UITableViewCell *)cell {
    UIAlertController *alertController  = [UIAlertController alertControllerWithTitle:nil message:@"Are you Sure ?" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *signoutAction = [UIAlertAction actionWithTitle:@"Yes, Signout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.dimBackground = YES;
        
        // Remove all user data here
        [self removeAllUserData];
        
        [self removeLastObject];
        
        [self.tableView reloadData];
        
        [_hud hide:YES];
        
        
//        LogSignViewController *logSignVC = [self.storyboard instantiateViewControllerWithIdentifier:@"logSignNVC"];
//        
//        [self presentViewController:logSignVC animated:NO completion:nil];
        
        
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // dismiss alertController
        
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:signoutAction];
    [alertController addAction:cancelAction];
    
    alertController.popoverPresentationController.sourceView = cell;
    alertController.popoverPresentationController.sourceRect = cell.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
    
}


-(void)removeAllUserData {
    
    // Clear all orders & lineItems
    [self deleteAllObjects:@"Order"];
    [self deleteAllObjects:@"LineItems"];
    
    
    
    User *user = [User savedUser];
    NSLog(@"%@",user);
    
    [User clearUser];
    
    
    
    
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

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
//#import <FBSDKCoreKit/FBSDKCoreKit.h>
//#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "LogSignViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AddressesViewController.h"
#import "AppDelegate.h"
#import "MyOrdersViewController.h"
#import "LoginView.h"
#import "FavouritesViewController.h"
#import "EditProfileViewController.h"
#import "MyOrdersVC.h"
#import "NewMyOrdersViewController.h"
#import "ShowMyBookingsVC.h"


enum MyAccountCells {
    MyOrdersCell=0,
    MyBookingCell,
    MyAddressesCell,
    FavouriteCell,
    LeaderBoardCell
};

#define kLoginViewTag 20

@interface MyAccountViewController ()
{
    NSString *cellIdentifier;
    
}

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation MyAccountViewController
{
    NSArray  *_iconsArray;
    NSArray  *_options;
    MBProgressHUD *_hud;
    LoginView *_loginView;
}

#pragma mark - View Did Load
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editProfile:)];
    UIBarButtonItem *cartItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"Logout"] style:UIBarButtonItemStylePlain target:self action:@selector(ShowLogout)];
    self.navigationItem.leftBarButtonItem = cartItem;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    [self showViewAfterLogin];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[self.navigationController.view viewWithTag:kLoginViewTag] removeFromSuperview];
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


-(void)configureProfileViewCell:(ProfileViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    
    User *user = [User savedUser];
    NSLog(@"%f",cell.profileImage.frame.size.width);
    
    NSString *firstname = setValidValue(user.firstName);
    NSString *lastname = setValidValue(user.lastName);
    
    cell.userName.text = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
    cell.userEmail.text = setValidValue(user.email);
    cell.userMobile.text    =   isValid(user.mobno) ? user.mobno : @"+91 xxxxx xxxxx";
    
    NSURL *url = [NSURL URLWithString:user.profilePic];
    cell.backgroundColor = [UIColor whiteColor];
    [cell.profileImage sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"profile_placeholder"] options:SDWebImageRefreshCached];
    cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.width/2.0f;
    cell.profileImage.clipsToBounds = YES;
}


-(void)configureBasicViewCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    
    if ([_options[indexPath.section] isKindOfClass:[NSArray class]]) {
        
        NSArray *array = _options[indexPath.section];
        NSArray *icons = _iconsArray[indexPath.section];
        
        cell.textLabel.text = array[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", icons[indexPath.row]]];
    }
    else if(indexPath.section != 0) {
        cell.textLabel.text = _options[indexPath.section];
        cell.imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", _iconsArray[indexPath.section]]];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
    {
        return 238.f;
    } else
        return 44.0f;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (section == 0) {
        header.frame = CGRectMake(0, 0, self.view.frame.size.width, 1);
    }
    else if (section == 1) {
        header.frame = CGRectMake(0, 0, self.view.frame.size.width, 10);
    }
    
    
    return header;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 1.f;
    }
    else
        return 10.f;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        
        if (indexPath.row == MyOrdersCell) {
            
            //            MyOrdersViewController *myOrdersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"myOrdersVC"];
            //            [self.navigationController pushViewController:myOrdersVC animated:YES];
            
//            MyOrdersVC *myOrdersVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyOrdersVC"];
//            [self.navigationController pushViewController:myOrdersVC animated:YES];
            
            NewMyOrdersViewController *newOrderVC   =   [self.storyboard instantiateViewControllerWithIdentifier:@"newMyOrdersVC"];
            [self.navigationController pushViewController:newOrderVC animated:YES];
            
        }
        
        else if (indexPath.row==MyBookingCell)
        {
            ShowMyBookingsVC *addressesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShowMyBookingsVC"];
            
//            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:addressesVC];
//            [self presentViewController:navigationController animated:YES completion:nil];
           [self.navigationController pushViewController:addressesVC animated:YES];
        }
        
        else if (indexPath.row == MyAddressesCell)
        {
            AddressesViewController *addressesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesVC"];
            addressesVC.isGettingOrder = NO;
            [self.navigationController pushViewController:addressesVC animated:YES];
        }
        else if (indexPath.row == FavouriteCell) {
            
            FavouritesViewController *favouritesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"favouritesVC"];
            
            [self.navigationController pushViewController:favouritesVC animated:YES];
        }
    }
    else if (indexPath.section == 2) {
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [self showWarningBeforeSignoutForCell:cell];
    }
}




-(void)showWarningBeforeSignoutForCell: (UITableViewCell *)cell {
    
    UIAlertController *alertController  = [UIAlertController alertControllerWithTitle:nil message:@"Are you Sure ?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *signoutAction = [UIAlertAction actionWithTitle:@"Yes, Signout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.dimBackground = YES;
        // Remove all user data here
        [self removeAllUserData];
        [self.tableView reloadData];
        [_hud hide:YES];
        // present login view or show login view.
        [self displayLoginView];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:signoutAction];
    [alertController addAction:cancelAction];
    
    alertController.popoverPresentationController.sourceView = cell;
    alertController.popoverPresentationController.sourceRect = cell.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark - Helper Methods.
-(void)ShowLogout
{
    UIAlertController *alertController  = [UIAlertController alertControllerWithTitle:nil message:@"Are you Sure ?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *signoutAction = [UIAlertAction actionWithTitle:@"Yes, Signout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
    {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.dimBackground = YES;
        // Remove all user data here
        [self removeAllUserData];
        [self.tableView reloadData];
        [_hud hide:YES];
        // present login view or show login view.
        [self displayLoginView];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertController addAction:signoutAction];
    [alertController addAction:cancelAction];
    
    //    alertController.popoverPresentationController.sourceView = self;
    //    alertController.popoverPresentationController.sourceRect = cell.bounds;
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}





-(void)removeAllUserData
{
    
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


-(void)showLoginPageVC
{
    LogSignViewController *logSignVC = [self.storyboard instantiateViewControllerWithIdentifier:@"logSignNVC"];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        logSignVC.modalPresentationStyle    = UIModalPresentationFormSheet;
    }
    
    
    [self presentViewController:logSignVC animated:YES completion:nil];
    
    
}



-(void)displayLoginView {
    
    _loginView = [[[NSBundle mainBundle] loadNibNamed:@"LoginView" owner:self options:nil] lastObject];
    _loginView.frame = self.tableView.frame;
    _loginView.tag = kLoginViewTag;
    
    [_loginView.signinButton addTarget:self action:@selector(showLoginPageVC) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationController.view insertSubview:_loginView belowSubview:self.navigationController.navigationBar];
    
}


-(void)showViewAfterLogin {
    
    User *user = [User savedUser];
    
    if (user != nil) {
        //        _options = @[ @"", @[@"My Orders", @"My Bookings", @"My Addresses",@"Favourites", @"Leaderboard"],
        //                      @"Sign Out"];
        
        //        _iconsArray  = @[
        //                         @"",
        //                         @[@"myorder", @"booking", @"address",@"store_fav", @"leaderboard"],
        //                         @"signout"
        //                         ];
        
        
        _options = @[ @"", @[@"My Orders", @"My Bookings", @"My Addresses",@"Favourites", @"Leaderboard"]];
        
        
        _iconsArray  = @[
                         @"",
                         @[@"myorder", @"booking", @"address",@"store_fav", @"leaderboard"]];
        
        
        [self.tableView reloadData];
    }
    else {
        
        // Show login view
        
        [self displayLoginView];
    }
    
}

-(void)editProfile:(id)sender {
    
    EditProfileViewController *editProfileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"editProfileVC"];
    [self.navigationController pushViewController:editProfileVC animated:YES];
    
}


@end

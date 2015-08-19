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

@interface MyAccountViewController ()
{
    NSString *cellIdentifier;
}
@property (nonatomic, strong) NSMutableArray *options;

@end

@implementation MyAccountViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear");
    self.options = [[NSMutableArray alloc]initWithArray:@[@"My Orders", @"My Addresses", @"Track Order", @"Account Settings", @"Sign Out"]];
    
    
    [self.tableView reloadData];
    
    
    User *user = [User savedUser];
    NSLog(@"%@",user.userID);
    
    if (!user) {
        NSLog(@"not user");
    } else if (user != nil) {
        NSLog(@"correctly not user");
    }
    
//    ![FBSDKAccessToken currentAccessToken]
    
    if (user == nil) {
//        LogSignViewController *logSignupVC = [self.storyboard instantiateViewControllerWithIdentifier:@"logSignNVC"];
//        [self presentViewController:logSignupVC animated:YES completion:nil];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    return [self.options count];
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
    cell.textLabel.text = self.options[indexPath.row];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 212.0f;
    } else
        return 44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 4) {
        FBSDKLoginManager *manager = [[FBSDKLoginManager alloc]init];
        [manager logOut];
        
        User *user = [User savedUser];
        NSLog(@"%@",user);
        
        [User clearUser];
        
        [self.options removeLastObject];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        LogSignViewController *logSignVC = [self.storyboard instantiateViewControllerWithIdentifier:@"logSignNVC"];
        [self presentViewController:logSignVC animated:NO completion:nil];
    }
}


@end

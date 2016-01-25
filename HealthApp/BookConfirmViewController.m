//
//  BookConfirmViewController.m
//  Neediator
//
//  Created by adverto on 25/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "BookConfirmViewController.h"
#import "OrderCompleteViewController.h"

@interface BookConfirmViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation BookConfirmViewController {
    NSURLSessionDataTask *_task;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = @"Verify Details";
    
    self.bookButton.layer.cornerRadius = 5.f;
    self.bookButton.layer.masksToBounds = YES;
    [self.bookButton addTarget:self action:@selector(sendBookRequest) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    User *user = [User savedUser];
    if (user.userID != nil) {
        // Logged in
        
        [self loadInfo];
    }
    else {
        [self showLoginPageAndIsPlacingOrder:NO];
    }
}

-(void)showLoginPageAndIsPlacingOrder:(BOOL)isPlacing {
    
    LogSignViewController *logSignVC = (LogSignViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
    logSignVC.isPlacingOrder = isPlacing;
    
    UINavigationController *logSignNav = [[UINavigationController alloc]initWithRootViewController:logSignVC];
    logSignNav.navigationBar.tintColor = self.view.tintColor;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        logSignNav.modalPresentationStyle    = UIModalPresentationFormSheet;
    }
    
    [self presentViewController:logSignNav animated:YES completion:^{
        [self loadInfo];
    }];
}




-(void)loadInfo {
    
    User *user = [User savedUser];
    if (user.userID != nil) {
        self.emailTextfield.text = user.email;
    }
    else
        self.emailTextfield.text = @"NOT LOGGED IN";
    
    self.name.text = self.entity_name;
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.entity_meta_info]];
    self.appointmentDateTimeLabel.text = [NSString stringWithFormat:@"🕚 %@, %@",self.date, self.time];
    
}


-(void)sendBookRequest {
    
    NSLog(@"Book");
    User *user = [User savedUser];
    
    NSDictionary *parameter = @{
                                
                                @"CatId" : self.cat_id,
                                @"StoreId" : self.entity_id,
                                @"BusinessIntervalId" : self.timeSlot_id,
                                @"date" : self.date,
                                @"userid" : user.userID
                                
                                };
    
    NSLog(@"Parameter %@", parameter);
    
    [self showHUD];
    _task = [[NAPIManager sharedManager] postBookingWithRequest:parameter success:^(NSDictionary *response) {
        NSLog(@"Success %@", response);
        
        OrderCompleteViewController *bookCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
        bookCompleteVC.order_number.text            = [NSString stringWithFormat:@"Appointment no. %@", response[@"appointmentid"]];
        bookCompleteVC.message.text                 = @"Your Appointment is currently being processed. You will receive an appointment confirmation email shortly with the date & time.";
        bookCompleteVC.viewButton.hidden            = YES;
        
        [self.navigationController pushViewController:bookCompleteVC animated:YES];
        
        
        [self hideHUD];
    } failure:^(NSError *error) {
        
        [self hideHUD];
        NSLog(@"Error %@", error.localizedDescription);
    }];
    
}


-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.color = [UIColor clearColor];
    self.hud.labelText = @"Loading...";
    self.hud.labelColor = [UIColor darkGrayColor];
    self.hud.activityIndicatorColor = [UIColor blackColor];
    self.hud.detailsLabelColor = [UIColor darkGrayColor];
}

-(void)hideHUD {
    [self.hud hide:YES];
}


@end

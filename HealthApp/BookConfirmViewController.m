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

@implementation BookConfirmViewController
{
    NSURLSessionDataTask *_task;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.title = @"VERIFY DETAILS";
    
    self.bookButton.layer.cornerRadius = 5.f;
    self.bookButton.layer.masksToBounds = YES;
    [self.bookButton addTarget:self action:@selector(bookButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self loadInfo];
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
    self.metaLabel.text = self.entity_meta_string;
    
    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width/2;
    self.profileImageView.layer.masksToBounds = YES;
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.image_url]];
    self.appointmentDateTimeLabel.text = [NSString stringWithFormat:@"🕚 %@, %@",self.date, self.time];
    
}



-(void)bookButtonTapped {
    
    User *user = [User savedUser];
    if (user.userID != nil) {
        // Logged in
        
        [self sendBookRequest];
    }
    else {
        [self showLoginPageAndIsPlacingOrder:NO];
    }
}


-(void)sendBookRequest {
    
    NSLog(@"Book");
    User *user = [User savedUser];
    
    //    NSDictionary *parameter = @{
    //
    //                                @"CatId" : self.cat_id,
    //                                @"StoreId" : self.entity_id,
    //                                @"BusinessIntervalId" : self.timeSlot_id,
    //                                @"date" : self.date,
    //                                @"userid" : user.userID
    //
    //                                };
    
    NSString *parameterString = [NSString stringWithFormat:@"SectionId=%@&StoreId=%@&BusinessIntervalId=%@&date=%@&userid=%@", self.cat_id, self.entity_id, self.timeSlot_id, self.date, user.userID];
    
    
    
    
    
    //    NSLog(@"Parameter %@", parameterString);
    //
    //    [self showHUD];
    //    _task = [[NAPIManager sharedManager] postBookingWithRequest:parameterString success:^(NSDictionary *response) {
    //        NSLog(@"Success %@", response);
    //
    //        OrderCompleteViewController *bookCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
    //        bookCompleteVC.booking_id                   = [NSString stringWithFormat:@"Booking no. %@", response[@"appointmentid"]];
    //        bookCompleteVC.message                      = @"Your Appointment is currently being processed. You will receive an appointment confirmation email shortly with the date & time.";
    //        bookCompleteVC.heading                      = @"Booking Complete Successfully";
    //
    //        [self.navigationController pushViewController:bookCompleteVC animated:YES];
    //
    //
    //        [self hideHUD];
    //    } failure:^(NSError *error) {
    //
    //        [self hideHUD];
    //        NSLog(@"Error %@", error.localizedDescription);
    //    }];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://192.168.1.199/NeediatorWebservice/neediatorWs.asmx/Book"]];
    
    
    request.HTTPMethod = @"POST";
    request.HTTPBody   = [NSData dataWithBytes:[parameterString UTF8String] length:[parameterString length]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"%@",response);
        
        
        
        if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
        else
        {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&jsonError];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Display on main view
                [self hideHUD];
                
                OrderCompleteViewController *bookCompleteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"orderCompleteVC"];
                bookCompleteVC.booking_id            = [NSString stringWithFormat:@"Booking no. %@", json[@"appointmentid"]];
                bookCompleteVC.message                 = @"Your Booking is currently being processed. You will receive an Booking confirmation email shortly with complete details.";
                bookCompleteVC.heading                  = @"Booking Complete Successfully";
                
                [self.navigationController pushViewController:bookCompleteVC animated:YES];
            });
        }
        
    }];
    [task resume];
    [self showHUD];
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

//
//  DoctorViewController.m
//  Chemist Plus
//
//  Created by adverto on 31/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "DoctorViewController.h"
#import "DoctorViewCell.h"
#import "DoctorDetailsViewController.h"
#import "DoctorModel.h"
#import "ClinicsModel.h"
#import "NoStores.h"
#import "NoConnectionView.h"

NSString *const CellIdentifier = @"doctorsCell";

@interface DoctorViewController ()

@property (nonatomic, strong) NSArray *doctorsArray;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NoStores *noDoctorsView;

@end

@implementation DoctorViewController {
    NoConnectionView *_connectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self requestDoctors];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    [[self.navigationController.view viewWithTag:kDoctorsNoDoctorsTag] removeFromSuperview];
    
    [self removeConnectionView];
    
    
}


-(void)requestDoctors {
    [self removeConnectionView];
    
    Location *location_store = [Location savedLocation];
    
    StoreListRequestModel *requestModel = [StoreListRequestModel new];
    requestModel.location = [NSString stringWithFormat:@"%@,%@", location_store.latitude, location_store.longitude];
    
    [self showHUD];
    
    [[APIManager sharedManager] getDoctorListingsWithRequestModel:requestModel success:^(DoctorResponseModel *response) {
        NSLog(@"response %@",response);
        
        [self hideHUD];
        self.doctorsArray = response.clinics;
        
        if (self.doctorsArray.count == 0) {
            [self showNoDoctorsView:location_store];
        }
        
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error, BOOL loginFailure) {
        [self hideHUD];
        
        if (error) {
            NSLog(@"Error %@",[error localizedDescription]);
            
            
            _connectionView = [[[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil] lastObject];
            _connectionView.tag = kDoctorsConnectionViewTag;
            _connectionView.frame = self.tableView.frame;
            _connectionView.label.text = [error localizedDescription];
            [_connectionView.retryButton addTarget:self action:@selector(requestDoctors) forControlEvents:UIControlEventTouchUpInside];
            
            [self.navigationController.view insertSubview:_connectionView belowSubview:self.navigationController.navigationBar];
            
        }
        else if (loginFailure) {
            LogSignViewController *logSignVC = (LogSignViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
            logSignVC.isPlacingOrder = NO;
            
            UINavigationController *logSignNav = [[UINavigationController alloc] initWithRootViewController:logSignVC];
            logSignNav.navigationBar.tintColor = self.tableView.tintColor;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                logSignNav.modalPresentationStyle    = UIModalPresentationFormSheet;
            }
            
            [self presentViewController:logSignNav animated:YES completion:nil];
        }
    }];
    
}

-(void)removeConnectionView {
    
    if (_connectionView) {
        [[self.navigationController.view viewWithTag:kDoctorsConnectionViewTag] removeFromSuperview];
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.doctorsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DoctorViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ClinicsModel *clinics = self.doctorsArray[indexPath.row];
    
    cell.doctorNameLabel.text = clinics.doctor.name;
    cell.clinicLocationLabel.text = clinics.street_address;
    cell.clinicName.text = clinics.name;
    cell.experienceLabel.text = [NSString stringWithFormat:@"%@yrs",clinics.doctor.experience.stringValue];
    cell.distance.text = [NSString stringWithFormat:@"%.02f KM", clinics.nearest_distance.floatValue];
    cell.consultationFeeLabel.text = [NSString stringWithFormat:@"Rs. %@", clinics.doctor.fees];
    
    return cell;
}


- (IBAction)bookButtonPressed:(id)sender {
    
    
    
    
    
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"doctorDetailsVC"]) {
//        NSLog(@"Doctor DetailsVC");
//    }
//}



#define Helper Methods 

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.color = [UIColor clearColor];
    self.hud.labelText = @"Loading Doctors...";
    self.hud.labelColor = [UIColor darkGrayColor];
    self.hud.activityIndicatorColor = [UIColor blackColor];
    self.hud.detailsLabelColor = [UIColor darkGrayColor];
}

-(void)hideHUD {
    [self.hud hide:YES];
}


-(void)showNoDoctorsView:(Location *)location {
    
    self.noDoctorsView = [[[NSBundle mainBundle] loadNibNamed:@"NoStores" owner:self options:nil] lastObject];
    self.noDoctorsView.frame = self.tableView.frame;
    self.noDoctorsView.tag = kDoctorsNoDoctorsTag;
    self.noDoctorsView.location.text = location.location_name;
    
    
    [self.noDoctorsView.changeButton addTarget:self action:@selector(goToSearchTab) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.view insertSubview:self.noDoctorsView belowSubview:self.navigationController.navigationBar];
}

-(void)goToSearchTab {
    
    
    [self.noDoctorsView removeFromSuperview];
    
    UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
    
    [tabBarController setSelectedIndex:1];
    
    
}

@end

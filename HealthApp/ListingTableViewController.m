//
//  ListingTableViewController.m
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ListingTableViewController.h"
#import "ListingCell.h"
#import "ChemistResponseModel.h"
#import "HospitalResponseModel.h"
#import "DessertResponseModel.h"
#import "RestaurantResponseModel.h"
#import "NoStores.h"
#import "NoConnectionView.h"
#import "ListingModel.h"


@interface ListingTableViewController ()

@property (nonatomic, strong) NSArray *listingArray;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NoStores *noListingView;

@end

@implementation ListingTableViewController {
    NSURLSessionDataTask *_task;
    NoConnectionView *_connectionView;
}


-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.root.capitalizedString;
    
    [self requestListings];
   
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    [[self.navigationController.view viewWithTag:kListingNoListingTag] removeFromSuperview];
    
    [self removeConnectionView];
    
    [_task cancel];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.listingArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ListingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listingCellIdentifier" forIndexPath:indexPath];
    
    
    // Configure the cell...
    
    ListingModel *model = self.listingArray[indexPath.row];
    
    cell.name.text = model.name;
    cell.street.text = model.street_address;
    cell.city.text = model.city;
    cell.distance.text = [NSString stringWithFormat:@"%.02f KM", model.nearest_distance.floatValue];
    cell.imageview.image = [UIImage imageNamed:self.icon];
    
    return cell;
}




#define Helper Methods

-(void)showHUD {
    self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.hud.color = [UIColor clearColor];
    self.hud.labelText = [NSString stringWithFormat:@"Loading %@...",self.root.capitalizedString];
    self.hud.labelColor = [UIColor darkGrayColor];
    self.hud.activityIndicatorColor = [UIColor blackColor];
    self.hud.detailsLabelColor = [UIColor darkGrayColor];
}

-(void)hideHUD {
    [self.hud hide:YES];
}


-(void)goToSearchTab {
    
    
    [self.noListingView removeFromSuperview];
    
    UITabBarController *tabBarController = (UITabBarController *)[[[UIApplication sharedApplication]keyWindow]rootViewController];
    
    [tabBarController setSelectedIndex:1];
    
    
}

-(void)shownoListingView:(Location *)location {
    
    self.noListingView = [[[NSBundle mainBundle] loadNibNamed:@"NoStores" owner:self options:nil] lastObject];
    self.noListingView.frame = self.tableView.frame;
    self.noListingView.tag = kListingNoListingTag;
    self.noListingView.location.text = location.location_name;
    
    
    [self.noListingView.changeButton addTarget:self action:@selector(goToSearchTab) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController.view insertSubview:self.noListingView belowSubview:self.navigationController.navigationBar];
}


-(void)removeConnectionView {
    
    if (_connectionView) {
        [[self.navigationController.view viewWithTag:kListingConnectionViewTag] removeFromSuperview];
    }
    
}

-(void)requestListings {
    
    
    [self removeConnectionView];
    
    Location *location_store = [Location savedLocation];
    
    ListingRequestModel *requestModel = [ListingRequestModel new];
    requestModel.location = [NSString stringWithFormat:@"%@,%@", location_store.latitude, location_store.longitude];
    
    
    NSDictionary *parameters = [MTLJSONAdapter JSONDictionaryFromModel:requestModel error:nil];
    NSMutableDictionary *parametersWithKey = [[NSMutableDictionary alloc] initWithDictionary:parameters];
    
    [parametersWithKey setObject:kStoreTokenKey forKey:@"token"];
    
    
    NSString *url = [NSString stringWithFormat:@"/api/%@", self.root];
    
    [self showHUD];
    
    _task = [[APIManager sharedManager] GET:url parameters:parametersWithKey progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%@", downloadProgress.localizedDescription);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *responseDictionary = (NSDictionary *)responseObject;
        NSLog(@"Response = %@",responseDictionary);
        
        NSError *error;
        
        [self hideHUD];
        
        if ([self.root isEqualToString:@"chemists"]) {
            
            ChemistResponseModel *list = [MTLJSONAdapter modelOfClass:ChemistResponseModel.class fromJSONDictionary:responseDictionary error:&error];
            NSLog(@"%@",list);
            
            self.listingArray = list.chemists;
            if (self.listingArray.count == 0) {
                [self shownoListingView:location_store];
            }
            
            
            [self.tableView reloadData];
            
        }
        else if ([self.root isEqualToString:@"hospitals"]) {
            HospitalResponseModel *list = [MTLJSONAdapter modelOfClass:HospitalResponseModel.class fromJSONDictionary:responseDictionary error:&error];
            NSLog(@"%@",list);
            
            if (error) {
                NSLog(@"Error in conversion %@",[error description]);
            }
            self.listingArray = list.hospitals;
            if (self.listingArray.count == 0) {
                [self shownoListingView:location_store];
            }
            
            
            [self.tableView reloadData];
            
        }
        else if ([self.root isEqualToString:@"restaurants"]) {
            RestaurantResponseModel *list = [MTLJSONAdapter modelOfClass:RestaurantResponseModel.class fromJSONDictionary:responseDictionary error:&error];
            NSLog(@"%@",list);
            
            if (error) {
                NSLog(@"Error in conversion %@",[error description]);
            }
            
            self.listingArray = list.restaurants;
            if (self.listingArray.count == 0) {
                [self shownoListingView:location_store];
            }
            
            
            [self.tableView reloadData];
            
        }
        else if ([self.root isEqualToString:@"desserts"]) {
            DessertResponseModel *list = [MTLJSONAdapter modelOfClass:DessertResponseModel.class fromJSONDictionary:responseDictionary error:&error];
            NSLog(@"%@",list);
            
            self.listingArray = list.desserts;
            if (self.listingArray.count == 0) {
                [self shownoListingView:location_store];
            }
            
            
            [self.tableView reloadData];
            
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [self hideHUD];
        
        // failure
        if (error) {
            NSLog(@"Error %@",[error localizedDescription]);
            
            
            _connectionView = [[[NSBundle mainBundle] loadNibNamed:@"NoConnectionView" owner:self options:nil] lastObject];
            _connectionView.tag = kListingConnectionViewTag;
            _connectionView.frame = self.tableView.frame;
            _connectionView.label.text = [error localizedDescription];
            [_connectionView.retryButton addTarget:self action:@selector(requestListings) forControlEvents:UIControlEventTouchUpInside];
            
            [self.navigationController.view insertSubview:_connectionView belowSubview:self.navigationController.navigationBar];
            
        }
        
    }];
}


@end

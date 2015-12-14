//
//  SearchViewController.m
//  Neediator
//
//  Created by adverto on 07/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "SearchViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Location.h"
#import "StoreListRequestModel.h"
#import "StoreListResponseModel.h"
#import "APIManager.h"


#define kDefaultLocationMessage @"Select Location"

@interface SearchViewController ()<GMSAutocompleteResultsViewControllerDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL isTapped;
@property (nonatomic, strong) NSString *currentPlace;
@property (nonatomic, strong) NSMutableArray *storesArray;


@end

@implementation SearchViewController {
    UISearchController *_searchController;
    GMSAutocompleteResultsViewController *_autoCompleteViewController;
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    Location *_location;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeSearchController];
    
    _locationManager = [[CLLocationManager alloc] init];
    _geocoder = [[CLGeocoder alloc] init];
    _location = [[Location alloc] init];
    
    _storesArray = [NSMutableArray array];
    [_storesArray addObject:@"Searching..."];
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _location = [Location savedLocation];
    
    if (_location != nil) {
        
        if ([CLLocationManager locationServicesEnabled]) {
            
            if (_location.isCurrentLocation) {
                
                [self decorateSelectCurrentLocation];
                
                
            }
            
        }
        
        [self loadStoresWithLocation:_location];
        self.currentPlace = _location.location_name;
        [self.tableView reloadData];
        
    }
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)initializeSearchController {
    
    _autoCompleteViewController = [[GMSAutocompleteResultsViewController alloc] init];
    _autoCompleteViewController.delegate = self;
    
    
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type                   = kGMSPlacesAutocompleteTypeFilterAddress;
    filter.country                = @"IN";
    
    _autoCompleteViewController.autocompleteFilter = filter;
    
    
    _searchController           = [[UISearchController alloc]initWithSearchResultsController:_autoCompleteViewController];
    _searchController.hidesNavigationBarDuringPresentation = NO;
    _searchController.dimsBackgroundDuringPresentation = YES;
    
    _searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchController.searchBar.searchBarStyle   = UISearchBarStyleMinimal;
    
    [_searchController.searchBar sizeToFit];
    
    self.navigationItem.titleView                = _searchController.searchBar;
    self.definesPresentationContext              = YES;
    
    // resolves the issue of repostioning the tableview when rotated to landscape.
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    _searchController.searchResultsUpdater       = _autoCompleteViewController;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _searchController.modalPresentationStyle = UIModalPresentationPopover;
    } else {
        _searchController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else
        return self.storesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellReuseId = @"SearchReuseCell";
    static NSString *LocationCellReuseId = @"LocationCell";
    
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        NSLog(@"Show location");
        
        cell = [tableView dequeueReusableCellWithIdentifier:LocationCellReuseId];
        
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LocationCellReuseId];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor    = [UIColor darkGrayColor];
        
        if (self.currentPlace == nil) {
            cell.textLabel.text = kDefaultLocationMessage;
        } else
            cell.textLabel.text = self.currentPlace;
        
        
        
        
    } else {
        
        cell = [tableView dequeueReusableCellWithIdentifier:CellReuseId];
        
        if(cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellReuseId];
        }
        
        
        
        id store = [self.storesArray objectAtIndex:indexPath.row];
        
        if ([store isKindOfClass:[StoresModel class]]) {
            StoresModel *model = (StoresModel *)store;
            
            cell.textLabel.text      = model.storeName;
        }
        else
            cell.textLabel.text      = [self.storesArray objectAtIndex:indexPath.row];
        
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.backgroundColor = [UIColor clearColor];
        
    }
    
    
    
    return cell;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        
        return @"Location";
        
    } else
        return @"Browse By Stores";
    
}


#pragma mark - GMSAutocompleteResultsViewControllerDelegate

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
 didAutocompleteWithPlace:(GMSPlace *)place {
    [_searchController setActive:NO];
    
    
    NSLog(@"Place co-ordinates %f and %f", place.coordinate.latitude, place.coordinate.longitude);
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    
    if (self.isTapped) {
        [self deselectCurrentLocation];
    }
    
    
    _location = [Location savedLocation];
    if (_location == nil) {
        
        self.currentPlace = kDefaultLocationMessage;
    }
    else {
        
        NSArray *trimmedLocation        = [place.formattedAddress componentsSeparatedByString:@","];
        
        NSInteger count = trimmedLocation.count;
        NSString *currentPlaceString;
        
        if (count == 1) {
            currentPlaceString          = [NSString stringWithFormat:@"%@", trimmedLocation[count-1]];
        }
        else if (count == 2) {
            currentPlaceString          = [NSString stringWithFormat:@"%@, %@", trimmedLocation[count-1 ], trimmedLocation[count]];
        }
        else if (count == 3) {
            currentPlaceString          = [NSString stringWithFormat:@"%@, %@", trimmedLocation[count-2 ], trimmedLocation[count-1]];
        }
        else if (count == 4) {
            currentPlaceString          = [NSString stringWithFormat:@"%@, %@", trimmedLocation[count-3 ], trimmedLocation[count-2]];
        }
        else if (count > 4) {
            currentPlaceString          = [NSString stringWithFormat:@"%@, %@", trimmedLocation[count-4 ], trimmedLocation[count-3]];
        }
        
        self.currentPlace               = currentPlaceString;
        
        
        _location.location_name          = self.currentPlace;
        _location.latitude               = [NSString stringWithFormat:@"%f", place.coordinate.latitude];
        _location.longitude              = [NSString stringWithFormat:@"%f", place.coordinate.longitude];
        _location.isCurrentLocation      = NO;
        [_location save];
        
        
        
        [self loadStoresWithLocation:_location];
        
    }
    
    if (self.storesArray.count != 0) {
        [self.storesArray removeAllObjects];
        [self.storesArray addObject:@"Searching..."];
    }
    
    [self.tableView reloadData];
    
}

- (void)resultsController:(GMSAutocompleteResultsViewController *)resultsController
didFailAutocompleteWithError:(NSError *)error {
    [_searchController setActive:NO];
    
    NSLog(@"Autocomplete failed with error: %@", error.localizedDescription);
    
    self.currentPlace           = @"Cannot select location now.";
    
    [self.tableView reloadData];
    
}




- (IBAction)nearByButtonPressed:(UIBarButtonItem *)sender {
    
    if (!self.isTapped) {
        
        
        [self selectCurrentLocation];
        
        
    } else {
        
        [self deselectCurrentLocation];
        
    }
    
    
    
}


-(void)selectCurrentLocation {
    
    self.isTapped = YES;
    
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [_locationManager requestWhenInUseAuthorization];
    
    [_locationManager startUpdatingLocation];
    
}

-(void)decorateSelectCurrentLocation {
    
    [self.nearByButton setImage:[UIImage imageNamed:@"near_me_filled"]];
    
}

-(void)deselectCurrentLocation {
    [_locationManager stopUpdatingLocation];
    
    self.isTapped = NO;
    
    [self decorateDeselectCurrentLocation];
    
    [self.tableView reloadData];
}

-(void)decorateDeselectCurrentLocation {
    [self.nearByButton setImage:[UIImage imageNamed:@"near_me"]];
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", [error localizedDescription]);
    
    [self decorateDeselectCurrentLocation];
    
    if ([error domain] == kCLErrorDomain) {
        switch ([error code]) {
            case kCLErrorDenied:
                NSLog(@"go to settings and enable location");
                break;
                
            case kCLErrorLocationUnknown:
                NSLog(@"Location Unknown");
                
            default:
                NSLog(@"Failed to get the location");
                break;
        }
    } else {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Neediator" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
    
    
    
    
    
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        NSLog(@"%.8f", currentLocation.coordinate.longitude);
        NSLog(@"%.8f", currentLocation.coordinate.latitude);
        
    }
    
    _location = [Location savedLocation];
    if (_location != nil) {
        
        if ([oldLocation isEqual:newLocation]) {
            [self decorateSelectCurrentLocation];
        }
        
    }
    
    
    // Reverse Geocoding
    [_geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (error == nil && [placemarks count] > 0) {
            _placemark = [placemarks lastObject];
            NSLog(@"%@ %@\n%@ %@\n%@\n%@",
                                 _placemark.subLocality, _placemark.locality,
                                 _placemark.postalCode, _placemark.addressDictionary,
                                 _placemark.administrativeArea,
                                 _placemark.country);
            
            self.currentPlace = [NSString stringWithFormat:@"%@, %@", _placemark.subLocality, _placemark.locality];
            
            
            _location.latitude = [NSString stringWithFormat:@"%.8f",currentLocation.coordinate.latitude];
            _location.longitude = [NSString stringWithFormat:@"%.8f",currentLocation.coordinate.longitude];
            _location.location_name = self.currentPlace;
            _location.isCurrentLocation = YES;
            
            [_location save];
            
            [self decorateSelectCurrentLocation];
            
            if (self.storesArray.count != 0) {
                [self.storesArray removeAllObjects];
                [self.storesArray addObject:@"Searching..."];
            }
            
            [self.tableView reloadData];
            
            
            [self loadStoresWithLocation:_location];
            
            
            
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}



-(void)loadStoresWithLocation:(Location *)location {
    StoreListRequestModel *requestModel = [StoreListRequestModel new];
    requestModel.location = [NSString stringWithFormat:@"%@,%@", location.latitude, location.longitude];
    
    [[APIManager sharedManager] getStoresWithRequestModel:requestModel success:^(StoreListResponseModel *responseModel) {
        
        if (self.storesArray.count != 0) {
            [self.storesArray removeAllObjects];
        }
        
        
        [self.storesArray addObjectsFromArray:responseModel.stores];
        
        if (self.storesArray.count == 0) {
            [self.storesArray addObject:@"We have not reached here yet!"];
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertError show];
    }];
}






@end

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
#import "ListingRequestModel.h"
#import "StoreListResponseModel.h"
#import "APIManager.h"


#define kDefaultLocationMessage @"Select Location"

@interface SearchViewController ()<GMSAutocompleteResultsViewControllerDelegate, UISearchBarDelegate, UISearchControllerDelegate>

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, assign) BOOL isTapped;
@property (nonatomic, strong) NSString *currentPlace;
@property (nonatomic, strong) NSMutableArray *storesArray;

@end


typedef NS_ENUM(NSUInteger, NeediatorSearchScope)
{
    searchScopeLocation = 0,
    searchScopeCategory,
    searchScopeStore,
    searchScopeProduct
};

@implementation SearchViewController {
    UISearchController *_searchController;
    GMSAutocompleteResultsViewController *_autoCompleteViewController;
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [self initializeSearchController];
    
    _locationManager = [[CLLocationManager alloc] init];
    _geocoder = [[CLGeocoder alloc] init];
    
    _storesArray = [NSMutableArray array];
    [_storesArray addObject:@"Searching..."];
    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    Location *location = [Location savedLocation];
    
    if (location != nil) {
        
        
        /* just to check whether the location selected is current or not */
//        if ([CLLocationManager locationServicesEnabled]) {
//            
//            if (location.isCurrentLocation) {
//                
//                [self decorateSelectCurrentLocation];
//                
//                
//            }
//            
//        }
        
        [self loadStoresWithLocation:location];
        self.currentPlace = location.location_name;
        [self.tableView reloadData];
        
    }
    
    
    
    
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Search Screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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
    _searchController.hidesNavigationBarDuringPresentation = YES;
    _searchController.dimsBackgroundDuringPresentation = YES;
    _searchController.searchBar.placeholder = @"Search";
    _searchController.delegate = self;
    _searchController.searchBar.delegate = self;
    _searchController.searchBar.scopeButtonTitles = @[@"Location", @"Category", @"Store", @"Product"];
    
    _searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _searchController.searchBar.searchBarStyle   = UISearchBarStyleDefault;
    
    [_searchController.searchBar sizeToFit];
    
    self.tableView.tableHeaderView                = _searchController.searchBar;
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


#pragma mark - UISearchController Delegate

-(void)didPresentSearchController:(UISearchController *)searchController {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [searchController.searchBar becomeFirstResponder];
    });
    
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
        
        cell.imageView.image = [UIImage imageNamed:@"location_marker"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textColor    = [UIColor darkGrayColor];
        cell.textLabel.font         = [UIFont fontWithName:@"AvenirNext-Regular" size:15.f];
        
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
        
        cell.imageView.image    = [UIImage imageNamed:@"shop"];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font         = [UIFont fontWithName:@"AvenirNext-Regular" size:15.f];
        
    }
    
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // active search bar
        
        [_searchController setActive:YES];
        
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 40)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, 200, 20)];
    label.textColor = [UIColor blackColor];
    label.font      = [UIFont fontWithName:@"AvenirNext-Medium" size:14.f];
    
    if (section == 0) {
        label.text = [NSString stringWithFormat:@"LOCATION"];
    }
    else
        label.text = @"BROWSE BY STORES";
    
    [headerView addSubview:label];
    
    return headerView;
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
    
    
    Location *location = [Location savedLocation];
    if (location == nil) {
        
        location = [[Location alloc] init];
        
        self.currentPlace = kDefaultLocationMessage;
    }
    
    
    NSArray *trimmedLocation        = [place.formattedAddress componentsSeparatedByString:@","];
    
    NSInteger count = trimmedLocation.count;
    NSString *currentPlaceString;
    
    if (count == 1) {
        currentPlaceString          = [NSString stringWithFormat:@"%@", trimmedLocation[count-1]];
    }
    else if (count == 2) {
        currentPlaceString          = [NSString stringWithFormat:@"%@, %@", trimmedLocation[count-2 ], trimmedLocation[count-1]];
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
    
    
    if (self.currentPlace) {
        self.currentPlace = nil;
    }
    
    self.currentPlace               = currentPlaceString;
    
    
    location.location_name          = self.currentPlace;
    location.latitude               = [NSString stringWithFormat:@"%f", place.coordinate.latitude];
    location.longitude              = [NSString stringWithFormat:@"%f", place.coordinate.longitude];
    location.isCurrentLocation      = NO;
    [location save];
    
    
    
    [self loadStoresWithLocation:location];
    
    
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


#pragma mark -
#pragma mark === UISearchBarDelegate ===
#pragma mark -

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    // to find the autocomplete.
//    https://maps.googleapis.com/maps/api/place/autocomplete/json?components=country:IN&key=AIzaSyDKhfrd69hGKU2ZqUA5Lv5Zd0q00movdPA&input=marin
    
    // to get the lat-lng.
//    https://maps.googleapis.com/maps/api/geocode/json?address=Marine%20Lines,%20Mumbai,%20Maharashtra,%20India&sensor=false
    
    if (selectedScope == searchScopeStore) {
        self.searchController.searchBar.placeholder = @"Search by Store";
    }
    else if (selectedScope == searchScopeCategory)
        self.searchController.searchBar.placeholder = @"Search by Category";
    else if (selectedScope == searchScopeLocation)
        self.searchController.searchBar.placeholder = @"Search by Location";
    else if (selectedScope == searchScopeProduct)
        self.searchController.searchBar.placeholder = @"Search by Product";
    
    
    [self updateSearchResultsForSearchController:self.searchController];
}

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}

- (void)searchForText:(NSString *)searchText scope:(NeediatorSearchScope)scopeOption
{
    
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", [error localizedDescription]);
    
    [self decorateDeselectCurrentLocation];
    
    if ([error domain] == kCLErrorDomain) {
        switch ([error code]) {
            case kCLErrorDenied:
                [self alertLocationPermission];
                
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
    
    Location *location = [Location savedLocation];
    if (location != nil) {
        
        if ([oldLocation isEqual:newLocation]) {
            [self decorateSelectCurrentLocation];
        }
        
    } else {
        location = [[Location alloc] init];
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
            
            if (self.currentPlace) {
                self.currentPlace = nil;
            }
            
            self.currentPlace = [NSString stringWithFormat:@"%@, %@", _placemark.subLocality, _placemark.locality];
            
            
            location.latitude = [NSString stringWithFormat:@"%.8f",currentLocation.coordinate.latitude];
            location.longitude = [NSString stringWithFormat:@"%.8f",currentLocation.coordinate.longitude];
            location.location_name = self.currentPlace;
            location.isCurrentLocation = YES;
            
            [location save];
            
            [self decorateSelectCurrentLocation];
            
            if (self.storesArray.count != 0) {
                [self.storesArray removeAllObjects];
                [self.storesArray addObject:@"Searching..."];
            }
            
            [self.tableView reloadData];
            
            
            [self loadStoresWithLocation:location];
            
            
            
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
}



-(void)loadStoresWithLocation:(Location *)location {
    ListingRequestModel *requestModel = [ListingRequestModel new];
//    requestModel.location = [NSString stringWithFormat:@"%@,%@", location.latitude, location.longitude];
    
    [[APIManager sharedManager] getStoresWithRequestModel:requestModel success:^(StoreListResponseModel *responseModel) {
        
        if (self.storesArray.count != 0) {
            [self.storesArray removeAllObjects];
        }
        
        
        [self.storesArray addObjectsFromArray:responseModel.stores];
        
        if (self.storesArray.count == 0) {
            [self.storesArray addObject:@"We have not reached here yet!"];
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error, BOOL loginFailure) {
        if (loginFailure) {
            
            LogSignViewController *logSignVC = (LogSignViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"loginSignupVC"];
            logSignVC.isPlacingOrder = NO;
            
            UINavigationController *logSignNav = [[UINavigationController alloc] initWithRootViewController:logSignVC];
            logSignNav.navigationBar.tintColor = self.tableView.tintColor;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                logSignNav.modalPresentationStyle    = UIModalPresentationFormSheet;
            }
            
            [self presentViewController:logSignNav animated:YES completion:nil];
        }
        else if (error) {
            
            UIAlertView *alertError = [[UIAlertView alloc]initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertError show];
        }
        
        
    }];
}



-(void)alertLocationPermission {
    
    
    UIAlertController *alertLocationController = [UIAlertController alertControllerWithTitle:@"Location not Enabled" message:@"Location services are not enabled on your device. Please go to settings and enable location service to use this feature." preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Go to Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (UIApplicationOpenSettingsURLString != NULL) {
            NSURL *settingURL         = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingURL];
        }
        else {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Go to Settings" message:@"Location services are not enabled on your device. Please go to settings and enable location service to use this feature." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            
            [alert show];

            
        }
        
        
    }];
    
    
    [alertLocationController addAction:cancelAction];
    [alertLocationController addAction:settingsAction];
    
    [self presentViewController:alertLocationController animated:YES completion:nil];
    
}



@end

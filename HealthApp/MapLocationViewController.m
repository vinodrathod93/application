//
//  MapLocationViewController.m
//  Neediator
//
//  Created by adverto on 16/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "MapLocationViewController.h"

@interface MapLocationViewController ()

@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSURLSession *markerSession;
@property (nonatomic, strong) GMSPolyline *polyline;

@end

@implementation MapLocationViewController {
    NSString *_currentPlaceString;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.URLCache = [[NSURLCache alloc] initWithMemoryCapacity:2*1024*1024 diskCapacity:10*1024*1024 diskPath:@"MarkerData"];
    self.markerSession = [NSURLSession sessionWithConfiguration:config];
    
    
    
    
    UIView *storeInfoView = [[UIView alloc] initWithFrame:CGRectMake(10, self.topLayoutGuide.length + 10, CGRectGetWidth(self.view.frame) - (2*10), 120)];
    storeInfoView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    storeInfoView.layer.cornerRadius = 6.f;
    storeInfoView.layer.masksToBounds = YES;
    
    UILabel *storeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(storeInfoView.frame) - (2 * 10), 30)];
    storeNameLabel.text      = self.storeName;
    storeNameLabel.font      = [NeediatorUtitity mediumFontWithSize:18];
    
    UILabel *storeAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, storeNameLabel.frame.size.height + (2 * 10), CGRectGetWidth(storeInfoView.frame) - (2 * 10), 50)];
    storeAddressLabel.text       = self.storeAddressArray[0][@"address"];
    storeAddressLabel.numberOfLines = 0;
    storeAddressLabel.font = [NeediatorUtitity regularFontWithSize:15.f];
    storeAddressLabel.textColor = [UIColor lightGrayColor];
    
    [storeInfoView addSubview:storeNameLabel];
    [storeInfoView addSubview:storeAddressLabel];
    
    
    
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    
    
//    Location *location = [Location savedLocation];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude zoom:15 bearing:0 viewingAngle:0];
    
//    CGRect frame = CGRectMake(0, 100, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - 100);
    
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.myLocationEnabled = YES;
    
    
    
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMinZoom:0 maxZoom:20];
    
    
    
    NSDictionary *storeAddress = [self.storeAddressArray firstObject];
    NSString *storeLatitude = storeAddress[@"latitude"];
    NSString *storeLongitude = storeAddress[@"longitude"];
    
    
    // setup marker
    
    GMSMarker *marker1 = [[GMSMarker alloc] init];
    marker1.position    = CLLocationCoordinate2DMake(storeLatitude.doubleValue, storeLongitude.doubleValue);
    marker1.title   = self.storeName;
    marker1.appearAnimation  = kGMSMarkerAnimationPop;
    marker1.map         = self.mapView;
    
    
//    [self geocodeCurrentPlaceString];
    
    GMSMarker *currentLocationMarker = [[GMSMarker alloc] init];
    currentLocationMarker.position = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
    currentLocationMarker.title = @"Current Location";
    currentLocationMarker.icon = [GMSMarker markerImageWithColor:[UIColor lightGrayColor]];
    currentLocationMarker.appearAnimation = kGMSMarkerAnimationPop;
    currentLocationMarker.map = self.mapView;
    
    [self focusMapShow:marker1 andDestination:currentLocationMarker];
    [self requestDirectionFromMarker:marker1 toDestination:currentLocationMarker];
    
//    GMSMutablePath *path = [[GMSMutablePath alloc] init];
//    [path addLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
//    [path addLatitude:storeLatitude.doubleValue longitude:storeLongitude.doubleValue];
//    
//    GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
//    singleLine.map = self.mapView;
    
    
    [self.view addSubview:self.mapView];
    [self.view addSubview:storeInfoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    GMSCameraUpdate *zoomCamera = [GMSCameraUpdate zoomOut];
    [self.mapView animateWithCameraUpdate:zoomCamera];
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 5, 0, self.bottomLayoutGuide.length + 5, 0);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}



- (void)focusMapShow:(GMSMarker *)origin andDestination:(GMSMarker *)destination
{
    NSArray *markers = @[origin, destination];
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
    
    for (GMSMarker *marker in markers)
        bounds = [bounds includingCoordinate:marker.position];
    
    [self.mapView animateToBearing:0];
    [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:40]];
    
}


-(void)requestDirectionFromMarker:(GMSMarker *)marker toDestination:(GMSMarker *)destination {
    
    
    
    self.polyline.map = nil;
    self.polyline = nil;
    
    
        NSString *urlString = [NSString stringWithFormat:@"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                               @"https://maps.googleapis.com/maps/api/directions/json",
                               destination.position.latitude,
                               destination.position.longitude,
                               marker.position.latitude,
                               marker.position.longitude,
                               kGoogleAPIServerKey
                               ];
        
        NSURL *directionURL = [NSURL URLWithString:urlString];
        NSURLSessionDataTask *task = [self.markerSession dataTaskWithURL:directionURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // directions Task
            
            
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (!error) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    NSArray *routes = json[@"routes"];
                    if (routes.count > 0) {
                        GMSPath *path = [GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
                        
                        self.polyline = [GMSPolyline polylineWithPath:path];
                        self.polyline.strokeWidth = 7;
                        self.polyline.strokeColor = [UIColor yellowColor];
                        self.polyline.map = self.mapView;
                    }
                    
                }];
            }
            
            
        }];
        
        [task resume];

    
}




-(void)geocodeCurrentPlaceString {
    __block CLPlacemark *placemark;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:self.locationManager.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       NSLog(@"reverseGeocodeLocation:completionHandler: Completion Handler called!");
                       
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                           
                       }
                       
                       
                       placemark = [placemarks objectAtIndex:0];
                       
                       NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
                       NSLog(@"placemark.country %@",placemark.country);
                       NSLog(@"placemark.postalCode %@",placemark.postalCode);
                       NSLog(@"placemark.administrativeArea %@",placemark.administrativeArea);
                       NSLog(@"placemark.locality %@",placemark.locality);
                       NSLog(@"placemark.subLocality %@",placemark.subLocality);
                       NSLog(@"placemark.subThoroughfare %@",placemark.subThoroughfare);
                       
                       NSString *currentPlace = [NSString stringWithFormat:@"%@, %@", placemark.subLocality, placemark.locality];
                       _currentPlaceString = currentPlace;
                       
                   }];
    
    
    
   
}



























@end

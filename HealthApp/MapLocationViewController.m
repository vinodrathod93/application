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
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [self.locationManager startUpdatingLocation];
    
    
//    Location *location = [Location savedLocation];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude zoom:14 bearing:0 viewingAngle:0];
    
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.myLocationEnabled = YES;
    
    
    
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMinZoom:10 maxZoom:18];
    
    
    
    NSDictionary *storeAddress = [self.storeAddressArray firstObject];
    NSString *storeLatitude = storeAddress[@"latitude"];
    NSString *storeLongitude = storeAddress[@"longitude"];
    
    
    // setup marker
    
    GMSMarker *marker1 = [[GMSMarker alloc] init];
    marker1.position    = CLLocationCoordinate2DMake(storeLatitude.doubleValue, storeLongitude.doubleValue);
    marker1.title   = self.storeName;
    marker1.appearAnimation  = kGMSMarkerAnimationPop;
    marker1.map         = self.mapView;
    
    
    [self geocodeCurrentPlaceString];
    
    GMSMarker *currentLocationMarker = [[GMSMarker alloc] init];
    currentLocationMarker.position = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
    currentLocationMarker.title = @"Current Location";
    currentLocationMarker.icon = [GMSMarker markerImageWithColor:[UIColor lightGrayColor]];
    currentLocationMarker.appearAnimation = kGMSMarkerAnimationPop;
    currentLocationMarker.map = self.mapView;
    
    
    [self requestDirectionFromMarker:marker1];
    
//    GMSMutablePath *path = [[GMSMutablePath alloc] init];
//    [path addLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
//    [path addLatitude:storeLatitude.doubleValue longitude:storeLongitude.doubleValue];
//    
//    GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
//    singleLine.map = self.mapView;
    
    
    [self.view addSubview:self.mapView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.mapView.padding = UIEdgeInsetsMake(self.topLayoutGuide.length + 5, 0, self.bottomLayoutGuide.length + 5, 0);
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


-(void)requestDirectionFromMarker:(GMSMarker *)marker {
    
    
    
    self.polyline.map = nil;
    self.polyline = nil;
    
    
        NSString *urlString = [NSString stringWithFormat:@"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                               @"https://maps.googleapis.com/maps/api/directions/json",
                               self.locationManager.location.coordinate.latitude,
                               self.locationManager.location.coordinate.longitude,
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
                    GMSPath *path = [GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
                    
                    self.polyline = [GMSPolyline polylineWithPath:path];
                    self.polyline.strokeWidth = 7;
                    self.polyline.strokeColor = [UIColor yellowColor];
                    self.polyline.map = self.mapView;
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

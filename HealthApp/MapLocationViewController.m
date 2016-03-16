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

@end

@implementation MapLocationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
//    [self.locationManager startUpdatingLocation];
    
    
    Location *location = [Location savedLocation];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:location.latitude.doubleValue longitude:location.longitude.doubleValue zoom:14 bearing:0 viewingAngle:0];
    
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
    marker1.appearAnimation  = kGMSMarkerAnimationPop;
    marker1.map         = self.mapView;
    
    
    
    
    GMSMarker *currentLocationMarker = [[GMSMarker alloc] init];
    currentLocationMarker.position = CLLocationCoordinate2DMake(location.latitude.doubleValue, location.longitude.doubleValue);
    currentLocationMarker.title = @"Current Location";
    currentLocationMarker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    currentLocationMarker.appearAnimation = kGMSMarkerAnimationPop;
    currentLocationMarker.map = self.mapView;
    
    
    
    
    GMSMutablePath *path = [[GMSMutablePath alloc] init];
    [path addLatitude:location.latitude.doubleValue longitude:location.longitude.doubleValue];
    [path addLatitude:storeLatitude.doubleValue longitude:storeLongitude.doubleValue];
    
    GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
    singleLine.map = self.mapView;
    
    
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


//-(void)locationmanager

@end

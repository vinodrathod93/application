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

@end

@implementation MapLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:28.5382 longitude:-81.3687 zoom:14 bearing:0 viewingAngle:0];
    
    self.mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
    self.mapView.mapType = kGMSTypeNormal;
    self.mapView.myLocationEnabled = YES;
    
    self.mapView.settings.compassButton = YES;
    self.mapView.settings.myLocationButton = YES;
    [self.mapView setMinZoom:10 maxZoom:18];
    
    
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

@end

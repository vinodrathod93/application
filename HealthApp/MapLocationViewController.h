//
//  MapLocationViewController.h
//  Neediator
//
//  Created by adverto on 16/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface MapLocationViewController : UIViewController<CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *storeAddressArray;
@property (nonatomic, strong) NSString *storeName;
@property(nonatomic,retain) NSString *storeDistance;


@end

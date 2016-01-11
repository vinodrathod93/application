//
//  ClinicsModel.h
//  Neediator
//
//  Created by adverto on 11/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "DoctorModel.h"

@interface ClinicsModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *street_address;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSNumber *pincode;
@property (nonatomic, copy) NSString *nearest_distance;

@property (nonatomic, strong) DoctorModel *doctor;

@end

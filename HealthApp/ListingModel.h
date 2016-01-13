//
//  ListingModel.h
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ListingModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *street_address;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *pincode;
@property (nonatomic, copy) NSString *nearest_distance;

@end

//
//  ListingModel.m
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ListingModel.h"

@implementation ListingModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"name"                : @"name",
             @"street_address"      : @"street_address",
             @"city"                : @"city",
             @"pincode"             : @"pincode",
             @"nearest_distance"    : @"nearest_distance"
             
             };
}

@end

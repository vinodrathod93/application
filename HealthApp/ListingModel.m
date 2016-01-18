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
             @"list_id"             : @"id",
             @"name"                : @"name",
             @"address"             : @"address",
             @"image_url"           : @"image_url",
             @"city"                : @"city",
             @"mobile"              : @"mobile",
             @"nearest_distance"    : @"distance",
             @"ratings"             : @"ratings"
             
             };
}

@end

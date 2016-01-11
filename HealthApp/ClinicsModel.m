//
//  ClinicsModel.m
//  Neediator
//
//  Created by adverto on 11/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ClinicsModel.h"

@implementation ClinicsModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name": @"name",
             @"street_address": @"street_address",
             @"city": @"city",
             @"pincode": @"pincode",
             @"nearest_distance": @"nearest_distance",
             @"doctor": @"doctor"
             };
}

+(NSValueTransformer *)doctorJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:[DoctorModel class]];
}

@end

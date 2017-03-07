//
//  DoctorResponseModel.m
//  Neediator
//
//  Created by adverto on 11/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "DoctorResponseModel.h"
#import "ClinicsModel.h"

@implementation DoctorResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"clinics" : @"nearclinics"
             };
}

+(NSValueTransformer *)clinicsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[ClinicsModel class]];
}

@end

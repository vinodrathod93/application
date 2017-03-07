//
//  HospitalResponseModel.m
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "HospitalResponseModel.h"
#import "ListingModel.h"
#import "MetaPagingModel.h"

@implementation HospitalResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             
             @"hospitals" : @"hospitals",
             @"meta"     : @"meta"
             
             };
}

+(NSValueTransformer *)hospitalsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[ListingModel class]];
}

+(NSValueTransformer *)metaJSONTransformer {
    return [MTLJSONAdapter transformerForModelPropertiesOfClass:[MetaPagingModel class]];
}

@end

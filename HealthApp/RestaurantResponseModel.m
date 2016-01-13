//
//  RestaurantResponseModel.m
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "RestaurantResponseModel.h"
#import "ListingModel.h"
#import "MetaPagingModel.h"

@implementation RestaurantResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             
             @"restaurants" : @"restaurants",
             @"meta"     : @"meta"
             
             };
}

+(NSValueTransformer *)restaurantsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[ListingModel class]];
}

+(NSValueTransformer *)metaJSONTransformer {
    return [MTLJSONAdapter transformerForModelPropertiesOfClass:[MetaPagingModel class]];
}

@end

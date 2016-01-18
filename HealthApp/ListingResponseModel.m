//
//  ListingResponseModel.m
//  Neediator
//
//  Created by adverto on 18/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ListingResponseModel.h"
#import "ListingModel.h"
#import "PromotionModel.h"

@implementation ListingResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             
             @"services"   : @"Services",
             @"promotions" : @"Promotions"
             
             };
}

+(NSValueTransformer *)servicesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[ListingModel class]];
}

+(NSValueTransformer *)promotionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[PromotionModel class]];
}

@end

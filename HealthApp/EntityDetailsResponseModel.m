//
//  EntityDetailsResponseModel.m
//  Neediator
//
//  Created by adverto on 20/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "EntityDetailsResponseModel.h"
#import "EntityDetailModel.h"

@implementation EntityDetailsResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             
             @"details" : @"Details"
             };
}


+(NSValueTransformer *)detailsJSONTransformer  {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[EntityDetailModel class]];
}

@end

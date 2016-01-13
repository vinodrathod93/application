//
//  ListingResponseModel.m
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ChemistResponseModel.h"
#import "ListingModel.h"
#import "MetaPagingModel.h"

@implementation ChemistResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             
             @"chemists" : @"chemists"
             
             };
}

+(NSValueTransformer *)chemistsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[ListingModel class]];
}


@end

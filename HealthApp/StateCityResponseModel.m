//
//  StateCityResponseModel.m
//  Neediator
//
//  Created by Vinod Rathod on 08/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "StateCityResponseModel.h"
#import "StatesModel.h"

@implementation StateCityResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"states" : @"states"
             
             };
}

+(NSValueTransformer *)statesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[StatesModel class]];
}
@end

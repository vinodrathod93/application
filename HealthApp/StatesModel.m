//
//  StatesModel.m
//  Neediator
//
//  Created by Vinod Rathod on 08/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "StatesModel.h"
#import "CitiesModel.h"

@implementation StatesModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"stateName"   : @"name",
             @"stateID"     : @"id",
             @"cities"      : @"cities"
             };
}


+(NSValueTransformer *)citiesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[CitiesModel class]];
}

@end

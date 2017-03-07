//
//  CitiesModel.m
//  Neediator
//
//  Created by Vinod Rathod on 08/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "CitiesModel.h"

@implementation CitiesModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"cityID"      : @"id",
             @"cityName"    : @"name",
             @"stateID"     : @"stateid"
             
             };
}
@end

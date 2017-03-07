//
//  FilterHelperModel.m
//  Neediator
//
//  Created by Vinod Rathod on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FilterHelperModel.h"

@implementation FilterHelperModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"filterID": @"id",
             @"name"    : @"name"
             
             };
}

@end

//
//  EntityDetailModel.m
//  Neediator
//
//  Created by adverto on 20/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "EntityDetailModel.h"

@implementation EntityDetailModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"title" : @"Key",
             @"body"  : @"Value"
             
             };
}
@end

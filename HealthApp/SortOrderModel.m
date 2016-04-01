//
//  SortOrderModel.m
//  Neediator
//
//  Created by adverto on 01/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "SortOrderModel.h"

@implementation SortOrderModel


+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name"                : @"name",
             @"sortOrderID"         : @"id"
             
             };
}

@end

//
//  MetaPagingModel.m
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "MetaPagingModel.h"

@implementation MetaPagingModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"count": @"count",
             @"total_count": @"total_count",
             @"current_page": @"current_page",
             @"per_page": @"per_page",
             @"pages": @"pages"
             
             };
}

@end

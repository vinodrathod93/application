//
//  ListingRequestModel.m
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "ListingRequestModel.h"

@implementation ListingRequestModel

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"latitude"        : @"latitude",
             @"longitude"       : @"longitude",
             @"category_id"     : @"Sectionid",
             @"subcategory_id"  : @"Categoryid",
             @"page"            : @"page",
             @"sort_id"         : @"type_id",
             @"sortOrder_id"    : @"sort_type",
             @"is24Hrs"         : @"twenty_four_hr",
             @"hasOffers"       : @"offer",
             @"minDelivery_id"  : @"minimum_delivery_id",
             @"ratings_id"      : @"ratings_id",
             @"user_id"         : @"userid"
        };
}




@end

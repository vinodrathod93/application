//
//  PromotionModel.m
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "PromotionModel.h"

@implementation PromotionModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"prom_id"             : @"Id",
             @"code"                : @"PromotionCode",
             @"name"                : @"PromotionName",
             @"image_url"           : @"PromotionImageUrl",
             @"cat_id"              : @"SectionId",
             @"store_id"            : @"StoreId",
             @"is_star_promoter"    : @"isStarPromoter"
             
             };
}
@end

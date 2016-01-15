//
//  CategoryModel.m
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "CategoryModel.h"

@implementation CategoryModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"cat_id"      : @"CatId",
             @"name"        : @"CatName",
             @"group"       : @"CatGroup",
             @"image_url"   : @"ImageUrl",
             @"is_active"   : @"IsActive",
             @"color_code"  : @"ColorCode",
             
             };
}
@end

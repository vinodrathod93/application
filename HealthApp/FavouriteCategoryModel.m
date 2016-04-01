//
//  FavouriteCategoryModel.m
//  Neediator
//
//  Created by adverto on 01/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FavouriteCategoryModel.h"
#import "FavouriteStoreModel.h"

@implementation FavouriteCategoryModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"category": @"category",
             @"cat_id": @"cat_id",
             @"category_image_url": @"image_url",
             @"stores"  : @"details"
             };
}


+ (NSValueTransformer *)storesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[FavouriteStoreModel class]];
}

@end

//
//  FavouritesResponseModel.m
//  Neediator
//
//  Created by adverto on 01/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FavouritesResponseModel.h"
#import "FavouriteCategoryModel.h"

@implementation FavouritesResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"favouriteCategories"  : @"stores"
             };
}

+(NSValueTransformer *)favouriteCategoriesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[FavouriteCategoryModel class]];
}

@end

//
//  FavouriteStoreDetailModel.m
//  Neediator
//
//  Created by adverto on 09/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FavouriteStoreDetailModel.h"
#import "FavouriteStoreModel.h"

@implementation FavouriteStoreDetailModel


+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"favouriteID"    : @"id",
             @"listing_stores" : @"listing_stores"
             
             };
}

+ (NSValueTransformer *)listing_storesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[FavouriteStoreModel class]];
}


@end

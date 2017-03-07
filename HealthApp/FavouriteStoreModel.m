//
//  FavouriteStoreModel.m
//  Neediator
//
//  Created by adverto on 01/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FavouriteStoreModel.h"

@implementation FavouriteStoreModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"store_id"        : @"id",
             @"store_name"      : @"name",
             @"store_image_url" : @"image_url",
             @"timing"          : @"timing",
             @"charges"         : @"charges",
             @"address"         : @"address",
             @"area"            : @"area",
             @"city"            : @"city",
             @"state"           : @"state",
             @"ratings"         : @"ratings",
             @"reviews_count"   : @"reviews_count",
             @"isBook"          : @"book",
             @"isFavourite"     : @"isfavourite",
             @"isLike"          : @"islike",
             @"isDislike"       : @"dislike",
             @"phone_numbers"   : @"phone_no",
             @"likeDislikes"    : @"LikeUnlike",
             @"images"          : @"Images"
             };
}
@end

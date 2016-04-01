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
             @"fav_id" : @"id",
             @"store_name" : @"name",
             @"storePhoneNumber" : @"phone",
             @"mobile_number" : @"mobile",
             @"store_image_url" : @"image_url",
             @"store_id" : @"store_id",
             @"timing" : @"timing",
             @"charges" : @"charges",
             @"address" : @"address",
             @"city" : @"city",
             @"state" : @"state",
             @"ratings" : @"ratings"
             };
}
@end

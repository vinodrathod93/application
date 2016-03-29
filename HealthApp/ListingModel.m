//
//  ListingModel.m
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ListingModel.h"

@implementation ListingModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"list_id"             : @"id",
             @"name"                : @"name",
             @"address"             : @"address",
             @"image_url"           : @"image_url",
             @"city"                : @"city",
             @"phone_nos"           : @"phone_no",
             @"nearest_distance"    : @"distance",
             @"ratings"             : @"ratings",
             @"timing"              : @"timing",
             @"minOrder"            : @"charges",
             @"reviews_count"       : @"reviews_count",
             @"isFavourite"         : @"isfavourite",
             @"isLike"              : @"islike",
             @"isDislike"           : @"dislike",
             @"isBook"              : @"book",
             @"isCall"              : @"call",
             @"images"              : @"Images",
             @"likeUnlike"          : @"LikeUnlike"
             
             };
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self == nil) return nil;
    
    
    NSLog(@"LikeUnlike %@", self.likeUnlike);
    
    if (self.likeUnlike == nil) {
        self.likeUnlike = @[];
    }
    
    return self;
}

@end

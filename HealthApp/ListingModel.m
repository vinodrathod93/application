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
             @"isBook"              : @"book",
             @"isCall"              : @"call",
             @"images"              : @"Images"
             
             };
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self == nil) return nil;
    
    NSLog(@"Dictionary value %@", dictionaryValue);
    NSLog(@"Phone %@", self.phone_nos);
    NSLog(@"Images %@", self.images);
    
    return self;
}

@end

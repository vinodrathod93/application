//
//  SubCategoryModel.m
//  Neediator
//
//  Created by adverto on 26/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "SubCategoryModel.h"

@implementation SubCategoryModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"categoryID"   : @"CategoryId",
             @"sectionID"      : @"SectionId",
             @"name"        : @"Name",
             @"is_active"   : @"IsActive",
             @"image_url"   : @"ImageUrl"
             
        };
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error
{
    self = [super initWithDictionary:dictionaryValue error:error];
    if (self == nil) return nil;
    NSLog(@"Dictionary value %@", dictionaryValue);
    return self;
}

@end

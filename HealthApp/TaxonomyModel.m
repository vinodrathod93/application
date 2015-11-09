//
//  TaxonomyModel.m
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "TaxonomyModel.h"

@implementation TaxonomyModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"taxonomyName": @"name",
             @"taxons": @"taxons"
             };
}

+ (NSValueTransformer *)taxonsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TaxonModel class]];
}

@end

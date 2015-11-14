//
//  TaxonomyListResponseModel.m
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "TaxonomyListResponseModel.h"

@implementation TaxonomyListResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"taxonomies" : @"taxonomies"
             };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)taxonomiesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:TaxonomyModel.class];
}

@end

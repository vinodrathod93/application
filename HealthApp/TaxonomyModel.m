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
             @"taxonomyName": @"root",
             @"taxons": @"root.taxons"
             };
}

+ (NSValueTransformer *)taxonsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TaxonModel class]];
}

+ (NSValueTransformer *)taxonomyNameJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *root, BOOL *success, NSError *__autoreleasing *error) {
        NSString *taxonomyName = root[@"name"];
        
        return taxonomyName;
    } reverseBlock:^id(NSString *taxonomyName, BOOL *success, NSError *__autoreleasing *error) {
        return @{ @"name": taxonomyName };
    }];
}

@end

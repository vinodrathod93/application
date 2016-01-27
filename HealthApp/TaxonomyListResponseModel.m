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
             @"taxonomies" : @"Taxonomy"
             };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)taxonomiesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:TaxonomyModel.class];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self == nil) return nil;
    
    NSLog(@"%@", dictionaryValue);
    
    
    
    return self;
}
@end

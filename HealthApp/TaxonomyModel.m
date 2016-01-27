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
             @"taxonomyId"  : @"Id",
             @"taxonomyName": @"Name",
             @"hasTaxons"   : @"HasTaxon",
             @"catId"       : @"Catid",
             @"taxons"      : @"Taxons"
             };
}

+ (NSValueTransformer *)taxonsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TaxonModel class]];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self == nil) return nil;
    
    NSLog(@"%@", dictionaryValue);
    
    
    
    return self;
}

@end

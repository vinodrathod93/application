//
//  TaxonModel.m
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "TaxonModel.h"

@implementation TaxonModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"taxonID": @"Id",
             @"taxonName": @"Name",
             @"taxonomyID" : @"TaxonomiesId"
             };
}


-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self == nil) return nil;
    
    NSLog(@"%@", dictionaryValue);
    
    
    
    return self;
}

@end

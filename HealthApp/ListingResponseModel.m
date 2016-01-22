//
//  ListingResponseModel.m
//  Neediator
//
//  Created by adverto on 18/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "ListingResponseModel.h"
#import "ListingModel.h"
#import "PromotionModel.h"

@implementation ListingResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             
             @"records"         : @"records",
             @"type"            : @"type"
             
             };
}

+(NSValueTransformer *)recordsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[ListingModel class]];
}

+(NSValueTransformer *)typeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(id value, BOOL *success, NSError *__autoreleasing *error) {
        return value;
    }];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self == nil) return nil;
    
    NSLog(@"%@", dictionaryValue);
    
    
    if ([dictionaryValue[@"type"] isKindOfClass:[NSDictionary class]]) {
        
        // nothing.
        NSDictionary *type  = dictionaryValue[@"type"];
        self.isProductType  = type[@"IsProduct"];
        self.urlString      = type[@"Url"];
        self.parameters     = type[@"Parameters"];
        
    }
    else
        NSLog(@"Something is nil");
    
    
    return self;
}


@end

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
#import "FilterListModel.h"

@implementation ListingResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             
             @"records"         : @"records",
             @"type"            : @"type",
             @"deliveryTypes"   : @"deliverytype",
             @"sorting_list"    : @"sort",
             @"filter_list"     : @"filter",
             @"current_count"   : @"current_count",
             @"total_count"     : @"total_count",
             @"total_pages"     : @"total_pages",
             @"current_page"    : @"current_page"
             
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

+(NSValueTransformer *)sorting_listJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[SortListModel class]];
}


+(NSValueTransformer *)filter_listJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[FilterListModel class]];
}


-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self == nil) return nil;
    
    NSLog(@"%@", dictionaryValue);
    
    
    if ([dictionaryValue[@"type"] isKindOfClass:[NSDictionary class]]) {
        
        // nothing.
        NSDictionary *type  = dictionaryValue[@"type"];
        
        
        self.isProductType  = [type[@"IsProduct"] boolValue];
        self.urlString      = type[@"Url"];
        self.parameters     = type[@"Parameters"];
        
    }
    else
        NSLog(@"Something is nil");
    
    
    return self;
}


@end

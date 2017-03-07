//
//  StoreListResponseModel.m
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "StoreListResponseModel.h"

@class StoresModel;

@implementation StoreListResponseModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"stores" : @"nearstores"
             };
}

#pragma mark - JSON Transformer

+ (NSValueTransformer *)storesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:StoresModel.class];
}

@end

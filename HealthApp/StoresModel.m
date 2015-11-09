//
//  StoresModel.m
//  Chemist Plus
//
//  Created by adverto on 05/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "StoresModel.h"

@implementation StoresModel

#pragma mark - Mantle JSONKeyPathsByPropertyKey

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"storeName": @"name",
             @"storeUrl" : @"url",
             @"storeStreetAddress": @"street_address",
             @"storeCity": @"city",
             @"storePincode": @"pincode",
             @"storeState": @"state",
             @"storeCountry": @"country",
             @"storeDistance": @"nearest_distance",
             @"storeImage": @"medium_url"
             };
}

+ (NSValueTransformer *)storeStateJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *state, BOOL *success, NSError *__autoreleasing *error) {
        NSString *state_code = state[@"abbr"];
        
        return state_code;
    } reverseBlock:^id(NSString *state_code, BOOL *success, NSError *__autoreleasing *error) {
        return @{ @"abbr": state_code };
    }];
}

+ (NSValueTransformer *)storeCountryJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *country, BOOL *success, NSError *__autoreleasing *error) {
        NSString *country_code = country[@"iso"];
        return country_code;
    } reverseBlock:^id(NSString *country_code, BOOL *success, NSError *__autoreleasing *error) {
        return @{ @"iso": country_code };
    }];
}

@end

//
//  DessertResponseModel.m
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "DessertResponseModel.h"
#import "ListingModel.h"
#import "MetaPagingModel.h"

@implementation DessertResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             
             @"desserts" : @"desserts",
             @"meta"     : @"meta"
             
             };
}

+(NSValueTransformer *)dessertsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[ListingModel class]];
}

+(NSValueTransformer *)metaJSONTransformer {
    return [MTLJSONAdapter transformerForModelPropertiesOfClass:[MetaPagingModel class]];
}

@end

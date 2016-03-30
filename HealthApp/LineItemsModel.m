//
//  LineItemsModel.m
//  Neediator
//
//  Created by adverto on 17/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "LineItemsModel.h"
#import "VariantImagesModel.h"

@implementation LineItemsModel



+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"variantName"     :  @"variantname",
             @"variantPrice"    :  @"rate",
             @"quantity"        :  @"qty",
             @"amount"          :  @"subtotal",
             @"imageURL"        :  @"imageurl"
             
             };
}


//+(NSValueTransformer *)variantNameJSONTransformer {
//    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
//        return value;
//    }];
//}
//
//+(NSValueTransformer *)imagesJSONTransformer {
//    return [MTLJSONAdapter arrayTransformerWithModelClass:[VariantImagesModel class]];
//}

@end

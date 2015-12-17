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

//
//variantName;
//@property (nonatomic, copy) NSString *variantPrice;
//@property (nonatomic, copy) NSNumber *quantity;
//@property (nonatomic, copy) NSString *amount;
//@property (nonatomic, copy) NSArray *images;

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"variantName"     :  @"variant.name",
             @"variantPrice"    :  @"single_display_amount",
             @"quantity"        :  @"quantity",
             @"amount"          :  @"display_amount",
             @"images"          :  @"variant.images"
             
             };
}


+(NSValueTransformer *)variantNameJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return value;
    }];
}

+(NSValueTransformer *)imagesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[VariantImagesModel class]];
}

@end

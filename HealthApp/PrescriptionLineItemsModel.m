//
//  PrescriptionLineItemsModel.m
//  Neediator
//
//  Created by adverto on 23/12/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "PrescriptionLineItemsModel.h"
#import "VariantImagesModel.h"

@implementation PrescriptionLineItemsModel


+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"imageURL"        :  @"image_url",
             };
}



+(NSValueTransformer *)imagesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[VariantImagesModel class]];
}






@end

//
//  VariantImagesModel.m
//  Neediator
//
//  Created by adverto on 17/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "VariantImagesModel.h"

@implementation VariantImagesModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
      @"mini_url"   : @"mini_url",
      @"small_url"  : @"small_url",
      @"product_url": @"product_url"
      };
}

@end

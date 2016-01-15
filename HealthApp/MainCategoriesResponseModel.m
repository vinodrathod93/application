//
//  MainCategoriesResponseModel.m
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "MainCategoriesResponseModel.h"
#import "CategoryModel.h"
#import "PromotionModel.h"

@implementation MainCategoriesResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    
    return @{
             
             @"categories" : @"Categories",
             @"promotions" : @"Promotions"
             
             };
}

+(NSValueTransformer *)categoriesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[CategoryModel class]];
}

+(NSValueTransformer *)promotionsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[PromotionModel class]];
}

@end

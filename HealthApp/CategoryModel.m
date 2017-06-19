//
//  CategoryModel.m
//  Neediator
//
//  Created by adverto on 15/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "CategoryModel.h"
#import "SubCategoryModel.h"
#import "FilterListModel.h"
#import "SortListModel.h"

@implementation CategoryModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"SectionID"       : @"SectionId",
             @"SectionName"     : @"SectionName",
             @"has_subCat"      : @"HasCategory",
             @"ImageUrl"        : @"ImageUrl",
             @"is_active"       : @"IsActive",
             @"ColorCode"       : @"ColorCode",
             @"is_product"      : @"isProduct"
//             @"subCat_array": @"CatList"
             };
}


//+(NSValueTransformer *)subCat_arrayJSONTransformer
//{
//    return [MTLJSONAdapter arrayTransformerWithModelClass:[SubCategoryModel class]];
//}


@end

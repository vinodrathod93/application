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
             @"cat_id"      : @"Catid",
             @"name"        : @"Catname",
             @"has_subCat"  : @"HassubCat",
             @"image_url"   : @"Imageurl",
             @"is_active"   : @"Isactive",
             @"color_code"  : @"Colorcode",
             @"is_product"  : @"Isproduct",
             @"subCat_array": @"SubCatList",
             @"sorting_list": @"sort_list",
             @"filter_list" : @"filter_list"
             
             };
}


+(NSValueTransformer *)subCat_arrayJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[SubCategoryModel class]];
}

//+(NSValueTransformer *)sorting_listJSONTransformer {
//    return [MTLJSONAdapter arrayTransformerWithModelClass:[SortListModel class]];
//}
//
//
//+(NSValueTransformer *)filter_listJSONTransformer {
//    return [MTLJSONAdapter arrayTransformerWithModelClass:[FilterListModel class]];
//}

@end

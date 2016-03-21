//
//  FilterListModel.m
//  Neediator
//
//  Created by Vinod Rathod on 19/03/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "FilterListModel.h"
#import "FilterHelperModel.h"

@implementation FilterListModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"filterName"    : @"key",
             @"filterValues"  : @"value",
             @"filterParameter": @"parameter"
             
             };
}


+(NSValueTransformer *)filterValuesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[FilterHelperModel class]];
}

@end

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
             @"minimum_delivery"    : @"minimum_delivery",
             @"ratings"             : @"ratings"
             
             };
}

+(NSValueTransformer *)minimum_deliveryJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[FilterHelperModel class]];
}

+(NSValueTransformer *)ratingsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[FilterHelperModel class]];
}

@end

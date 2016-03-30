//
//  MyOrdersModel.m
//  Neediator
//
//  Created by adverto on 17/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "MyOrdersModel.h"
#import "StoresModel.h"
#import "LineItemsModel.h"

@implementation MyOrdersModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"orderNumber" : @"orderno",
             @"orderTotal"  : @"total",
             @"orderState"  : @"status",
             @"shipmentState": @"status",
             @"paymentState" : @"status",
             @"completed_date"   : @"orderdate",
             @"storeName"        : @"storename",
             @"line_items"   : @"myorder_productlist"
             
             };
}

+(NSValueTransformer *)storeNameJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        return value;
    }];
}

+(NSValueTransformer *)line_itemsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[LineItemsModel class]];
}

@end

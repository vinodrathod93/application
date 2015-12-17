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
             
             @"orderNumber" : @"number",
             @"orderTotal"  : @"display_total",
             @"orderState"  : @"state",
             @"shipmentState": @"shipment_state",
             @"paymentState" : @"payment_state",
             @"completed_date"   : @"completed_at",
             @"storeName"        : @"store.name",
             @"line_items"   : @"line_items"
             
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

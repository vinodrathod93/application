//
//  MyOrdersResponseModel.m
//  Neediator
//
//  Created by adverto on 17/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "MyOrdersResponseModel.h"

@implementation MyOrdersResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"orders" : @"orders"
             };
}

+(NSValueTransformer *)ordersJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MyOrdersModel class]];
}

@end

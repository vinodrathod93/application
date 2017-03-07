//
//  MyOrdersResponseModel.m
//  Neediator
//
//  Created by adverto on 17/12/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "MyOrdersResponseModel.h"
#import "MyPrescriptionModel.h"

@implementation MyOrdersResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"orders"                      : @"myorders",
             @"statusArray"                 : @"status",
             @"Prescriptions"               : @"prescriptionlist",
             @"processingorderreason"       : @"processingorderreason",
             @"pendingorderreason"          : @"pendingorderreason"
             };
}

+(NSValueTransformer *)ordersJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MyOrdersModel class]];
}


+(NSValueTransformer *)PrescriptionJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MyPrescriptionModel class]];
}



@end

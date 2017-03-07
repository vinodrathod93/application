//
//  MyPrescriptionModel.m
//  Neediator
//
//  Created by adverto on 01/02/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "MyPrescriptionModel.h"
#import "PrescriptionLineItemsModel.h"

@implementation MyPrescriptionModel


+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"orderno"         : @"orderno",
             @"storeid"             : @"store_id",
             @"sectionid"           : @"Section_id",
             @"userid"              : @"userid",
             @"line_itemss"         : @"prelist",
             @"status"              : @"status",
             @"storeName"           : @"storename",
             @"createdOn"           : @"createdon"
             };
}

+(NSValueTransformer *)line_itemssJSONTransformer
{
    return [MTLJSONAdapter arrayTransformerWithModelClass:[PrescriptionLineItemsModel class]];
}

@end

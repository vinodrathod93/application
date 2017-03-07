//
//  MyBookingModel.m
//  Neediator
//
//  Created by adverto on 14/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "MyBookingModel.h"

@implementation MyBookingModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"Status"              : @"Status",
             @"BookingNo"           : @"BookingNo",
             @"Date"                : @"Date",
             @"PurposeType"         : @"purposetype",
             @"TimeSlotFrom"        : @"timeslotfrom",
             @"TimeSlotTo"          : @"timeslotto",
             @"Area"                : @"area",
             @"Name"                : @"Name"
        };
}


@end

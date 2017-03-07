//
//  MyBookingResponseModel.m
//  Neediator
//
//  Created by adverto on 14/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import "MyBookingResponseModel.h"

@implementation MyBookingResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"Status"                   : @"BookingStatus",
             @"Bookings"                 : @"Bookings"
          
             };
}

+(NSValueTransformer *)statusJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MyBookingModel class]];
}


+(NSValueTransformer *)BookingsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[MyBookingModel class]];
}


@end

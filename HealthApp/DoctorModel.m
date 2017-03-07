//
//  DoctorModel.m
//  Neediator
//
//  Created by adverto on 11/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "DoctorModel.h"

@implementation DoctorModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"name"                : @"name",
             @"email"               : @"email",
             @"mobile_number"       : @"mobile_number",
             @"experience"          : @"experience",
             @"fees"                : @"fees",
             @"do_appointments"     : @"do_appointments",
             @"do_home_visits"      : @"do_home_visits",
             @"do_message_consulting": @"do_message_consulting"
             
             };
}
@end

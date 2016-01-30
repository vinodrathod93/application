//
//  TimeSlotResponseModel.m
//  Neediator
//
//  Created by adverto on 25/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import "TimeSlotResponseModel.h"
#import "TimeSlotModel.h"

@implementation TimeSlotResponseModel

+(NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             
             @"timeSlots"   : @"timeslot",
             @"entityName"  : @"storename",
             @"categoryName": @"catname",
             @"categoryID"  : @"catid",
             @"entityID"    : @"store_id"
             
             };
}


+ (NSValueTransformer *)timeSlotsJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[TimeSlotModel class]];
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError *__autoreleasing *)error {
    self = [super initWithDictionary:dictionaryValue error:error];
    
    if (self == nil) {
        return nil;
    }
    
    NSLog(@"%@", dictionaryValue);
    
    return self;
}
@end

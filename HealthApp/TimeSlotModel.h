//
//  TimeSlotModel.h
//  Neediator
//
//  Created by adverto on 25/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TimeSlotModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSDate *date;
@property (nonatomic, copy) NSDictionary *timeSlot;

@end

//
//  TimeSlotResponseModel.h
//  Neediator
//
//  Created by adverto on 25/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface TimeSlotResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *timeSlots;
@property (nonatomic, copy) NSString *entityName;
@property (nonatomic, copy) NSString *categoryName;
@property (nonatomic, copy) NSNumber *categoryID;
@property (nonatomic, copy) NSNumber *entityID;

@end

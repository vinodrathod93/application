//
//  MyBookingModel.h
//  Neediator
//
//  Created by adverto on 14/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface MyBookingModel : MTLModel<MTLJSONSerializing>




@property (nonatomic, copy) NSString *Status;
@property (nonatomic, copy) NSString *BookingNo;
@property (nonatomic, copy) NSString *Date;
@property (nonatomic, copy) NSString *PurposeType;
@property (nonatomic, copy) NSString *TimeSlotFrom;
@property (nonatomic, copy) NSString *TimeSlotTo;
@property (nonatomic, copy) NSString *Area;
@property (nonatomic, copy) NSString *Name;



@property (nonatomic, copy) NSNumber *statusCode;

@property (nonatomic) BOOL isExpanded;
@property (nonatomic) BOOL isCancelExpanded;

@end

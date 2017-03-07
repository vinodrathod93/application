//
//  MyBookingResponseModel.h
//  Neediator
//
//  Created by adverto on 14/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "MyBookingModel.h"


@interface MyBookingResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *Status;
@property(nonatomic,copy)   NSArray *Bookings;

@end

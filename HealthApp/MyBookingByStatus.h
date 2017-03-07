//
//  MyBookingByStatus.h
//  Neediator
//
//  Created by adverto on 14/01/17.
//  Copyright © 2017 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>
@interface MyBookingByStatus : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *status;
@end

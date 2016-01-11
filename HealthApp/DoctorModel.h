//
//  DoctorModel.h
//  Neediator
//
//  Created by adverto on 11/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface DoctorModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *mobile_number;
@property (nonatomic, copy) NSNumber *experience;
@property (nonatomic, copy) NSString *fees;
@property (nonatomic) BOOL do_appointments;
@property (nonatomic) BOOL do_home_visits;
@property (nonatomic) BOOL do_message_consulting;

@end

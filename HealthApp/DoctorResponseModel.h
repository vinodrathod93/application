//
//  DoctorResponseModel.h
//  Neediator
//
//  Created by adverto on 11/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface DoctorResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *clinics;

@end

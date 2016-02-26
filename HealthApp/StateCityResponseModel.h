//
//  StateCityResponseModel.h
//  Neediator
//
//  Created by Vinod Rathod on 08/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface StateCityResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *states;

@end

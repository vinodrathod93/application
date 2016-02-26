//
//  StatesModel.h
//  Neediator
//
//  Created by Vinod Rathod on 08/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface StatesModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *stateName;
@property (nonatomic, copy) NSNumber *stateID;
@property (nonatomic, copy) NSArray *cities;

@end

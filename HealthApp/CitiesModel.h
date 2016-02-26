//
//  CitiesModel.h
//  Neediator
//
//  Created by Vinod Rathod on 08/02/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CitiesModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *cityName;
@property (nonatomic, copy) NSNumber *cityID;
@property (nonatomic, copy) NSNumber *stateID;

@end

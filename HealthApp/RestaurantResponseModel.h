//
//  RestaurantResponseModel.h
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface RestaurantResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *restaurants;
@property (nonatomic, copy) NSDictionary *meta;

@end

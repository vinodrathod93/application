//
//  StoreListRequestModel.h
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface StoreListRequestModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *location;

@end
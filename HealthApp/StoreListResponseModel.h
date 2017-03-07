//
//  StoreListResponseModel.h
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>
#import "StoresModel.h"

@interface StoreListResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *stores;

@end

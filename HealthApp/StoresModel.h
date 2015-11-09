//
//  StoresModel.h
//  Chemist Plus
//
//  Created by adverto on 05/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface StoresModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *storeName;
@property (nonatomic, copy) NSString *storeUrl;
@property (nonatomic, copy) NSString *storeStreetAddress;
@property (nonatomic, copy) NSString *storeCity;
@property (nonatomic, copy) NSNumber *storePincode;
@property (nonatomic, copy) NSString *storeState;
@property (nonatomic, copy) NSString *storeCountry;
@property (nonatomic, copy) NSString *storeDistance;
@property (nonatomic, copy) NSString *storeImage;

@end

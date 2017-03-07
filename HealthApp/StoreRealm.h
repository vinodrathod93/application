//
//  StoreRealm.h
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Realm/Realm.h>
#import "StoresModel.h"

@interface StoreRealm : RLMObject

@property  NSString *storeName;
@property  NSString *storeUrl;
@property  NSString *storeStreetAddress;
@property  NSString *storeCity;
@property  NSNumber<RLMInt> *storePincode;
@property  NSString *storeState;
@property  NSString *storeCountry;
@property  NSString *storeDistance;
@property  NSString *storeImage;

- (id)initWithMantleModel:(StoresModel *)storeModel;

@end

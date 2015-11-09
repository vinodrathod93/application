//
//  StoreRealm.m
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import "StoreRealm.h"

@implementation StoreRealm

- (id)initWithMantleModel:(StoresModel *)storeModel{
    self = [super init];
    if(!self) return nil;
    
    self.storeName = storeModel.storeName;
    self.storeUrl = storeModel.storeUrl;
    self.storeStreetAddress = storeModel.storeStreetAddress;
    self.storeCity = storeModel.storeCity;
    self.storePincode = storeModel.storePincode;
    self.storeState = storeModel.storeState;
    self.storeCountry = storeModel.storeCountry;
    self.storeDistance = storeModel.storeDistance;
    self.storeImage = storeModel.storeImage;
    
    return self;
}

@end

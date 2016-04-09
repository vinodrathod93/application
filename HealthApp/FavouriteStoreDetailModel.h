//
//  FavouriteStoreDetailModel.h
//  Neediator
//
//  Created by adverto on 09/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FavouriteStoreDetailModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *listing_stores;
@property (nonatomic, copy) NSNumber *favouriteID;

@end

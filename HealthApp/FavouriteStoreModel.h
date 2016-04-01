//
//  FavouriteStoreModel.h
//  Neediator
//
//  Created by adverto on 01/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FavouriteStoreModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *fav_id;
@property (nonatomic, copy) NSString *store_name;
@property (nonatomic, copy) NSString *storePhoneNumber;
@property (nonatomic, copy) NSNumber *store_id;
@property (nonatomic, copy) NSString *store_image_url;
@property (nonatomic, copy) NSString *mobile_number;
@property (nonatomic, copy) NSString *timing;
@property (nonatomic, copy) NSString *charges;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSNumber *ratings;



@end

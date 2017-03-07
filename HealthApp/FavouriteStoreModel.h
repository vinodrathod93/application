//
//  FavouriteStoreModel.h
//  Neediator
//
//  Created by adverto on 01/04/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface FavouriteStoreModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *store_id;
@property (nonatomic, copy) NSString *store_name;
@property (nonatomic, copy) NSString *store_image_url;
@property (nonatomic, copy) NSString *timing;
@property (nonatomic, copy) NSString *charges;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *ratings;
@property (nonatomic, copy) NSString *reviews_count;


@property (nonatomic, copy) NSNumber *isBook;
@property (nonatomic, copy) NSNumber *isFavourite;
@property (nonatomic, copy) NSNumber *isLike;
@property (nonatomic, copy) NSNumber *isDislike;

@property (nonatomic, copy) NSArray *phone_numbers;
@property (nonatomic, copy) NSArray *likeDislikes;
@property (nonatomic, copy) NSArray *images;




@end

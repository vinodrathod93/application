//
//  ListingRequestModel.h
//  Chemist Plus
//
//  Created by adverto on 09/11/15.
//  Copyright © 2015 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ListingRequestModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *category_id;
@property (nonatomic, copy) NSString *latitude;
@property (nonatomic, copy) NSString *longitude;
@property (nonatomic, copy) NSString *page;
@property (nonatomic, copy) NSString *sortType_id;
@property (nonatomic, copy) NSNumber *is24Hrs;
@property (nonatomic, copy) NSNumber *hasOffers;
@property (nonatomic, copy) NSString *minDelivery_id;
@property (nonatomic, copy) NSString *ratings_id;
@property (nonatomic, copy) NSString *subcategory_id;


@end

//
//  ListingModel.h
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ListingModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSString *list_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSArray  *phone_nos;
@property (nonatomic, copy) NSString *nearest_distance;
@property (nonatomic, copy) NSString *ratings;
@property (nonatomic, copy) NSString *timing;
@property (nonatomic, copy) NSString *minOrder;
@property (nonatomic, copy) NSString *reviews_count;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *FeesCharge;


@property (nonatomic, copy) NSNumber *isFavourite;
@property (nonatomic, copy) NSNumber *isLike;
@property (nonatomic, copy) NSNumber *isDislike;

@property(nonatomic,assign)BOOL isOffer;

@property (nonatomic, copy) NSNumber *isBook;
@property (nonatomic, copy) NSNumber *isCall;
@property (nonatomic, copy) NSNumber *isHomeRequest;

@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) NSArray *likeUnlike;
@property (nonatomic, copy) NSArray *premium;

@property(nonatomic,copy)   NSArray *offerArray;





@property (nonatomic, copy) NSString *Sunday;
@property (nonatomic, copy) NSString *Monday;
@property (nonatomic, copy) NSString *Tuesday;
@property (nonatomic, copy) NSString *Wednesday;
@property (nonatomic, copy) NSString *Thursday;
@property (nonatomic, copy) NSString *Friday;
@property (nonatomic, copy) NSString *Saturday;










@end

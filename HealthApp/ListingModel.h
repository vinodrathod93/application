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
@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSArray *phone_nos;
@property (nonatomic, copy) NSString *nearest_distance;
@property (nonatomic, copy) NSString *ratings;
@property (nonatomic, copy) NSString *timing;

@property (nonatomic, copy) NSNumber *isBook;
@property (nonatomic, copy) NSNumber *isCall;

@property (nonatomic, copy) NSArray *images;
@end

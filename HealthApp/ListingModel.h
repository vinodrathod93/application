//
//  ListingModel.h
//  Neediator
//
//  Created by adverto on 12/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ListingModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSNumber *list_id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *nearest_distance;
@property (nonatomic, copy) NSNumber *ratings;
@property (nonatomic, copy) NSString *timing;

@property (nonatomic, copy) NSNumber *isBook;
@property (nonatomic, copy) NSNumber *isCall;


@end

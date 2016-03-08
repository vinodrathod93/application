//
//  ListingResponseModel.h
//  Neediator
//
//  Created by adverto on 18/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ListingResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy) NSArray *records;
@property (nonatomic, copy) NSDictionary *type;
@property (nonatomic, copy) NSArray *deliveryTypes;


@property (nonatomic, assign) BOOL isProductType;
@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSDictionary *parameters;

@end

//
//  ListingResponseModel.h
//  Neediator
//
//  Created by adverto on 18/01/16.
//  Copyright © 2016 adverto. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ListingResponseModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, copy)     NSDictionary *type;
@property (nonatomic, strong)   NSDictionary *parameters;

@property (nonatomic, copy) NSNumber *current_count;
@property (nonatomic, copy) NSNumber *total_count;
@property (nonatomic, copy) NSNumber *total_pages;

@property (nonatomic, strong)   NSString    *urlString;
@property (nonatomic, copy)     NSString    *current_page;

@property (nonatomic, assign) BOOL isProductType;



@property (nonatomic, copy) NSArray *records;
@property (nonatomic, copy) NSArray *deliveryTypes;
@property(nonatomic,copy)   NSArray *addressTypes;
@property(nonatomic,copy)   NSArray *PurposeType;
@property (nonatomic, copy) NSArray *sorting_list;
@property (nonatomic, copy) NSArray *filter_list;


@end

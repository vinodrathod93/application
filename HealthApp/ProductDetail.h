//
//  ProductDetail.h
//  Chemist Plus
//
//  Created by adverto on 21/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductDetail : NSObject

@property (nonatomic, strong) NSString *productID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *displayPrice;
@property (nonatomic, assign) BOOL hasVariant;
@property (nonatomic, strong) NSString *variantID;
@property (nonatomic, strong) NSNumber *total_on_hand;

@property (nonatomic, strong) NSArray *small_img;
@property (nonatomic, strong) NSArray *product_img;
@property (nonatomic, strong) NSArray *large_img;


@property (nonatomic, strong) NSArray *variants;

@end

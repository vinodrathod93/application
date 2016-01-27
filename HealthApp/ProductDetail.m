//
//  ProductDetail.m
//  Chemist Plus
//
//  Created by adverto on 21/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "ProductDetail.h"

@implementation ProductDetail

- (id)init
{
    self = [super init];
    if (self) {
        self.productID      = nil;
        self.name           = nil;
        self.summary        = nil;
        self.price          = nil;
        self.displayPrice   = nil;
        self.masterPrice    = nil;
        self.hasVariant = NO;
        
    }
    return self;
}

@end

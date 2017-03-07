//
//  CartViewModel.m
//  Chemist Plus
//
//  Created by adverto on 23/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import "CartViewModel.h"

@implementation CartViewModel

- (id)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.cartProducts = array;
    }
    return self;
}

-(AddToCart *)modelAtIndex:(NSInteger)index {
    
    return self.cartProducts[index];
}

-(NSString *)imageAtIndex:(NSInteger)index {
    AddToCart *model = [self modelAtIndex:index];
    
    return model.productImage;
}

-(NSString *)nameAtIndex:(NSInteger)index {
    AddToCart *model = [self modelAtIndex:index];
    
    return model.productName;
}

-(NSNumber *)priceAtIndex:(NSInteger)index {
    AddToCart *model = [self modelAtIndex:index];
    
    return model.productPrice;
}

-(NSInteger)numberOfCartProducts
{
    return self.cartProducts.count;
}



@end

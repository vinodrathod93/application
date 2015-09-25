//
//  CartViewModel.h
//  Chemist Plus
//
//  Created by adverto on 23/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddToCart.h"

@interface CartViewModel : NSObject

@property (nonatomic, strong) NSArray *cartProducts;
@property (nonatomic, strong) AddToCart *model;


- (id)initWithArray:(NSArray *)array;

-(NSString *)imageAtIndex:(NSInteger)index;
-(NSString *)nameAtIndex:(NSInteger)index;
-(NSNumber *)priceAtIndex:(NSInteger)index;
-(NSInteger)numberOfCartProducts;

@end

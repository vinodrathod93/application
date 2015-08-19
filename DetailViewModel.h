//
//  DetailViewModel.h
//  Chemist Plus
//
//  Created by adverto on 17/07/15.
//  Copyright (c) 2015 adverto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddToCart.h"

@protocol viewModelDelegate <NSObject>

-(void)didReceiveData;

@end

@interface DetailViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *viewModelProducts;
@property (nonatomic, strong) AddToCart *addToCart;
@property (nonatomic, weak) id <viewModelDelegate> delegate;


-(id)initWithArray:(NSArray *)array;

+(NSArray *)productsFromJSON:(NSDictionary *)objectNotation;
-(NSInteger)numberOfProducts;
-(NSString *)imageAtIndex:(NSInteger)index;
-(NSString *)nameAtIndex:(NSInteger)index;
-(NSString *)summaryAtIndex:(NSInteger)index;
-(NSString *)priceAtIndex:(NSInteger)index;

+(NSArray *)infiniteProductsFromJSON:(NSDictionary *)dictionary;
-(NSString *)infiniteImageAtIndex:(NSInteger)index;
-(void)addProducts:(NSArray *)array;
-(NSString *)getItemsCount:(NSDictionary *)dictionary;
-(NSString *)getPagesCount:(NSDictionary *)dictionary;
-(NSString *)currentPage:(NSDictionary *)dictionary;
-(NSString *)nextPage:(NSDictionary *)dictionary;

@end
